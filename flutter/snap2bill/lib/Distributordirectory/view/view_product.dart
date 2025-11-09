// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Distributordirectory/Editfolder/edit_product.dart';
//
//
// class view_product extends StatelessWidget {
//   const view_product({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: view_product_sub(),);
//   }
// }
//
// class view_product_sub extends StatefulWidget {
//   const view_product_sub({Key? key}) : super(key: key);
//
//   @override
//   State<view_product_sub> createState() => _view_product_subState();
// }
//
// class _view_product_subState extends State<view_product_sub> {
//
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String b = prefs.getString("lid").toString();
//     String foodimage="";
//     var data =
//     await http.post(Uri.parse(prefs.getString("ip").toString()+"/distributor_view_product"),
//         body: {"id":b}
//     );
//
//     var jsonData = json.decode(data.body);
// //    print(jsonData);
//     List<Joke> jokes = [];
//     for (var joke in jsonData["data"]) {
//       print(joke);
//       Joke newJoke = Joke(
//           joke["id"].toString(),
//           joke["product_name"],
//           joke["price"].toString(),
//           prefs.getString("ip").toString()+joke["image"].toString(),
//
//           joke["description"].toString(),
//           joke["quantity"].toString(),
//           (joke["CATEGORY"] ?? "").toString(),
//           (joke["CATEGORY_NAME"] ?? "").toString(),
//       );
//       jokes.add(newJoke);
//     }
//     return jokes;
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body:      Container(
//
//         child:
//         FutureBuilder(
//           future: _getJokes(),
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
// //              print("snapshot"+snapshot.toString());
//             if (snapshot.data == null) {
//               return Container(
//                 child: Center(
//                   child: Text("Loading..."),
//                 ),
//               );
//             } else {
//               return ListView.builder(
//                 itemCount: snapshot.data.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   var i = snapshot.data![index];
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Card(
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         side: BorderSide(color: Colors.grey.shade300),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//
//                             SizedBox(height: 10),
//                             Image.network(i.image.toString(),height: 100,width: 100,),
//                             _buildRow("Name:", i.product_name.toString()),
//                             _buildRow("Price:", i.price.toString()),
//                             _buildRow("Description:", i.description.toString()),
//                             _buildRow("Quantity:", i.quantity.toString()),
//                             _buildRow("Category:", i.CATEGORY_NAME.toString()),
//
//                             SizedBox(height: 10,),
//                             Row(children: [ElevatedButton(onPressed: (){
//
//                               Navigator.push(context, MaterialPageRoute(builder: (context)=>edit_product(
//                                 id:i.id.toString(),
//                                 product_name:i.product_name.toString(),
//                                 price:i.price.toString(),
//                                 description:i.description.toString(),
//                                 quantity:i.quantity.toString(),
//                                 category: i.CATEGORY.toString(),
//                                 category_name: i.CATEGORY_NAME.toString(),
//
//                               )));
//                             }, child: Text("Edit product"))],)
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//
//
//             }
//           },
//
//
//         ),
//
//
//
//
//
//       ),
//
//
//
//     );
//   }
//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           SizedBox(width: 5),
//           Flexible(
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: Colors.grey.shade800,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
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
//   Joke(this.id, this.product_name, this.price, this.image, this.description,
//       this.quantity, this.CATEGORY, this.CATEGORY_NAME);
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/Editfolder/edit_product.dart';

class view_product extends StatelessWidget {
  const view_product({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: view_product_sub());
  }
}

class view_product_sub extends StatefulWidget {
  const view_product_sub({Key? key}) : super(key: key);

  @override
  State<view_product_sub> createState() => _view_product_subState();
}

class _view_product_subState extends State<view_product_sub> {
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

    final uri = Uri.parse("$base/distributor_view_product");
    final res = await http.post(uri, body: {"id": uid}); // server expects 'id'

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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => edit_product(
                                      id: i.id,
                                      product_name: i.product_name,
                                      price: i.price,
                                      description: i.description,
                                      quantity: i.quantity,
                                      category: i.CATEGORY,
                                      category_name: i.CATEGORY_NAME,
                                    ),
                                  ),
                                ).then((_) => setState(() {})); // refresh on return
                              },
                              child: const Text("Edit product"),
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
