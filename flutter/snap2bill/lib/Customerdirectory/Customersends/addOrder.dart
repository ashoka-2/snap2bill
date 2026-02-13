
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
  List<dynamic> fbtProducts = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _ip = "";
  late Color successColor;

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

  int get currentQty => int.tryParse(_qtyController.text) ?? 1;

  Future<void> _fetchDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _ip = prefs.getString("ip") ?? "";
    String pid = widget.pid ?? prefs.getString("pid") ?? "";

    final response = await http.post(
      Uri.parse("$_ip/get_product_details"),
      body: {'pid': pid},
    );

    if (response.statusCode == 200) {
      setState(() {
        productData = json.decode(response.body)['data'];
      });

      // 🚀 1. Pehle suggestions fetch karein
      _fetchSuggestions(pid);

      // 🚀 2. Backend ko batayein ki ye product dekha gaya hai (Recently Viewed)
      _saveToRecentOnServer(pid);
    }
  }

  // 🔥 NEW FUNCTION: Backend par entry save karne ke liye
  Future<void> _saveToRecentOnServer(String sid) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await http.post(
        Uri.parse("$_ip/add_to_recent"), // Ensure this route is in urls.py
        body: {
          'cid': prefs.getString("cid"),
          'sid': sid,
        },
      );
      debugPrint("Logged to recently viewed: $sid");
    } catch (e) {
      debugPrint("Error logging recent view: $e");
    }
  }

  Future<void> _fetchSuggestions(String sid) async {
    try {
      final response = await http.post(
        Uri.parse("$_ip/get_incremental_suggestions"),
        body: {'sid': sid},
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            fbtProducts = data['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("FBT Fetch Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addToCart({String? customPid, String? customQty}) async {
    setState(() => _isSubmitting = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse("$_ip/addorder"),
      body: {
        "quantity": customQty ?? _qtyController.text,
        'cid': prefs.getString("cid"),
        'pid': customPid ?? (widget.pid ?? prefs.getString("pid")),
      },
    );

    if (json.decode(response.body)['status'] == 'ok') {
      CustomSnackBar.show(context, "Added to cart!", backgroundColor: successColor);

      if (customPid == null) {
        // 🚀 Step 1: pushReplacement ki jagah push use karein
        // Isse page stack mein rehta hai
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const viewCart())
        ).then((_) {
          // 🚀 Step 2: Jab user Cart page se wapas is page par aaye
          // toh turant home page tak signal bhejne ke liye pop karein
          Navigator.pop(context, "refresh");
        });
      }
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    successColor = AppColors.getSuccessColor(context);
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    double price = double.tryParse(productData!['price'].toString()) ?? 0.0;
    double totalPrice = price * currentQty;
    String unit = productData!['unit_name'] ?? "Unit";
    final bgColor = AppColors.getScaffoldBg(context);
    final textColor = AppColors.getTextColor(context);
    final cardColor = AppColors.getCardColor(context);
    final subTextColor = AppColors.getTextSubColor(context);
    final borderColor = AppColors.getBorderColor(context).withValues(alpha: 0.5);
    final primaryColor = AppColors.getPrimaryColor(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: ThemeNavbar(
        title: "Order Product",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () => Navigator.pop(context, "refresh"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            const SizedBox(height: 25),
            _buildMainInfo(cardColor, primaryColor, textColor, subTextColor, borderColor, unit),
            const SizedBox(height: 20),
            _buildDescription(cardColor, textColor, subTextColor),
            const SizedBox(height: 30),

            if (fbtProducts.isNotEmpty) ...[
              Text(
                "Frequently Bought Together",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fbtProducts.length,
                  itemBuilder: (context, index) {
                    var item = fbtProducts[index];
                    return _buildFBTCard(item, cardColor, textColor, subTextColor, primaryColor);
                  },
                ),
              ),
            ],
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(cardColor, subTextColor, unit, primaryColor, totalPrice),
    );
  }

  // WIDGET HELPERS
  Widget _buildProductImage() {
    return Container(
      height: 320, width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: AppColors.BlackColor.withValues(alpha:0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Hero(
        tag: 'prod_${productData!['id']}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: InteractiveViewer(
            child: Image.network(_ip + productData!['image'], fit: BoxFit.fill),
          ),
        ),
      ),
    );
  }

  Widget _buildFBTCard(item, cardColor, textColor, subTextColor, primaryColor) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: subTextColor.withValues(alpha:0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                _ip + item['image'],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(item['product_name'], maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
          Text("₹${item['price']}", style: TextStyle(fontSize: 12, color: successColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          InkWell(
            onTap: () {
              SharedPreferences.getInstance().then((prefs) {
                prefs.setString("pid", item['id'].toString());
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => addOrder(pid: item['id'].toString())));
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(color: primaryColor.withValues(alpha:0.1), borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Text("+ Add", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMainInfo(cardColor, primaryColor, textColor, subTextColor, borderColor, unit) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(productData!['category'].toString().toUpperCase(), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Text(productData!['product_name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Unit Price", style: TextStyle(color: subTextColor, fontSize: 12)),
                Text("₹${productData!['price']}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: successColor)),
              ]),
              _buildQtySelector(primaryColor, borderColor, textColor, subTextColor, unit),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtySelector(primaryColor, borderColor, textColor, subTextColor, unit) {
    return Container(
      decoration: BoxDecoration(color: AppColors.getPillBg(context), borderRadius: BorderRadius.circular(18), border: Border.all(color: borderColor)),
      child: Row(children: [
        IconButton(onPressed: () { if (currentQty > 1) setState(() => _qtyController.text = (currentQty - 1).toString()); }, icon: Icon(Icons.remove_circle_outline, color: primaryColor)),
        SizedBox(width: 55, child: TextField(controller: _qtyController, keyboardType: TextInputType.number, textAlign: TextAlign.center, onChanged: (v) => setState(() {}), decoration: const InputDecoration(border: InputBorder.none))),
        IconButton(onPressed: () { if (currentQty < 100) setState(() => _qtyController.text = (currentQty + 1).toString()); }, icon: Icon(Icons.add_circle_outline, color: primaryColor)),
      ]),
    );
  }

  Widget _buildDescription(cardColor, textColor, subTextColor) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 12),
        Text(productData!['description'] ?? "No description available.", style: TextStyle(color: subTextColor, height: 1.6, fontSize: 14)),
      ]),
    );
  }

  Widget _buildBottomBar(cardColor, subTextColor, unit, primaryColor, totalPrice) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
      decoration: BoxDecoration(color: cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Total ($currentQty $unit)", style: TextStyle(color: subTextColor, fontSize: 13)),
          Text("₹${totalPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryColor)),
        ]),
        const SizedBox(width: 10),
        Expanded(child: AppButton(text: "ADD TO CART", icon: Icons.shopping_cart_outlined, isLoading: _isSubmitting, onPressed: _addToCart)),
      ]),
    );
  }
}