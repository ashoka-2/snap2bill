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
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/view/myProducts.dart';

class editStock extends StatefulWidget {
  final id;
  final price;
  final quantity;

  const editStock({
    required this.id,
    required this.price,
    required this.quantity,
  }) : super();

  @override
  State<editStock> createState() => _editStockState();
}

class _editStockState extends State<editStock> {
  final quantity = TextEditingController();
  final price = TextEditingController();
  bool _isLoading = false; // Added for loading state

  @override
  void initState() {
    super.initState();
    price.text = widget.price;
    quantity.text = widget.quantity;
  }

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
          "Edit Stock Details",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // --- Header Icon ---
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit_note_rounded, size: 50, color: Colors.indigo.shade400),
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
                    Text(
                      "Update Product Info",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 20),

                    // Quantity Field
                    _buildTextField(
                      controller: quantity,
                      label: "Stock Quantity",
                      hint: "Enter quantity",
                      icon: Icons.inventory_2_outlined,
                      isNumber: true,
                    ),
                    const SizedBox(height: 20),

                    // Price Field
                    _buildTextField(
                      controller: price,
                      label: "Price",
                      hint: "Enter price",
                      icon: Icons.currency_rupee,
                      isNumber: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- Update Button ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
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
                          Uri.parse("$ip/edit_stock"),
                          body: {
                            'pid': pid ?? widget.id.toString(), // Fallback to widget id if pref is missing
                            'uid': uid ?? "",
                            'quantity': quantity.text,
                            'price': price.text,
                          },
                        );

                        // Use pushReplacement to go back to list cleanly
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const myProducts())
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Error updating stock")),
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
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
                    "Update",
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