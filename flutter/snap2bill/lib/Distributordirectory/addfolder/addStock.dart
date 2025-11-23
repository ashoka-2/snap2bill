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
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/view/myProducts.dart';

class addStock extends StatelessWidget {
  const addStock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FIX: Removed MaterialApp so navigation history is preserved
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
  bool _isLoading = false; // To show loading spinner

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          "Update Inventory",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // --- Header Image/Icon ---
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_business_outlined, size: 60, color: Colors.indigo.shade400),
              ),
              const SizedBox(height: 30),

              // --- Form Card ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Stock Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Enter the new quantity and price to update.",
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 25),

                    // Quantity Field
                    _buildTextField(
                      controller: stock,
                      label: "Quantity",
                      hint: "Ex: 50",
                      icon: Icons.inventory_2_outlined,
                      isNumber: true,
                    ),
                    const SizedBox(height: 20),

                    // Price Field
                    _buildTextField(
                      controller: price,
                      label: "Price per Unit",
                      hint: "Ex: 1200",
                      icon: Icons.currency_rupee, // Or Icons.attach_money
                      isNumber: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- Add Button ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    // Basic Validation
                    if (stock.text.isEmpty || price.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all fields")),
                      );
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String? ip = prefs.getString("ip");
                      String? pid = prefs.getString("pid");
                      String? uid = prefs.getString("uid");

                      if (ip != null) {
                        var data = await http.post(
                          Uri.parse("$ip/add_stock"),
                          body: {
                            'pid': pid ?? "",
                            'uid': uid ?? "",
                            'quantity': stock.text,
                            'price': price.text,
                          },
                        );

                        // Use pushReplacement to avoid back-button loop
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const myProducts())
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text(
                    "Update Stock",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for TextFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.indigo.shade300),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}