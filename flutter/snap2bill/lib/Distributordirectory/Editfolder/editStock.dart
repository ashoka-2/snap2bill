// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Customerdirectory/custviews/view_product.dart';
// import 'package:snap2bill/Distributordirectory/view/myProducts.dart';
//
//
//
// class editStock extends StatefulWidget {
//   final id;
//   final price;
//   final quantity;
//
//   const editStock({
//     required this.id,
//     required this.price,
//     required this.quantity,
// }) : super();
//
//   @override
//   State<editStock> createState() => _editStockState();
// }
//
// class _editStockState extends State<editStock> {
//   final quantity = TextEditingController();
//   final price = TextEditingController();
//   @override
//   void initState() {
//     super.initState();
//     price.text = widget.price;
//     quantity.text = widget.quantity;
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body:
//
//       Column(
//         children: [
//           TextField(controller: quantity,
//             decoration: InputDecoration(
//                 hintText: 'Enter stock quantity',
//                 labelText: 'Quantity',
//                 prefixIcon: Icon(Icons.clean_hands),
//                 border: OutlineInputBorder()
//             ),),
//           TextField(controller: price,
//             decoration: InputDecoration(
//                 hintText: 'Enter price',
//                 labelText: 'Price',
//                 prefixIcon: Icon(Icons.currency_rupee),
//                 border: OutlineInputBorder()
//             ),),
//
//           SizedBox(height: 10,),
//           ElevatedButton(onPressed: () async {
//             SharedPreferences prefs = await SharedPreferences.getInstance();
//             var data = await http.post(Uri.parse(prefs.getString("ip").toString()+"/edit_stock"),
//                 body: {
//                   'pid':prefs.getString("pid").toString(),'uid':prefs.getString("uid").toString(),
//                   'quantity':quantity.text,
//                   'price':price.text,
//                 }
//             );
//             Navigator.push(context, MaterialPageRoute(builder: (context)=>myProducts()));
//
//           }, child: Text("Update"))
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // REQUIRED FOR VALIDATION
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/view/myProducts.dart';

// Make sure this points to your actual colors file
import '../../theme/colors.dart';
import '../../widgets/app_button.dart';

class editStock extends StatefulWidget {
  final id;
  final price;
  final quantity;

  const editStock({
    Key? key,
    required this.id,
    required this.price,
    required this.quantity,
  }) : super(key: key);

  @override
  State<editStock> createState() => _editStockState();
}

class _editStockState extends State<editStock> {
  final quantity = TextEditingController();
  final price = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    price.text = widget.price.toString();
    quantity.text = widget.quantity.toString();
  }

  // --- API Update Logic ---
  Future<void> _updateStock() async {
    // 1. Basic Validation: Check if empty
    if (quantity.text.isEmpty || price.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ip = prefs.getString("ip");
      String? pid = prefs.getString("pid");
      String? uid = prefs.getString("uid");

      if (ip != null) {
        final uri = Uri.parse("$ip/edit_stock");

        // Ensure we send valid strings
        final body = {
          'pid': pid ?? widget.id.toString(),
          'uid': uid ?? "",
          'quantity': quantity.text,
          'price': price.text,
        };

        var response = await http.post(uri, body: body);

        if (response.statusCode == 200) {
          if (!mounted) return;
          // Return to the previous screen cleanly
          if (!mounted) return;
          Navigator.pop(context, 'refresh');
        } else {
          throw Exception("Failed to update");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating stock: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Theme Handling ---
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Design Colors
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = theme.cardColor;
    final hintColor = isDark ? Colors.white38 : Colors.grey[500];
    // REMOVED inputFillColor variable
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;

    // Button Colors (Adapting based on theme)
    final buttonColor = isDark ? Colors.white : Colors.black;
    final buttonTextColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          "Edit Stock",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // --- Header Icon (Visual Appeal) ---
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.orange.shade50,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                    Icons.inventory_2_outlined,
                    size: 45,
                    color: isDark ? Colors.white : Colors.orange.shade800
                ),
              ),
              const SizedBox(height: 40),

              // --- Form Card ---
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Update Details",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Quantity Field
                    _buildThemeTextField(
                      controller: quantity,
                      label: "Quantity",
                      hint: "Available stock",
                      icon: Icons.layers_outlined,
                      isNumber: true,
                      textColor: textColor,
                      hintColor: hintColor!,
                      borderColor: borderColor,
                      // Validation: Digits Only
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 20),

                    // Price Field
                    _buildThemeTextField(
                      controller: price,
                      label: "Price",
                      hint: "Product price",
                      icon: Icons.currency_rupee,
                      isNumber: true,
                      textColor: textColor,
                      hintColor: hintColor,
                      borderColor: borderColor,
                      // Validation: Digits Only
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- APP BUTTON ---
              AppButton(
                text: "Update Stock",
                onPressed: _updateStock,
                isLoading: _isLoading,

                // Theme Adaptation:
                color: buttonColor,        // White in DarkMode, Black in LightMode
                textColor: buttonTextColor, // Inverse of background

                // Optional styling extras:
                icon: Icons.check_circle_outline,
                isTrailingIcon: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper for Beautiful TextFields ---
  Widget _buildThemeTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color textColor,
    required Color hintColor,
    required Color borderColor,
    bool isNumber = false,
    List<TextInputFormatter>? inputFormatters, // Added parameter
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: textColor.withOpacity(0.7)
            )
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          // APPLY VALIDATION HERE
          inputFormatters: inputFormatters,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor, fontSize: 14),
            prefixIcon: Icon(icon, color: textColor.withOpacity(0.5), size: 20),
            // Removed filled: true and fillColor completely
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: textColor, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}