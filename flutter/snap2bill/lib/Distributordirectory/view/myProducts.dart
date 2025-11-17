import 'package:flutter/material.dart';



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/Editfolder/edit_product.dart';

import '../Editfolder/editStock.dart';
import '../addfolder/addStock.dart';

class myProducts extends StatelessWidget {
  const myProducts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: myProductsSub());
  }
}

class myProductsSub extends StatefulWidget {
  const myProductsSub({Key? key}) : super(key: key);

  @override
  State<myProductsSub> createState() => _myProductsSubState();
}

class _myProductsSubState extends State<myProductsSub> {
  Future<List<Joke>> _getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final base = prefs.getString("ip") ?? "";
    final uid  = prefs.getString("uid"); // <-- distributor id you use

    if (base.isEmpty) {
      throw Exception("Missing base URL (ip).");
    }
    if (uid == null || uid.isEmpty) {
      throw Exception("Missing distributor id (uid). Save it after login.");
    }

    final uri = Uri.parse("$base/distributor_products");
    final res = await http.post(uri, body: {"uid": prefs.getString('uid').toString()}); // server expects 'id'

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final js = json.decode(res.body);
    if (js is! Map || js['status'] != 'ok' || js['data'] == null) {
      final msg = (js is Map && js['message'] != null)
          ? js['message'].toString()
          : "Unexpected response: ${res.body}";
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
    if (base.endsWith("/") && path.startsWith("/")) return base + path.substring(1);
    if (!base.endsWith("/") && !path.startsWith("/")) return "$base/$path";
    return base + path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Joke>>(
        future: _getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Error: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red)),
              ),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text("No products found"));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final i = items[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        i.image.trim().isEmpty
                            ? const SizedBox(height: 100, width: 100)
                            : Image.network(i.image, height: 100, width: 100, fit: BoxFit.cover),
                        _buildRow("Name:", i.product_name),
                        _buildRow("Price:", i.price),
                        _buildRow("Description:", i.description),
                        _buildRow("Quantity:", i.quantity),
                        _buildRow("Category:", i.CATEGORY_NAME),
                        const SizedBox(height: 10),
                        Row(
                          children: [

                            ElevatedButton(
                              onPressed: () async {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                prefs.setString("pid", i.id);
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>editStock()));


                              },
                              child: const Text("Edit stock"),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }





  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 5),
          Flexible(child: Text(value, style: TextStyle(color: Colors.grey.shade800))),
        ],
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
