// import 'package:flutter/material.dart';
//
//
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Distributordirectory/Editfolder/edit_product.dart';
//
// import '../Editfolder/editStock.dart';
// import '../addfolder/addStock.dart';
//
// class myProducts extends StatelessWidget {
//   const myProducts({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(home: myProductsSub());
//   }
// }
//
// class myProductsSub extends StatefulWidget {
//   const myProductsSub({Key? key}) : super(key: key);
//
//   @override
//   State<myProductsSub> createState() => _myProductsSubState();
// }
//
// class _myProductsSubState extends State<myProductsSub> {
//   Future<List<Joke>> _getProducts() async {
//     final prefs = await SharedPreferences.getInstance();
//     final base = prefs.getString("ip") ?? "";
//     final uid  = prefs.getString("uid"); // <-- distributor id you use
//
//     if (base.isEmpty) {
//       throw Exception("Missing base URL (ip).");
//     }
//     if (uid == null || uid.isEmpty) {
//       throw Exception("Missing distributor id (uid). Save it after login.");
//     }
//
//     final uri = Uri.parse("$base/distributor_products");
//     final res = await http.post(uri, body: {"uid": prefs.getString('uid').toString()}); // server expects 'id'
//
//     if (res.statusCode != 200) {
//       throw Exception("HTTP ${res.statusCode}: ${res.body}");
//     }
//
//     final js = json.decode(res.body);
//     if (js is! Map || js['status'] != 'ok' || js['data'] == null) {
//       final msg = (js is Map && js['message'] != null)
//           ? js['message'].toString()
//           : "Unexpected response: ${res.body}";
//       throw Exception(msg);
//     }
//
//     final List<Joke> out = [];
//     for (final it in (js['data'] as List)) {
//       out.add(Joke(
//         (it["id"] ?? "").toString(),
//         (it["product_name"] ?? "").toString(),
//         (it["price"] ?? "").toString(),
//         _joinUrl(base, (it["image"] ?? "").toString()),
//         (it["description"] ?? "").toString(),
//         (it["quantity"] ?? "").toString(),
//         (it["CATEGORY"] ?? "").toString(),
//         (it["CATEGORY_NAME"] ?? "").toString(),
//       ));
//     }
//     return out;
//   }
//
//   String _joinUrl(String base, String path) {
//     if (base.endsWith("/") && path.startsWith("/")) return base + path.substring(1);
//     if (!base.endsWith("/") && !path.startsWith("/")) return "$base/$path";
//     return base + path;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<List<Joke>>(
//         future: _getProducts(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text("Error: ${snapshot.error}",
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(color: Colors.red)),
//               ),
//             );
//           }
//           final items = snapshot.data ?? [];
//           if (items.isEmpty) {
//             return const Center(child: Text("No products found"));
//           }
//
//           return ListView.builder(
//             itemCount: items.length,
//             itemBuilder: (context, index) {
//               final i = items[index];
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Card(
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     side: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 10),
//                         i.image.trim().isEmpty
//                             ? const SizedBox(height: 100, width: 100)
//                             : Image.network(i.image, height: 100, width: 100, fit: BoxFit.cover),
//                         _buildRow("Name:", i.product_name),
//                         _buildRow("Price:", i.price),
//                         _buildRow("Description:", i.description),
//                         _buildRow("Quantity:", i.quantity),
//                         _buildRow("Category:", i.CATEGORY_NAME),
//                         const SizedBox(height: 10),
//                         Row(
//                           children: [
//
//                             ElevatedButton(
//                               onPressed: () async {
//                                 SharedPreferences prefs = await SharedPreferences.getInstance();
//                                 prefs.setString("pid", i.id);
//                                 Navigator.push(context, MaterialPageRoute(builder: (context)=>editStock(
//                                   id:i.id.toString(),
//                                   price:i.price.toString(),
//                                   quantity:i.quantity.toString(),
//
//                                 )));
//                               },
//                               child: const Text("Edit stock"),
//                             ),
//                             ElevatedButton(
//                               onPressed: () async {
//                                 SharedPreferences prefs = await SharedPreferences.getInstance();
//                                 var data = await http.post(
//                                     Uri.parse(prefs.getString("ip").toString()+"/delete_distributor_product/${i.id}"),
//                                     body: {
//                                       'id': prefs.getString("id").toString(),
//                                     }
//                                 );
//                                 Navigator.push(context, MaterialPageRoute(builder: (context)=>myProducts()));
//                               },
//
//                               child: const Text("Delete stock"),
//                             ),
//
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//
//
//
//
//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//           ),
//           const SizedBox(width: 5),
//           Flexible(child: Text(value, style: TextStyle(color: Colors.grey.shade800))),
//         ],
//       ),
//     );
//   }
// }
//
// class Joke {
//   final String id;
//   final String product_name;
//   final String price;
//   final String image;
//   final String description;
//   final String quantity;
//   final String CATEGORY;
//   final String CATEGORY_NAME;
//
//   Joke(
//       this.id,
//       this.product_name,
//       this.price,
//       this.image,
//       this.description,
//       this.quantity,
//       this.CATEGORY,
//       this.CATEGORY_NAME,
//       );
// }
//
//











// lib/Distributordirectory/view/myProducts.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// keep only editStock (as requested). NO addStock import.
import '../Editfolder/editStock.dart';

class myProducts extends StatelessWidget {
  const myProducts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const myProductsSub();
  }
}

class myProductsSub extends StatefulWidget {
  const myProductsSub({Key? key}) : super(key: key);

  @override
  State<myProductsSub> createState() => _myProductsSubState();
}

class _myProductsSubState extends State<myProductsSub> {
  bool _isDeleting = false;

  Future<List<Joke>> _getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final base = prefs.getString("ip") ?? "";
    final uid = prefs.getString("uid") ?? "";

    if (base.isEmpty || uid.isEmpty) return [];

    try {
      final uri = Uri.parse("$base/distributor_products");
      final res = await http.post(uri, body: {"uid": uid});

      if (res.statusCode != 200) return [];

      final js = json.decode(res.body);
      if (js is! Map || js['status'] != 'ok' || js['data'] == null) return [];

      final List<Joke> out = [];
      for (final it in (js['data'] as List)) {
        out.add(Joke(
          (it["id"] ?? "").toString(),
          (it["product_name"] ?? "").toString(),
          (it["price"] ?? "").toString(),
          _joinUrl(base, (it["image"] ?? "").toString()),
          (it["description"] ?? "").toString(),
          (it["quantity"] ?? "").toString(),
          (it["CATEGORY"] ?? "").toString(),
          (it["CATEGORY_NAME"] ?? "").toString(),
        ));
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  String _joinUrl(String base, String path) {
    final p = path.trim();
    if (p.isEmpty) return "";
    if (base.endsWith("/") && p.startsWith("/")) return base + p.substring(1);
    if (!base.endsWith("/") && !p.startsWith("/")) return "$base/$p";
    return base + p;
  }

  Future<void> _deleteProduct(String pid) async {
    if (_isDeleting) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final ip = prefs.getString("ip") ?? "";
      if (ip.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Server IP not configured.')));
        return;
      }

      final senderId = prefs.getString("id") ?? prefs.getString("uid") ?? "";
      final uri = Uri.parse("$ip/delete_distributor_product/$pid");
      final res = await http.post(uri, body: {'id': senderId});

      if (!mounted) return;

      if (res.statusCode == 200) {
        try {
          final js = json.decode(res.body);
          if (js is Map && js['status'] == 'ok') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted')));
            setState(() {}); // refresh list
          } else {
            // Treat 200 as success even if body differs
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted')));
            setState(() {});
          }
        } catch (_) {
          // Non-JSON but 200 -> success
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted')));
          setState(() {});
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server error: ${res.statusCode}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting product: $e')));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
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
          "Product List",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Joke>>(
        future: _getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[300], size: 50),
                    const SizedBox(height: 10),
                    const Text("Something went wrong", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text("No products found", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final i = items[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Image Section ---
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: (i.image.trim().isEmpty)
                              ? Container(height: 180, color: Colors.grey[200], child: const Center(child: Icon(Icons.image, color: Colors.grey)))
                              : Image.network(
                            i.image,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) => Container(height: 180, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
                          ),
                        ),
                        // Category Badge
                        Positioned(
                          top: 15,
                          left: 15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              i.CATEGORY_NAME.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // --- Details Section ---
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  i.product_name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue.shade100),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.layers, size: 14, color: Colors.blue[800]),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Qty: ${i.quantity}",
                                      style: TextStyle(color: Colors.blue[800], fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // ⭐⭐⭐ ADDED PRICE LINE ⭐⭐⭐
                          Text(
                            "₹ ${i.price}",
                            style: TextStyle(
                              color: Colors.indigo.shade700,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),




                          const SizedBox(height: 8),

                          Text(
                            i.description,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 20),
                          Divider(height: 1, color: Colors.grey[200]),
                          const SizedBox(height: 15),

                          // --- Action Row: Edit Stock + Delete ---
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setString("pid", i.id);
                                    if (!mounted) return;
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => editStock(
                                      id: i.id.toString(),
                                      price: i.price.toString(),
                                      quantity: i.quantity.toString(),
                                    )));
                                  },
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text("Edit Stock"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isDeleting ? null : () => _deleteProduct(i.id),
                                  child: _isDeleting ? const Text("Deleting...") : const Text("Delete", style: TextStyle(color: Colors.red)),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.red.shade200),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Joke {
  final String id;
  final String product_name;
  final String price;
  final String image;
  final String description;
  final String quantity;
  final String CATEGORY;
  final String CATEGORY_NAME;

  Joke(
      this.id,
      this.product_name,
      this.price,
      this.image,
      this.description,
      this.quantity,
      this.CATEGORY,
      this.CATEGORY_NAME,
      );
}
