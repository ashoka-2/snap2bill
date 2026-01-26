import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Customerdirectory/custviews/viewCart.dart';
import 'package:snap2bill/theme/colors.dart';

import '../../widgets/Navbar.dart';
import '../../widgets/SnackBar.dart';
import '../../widgets/app_button.dart';

class addOrder extends StatefulWidget {
  final String? pid;
  const addOrder({Key? key, this.pid}) : super(key: key);

  @override
  State<addOrder> createState() => _addOrderState();
}

class _addOrderState extends State<addOrder> {
  final TextEditingController _qtyController = TextEditingController(text: "1");
  Map<String, dynamic>? productData;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _ip = "";

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  // Helper to get current qty safely
  int get currentQty => int.tryParse(_qtyController.text) ?? 1;

  Future<void> _fetchDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _ip = prefs.getString("ip") ?? "";
    String pid = prefs.getString("pid") ?? "";

    final response = await http.post(
      Uri.parse("$_ip/get_product_details"),
      body: {'pid': pid},
    );

    if (response.statusCode == 200) {
      setState(() {
        productData = json.decode(response.body)['data'];
        _isLoading = false;
      });
    }
  }

  Future<void> _addToCart() async {
    // 🚀 VALIDATION: Ensure quantity is between 1 and 100
    if (currentQty < 1) {
      CustomSnackBar.show(context, "Quantity cannot be less than 1.", backgroundColor: AppColors.dangerColor, durationMs: 800);

      return;
    }
    if (currentQty > 100) {
      CustomSnackBar.show(context, "Maximum quantity allowed is 100.", backgroundColor: AppColors.dangerColor, durationMs: 800);
      return;
    }

    setState(() => _isSubmitting = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse("$_ip/addorder"),
      body: {
        "quantity": _qtyController.text,
        'cid': prefs.getString("cid"),
        'pid': prefs.getString("pid"),
      },
    );

    if (json.decode(response.body)['status'] == 'ok') {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const viewCart()),
        );
      }
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    double price = double.tryParse(productData!['price'].toString()) ?? 0.0;
    double totalPrice = price * currentQty;
    String unit = productData!['unit_name'] ?? "Unit";

    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = theme.cardColor;
    final subTextColor = isDark ? Colors.white38 : Colors.grey[600];
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: ThemeNavbar(
        title: "Order Product",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () => Navigator.pop(context),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 320,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ?  Color(0xFF2C2C2C) : AppColors.getPrimaryColor(context).withValues(alpha:0.5),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Hero(
                tag: 'prod_${productData!['pid']}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: InteractiveViewer(
                    child: Image.network(
                      _ip + productData!['image'],
                      fit: BoxFit.fill,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color:isDark? Colors.black.withValues(alpha:0.3): Colors.black.withValues(alpha:0.05), blurRadius: 20, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productData!['category'].toString().toUpperCase(),
                    style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productData!['product_name'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const Divider(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Unit Price", style: TextStyle(color: subTextColor, fontSize: 12)),
                          Text(
                            "₹${productData!['price']}",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.greenAccent : Colors.green[800]
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey[100],
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  if (currentQty > 1) setState(() => _qtyController.text = (currentQty - 1).toString());
                                },
                                icon: Icon(Icons.remove_circle_outline, color: theme.primaryColor, size: 22)
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 55,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: TextField(
                                      controller: _qtyController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      onChanged: (value) {
                                        // 🚀 Validation on manual typing
                                        int? val = int.tryParse(value);
                                        if (val != null && val > 100) {
                                          _qtyController.text = "100";
                                          _qtyController.selection = TextSelection.fromPosition(const TextPosition(offset: 3));
                                        }
                                        setState(() {});
                                      },
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(3), // Prevents typing more than 3 digits
                                      ],
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                                      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                                    ),
                                  ),
                                ),
                                Text(unit, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subTextColor)),
                              ],
                            ),
                            IconButton(
                                onPressed: () {
                                  // 🚀 Validation on increment button
                                  if (currentQty < 100) {
                                    setState(() => _qtyController.text = (currentQty + 1).toString());
                                  } else {
                                    CustomSnackBar.show(context, "Maximum limit reached.", backgroundColor: AppColors.dangerColor, durationMs: 1000);
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
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 12),
                  Text(
                    productData!['description'] ?? "No description available.",
                    style: TextStyle(color: subTextColor, height: 1.6, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
        decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.08), blurRadius: 15, offset: const Offset(0, -5))]
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total ($currentQty $unit)",maxLines: 1, style: TextStyle(color: subTextColor, fontSize: 13)),
                  Text("₹${totalPrice.toStringAsFixed(2)}",maxLines: 1,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: AppButton(
                text: "ADD TO CART",
                icon: Icons.shopping_cart_outlined,
                isLoading: _isSubmitting,
                onPressed: _addToCart,
                // isTrailingIcon: true,
                height: 55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}