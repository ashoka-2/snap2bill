
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snap2bill/widgets/CustomerNavigationBar.dart';

import '../../theme/colors.dart';
import '../../widgets/Navbar.dart';
import '../../widgets/SnackBar.dart';
import '../../widgets/app_button.dart';

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
  bool _isPlacingOrder = false;

  late Color successColor;
  late Color dangerColor;

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _ip = prefs.getString("ip") ?? "";
    String cid = prefs.getString('cid') ?? "";

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

  void _calculateLocalTotal() {
    double newTotal = 0;
    for (var item in _localItems) {
      double price = double.parse(item['price'].toString());
      int qty = int.tryParse(item['quantity'].toString()) ?? 1;
      newTotal += (price * qty);
    }
    setState(() {
      totalValue = newTotal.toStringAsFixed(0);
    });
  }

  Future<void> _updateQtyOnServer(String id, String qty) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await http.post(
        Uri.parse("${prefs.getString("ip")}/update_quantity"),
        body: {"id": id, "qty": qty},
      );
    } catch (e) {
      debugPrint("Sync Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    successColor = AppColors.getSuccessColor(context);
    dangerColor = AppColors.getDangerColor(context);


    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final subTextColor = isDark ? Colors.white38 : Colors.grey[500];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: ThemeNavbar(
        title: "Shopping Cart",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () => Navigator.pop(context),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _localItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_localItems.isEmpty) {
            return _buildEmptyState(isDark, subTextColor!);
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            itemCount: _localItems.length,
            itemBuilder: (context, index) {
              final item = _localItems[index];
              return _buildCartItem(item, index, theme, isDark, subTextColor!);
            },
          );
        },
      ),
      bottomNavigationBar: _buildSummary(theme, isDark, subTextColor!),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index, ThemeData theme, bool isDark, Color subTextColor) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;

    TextEditingController qtyCtrl = TextEditingController(text: item['quantity'].toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: isDark? Colors.black.withValues(alpha:0.3): Colors.black.withValues(alpha:0.05), blurRadius: 20, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                _joinUrl(item['image'].toString()),
                width: 90, height: 100, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 90, height: 90, color: isDark ? Colors.white10 : Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                            item['product_name'],
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)
                        ),
                      ),
                      DeleteButton(
                        size: 30,
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await http.post(
                            Uri.parse("${prefs.getString("ip")}/deleteFromCart"),
                            body: {"id": item['id'].toString()},
                          );
                          setState(() {
                            _localItems.removeAt(index);
                            _calculateLocalTotal();
                          });
                        },
                      ),
                    ],
                  ),
                  Text("By: ${item['distributor_name']}", style: TextStyle(color: subTextColor, fontSize: 11)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("₹${item['price']}", style: TextStyle(color:successColor, fontWeight: FontWeight.w900, fontSize: 18)),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey[100],
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  int val = int.tryParse(item['quantity'].toString()) ?? 1;
                                  if (val > 1) {
                                    int newVal = val - 1;
                                    setState(() => _localItems[index]['quantity'] = newVal);
                                    _calculateLocalTotal();
                                    _updateQtyOnServer(item['id'].toString(), newVal.toString());
                                  }
                                },
                                icon: Icon(Icons.remove_circle_outline, color: theme.primaryColor, size: 22)
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),

                                    child: TextField(
                                      controller: qtyCtrl,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(3),
                                      ],
                                      onChanged: (value) {
                                        int? val = int.tryParse(value);
                                        if (val != null) {
                                          // Auto-limit to 100 on typing
                                          if (val > 100) {
                                            val = 100;
                                            CustomSnackBar.show(context, "Max quantity is 100", backgroundColor: dangerColor);
                                          }
                                          if (val < 1) val = 1;
                                          _localItems[index]['quantity'] = val;
                                          _calculateLocalTotal();
                                          _updateQtyOnServer(item['id'].toString(), val.toString());
                                        }
                                      },
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                                      decoration: const InputDecoration(border: InputBorder.none, isDense: true,),

                                    ),
                                  ),
                                ),
                                Text(item['unit_name'] ?? "Unit", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: subTextColor)),
                              ],
                            ),
                            IconButton(
                                onPressed: () {
                                  int val = int.tryParse(item['quantity'].toString()) ?? 1;
                                  if (val < 100) {
                                    int newVal = val + 1;
                                    setState(() => _localItems[index]['quantity'] = newVal);
                                    _calculateLocalTotal();
                                    _updateQtyOnServer(item['id'].toString(), newVal.toString());
                                  } else {
                                    // 🚀 Custom SnackBar on limit reached
                                    CustomSnackBar.show(context, "Maximum quantity reached!", backgroundColor: dangerColor);
                                  }
                                },
                                icon: Icon(Icons.add_circle_outline, color: theme.primaryColor, size: 22)
                            ),
                          ],
                        ),
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

  Widget _buildSummary(ThemeData theme, bool isDark, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 35),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.1), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Amount", style: TextStyle(color: subTextColor, fontWeight: FontWeight.w600)),
              Text("₹$totalValue", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: theme.primaryColor)),
            ],
          ),
          const SizedBox(height: 20),
          AppButton(
            text: "PLACE ORDER",
            icon: Icons.check_circle_outline,
            isLoading: _isPlacingOrder,
            // isTrailingIcon: true,
            onPressed: () async {
              // 🚀 VALIDATION CHECK BEFORE ORDER
              bool hasExceededLimit = false;
              String exceededProduct = "";

              for (var item in _localItems) {
                int qty = int.tryParse(item['quantity'].toString()) ?? 1;
                if (qty > 100) {
                  hasExceededLimit = true;
                  exceededProduct = item['product_name'];
                  break;
                }
              }

              if (hasExceededLimit) {
                // 🚀 SHOW YOUR CUSTOM SNACKBAR
                CustomSnackBar.show(
                    context,
                    "Quantity for $exceededProduct exceeds 100!",
                    backgroundColor: dangerColor,
                    durationMs: 2000
                );
                return; // Stop execution
              }

              setState(() => _isPlacingOrder = true);
              try {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await http.post(
                  Uri.parse("${prefs.getString("ip")}/addFinalOrder"),
                  body: {'cid': prefs.getString("cid"), 'total': totalValue},
                );
                if (mounted) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CustomerNavigationBar(initialIndex: 0)));
                }
              } finally {
                if (mounted) setState(() => _isPlacingOrder = false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color subTextColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: subTextColor.withValues(alpha:0.3)),
          const SizedBox(height: 16),
          Text("Your cart is empty", style: TextStyle(color: subTextColor, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}