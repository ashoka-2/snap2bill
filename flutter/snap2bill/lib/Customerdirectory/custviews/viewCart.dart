


import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/widgets/CustomerNavigationBar.dart';
import '../../theme/colors.dart';
import '../../widgets/Navbar.dart';
import '../../widgets/SnackBar.dart';
import '../../widgets/app_button.dart';
import '../Customersends/addOrder.dart';

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
  List<dynamic> _recentItems = []; // 🚀 List for Recently Viewed
  bool _isPlacingOrder = false;

  late Color successColor;
  late Color dangerColor;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Helper to init both cart and recent items
  Future<void> _initializeData() async {
    cartFuture = _fetchCart();
    _fetchRecentProducts(); // 🚀 Recently viewed items call
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
      if (mounted) {
        setState(() {
          totalValue = body['total'].toString();
          _localItems = List<Map<String, dynamic>>.from(
              body['data'].map((item) => Map<String, dynamic>.from(item))
          );
        });
      }
      return _localItems;
    } else {
      throw Exception("Failed to load cart");
    }
  }

  // 🚀 FETCH RECENTLY VIEWED FROM BACKEND
  Future<void> _fetchRecentProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final res = await http.post(
          Uri.parse("${prefs.getString("ip")}/get_recent_products"),
          body: {'cid': prefs.getString("cid")}
      );
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        if (body['status'] == 'ok') {
          setState(() {
            _recentItems = body['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Recent Fetch Error: $e");
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
    final bgColor = AppColors.getScaffoldBg(context);
    final subTextColor = AppColors.getTextSubColor(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: ThemeNavbar(
        title: "Shopping Cart",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () {
          Navigator.pop(context, "refresh");
        },
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _localItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_localItems.isEmpty)
                  SizedBox(height: 300, child: _buildEmptyState(isDark, subTextColor!))
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _localItems.length,
                      itemBuilder: (context, index) {
                        final item = _localItems[index];
                        return _buildCartItem(item, index, theme, isDark, subTextColor!);
                      },
                    ),
                  ),

                // 🚀 RECENTLY VIEWED SECTION
                if (_recentItems.isNotEmpty) _buildRecentlyViewedSection(subTextColor!, isDark),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildSummary(theme, isDark, subTextColor!),
    );
  }

  // 🚀 RECENTLY VIEWED UI
  Widget _buildRecentlyViewedSection(Color subTextColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(25, 20, 25, 10),
          child: Text("Recently Viewed", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _recentItems.length,
            itemBuilder: (context, index) {
              final item = _recentItems[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => addOrder(pid: item['id'].toString()))),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 15, bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 10)],
                    border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl:_joinUrl(item['image']), fit: BoxFit.cover, width: double.infinity),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(item['product_name'], maxLines: 1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text("₹${item['price']}", style: TextStyle(fontSize: 13, color: successColor, fontWeight: FontWeight.w900)),
                      Text(item['distributor'], style: TextStyle(fontSize: 10, color: subTextColor)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index, ThemeData theme, bool isDark, Color subTextColor) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = AppColors.getTextColor(context);
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;
    TextEditingController qtyCtrl = TextEditingController(text: item['quantity'].toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CachedNetworkImage(
  imageUrl:_joinUrl(item['image'].toString()), width: 80, height: 85, fit: BoxFit.cover),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(item['product_name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor), maxLines: 1)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await http.post(Uri.parse("${prefs.getString("ip")}/deleteFromCart"), body: {"id": item['id'].toString()});
                          setState(() { _localItems.removeAt(index); _calculateLocalTotal(); });
                        },
                      ),
                    ],
                  ),
                  Text("By: ${item['distributor_name']}", style: TextStyle(color: subTextColor, fontSize: 11)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("₹${item['price']}", style: TextStyle(color: successColor, fontWeight: FontWeight.w900, fontSize: 13)),
                      _buildQuantityPicker(item, index, theme, isDark, borderColor, qtyCtrl, textColor, subTextColor),
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

  Widget _buildQuantityPicker(item, index, theme, isDark, borderColor, qtyCtrl, textColor, subTextColor) {
    return Container(
      decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
      child: Row(
        children: [
          _buildQtyBtn(Icons.remove, () {
            int val = int.tryParse(item['quantity'].toString()) ?? 1;
            if (val > 1) {
              int newVal = val - 1;
              setState(() => _localItems[index]['quantity'] = newVal);
              _calculateLocalTotal();
              _updateQtyOnServer(item['id'].toString(), newVal.toString());
            }
          }, theme.primaryColor),
          SizedBox(width: 30, child: Text(item['quantity'].toString(), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
          _buildQtyBtn(Icons.add, () {
            int val = int.tryParse(item['quantity'].toString()) ?? 1;
            if (val < 100) {
              int newVal = val + 1;
              setState(() => _localItems[index]['quantity'] = newVal);
              _calculateLocalTotal();
              _updateQtyOnServer(item['id'].toString(), newVal.toString());
            }
          }, theme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap, Color color) {
    return InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(8.0), child: Icon(icon, size: 16, color: color)));
  }

  Widget _buildSummary(ThemeData theme, bool isDark, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Amount", style: TextStyle(color: subTextColor, fontWeight: FontWeight.w600)),
                Text("₹$totalValue", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: theme.primaryColor)),
              ],
            ),
            const SizedBox(height: 15),
            AppButton(text: "PLACE ORDER", icon: Icons.check_circle_outline, isLoading: _isPlacingOrder, onPressed: _handlePlaceOrder),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder() async {
    setState(() => _isPlacingOrder = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await http.post(Uri.parse("${prefs.getString("ip")}/addFinalOrder"), body: {'cid': prefs.getString("cid"), 'total': totalValue});
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CustomerNavigationBar(initialIndex: 0)));
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
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