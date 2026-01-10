//
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/theme/colors.dart';
// import 'package:snap2bill/widgets/app_button.dart';
// import 'package:snap2bill/widgets/distributorNavigationbar.dart';
// import '../../widgets/Navbar.dart';
//
// class viewBillItems extends StatefulWidget {
//   const viewBillItems({Key? key}) : super(key: key);
//
//   @override
//   State<viewBillItems> createState() => _viewBillItemsState();
// }
//
// class _viewBillItemsState extends State<viewBillItems> {
//   late Future<Map<String, dynamic>> futureData;
//   String totalValue = "0";
//   List<Map<String, dynamic>> _localItems = [];
//
//   String? serverIp;
//
//   @override
//   void initState() {
//     super.initState();
//     futureData = fetchBillItems();
//   }
//
//   /// --- API FETCH LOGIC ---
//   Future<Map<String, dynamic>> fetchBillItems() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     serverIp = sp.getString("ip") ?? "";
//     String orderId = sp.getString("oid") ?? "";
//
//     final res = await http.post(
//       Uri.parse("$serverIp/view_distributor_ordersitems"),
//       body: {"id": orderId},
//     );
//
//     if (res.statusCode == 200) {
//       return json.decode(res.body);
//     } else {
//       throw Exception("Failed to load items");
//     }
//   }
//
//   /// --- DELETE LOGIC ---
//   Future<void> deleteItem(String id) async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     await http.post(
//       Uri.parse("${sp.getString("ip")}/delete_order_item"),
//       body: {'id': id},
//     );
//     setState(() {
//       futureData = fetchBillItems();
//     });
//   }
//
//   /// --- UPDATE LOGIC (Price & Quantity) ---
//   Future<void> updateItem(String itemId, String qty, String price) async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     await http.post(
//       Uri.parse("${sp.getString("ip")}/update_order_item"),
//       body: {
//         'id': itemId,
//         'quantity': qty,
//         'amount': price,
//       },
//     );
//     setState(() {
//       futureData = fetchBillItems();
//     });
//   }
//
//   void _calculateLocalTotal() {
//     double newTotal = 0;
//     for (var item in _localItems) {
//       // Ensure price is treated as a double even if it's a string from DB
//       double price = double.parse(item['price'].toString());
//       // Ensure quantity is treated as a number
//       double qty = double.parse(item['quantity'].toString());
//       newTotal += (price * qty);
//     }
//     setState(() {
//       // toStringAsFixed(0) removes decimals like .0
//       totalValue = newTotal.toStringAsFixed(0);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final subTextColor = isDark ? Colors.white70 : Colors.grey[600];
//
//     return Scaffold(
//       backgroundColor: AppColors.getScaffoldBg(context),
//       appBar: ThemeNavbar(
//         title: "Edit Bill Items",
//         leadingIcon: Icons.arrow_back_ios_rounded,
//         onLeadingPressed: () {
//           if (Navigator.canPop(context)) Navigator.pop(context);
//         },
//         centerTitle: true,
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: futureData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!['data'] == null || snapshot.data!['data'].isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.inventory_2_outlined, size: 70, color: subTextColor),
//                   const SizedBox(height: 10),
//                   Text("No items found", style: TextStyle(color: subTextColor)),
//                 ],
//               ),
//             );
//           }
//
//           List items = snapshot.data!['data'];
//
//           return ListView.builder(
//             padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
//             itemCount: items.length,
//             itemBuilder: (context, index) {
//               return _buildProductCard(items[index]);
//             },
//           );
//         },
//       ),
//       // bottomNavigationBar: Container(
//       //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//       //   decoration: BoxDecoration(
//       //     color: AppColors.getScaffoldBg(context),
//       //     border: Border(top: BorderSide(color: AppColors.getBorderColor(context).withOpacity(0.1), width: 1.5)),
//       //   ),
//       //   child: SafeArea(
//       //     child: AppButton(
//       //       text: "FINALIZE BILL",
//       //       icon: Icons.done_all_rounded,
//       //       onPressed: () async {
//       //       SharedPreferences prefs = await SharedPreferences.getInstance();
//       //
//       //       await http.post(
//       //         Uri.parse(prefs.getString("ip").toString() + "/addFinalBill"),
//       //         body: {'id': prefs.getString("oid"), 'total': totalValue},
//       //       );
//       //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DistributorNavigationBar(initialIndex: 2,)));
//       //
//       //
//       //       },
//       //     ),
//       //   ),
//       // ),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//         decoration: BoxDecoration(
//           color: AppColors.getScaffoldBg(context),
//           border: Border(
//             top: BorderSide(
//                 color: AppColors.getBorderColor(context).withOpacity(0.1),
//                 width: 1.5
//             ),
//           ),
//         ),
//         child: SafeArea(
//           child: Row(
//             children: [
//               // LEFT SIDE: Total Value Text
//               Expanded(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Total Amount",
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Text(
//                       "₹$totalValue", // Assuming totalValue is your variable
//                       style: TextStyle(
//                         color: AppColors.getTextColor(context),
//                         fontSize: 20,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // RIGHT SIDE: Finalize Bill Button
//               SizedBox(
//                 width: 180, // Giving the button a fixed width so it doesn't take full screen
//                 child: AppButton(
//                   text: "FINALIZE",
//                   height: 48, // Using the new flexible height property
//                   icon: Icons.done_all_rounded,
//                   onPressed: () async {
//                     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//                     await http.post(
//                       Uri.parse(prefs.getString("ip").toString() + "/addFinalBill"),
//                       body: {
//                         'id': prefs.getString("oid"),
//                         'total': totalValue.toString()
//                       },
//                     );
//
//                     if (context.mounted) {
//                       Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => DistributorNavigationBar(initialIndex: 2)
//                           )
//                       );
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProductCard(Map item) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = AppColors.getTextColor(context);
//     final subTextColor = isDark ? Colors.white70 : Colors.grey[600];
//
//     return InkWell(
//       onTap:() => _openEditSheet(item),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: isDark ? Colors.grey[900] : Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: AppColors.getBorderColor(context).withOpacity(0.1), width: 1.5),
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(15),
//               child: Image.network(
//                 "$serverIp${item['image']}",
//                 height: 90, width: 90, fit: BoxFit.cover,
//                 errorBuilder: (c, e, s) => Container(height: 90, width: 90, color: Colors.grey[200], child: const Icon(Icons.image_not_supported_outlined)),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(item['product_name'].toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
//                   const SizedBox(height: 4),
//                   Text("Rate: ₹${item['amount']}", style: TextStyle(fontSize: 13, color: subTextColor)),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//                         child: Text("Qty: ${item['quantity']}", style: const TextStyle(color: Color(0xff23afda), fontWeight: FontWeight.bold, fontSize: 12)),
//                       ),
//                       const Spacer(),
//                       Text(
//                         "₹${(double.tryParse(item['amount'].toString()) ?? 0) * (double.tryParse(item['quantity'].toString()) ?? 0)}",
//                         style: TextStyle(
//                             fontSize: 14, // 🚀 Total amount font size set to 14
//                             fontWeight: FontWeight.w900,
//                             color: textColor
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Divider(height: 24),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       EditButton(onPressed: () => _openEditSheet(item)),
//                       const SizedBox(width: 12),
//                       DeleteButton(onPressed: () => _confirmDeletion(item)),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _confirmDeletion(Map item) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text("Delete Item?"),
//         content: Text("Remove ${item['product_name']}?"),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//           TextButton(
//             onPressed: () {
//               deleteItem(item['id'].toString());
//               Navigator.pop(context);
//             },
//             child: const Text("Remove", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _openEditSheet(Map item) {
//     TextEditingController qtyController = TextEditingController(text: item['quantity'].toString());
//     TextEditingController priceController = TextEditingController(text: item['amount'].toString());
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppColors.getScaffoldBg(context),
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
//       builder: (context) => Padding(
//         padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(context).viewInsets.bottom + 30),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Update Item Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
//             const SizedBox(height: 5),
//             Text("${item['product_name']}", style: const TextStyle(color: Colors.grey)),
//             const SizedBox(height: 25),
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("Price (₹)", style: TextStyle(fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 8),
//                       TextField(
//                         controller: priceController,
//                         keyboardType: TextInputType.number,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
//                           prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 18),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 15),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("Quantity (Max 100)", style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 8),
//                       TextField(
//                         controller: qtyController,
//                         keyboardType: TextInputType.number,
//                         maxLength: 3, // 🚀 Physically limits to 3 digits
//                         decoration: InputDecoration(
//                           counterText: "",
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
//                           prefixIcon: const Icon(Icons.shopping_basket_outlined, size: 18),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 30),
//             AppButton(
//               text: "SAVE UPDATES",
//               onPressed: () {
//                 int? qty = int.tryParse(qtyController.text);
//                 if (qty == null || qty <= 0) {
//                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter a valid quantity")));
//                 } else if (qty > 100) {
//                   // 🚀 Logic to restrict quantity above 100
//                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Quantity cannot exceed 100")));
//                 } else {
//                   updateItem(
//                     item['id'].toString(),
//                     qtyController.text.trim(),
//                     priceController.text.trim(),
//                   );
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated successfully")));
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/theme/colors.dart';
import 'package:snap2bill/widgets/app_button.dart';
import 'package:snap2bill/widgets/distributorNavigationbar.dart';
import '../../widgets/Navbar.dart';

class viewBillItems extends StatefulWidget {
  const viewBillItems({Key? key}) : super(key: key);

  @override
  State<viewBillItems> createState() => _viewBillItemsState();
}

class _viewBillItemsState extends State<viewBillItems> {
  late Future<Map<String, dynamic>> futureData;
  String totalValue = "0";
  String? serverIp;
  List<dynamic> _items = []; // Local list to manage total calculation

  @override
  void initState() {
    super.initState();
    futureData = fetchBillItems();
  }

  /// --- API FETCH LOGIC ---
  Future<Map<String, dynamic>> fetchBillItems() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    serverIp = sp.getString("ip") ?? "";
    String orderId = sp.getString("oid") ?? "";

    final res = await http.post(
      Uri.parse("$serverIp/view_distributor_ordersitems"),
      body: {"id": orderId},
    );

    if (res.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(res.body);

      // Update local list and calculate total after frame builds
      if (jsonData['data'] != null) {
        _items = jsonData['data'];
        _calculateLocalTotal();
      }

      return jsonData;
    } else {
      throw Exception("Failed to load items");
    }
  }

  /// --- CALCULATION LOGIC ---
  void _calculateLocalTotal() {
    double newTotal = 0;
    for (var item in _items) {
      // Handles both String and int/double from backend
      double price = double.tryParse(item['amount'].toString()) ?? 0;
      double qty = double.tryParse(item['quantity'].toString()) ?? 0;
      newTotal += (price * qty);
    }
    setState(() {
      totalValue = newTotal.toStringAsFixed(0);
    });
  }

  /// --- DELETE LOGIC ---
  Future<void> deleteItem(String id) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await http.post(
      Uri.parse("${sp.getString("ip")}/delete_order_item"),
      body: {'id': id},
    );
    // Refresh data from server
    setState(() {
      futureData = fetchBillItems();
    });
  }

  /// --- UPDATE LOGIC (Price & Quantity) ---
  Future<void> updateItem(String itemId, String qty, String price) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await http.post(
      Uri.parse("${sp.getString("ip")}/update_order_item"),
      body: {
        'id': itemId,
        'quantity': qty,
        'amount': price,
      },
    );
    // Refresh data from server to sync total from DB
    setState(() {
      futureData = fetchBillItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];

    return Scaffold(
      backgroundColor: AppColors.getScaffoldBg(context),
      appBar: ThemeNavbar(
        title: "Edit Bill Items",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!['data'] == null || snapshot.data!['data'].isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 70, color: subTextColor),
                  const SizedBox(height: 10),
                  Text("No items found", style: TextStyle(color: subTextColor)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return _buildProductCard(_items[index]);
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.getScaffoldBg(context),
          border: Border(top: BorderSide(color: AppColors.getBorderColor(context).withOpacity(0.1), width: 1.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Amount", style: TextStyle(color: subTextColor, fontSize: 12)),
                    Text(
                      "₹$totalValue",
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 160,
                child: AppButton(
                  text: "FINALIZE",
                  height: 48,
                  icon: Icons.done_all_rounded,
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await http.post(
                      Uri.parse(prefs.getString("ip").toString() + "/addFinalBill"),
                      body: {'id': prefs.getString("oid"), 'total': totalValue},
                    );
                    if (context.mounted) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => DistributorNavigationBar(initialIndex: 2))
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextColor(context);
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getBorderColor(context).withOpacity(0.1), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              "$serverIp${item['image']}",
              height: 90, width: 90, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(height: 90, width: 90, color: Colors.grey[200], child: const Icon(Icons.image_not_supported_outlined)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['product_name'].toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 4),
                Text("Rate: ₹${item['amount']}", style: TextStyle(fontSize: 13, color: subTextColor)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text("Qty: ${item['quantity']}", style: const TextStyle(color: Color(0xff23afda), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const Spacer(),
                    Text(
                      "₹${(double.tryParse(item['amount'].toString()) ?? 0) * (double.tryParse(item['quantity'].toString()) ?? 0)}",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textColor),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    EditButton(onPressed: () => _openEditSheet(item)),
                    const SizedBox(width: 12),
                    DeleteButton(onPressed: () => _confirmDeletion(item)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeletion(Map item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Item?"),
        content: Text("Remove ${item['product_name']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              deleteItem(item['id'].toString());
              Navigator.pop(context);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openEditSheet(Map item) {
    TextEditingController qtyController = TextEditingController(text: item['quantity'].toString());
    TextEditingController priceController = TextEditingController(text: item['amount'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.getScaffoldBg(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(context).viewInsets.bottom + 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Update Item Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Price (₹)", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        decoration: InputDecoration(
                          counterText: "",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          prefixIcon: const Icon(Icons.shopping_basket_outlined, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            AppButton(
              text: "SAVE UPDATES",
              onPressed: () {
                int? qty = int.tryParse(qtyController.text);
                if (qty != null && qty > 0 && qty <= 100) {
                  updateItem(item['id'].toString(), qtyController.text, priceController.text);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Quantity (1-100)")));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}