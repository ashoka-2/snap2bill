

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:snap2bill/widgets/CustomerNavigationBar.dart';

class viewCart extends StatefulWidget {
  const viewCart({Key? key}) : super(key: key);

  @override
  State<viewCart> createState() => _viewCartState();
}

class _viewCartState extends State<viewCart> {
  String totalValue = "0";
  String _ip = "";
  late Future<List<Map<String, dynamic>>> cartFuture;
  List<Map<String, dynamic>> _localItems = [];

  @override
  void initState() {
    super.initState();
    cartFuture = _fetchCart();
  }

  String _joinUrl(String path) {
    if (path.isEmpty || path == "null") return "";
    if (path.startsWith('http')) return path;
    String cleanIp = _ip.endsWith('/') ? _ip.substring(0, _ip.length - 1) : _ip;
    String cleanPath = path.startsWith('/') ? path : '/$path';
    return cleanIp + cleanPath;
  }

  Future<List<Map<String, dynamic>>> _fetchCart() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    _ip = sh.getString("ip") ?? "";
    String cid = sh.getString('cid') ?? "";

    final res = await http.post(
        Uri.parse("$_ip/viewCart"),
        body: {'cid': cid}
    );

    if (res.statusCode == 200) {
      var body = json.decode(res.body);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            totalValue = body['total'].toString();
            // Convert everything to a mutable list so we can update qty locally
            _localItems = List<Map<String, dynamic>>.from(
                body['data'].map((item) => Map<String, dynamic>.from(item))
            );
          });
        }
      });

      return _localItems;
    } else {
      throw Exception("Failed to load cart");
    }
  }

  // ✅ FIXED: Robust calculation logic
  void _calculateLocalTotal() {
    double newTotal = 0;
    for (var item in _localItems) {
      // Ensure price is treated as a double even if it's a string from DB
      double price = double.parse(item['price'].toString());
      // Ensure quantity is treated as a number
      double qty = double.parse(item['quantity'].toString());
      newTotal += (price * qty);
    }
    setState(() {
      // toStringAsFixed(0) removes decimals like .0
      totalValue = newTotal.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Shopping Cart",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _localItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (_localItems.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _localItems.length,
            itemBuilder: (context, index) {
              final item = _localItems[index];
              return _buildCartItem(item, index, theme, isDark);
            },
          );
        },
      ),
      bottomNavigationBar: _buildSummary(theme, isDark),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                _joinUrl(item['image'].toString()),
                width: 90, height: 90, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 90, height: 90, color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['product_name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text("Distributor: ${item['distributor_name']}", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                  const SizedBox(height: 5),
                  Text("₹${item['price']}", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      InputQty(
                        maxVal: 100,
                        initVal: num.tryParse(item['quantity'].toString()) ?? 1,
                        minVal: 1,
                        steps: 1,
                        decoration: const QtyDecorationProps(
                          qtyStyle: QtyStyle.classic,
                          width: 12,
                          isBordered: false,
                        ),
                        onQtyChanged: (val) async {
                          // Update local UI immediately
                          setState(() {
                            _localItems[index]['quantity'] = val;
                          });
                          _calculateLocalTotal();

                          // Background Sync with Django
                          SharedPreferences sh = await SharedPreferences.getInstance();
                          await http.post(
                            Uri.parse(sh.getString("ip").toString() + "/update_quantity"),
                            body: {
                              "id": item['id'].toString(),
                              "qty": val.toString()
                            },
                          );
                        },
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () async {
                          SharedPreferences sh = await SharedPreferences.getInstance();
                          await http.post(
                            Uri.parse(sh.getString("ip").toString() + "/deleteFromCart"),
                            body: {"id": item['id'].toString()},
                          );
                          // On delete, we refresh the whole future to remove the row
                          setState(() {
                            _localItems.removeAt(index);
                            _calculateLocalTotal();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 35),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Amount", style: GoogleFonts.poppins(color: Colors.grey)),
              Text("₹$totalValue", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: theme.primaryColor)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              onPressed: () async {
                SharedPreferences sh = await SharedPreferences.getInstance();
                await http.post(
                  Uri.parse(sh.getString("ip").toString() + "/addFinalOrder"),
                  body: {'cid': sh.getString("cid"), 'total': totalValue},
                );
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CustomerNavigationBar(initialIndex: 0)));
              },
              child: Text("Place Order", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Text("Your cart is empty", style: GoogleFonts.poppins(color: Colors.grey)));
  }
}