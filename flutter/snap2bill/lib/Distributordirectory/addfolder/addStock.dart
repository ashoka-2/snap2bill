// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Customerdirectory/custviews/view_product.dart';
// import 'package:snap2bill/Distributordirectory/view/myProducts.dart';
//
//
// class addStock extends StatelessWidget {
//   const addStock({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: addStockSub(),);
//   }
// }
//
// class addStockSub extends StatefulWidget {
//   const addStockSub({Key? key}) : super(key: key);
//
//   @override
//   State<addStockSub> createState() => _addStockSubState();
// }
//
// class _addStockSubState extends State<addStockSub> {
//   TextEditingController stock = TextEditingController();
//   TextEditingController price = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body:
//
//         Column(
//           children: [
//             TextField(controller: stock,
//               decoration: InputDecoration(
//                   hintText: 'Enter stock quantity',
//                   labelText: 'Quantity',
//                   prefixIcon: Icon(Icons.clean_hands),
//                   border: OutlineInputBorder()
//               ),),
//             TextField(controller: price,
//               decoration: InputDecoration(
//                   hintText: 'Enter price',
//                   labelText: 'Price',
//                   prefixIcon: Icon(Icons.clean_hands),
//                   border: OutlineInputBorder()
//               ),),
//
//             SizedBox(height: 10,),
//             ElevatedButton(onPressed: () async {
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               var data = await http.post(Uri.parse(prefs.getString("ip").toString()+"/add_stock"),
//                   body: {
//                 'pid':prefs.getString("pid").toString(),
//                     'uid':prefs.getString("uid").toString(),
//                     'quantity':stock.text,
//                     'price':price.text,
//                   }
//               );
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>myProducts()));
//
//             }, child: Text("Add"))
//           ],
//         ),
//
//     );
//   }
// }
//
//
//
//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // REQUIRED FOR INPUT FORMATTERS
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/view/myProducts.dart';

// Make sure these point to your actual file locations
import '../../theme/colors.dart';
import '../../widgets/app_button.dart';

class addStock extends StatelessWidget {
  const addStock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const addStockSub();
  }
}

class addStockSub extends StatefulWidget {
  const addStockSub({Key? key}) : super(key: key);

  @override
  State<addStockSub> createState() => _addStockSubState();
}

class _addStockSubState extends State<addStockSub> {
  TextEditingController stock = TextEditingController();
  TextEditingController price = TextEditingController();
  bool _isLoading = false;

  // --- API Logic ---
  Future<void> _submitStock() async {
    // Basic Validation
    if (stock.text.isEmpty || price.text.isEmpty) {
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
        final uri = Uri.parse("$ip/add_stock");

        final body = {
          'pid': pid ?? "",
          'uid': uid ?? "",
          'quantity': stock.text,
          'price': price.text,
        };

        var response = await http.post(uri, body: body);

        if (response.statusCode == 200) {
          if (!mounted) return;
          // Success: Navigate back to products
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const myProducts())
          );
        } else {
          throw Exception("Server returned error");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
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
    final inputFillColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[50];
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;

    // Button Colors
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
          "Update Inventory",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // --- Header Icon ---
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.blue.shade50,
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
                    Icons.add_business_outlined,
                    size: 45,
                    color: isDark ? Colors.white : Colors.blue.shade700
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
                      "Stock Details",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Enter the new quantity and price to add.",
                      style: TextStyle(fontSize: 14, color: hintColor),
                    ),
                    const SizedBox(height: 25),

                    // Quantity Field (Digits Only)
                    _buildThemeTextField(
                      controller: stock,
                      label: "Quantity",
                      hint: "Ex: 50",
                      icon: Icons.inventory_2_outlined,
                      isNumber: true,
                      textColor: textColor,
                      hintColor: hintColor!,
                      borderColor: borderColor,
                      // Validation: Allow digits only
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 20),

                    // Price Field (Digits Only)
                    _buildThemeTextField(
                      controller: price,
                      label: "Price per Unit",
                      hint: "Ex: 1200",
                      icon: Icons.currency_rupee,
                      isNumber: true,
                      textColor: textColor,
                      hintColor: hintColor,
                      borderColor: borderColor,
                      // Validation: Allow digits only (add '.' to regex if you need decimals)
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- APP BUTTON ---
              AppButton(
                text: "Add Stock",
                onPressed: _submitStock,
                isLoading: _isLoading,
                color: buttonColor,
                textColor: buttonTextColor,
                icon: Icons.add_shopping_cart,
                isTrailingIcon: false,
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
    List<TextInputFormatter>? inputFormatters, // ADDED THIS PARAMETER
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
          // If isNumber is true, bring up number pad
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          // Apply the validation formatters here
          inputFormatters: inputFormatters,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor, fontSize: 14),
            prefixIcon: Icon(icon, color: textColor.withOpacity(0.5), size: 20),
            filled: true,
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