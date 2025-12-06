import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Imports from your project structure
import 'package:snap2bill/Distributordirectory/Editfolder/edit_product.dart';
import '../Editfolder/editStock.dart';
import '../addfolder/addStock.dart'; // Keeping this if you need it, based on your imports

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

  // --- API LOGIC ---
  Future<List<Joke>> _getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final base = prefs.getString("ip") ?? "";
    final uid = prefs.getString("uid");

    if (base.isEmpty) throw Exception("Missing base URL (ip).");
    if (uid == null || uid.isEmpty) throw Exception("Missing distributor id (uid).");

    final uri = Uri.parse("$base/distributor_products");
    final res = await http.post(uri, body: {"uid": uid});

    if (res.statusCode != 200) throw Exception("HTTP ${res.statusCode}: ${res.body}");

    final js = json.decode(res.body);
    if (js is! Map || js['status'] != 'ok' || js['data'] == null) {
      final msg = (js is Map && js['message'] != null) ? js['message'].toString() : "Unexpected response";
      throw Exception(msg);
    }

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
  }

  String _joinUrl(String base, String path) {
    if (path.isEmpty) return "";
    if (base.endsWith("/") && path.startsWith("/")) return base + path.substring(1);
    if (!base.endsWith("/") && !path.startsWith("/")) return "$base/$path";
    return base + path;
  }

  Future<void> _deleteProduct(String pid) async {
    if (_isDeleting) return;

    // Confirmation Dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final ip = prefs.getString("ip") ?? "";
      final senderId = prefs.getString("id") ?? prefs.getString("uid") ?? "";

      final uri = Uri.parse("$ip/delete_distributor_product/$pid");
      final res = await http.post(uri, body: {'id': senderId});

      if (res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted successfully')));
        setState(() {}); // Refresh UI
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if(mounted) setState(() => _isDeleting = false);
    }
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Instagram-like clean white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          "My Products",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Joke>>(
        future: _getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No products found"),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            padding: const EdgeInsets.only(bottom: 20),
            itemBuilder: (context, index) {
              final i = items[index];
              return _buildInstagramCard(i);
            },
          );
        },
      ),
    );
  }

  Widget _buildInstagramCard(Joke i) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. HEADER (Category + Name + 3 Dots)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                radius: 16,
                child: Icon(Icons.category, size: 16, color: Colors.blue.shade800),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i.product_name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      i.CATEGORY_NAME,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // 3-DOT MENU
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'edit') {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString("pid", i.id);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>editStock(
                      id:i.id.toString(),
                      price:i.price.toString(),
                      quantity:i.quantity.toString(),
                    )));
                  } else if (value == 'delete') {
                    _deleteProduct(i.id);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text('Edit Stock')],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Delete Product')],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. IMAGE
        Container(
          height: 300,
          width: double.infinity,
          color: Colors.grey.shade100,
          child: i.image.isEmpty
              ? const Center(child: Icon(Icons.image_not_supported, color: Colors.grey))
              : Image.network(
            i.image,
            fit: BoxFit.cover,
            errorBuilder: (c,o,s) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
          ),
        ),

        // 3. ACTION BAR (Price & Add to Bill)
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Price and Stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "₹ ${i.price}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87),
                  ),
                  Text(
                    "Available: ${i.quantity}",
                    style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Spacer(),
              // PRIMARY ACTION: ADD TO BILL
              ElevatedButton.icon(
                onPressed: () {
                  // Add to bill logic
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to bill (Logic pending)")));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700, // Instagram-like action color
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.receipt_long, size: 18),
                label: const Text("Add to Bill"),
              ),
            ],
          ),
        ),

        // 4. CAPTION / DESCRIPTION
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                const TextSpan(text: "Description: ", style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: i.description),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Divider(height: 1), // Separator between posts
      ],
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