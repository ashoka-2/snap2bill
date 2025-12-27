// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
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
//
//   @override
//   void initState() {
//     super.initState();
//     futureData = fetchItems();
//   }
//
//   /// ---------------- API ----------------
//
//   Future<Map<String, dynamic>> fetchItems() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     String ip = sp.getString("ip")!;
//     String cid = sp.getString("id")!;
//
//     final res = await http.post(
//       Uri.parse("$ip/view_orders_items"),
//       body: {'cid': cid},
//     );
//
//     return json.decode(res.body);
//   }
//
//   Future<void> deleteItem(String id) async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     String ip = sp.getString("ip")!;
//
//     await http.post(
//       Uri.parse("$ip/delete_order_item"),
//       body: {'id': id},
//     );
//
//     setState(() {
//       futureData = fetchItems();
//     });
//   }
//
//   Future<void> updateItem(
//       String itemId, String stockId, String qty) async {
//
//     print(itemId);
//     print(stockId);
//     print(qty);
//
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     String ip = sp.getString("ip")!;
//
//     await http.post(
//       Uri.parse("$ip/update_order_item"),
//       body: {
//         'id': itemId,
//         'stock_id': stockId,
//         'quantity': qty,
//       },
//     );
//
//     setState(() {
//       futureData = fetchItems();
//     });
//   }
//
//   /// ---------------- EDIT SHEET ----------------
//
//   void openEditSheet(
//       BuildContext context, Map item, List stockList) {
//
//     /// ALL stock ids
//     final stockIds =
//     stockList.map((s) => s['id'].toString()).toList();
//
//     /// FIX: use stock_id (NOT order item id)
//     String? selectedStockId = stockIds.contains(item['stock_id'].toString())
//         ? item['stock_id'].toString()
//         : null;
//
//     TextEditingController qty =
//     TextEditingController(text: item['quantity'].toString());
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         return Padding(
//           padding: EdgeInsets.fromLTRB(
//             16,
//             16,
//             16,
//             MediaQuery.of(context).viewInsets.bottom + 16,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Edit Order Item",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//
//               const SizedBox(height: 16),
//
//               /// PRODUCT SELECT
//               DropdownButtonFormField<String>(
//                 value: selectedStockId,
//                 items: stockList.map<DropdownMenuItem<String>>((s) {
//                   return DropdownMenuItem(
//                     value: s['id'].toString(),
//                     child: Text(s['product_name']),
//                   );
//                 }).toList(),
//                 onChanged: (v) {
//                   selectedStockId = v!;
//                 },
//                 decoration: const InputDecoration(
//                   labelText: "Product",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               /// QUANTITY
//               TextField(
//                 controller: qty,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: "Quantity",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               /// UPDATE BUTTON
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     SharedPreferences prefs = await SharedPreferences.getInstance();
//                     if (selectedStockId != null) {
//                       updateItem(
//                         item['id'].toString(),
//                         selectedStockId!,
//                         qty.text,
//                       );
//                     }
//
//                     else{
//
//
//                       updateItem(
//                         item['id'].toString(),
//                         prefs.getString("sid").toString(),
//                         qty.text,
//                       );
//                     }
//                     Navigator.pop(context);
//                   },
//                   child: const Text("Update Item"),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   /// ---------------- UI ----------------
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Order Items"),
//         centerTitle: true,
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: futureData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || snapshot.data!['data'].isEmpty) {
//             return const Center(child: Text("No products in order"));
//           }
//
//           List items = snapshot.data!['data'];
//           List stockList = snapshot.data!['data2'];
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: items.length,
//             itemBuilder: (context, index) {
//               final item = items[index];
//
//               return Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Row(
//                     children: [
//                       /// IMAGE
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(
//                           item['image'],
//                           width: 70,
//                           height: 70,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) =>
//                           const Icon(Icons.image),
//                         ),
//                       ),
//
//                       const SizedBox(width: 12),
//
//                       /// DETAILS
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               item['product_name'],
//                               style: const TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text("₹${item['price']}"),
//                             Text("Qty: ${item['quantity']}"),
//                           ],
//                         ),
//                       ),
//
//                       /// ACTIONS
//                       Column(
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.edit, color: Colors.blue),
//                             onPressed: () async {
//                               SharedPreferences prefs = await SharedPreferences.getInstance();
//                               prefs.setString("sid", item['sid'].toString());
//                               openEditSheet(
//                                 context,
//                                 item,
//                                 stockList,
//                               );
//                             },
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () async {
//                               bool confirm = await showDialog(
//                                 context: context,
//                                 builder: (_) => AlertDialog(
//                                   title: const Text("Remove Product"),
//                                   content: const Text(
//                                       "Remove this product from order?"),
//                                   actions: [
//                                     TextButton(
//                                       onPressed: () =>
//                                           Navigator.pop(context, false),
//                                       child: const Text("Cancel"),
//                                     ),
//                                     TextButton(
//                                       onPressed: () {
//
//                                         deleteItem(item['id'].toString());
//                                         Navigator.pop(context, true);
//
//                                       },
//
//                                       child: const Text(
//                                         "Remove",
//                                         style: TextStyle(color: Colors.red),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//
//
//                             },
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewOrderItems extends StatefulWidget {
  const ViewOrderItems({Key? key}) : super(key: key);

  @override
  State<ViewOrderItems> createState() => _ViewOrderItemsState();
}

class _ViewOrderItemsState extends State<ViewOrderItems> {
  late Future<Map<String, dynamic>> futureData;
  String? serverIp;

  @override
  void initState() {
    super.initState();
    futureData = fetchItems();
  }

  /// ---------------- URL HELPER ----------------
  /// This ensures the image path is always a valid full URL
  String _getImageUrl(String path) {
    if (path.isEmpty || path == "null") return "";
    if (path.startsWith('http')) return path;

    // Ensure the path starts with a /
    String formattedPath = path.startsWith('/') ? path : '/$path';
    return (serverIp ?? "") + formattedPath;
  }

  /// ---------------- API LOGIC ----------------

  Future<Map<String, dynamic>> fetchItems() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    serverIp = sp.getString("ip") ?? "";
    String orderId = sp.getString("id") ?? "";

    final res = await http.post(
      Uri.parse("$serverIp/view_orders_items"),
      body: {'cid': orderId},
    );

    return json.decode(res.body);
  }

  Future<void> deleteItem(String id) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await http.post(
        Uri.parse("${sp.getString("ip")}/delete_order_item"),
        body: {'id': id}
    );
    setState(() { futureData = fetchItems(); });
  }

  Future<void> updateItem(String itemId, String stockId, String qty) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await http.post(
      Uri.parse("${sp.getString("ip")}/update_order_item"),
      body: {'id': itemId, 'stock_id': stockId, 'quantity': qty},
    );
    setState(() { futureData = fetchItems(); });
  }

  /// ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Order Details",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!['data'] == null || snapshot.data!['data'].isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("No products found in this order"),
                ],
              ),
            );
          }

          List items = snapshot.data!['data'];
          List stockList = snapshot.data!['data2'] ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildModernProductCard(item, stockList, theme, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildModernProductCard(Map item, List stockList, ThemeData theme, bool isDark) {
    // Construct the full image URL correctly
    String fullImageUrl = _getImageUrl(item['image'].toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          // PRODUCT IMAGE
          Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: isDark ? Colors.black26 : Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: fullImageUrl.isNotEmpty
                  ? Image.network(
                fullImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, color: Colors.grey);
                },
              )
                  : const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),

          // PRODUCT INFO
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['product_name'] ?? "Unknown Product",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text("Price: ₹${item['price']}",
                      style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600)
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Quantity: ${item['quantity']}",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.blue.shade700
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ACTIONS
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: Colors.blue),
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString("sid", item['sid'].toString());
                  _openEditSheet(context, item, stockList);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: () => _confirmDeletion(item),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  void _confirmDeletion(Map item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Item?"),
        content: Text("Do you want to remove ${item['product_name']} from this order?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              deleteItem(item['id'].toString());
              Navigator.pop(context);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _openEditSheet(BuildContext context, Map item, List stockList) {
    String? selectedStockId = item['sid'].toString();
    TextEditingController qtyController = TextEditingController(text: item['quantity'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Update Item", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedStockId,
              decoration: const InputDecoration(labelText: "Product", border: OutlineInputBorder()),
              items: stockList.map<DropdownMenuItem<String>>((s) {
                return DropdownMenuItem(value: s['id'].toString(), child: Text(s['product_name']));
              }).toList(),
              onChanged: (v) => selectedStockId = v,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  updateItem(item['id'].toString(), selectedStockId!, qtyController.text);
                  Navigator.pop(context);
                },
                child: const Text("Update Order"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}