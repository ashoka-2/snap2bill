//
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // Required for input formatters
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:snap2bill/Customerdirectory/custviews/viewCart.dart';
//
// class addOrder extends StatefulWidget {
//   const addOrder({Key? key}) : super(key: key);
//
//   @override
//   State<addOrder> createState() => _addOrderState();
// }
//
// class _addOrderState extends State<addOrder> {
//   final TextEditingController _qtyController = TextEditingController(text: "1");
//   Map<String, dynamic>? productData;
//   bool _isLoading = true;
//   String _ip = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchDetails();
//   }
//
//   @override
//   void dispose() {
//     _qtyController.dispose();
//     super.dispose();
//   }
//
//   // Helper to get current qty safely
//   int get currentQty => int.tryParse(_qtyController.text) ?? 1;
//
//   Future<void> _fetchDetails() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     _ip = sh.getString("ip") ?? "";
//     String pid = sh.getString("pid") ?? "";
//
//     final response = await http.post(
//       Uri.parse("$_ip/get_product_details"),
//       body: {'pid': pid},
//     );
//
//     if (response.statusCode == 200) {
//       setState(() {
//         productData = json.decode(response.body)['data'];
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _addToCart() async {
//     if (currentQty < 1) return;
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     final response = await http.post(
//       Uri.parse("$_ip/addorder"),
//       body: {
//         "quantity": _qtyController.text,
//         'cid': sh.getString("cid"),
//         'pid': sh.getString("pid"),
//       },
//     );
//
//     if (json.decode(response.body)['status'] == 'ok') {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const viewCart()),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
//
//     double price = double.tryParse(productData!['price'].toString()) ?? 0.0;
//     double totalPrice = price * currentQty;
//
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text("Product Details",
//             style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 15),
//             // Product Image Container
//             Container(
//               height: 280,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: isDark ? Colors.white10 : Colors.grey[100],
//                 borderRadius: BorderRadius.circular(25),
//                 image: DecorationImage(
//                   image: NetworkImage(_ip + productData!['image']),
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 25),
//
//             Text(
//                 productData!['category'].toString().toUpperCase(),
//                 style: GoogleFonts.poppins(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)
//             ),
//             Text(
//                 productData!['product_name'],
//                 style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)
//             ),
//
//             const SizedBox(height: 20),
//
//             // Price and Dual-Input Quantity Section
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Unit Price", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
//                     Text(
//                       "₹${productData!['price']}",
//                       style: GoogleFonts.poppins(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: isDark ? Colors.greenAccent : Colors.green[800]
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 // ✅ UPDATED: Hybrid Quantity Selector (Buttons + Keyboard)
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 5),
//                   decoration: BoxDecoration(
//                     color: isDark ? Colors.white12 : Colors.grey[200],
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Row(
//                     children: [
//                       IconButton(
//                           onPressed: () {
//                             if (currentQty > 1) {
//                               setState(() => _qtyController.text = (currentQty - 1).toString());
//                             }
//                           },
//                           icon: Icon(Icons.remove_circle_outline, color: theme.primaryColor)
//                       ),
//
//                       // Keyboard Input Field
//                       SizedBox(
//                         width: 50,
//                         child: TextField(
//                           controller: _qtyController,
//                           keyboardType: TextInputType.number,
//                           textAlign: TextAlign.center,
//                           onChanged: (value) => setState(() {}),
//                           inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                           decoration: const InputDecoration(
//                             border: InputBorder.none,
//                             isDense: true,
//                             contentPadding: EdgeInsets.zero,
//                           ),
//                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//
//                       IconButton(
//                           onPressed: () {
//                             setState(() => _qtyController.text = (currentQty + 1).toString());
//                           },
//                           icon: Icon(Icons.add_circle_outline, color: theme.primaryColor)
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 25),
//               child: Divider(),
//             ),
//
//             // Description
//             Text("Description", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             Text(
//               productData!['description'] ?? "No description available.",
//               style: GoogleFonts.poppins(color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.6),
//             ),
//             const SizedBox(height: 120),
//           ],
//         ),
//       ),
//
//       // Bottom Bar with Total Price & Add to Cart
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
//         decoration: BoxDecoration(
//             color: theme.cardColor,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Total Price", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
//                   Text("₹${totalPrice.toStringAsFixed(2)}",
//                       style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColor)),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 20),
//             Expanded(
//               flex: 2,
//               child: ElevatedButton(
//                 onPressed: _addToCart,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: theme.primaryColor,
//                   padding: const EdgeInsets.symmetric(vertical: 18),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//                   elevation: 0,
//                 ),
//                 child: Text("Add to Cart",
//                     style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snap2bill/Customerdirectory/custviews/viewCart.dart';

class addOrder extends StatefulWidget {
  const addOrder({Key? key}) : super(key: key);

  @override
  State<addOrder> createState() => _addOrderState();
}

class _addOrderState extends State<addOrder> {
  final TextEditingController _qtyController = TextEditingController(text: "1");
  Map<String, dynamic>? productData;
  bool _isLoading = true;
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
    SharedPreferences sh = await SharedPreferences.getInstance();
    _ip = sh.getString("ip") ?? "";
    String pid = sh.getString("pid") ?? "";

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
    if (currentQty < 1) return;

    SharedPreferences sh = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse("$_ip/addorder"),
      body: {
        "quantity": _qtyController.text,
        'cid': sh.getString("cid"),
        'pid': sh.getString("pid"),
      },
    );

    if (json.decode(response.body)['status'] == 'ok') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const viewCart()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    double price = double.tryParse(productData!['price'].toString()) ?? 0.0;
    double totalPrice = price * currentQty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Product Details",
            style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),

            // ✅ HERO DESTINATION: Shows PROPER FULL IMAGE
            Container(
              height: 350, // Height increased to show full product
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Hero(
                tag: 'prod_${productData!['pid']}',
                child: Material(
                  color: Colors.transparent,
                  child: InteractiveViewer( // Allows user to zoom in/out on the full image
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        _ip + productData!['image'],
                        fit: BoxFit.contain, // ✅ Ensures full image is visible
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Text(
                productData!['category'].toString().toUpperCase(),
                style: GoogleFonts.poppins(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)
            ),
            Text(
                productData!['product_name'],
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)
            ),

            const SizedBox(height: 20),

            // Price and Dual-Input Quantity Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Unit Price", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    Text(
                      "₹${productData!['price']}",
                      style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.greenAccent : Colors.green[800]
                      ),
                    ),
                  ],
                ),

                // Hybrid Quantity Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            if (currentQty > 1) {
                              setState(() => _qtyController.text = (currentQty - 1).toString());
                            }
                          },
                          icon: Icon(Icons.remove_circle_outline, color: theme.primaryColor)
                      ),
                      SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _qtyController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onChanged: (value) => setState(() {}),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() => _qtyController.text = (currentQty + 1).toString());
                          },
                          icon: Icon(Icons.add_circle_outline, color: theme.primaryColor)
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Divider(),
            ),

            // Description
            Text("Description", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              productData!['description'] ?? "No description available.",
              style: GoogleFonts.poppins(color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.6),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),

      // Bottom Bar with Total Price & Add to Cart
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
        decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Price", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  Text("₹${totalPrice.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: Text("Add to Cart",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}