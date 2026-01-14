//
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/theme/colors.dart';
// import 'package:snap2bill/widgets/app_button.dart';
// import '../../widgets/Navbar.dart';
// // 🚀 USING YOUR CUSTOM SNACKBAR
// import '../../widgets/SnackBar.dart';
//
// class ViewOrderItems extends StatefulWidget {
//   const ViewOrderItems({Key? key}) : super(key: key);
//
//   @override
//   State<ViewOrderItems> createState() => _ViewOrderItemsState();
// }
//
// class _ViewOrderItemsState extends State<ViewOrderItems> {
//   late Future<Map<String, dynamic>> futureData;
//   String? serverIp;
//   bool isPaid = false;
//
//   @override
//   void initState() {
//     super.initState();
//     futureData = fetchItems();
//     _checkPaymentStatus();
//   }
//
//   void _checkPaymentStatus() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     String status = sp.getString("order_payment_status") ?? "pending";
//     setState(() {
//       isPaid = (status.toLowerCase() == 'paid' ||
//           status.toLowerCase() == 'online' ||
//           status.toLowerCase() == 'offline' ||
//           status.toLowerCase() == 'delivered');
//     });
//   }
//
//   String _getImageUrl(String path) {
//     if (path.isEmpty || path == "null") return "";
//     if (path.startsWith('http')) return path;
//     return (serverIp ?? "") + (path.startsWith('/') ? path : '/$path');
//   }
//
//   Future<Map<String, dynamic>> fetchItems() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     serverIp = sp.getString("ip") ?? "";
//     String orderId = sp.getString("id") ?? "";
//     final res = await http.post(Uri.parse("$serverIp/view_orders_items"), body: {'oid': orderId});
//     return json.decode(res.body);
//   }
//
//   Future<void> deleteItem(String id) async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     await http.post(Uri.parse("${sp.getString("ip")}/delete_order_item"), body: {'id': id});
//     // 🚀 Custom SnackBar for Deletion
//     CustomSnackBar.show(context, "Item removed from order", backgroundColor: Colors.redAccent);
//     setState(() { futureData = fetchItems(); });
//   }
//
//   Future<void> updateItem(String itemId, String qty) async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     final res = await http.post(
//       Uri.parse("${sp.getString("ip")}/update_order_item"),
//       body: {
//         'id': itemId,
//         'quantity': qty,
//         'role': 'customer'
//       },
//     );
//
//     var js = json.decode(res.body);
//     if (js['status'] == 'ok') {
//       // 🚀 Custom SnackBar for Success
//       CustomSnackBar.show(context, "Quantity updated successfully", backgroundColor: Colors.green);
//       setState(() { futureData = fetchItems(); });
//     } else {
//       // 🚀 Custom SnackBar for Error
//       CustomSnackBar.show(context, js['message'] ?? "Error updating item", backgroundColor: Colors.red,durationMs: 1200);
//     }
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
//         title: "Order Items",
//         leadingIcon: Icons.arrow_back_ios_rounded,
//         onLeadingPressed: () => Navigator.pop(context),
//         centerTitle: true,
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: futureData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting)
//             return const Center(child: CircularProgressIndicator());
//
//           if (!snapshot.hasData || snapshot.data!['data'] == null || snapshot.data!['data'].isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.shopping_bag_outlined, size: 70, color: subTextColor),
//                   const SizedBox(height: 10),
//                   Text("No items found", style: TextStyle(color: subTextColor)),
//                 ],
//               ),
//             );
//           }
//
//           List items = snapshot.data!['data'];
//           return ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             itemCount: items.length,
//             itemBuilder: (context, index) => _buildItemCard(items[index]),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildItemCard(Map item) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = AppColors.getTextColor(context);
//     final subTextColor = isDark ? Colors.white70 : Colors.grey[600];
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isDark ? Colors.grey[900] : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.getBorderColor(context).withOpacity(0.1), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(15),
//             child: Image.network(
//               _getImageUrl(item['image'].toString()),
//               width: 90, height: 90, fit: BoxFit.cover,
//               errorBuilder: (c, e, s) => Container(
//                   width: 90, height: 90,
//                   color: isDark ? Colors.grey[800] : Colors.grey[200],
//                   child: const Icon(Icons.broken_image)
//               ),
//             ),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item['product_name'] ?? "Product",
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
//                   maxLines: 1, overflow: TextOverflow.ellipsis,
//                 ),
//                 Text("Price: ₹${item['price']}", style: TextStyle(color: subTextColor, fontSize: 13)),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//                       child: Text(
//                         "Qty: ${item['quantity']} ${item['unit_name'] ?? ''}",
//                         style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
//                       ),
//                     ),
//                     Text(
//                       "₹${(double.tryParse(item['price'].toString()) ?? 0) * (double.tryParse(item['quantity'].toString()) ?? 0)}",
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textColor),
//                     ),
//                   ],
//                 ),
//                 if (!isPaid) ...[
//                   const Divider(height: 24),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       EditButton(size: 40, onPressed: () => _openEditSheet(item)),
//                       const SizedBox(width: 12),
//                       DeleteButton(size: 40, onPressed: () => _confirmDeletion(item)),
//                     ],
//                   ),
//                 ]
//               ],
//             ),
//           ),
//         ],
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
//         content: Text("Remove ${item['product_name']} from your order?"),
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
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppColors.getScaffoldBg(context),
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
//       builder: (_) => Padding(
//         padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(context).viewInsets.bottom + 30),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Edit Quantity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
//             const SizedBox(height: 10),
//             Text(item['product_name'], style: const TextStyle(color: Colors.grey)),
//             const SizedBox(height: 20),
//             TextField(
//               controller: qtyController,
//               keyboardType: TextInputType.number,
//               maxLength: 3,
//               decoration: InputDecoration(
//                   counterText: "",
//                   labelText: "Quantity",
//                   suffixText: item['unit_name'] ?? "",
//                   suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
//                   prefixIcon: const Icon(Icons.shopping_basket_outlined)
//               ),
//             ),
//             const SizedBox(height: 30),
//             AppButton(
//               text: "UPDATE QUANTITY",
//               onPressed: () {
//                 int? qty = int.tryParse(qtyController.text);
//                 if (qty == null || qty <= 0 || qty > 100) {
//                   // 🚀 Close the sheet first so the SnackBar is visible on the main page
//                   Navigator.pop(context);
//
//                   // Delay slightly to ensure the sheet animation finishes
//                   Future.delayed(const Duration(milliseconds: 200), () {
//                     CustomSnackBar.show(context, "Enter a valid quantity (1-100)", backgroundColor: Colors.orange,durationMs: 2000);
//                   });
//                 } else {
//                   // 🚀 Close the sheet first
//                   Navigator.pop(context);
//                   CustomSnackBar.show(context, "Updated Successfully", backgroundColor: Colors.green,durationMs: 1000);
//
//                   // Then run the update
//                   updateItem(item['id'].toString(), qtyController.text);
//                 }
//               },
//             ),          ],
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
import '../../widgets/Navbar.dart';
import '../../widgets/SnackBar.dart';

class ViewOrderItems extends StatefulWidget {
  const ViewOrderItems({Key? key}) : super(key: key);

  @override
  State<ViewOrderItems> createState() => _ViewOrderItemsState();
}

class _ViewOrderItemsState extends State<ViewOrderItems> {
  // 🚀 Change 1: Maintain a local list for partial updates
  List<dynamic> _items = [];
  bool _isInitialLoading = true;
  String? serverIp;
  bool isPaid = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkPaymentStatus();
  }

  void _checkPaymentStatus() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String status = sp.getString("order_payment_status") ?? "pending";
    setState(() {
      isPaid = (status.toLowerCase() == 'paid' ||
          status.toLowerCase() == 'online' ||
          status.toLowerCase() == 'offline' ||
          status.toLowerCase() == 'delivered');
    });
  }

  // 🚀 Change 2: Initial data fetcher that populates the list
  Future<void> _loadData() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      serverIp = sp.getString("ip") ?? "";
      String orderId = sp.getString("id") ?? "";
      final res = await http.post(Uri.parse("$serverIp/view_orders_items"), body: {'oid': orderId});
      var js = json.decode(res.body);

      setState(() {
        _items = js['data'] ?? [];
        _isInitialLoading = false;
      });
    } catch (e) {
      setState(() => _isInitialLoading = false);
    }
  }

  String _getImageUrl(String path) {
    if (path.isEmpty || path == "null") return "";
    if (path.startsWith('http')) return path;
    return (serverIp ?? "") + (path.startsWith('/') ? path : '/$path');
  }

  // 🚀 Change 3: Optimized update that only targets a specific index
  Future<void> updateItem(int index, String qty) async {
    String itemId = _items[index]['id'].toString();

    // Store old qty in case API fails
    var oldQty = _items[index]['quantity'];

    // 🚀 Update local UI instantly
    setState(() {
      _items[index]['quantity'] = qty;
    });

    SharedPreferences sp = await SharedPreferences.getInstance();
    final res = await http.post(
      Uri.parse("${sp.getString("ip")}/update_order_item"),
      body: {'id': itemId, 'quantity': qty, 'role': 'customer'},
    );

    var js = json.decode(res.body);
    if (js['status'] == 'ok') {
      CustomSnackBar.show(context, "Quantity updated successfully", backgroundColor: Colors.green);
    } else {
      // 🚀 Revert back if server fails
      setState(() {
        _items[index]['quantity'] = oldQty;
      });
      CustomSnackBar.show(context, js['message'] ?? "Error updating item", backgroundColor: Colors.red);
    }
  }

  Future<void> deleteItem(int index) async {
    String id = _items[index]['id'].toString();
    SharedPreferences sp = await SharedPreferences.getInstance();
    await http.post(Uri.parse("${sp.getString("ip")}/delete_order_item"), body: {'id': id});

    CustomSnackBar.show(context, "Item removed", backgroundColor: Colors.redAccent);

    // 🚀 Partial update: Just remove from list
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];

    return Scaffold(
      backgroundColor: AppColors.getScaffoldBg(context),
      appBar: ThemeNavbar(
        title: "Order Items",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () => Navigator.pop(context),
        centerTitle: true,
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? Center(child: Text("No items found", style: TextStyle(color: subTextColor)))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: _items.length,
        itemBuilder: (context, index) => _buildItemCard(_items[index], index),
      ),
    );
  }

  Widget _buildItemCard(Map item, int index) {
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              _getImageUrl(item['image'].toString()),
              width: 90, height: 90, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(width: 90, height: 90, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['product_name'] ?? "Product", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                Text("Price: ₹${item['price']}", style: TextStyle(color: subTextColor, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        "Qty: ${item['quantity']} ${item['unit_name'] ?? ''}",
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Text(
                      "₹${(double.tryParse(item['price'].toString()) ?? 0) * (double.tryParse(item['quantity'].toString()) ?? 0)}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textColor),
                    ),
                  ],
                ),
                if (!isPaid) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      EditButton(size: 40, onPressed: () => _openEditSheet(item, index)),
                      const SizedBox(width: 12),
                      DeleteButton(size: 40, onPressed: () => _confirmDeletion(index)),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeletion(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () { deleteItem(index); Navigator.pop(context); }, child: const Text("Remove", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _openEditSheet(Map item, int index) {
    TextEditingController qtyController = TextEditingController(text: item['quantity'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.getScaffoldBg(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(context).viewInsets.bottom + 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Edit Quantity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Quantity (1-100)",
                suffixText: item['unit_name'] ?? "",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 30),
            AppButton(
              text: "UPDATE QUANTITY",
              onPressed: () {
                int? qty = int.tryParse(qtyController.text);
                if (qty == null || qty <= 0 || qty > 100) {
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    CustomSnackBar.show(context, "Invalid quantity", backgroundColor: Colors.orange);
                  });
                } else {
                  Navigator.pop(context);
                  CustomSnackBar.show(context, "Updating...", backgroundColor: Colors.blue, durationMs: 800);
                  // 🚀 Pass the index to update specifically
                  updateItem(index, qtyController.text);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}