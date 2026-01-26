
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/scanItem.dart';
import 'dart:convert';

import '../../theme/colors.dart';
import '../../widgets/Navbar.dart';
import '../../widgets/SnackBar.dart';
import '../../widgets/app_button.dart';

class addToBill extends StatefulWidget {
  const addToBill({Key? key}) : super(key: key);

  @override
  State<addToBill> createState() => _addToBillState();
}

class _addToBillState extends State<addToBill> {
  final quantityController = TextEditingController(text: "1");
  final priceController = TextEditingController();

  String productName = "Loading...";
  String productImage = "";
  String unitName = ""; // 🚀 Added to store the unit (Kg, Pcs, etc.)
  bool _isLoading = true;
  bool _isSubmitting = false;

  late Color dangerColor;

  @override
  void initState() {
    super.initState();
    fetchFullDetails();
  }

  Future<void> fetchFullDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "";
      String sid = prefs.getString("sid") ?? "";

      var response = await http.post(Uri.parse("$ip/get_product_details"), body: {
        'pid': sid,
      });

      if (response.statusCode == 200) {
        var decoded = json.decode(response.body);
        if (decoded['status'] == 'ok') {
          setState(() {
            productName = decoded['data']['product_name'];
            priceController.text = decoded['data']['price'].toString();
            productImage = ip + decoded['data']['image'];
            unitName = decoded['data']['unit_name'] ?? ""; // 🚀 Extract Unit Name
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching details: $e");
    }
  }

  Future<void> _confirmAddToBill() async {
    if (quantityController.text.isEmpty || priceController.text.isEmpty) {
      CustomSnackBar.show(context, "Please fill all fields", backgroundColor: dangerColor);
      return;
    }

    setState(() => _isSubmitting = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("ip") ?? "";

    final response = await http.post(
      Uri.parse("$ip/addtobill"),
      body: {
        "quantity": quantityController.text,
        "price": priceController.text,
        'cid': prefs.getString("cid"),
        'sid': prefs.getString("sid"),
        'uid': prefs.getString("uid"),
      },
    );

    var res = json.decode(response.body);
    if (res['status'] == 'ok') {
      prefs.setString("oid", res['oid'].toString());
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  CameraCapture()));
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    dangerColor = AppColors.getDangerColor(context);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = theme.cardColor;
    final hintColor = isDark ? Colors.white38 : Colors.grey[500];
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: ThemeNavbar(
        title: "Confirm Item",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () => Navigator.pop(context),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Product Preview
              Container(
                height: 180, width: 180,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 15)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: productImage.isNotEmpty
                      ? Image.network(productImage, fit: BoxFit.fill)
                      : const Icon(Icons.inventory, size: 50),
                ),
              ),
              const SizedBox(height: 20),
              Text(productName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 35),

              // Form
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color:isDark? Colors.black.withValues(alpha:0.3): Colors.black.withValues(alpha:0.05), blurRadius: 20)],
                ),
                child: Column(
                  children: [
                    _buildThemeTextField(
                      controller: priceController,
                      label: "Unit Price",
                      hint: "Price per item",
                      icon: Icons.currency_rupee,
                      isNumber: true,
                      textColor: textColor,
                      hintColor: hintColor!,
                      borderColor: borderColor,
                    ),
                    const SizedBox(height: 20),
                    _buildThemeTextField(
                      controller: quantityController,
                      label: "Quantity",
                      hint: "Number of items",
                      icon: Icons.unarchive_outlined,
                      isNumber: true,
                      textColor: textColor,
                      hintColor: hintColor,
                      borderColor: borderColor,
                      // 🚀 Pass unitName to the suffix
                      suffixText: unitName,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              AppButton(
                text: "Add to Bill",
                onPressed: _confirmAddToBill,
                isLoading: _isSubmitting,
                icon: Icons.add_shopping_cart,
                isTrailingIcon: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color textColor,
    required Color hintColor,
    required Color borderColor,
    String? suffixText, // 🚀 New parameter
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor.withValues(alpha:0.7))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor, fontSize: 14),
            prefixIcon: Icon(icon, color: textColor.withValues(alpha:0.5), size: 20),
            // 🚀 Show the unit name as a suffix
            suffixIcon: suffixText != null ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              child: Text(suffixText, style: TextStyle(color: textColor.withValues(alpha:0.5), fontWeight: FontWeight.bold)),
            ) : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: textColor, width: 1)),
          ),
        ),
      ],
    );
  }
}