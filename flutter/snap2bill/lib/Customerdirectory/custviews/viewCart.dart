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
    final bgColor = AppColors.getScaffoldBg(context);
    final subTextColor = AppColors.getTextSubColor(context);

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
    final textColor = AppColors.getTextColor(context);

    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;

    TextEditingController qtyCtrl = TextEditingController(text: item['quantity'].toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                _joinUrl(item['image'].toString()),
                width: 80, height: 85, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80, height: 80, color: isDark ? Colors.white10 : Colors.grey[200],
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
                      const SizedBox(width: 5),
                      DeleteButton(
                        size: 32.0, // Aapne size manage karne ka option diya hai
                        showText: false, // Kyunki aapko sirf icon chahiye
                        onPressed: () async {
                          // 1. SharedPreferences se IP lo
                          SharedPreferences prefs = await SharedPreferences.getInstance();

                          // 2. API hit karo
                          await http.post(
                            Uri.parse("${prefs.getString("ip")}/deleteFromCart"),
                            body: {"id": item['id'].toString()},
                          );

                          // 3. UI update karo
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
                      Text("₹${item['price']}", style: TextStyle(color: successColor, fontWeight: FontWeight.w900, fontSize: 13)),

                      // --- RESPONSIVE INCREMENT/DECREMENT CONTAINER ---
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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

                            SizedBox(
                              width: 35,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
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
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                                    decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                                  ),
                                  Text(item['unit_name'] ?? "Unit", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: subTextColor)),
                                ],
                              ),
                            ),

                            _buildQtyBtn(Icons.add, () {
                              int val = int.tryParse(item['quantity'].toString()) ?? 1;
                              if (val < 100) {
                                int newVal = val + 1;
                                setState(() => _localItems[index]['quantity'] = newVal);
                                _calculateLocalTotal();
                                _updateQtyOnServer(item['id'].toString(), newVal.toString());
                              } else {
                                CustomSnackBar.show(context, "Maximum quantity reached!", backgroundColor: dangerColor);
                              }
                            }, theme.primaryColor),
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

  // --- COMPACT BUTTON BUILDER ---
  Widget _buildQtyBtn(IconData icon, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

 

  Widget _buildSummary(ThemeData theme, bool isDark, Color subTextColor) {
    // 🚀 Step 1: Media Query for orientation and dimensions
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenWidth = mediaQuery.size.width;

    return Container(
      // Landscape mein padding kam kar di taaki height bache
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 30 : 20,
        vertical: isLandscape ? 10 : 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5)
          )
        ],
      ),
      child: SafeArea(
        top: false, // Bottom safe area handle karne ke liye
        child: isLandscape
            ? _buildLandscapeLayout(theme, subTextColor) // 🚀 Landscape Layout
            : _buildPortraitLayout(theme, subTextColor), // 🚀 Portrait Layout
      ),
    );
  }

// 📱 Portrait Layout: Standard Column
  Widget _buildPortraitLayout(ThemeData theme, Color subTextColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total Amount", style: TextStyle(color: subTextColor, fontWeight: FontWeight.w600)),
            _buildPriceText(theme),
          ],
        ),
        const SizedBox(height: 20),
        _buildPlaceOrderButton(),
      ],
    );
  }

// 🌅 Landscape Layout: Horizontal Row to save height
  Widget _buildLandscapeLayout(ThemeData theme, Color subTextColor) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Amount", style: TextStyle(color: subTextColor, fontSize: 12)),
              _buildPriceText(theme),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 3,
          child: _buildPlaceOrderButton(),
        ),
      ],
    );
  }

// 💰 Price Widget (Common)
  Widget _buildPriceText(ThemeData theme) {
    return Flexible(
        child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
                "₹$totalValue",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: theme.primaryColor
                )
            )
        )
    );
  }

// 🛒 Place Order Button Logic (Common)
  Widget _buildPlaceOrderButton() {
    return AppButton(
      text: "PLACE ORDER",
      icon: Icons.check_circle_outline,
      height: 45, // Fixed height for consistency
      isLoading: _isPlacingOrder,
      onPressed: _handlePlaceOrder,
    );
  }

// 🛠️ Order Logic separated for clean code
  Future<void> _handlePlaceOrder() async {
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
      CustomSnackBar.show(context, "Quantity for $exceededProduct exceeds 100!", backgroundColor: dangerColor);
      return;
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
  }
  Widget _buildEmptyState(bool isDark, Color subTextColor) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: subTextColor.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text("Your cart is empty", style: TextStyle(color: subTextColor, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}