// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// // Assuming CustomerNavigationBar and other necessary files are correctly imported
// import 'package:snap2bill/widgets/CustomerNavigationBar.dart';
//
// class addOrder extends StatefulWidget {
//   // If possible, it's safer to pass product/stock ID directly here:
//   // final String? productId;
//   // const addOrder({Key? key, this.productId}) : super(key: key);
//
//   const addOrder({Key? key}) : super(key: key);
//
//   @override
//   State<addOrder> createState() => _addOrderState();
// }
//
// class _addOrderState extends State<addOrder> {
//   // Use a final keyword for controllers
//   final TextEditingController _quantityController = TextEditingController(text: "1");
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isAddingToCart = false;
//
//   @override
//   void dispose() {
//     _quantityController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _addToCart(BuildContext context) async {
//     if (!_formKey.currentState!.validate() || _isAddingToCart) {
//       return;
//     }
//
//     setState(() {
//       _isAddingToCart = true;
//     });
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String? ip = sh.getString("ip");
//     // Ensure all required IDs are available from SharedPreferences
//     String? cid = sh.getString("cid"); // Customer ID
//     String? uid = sh.getString("uid");
//     String? id  = sh.getString("pid");
//     // Product/Stock ID
//
//     if (ip == null || cid == null || uid == null || id == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Error: Missing login or product data (IP/CID/UID/ID)."),
//           backgroundColor: Colors.red,
//         ),
//       );
//       setState(() {
//         _isAddingToCart = false;
//       });
//       return;
//     }
//
//     try {
//       var data = await http.post(
//         Uri.parse("$ip/addorder"),
//         body: {
//           "quantity": _quantityController.text,
//           'uid': uid, // Distributor ID
//           'cid': cid, // Customer ID
//           'id': id,   // Product/Stock ID (The stock ID being ordered)
//         },
//       );
//
//       var jsonData = json.decode(data.body);
//
//       if (data.statusCode == 200 && jsonData['status'] == 'ok') {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Product added to cart successfully!")),
//         );
//         // Navigate back to the main customer navigation screen
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const CustomerNavigationBar(),
//           ),
//               (route) => false, // Clears the stack to prevent back button issues
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to add: ${jsonData['message'] ?? 'Server error.'}"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Network error: Could not reach server. $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isAddingToCart = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_new,
//             color: Colors.black87,
//             size: 20,
//           ),
//           onPressed: () {
//             if (Navigator.canPop(context)) Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           "Add Product to Cart",
//           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 10),
//               // --- Quantity Input ---
//               TextFormField(
//                 controller: _quantityController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   hintText: 'Enter quantity (e.g., 2, 5)',
//                   labelText: 'Quantity',
//                   prefixIcon: Icon(Icons.numbers),
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a quantity.';
//                   }
//                   if (int.tryParse(value) == null || int.parse(value) <= 0) {
//                     return 'Quantity must be a positive number.';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 30),
//
//               // --- Add to Cart Button ---
//               ElevatedButton(
//                 onPressed: _isAddingToCart ? null : () => _addToCart(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 child: _isAddingToCart
//                     ? const SizedBox(
//                   height: 20,
//                   width: 20,
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 3,
//                   ),
//                 )
//                     : const Text(
//                   "Add to Cart",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Customerdirectory/custviews/view_product.dart';
import 'package:snap2bill/widgets/CustomerNavigationBar.dart';

class addOrder extends StatefulWidget {
  const addOrder({Key? key}) : super(key: key);

  @override
  State<addOrder> createState() => _addOrderState();
}

class _addOrderState extends State<addOrder> {
  final quantity = TextEditingController(text: "1");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          "Add product to cart",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: double.infinity,
          height: 500,
          child: Column(
            children: [
              SizedBox(height: 10),
              TextField(
                controller: quantity,
                decoration: InputDecoration(
                  hintText: 'Enter quantiy',
                  labelText: 'Quantity',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  SharedPreferences sh = await SharedPreferences.getInstance();
                  var data = await http.post(
                    Uri.parse(sh.getString("ip").toString() + "/addorder"),
                    body: {
                      "quantity": quantity.text,
                      'uid': sh.getString("uid"),
                      'cid': sh.getString("cid"),
                      'id': sh.getString("id"),
                    },
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerNavigationBar(),
                    ),
                  );
                },
                child: Text("Add to cart"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}