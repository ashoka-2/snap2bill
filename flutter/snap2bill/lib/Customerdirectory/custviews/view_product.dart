// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
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
//     await http.post(Uri.parse(prefs.getString("ip").toString()+"/customer_view_products"),
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
//           joke["distributor_name"].toString()
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
//                             _buildRow("Distributor Name:", i.distributor_name.toString()),
//                             _buildRow("Name:", i.product_name.toString()),
//                             _buildRow("Price:", i.price.toString()),
//                             _buildRow("Description:", i.description.toString()),
//                             _buildRow("Quantity:", i.quantity.toString()),
//                             _buildRow("Category:", i.CATEGORY_NAME.toString()),
//
//                             SizedBox(height: 10,),
//                             ElevatedButton(onPressed: (){
//
//                             }, child: Text("add to cart"))
//
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
//   final String distributor_name;
//   Joke(this.id, this.product_name, this.price, this.image, this.description,
//       this.quantity, this.CATEGORY, this.CATEGORY_NAME, this.distributor_name);
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Customerdirectory/Customersends/addToCart.dart';

class view_product extends StatelessWidget {
  const view_product({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FIX: Removed MaterialApp here.
    // This allows the page to use the navigation history of your main app.
    return const view_product_sub();
  }
}

class view_product_sub extends StatefulWidget {
  const view_product_sub({Key? key}) : super(key: key);

  @override
  State<view_product_sub> createState() => _view_product_subState();
}

class _view_product_subState extends State<view_product_sub> {
  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String b = prefs.getString("lid").toString();

    // Safety check for null IP
    String ip = prefs.getString("ip") ?? "";
    if (ip.isEmpty) return [];

    var data = await http.post(
        Uri.parse(ip + "/customer_view_products"),
        body: {"id": b});

    var jsonData = json.decode(data.body);
    List<Joke> jokes = [];
    for (var joke in jsonData["data"]) {
      Joke newJoke = Joke(
          joke["id"].toString(),
          joke["product_name"],
          joke["price"].toString(),
          ip + joke["image"].toString(),
          joke["description"].toString(),
          joke["quantity"].toString(),
          (joke["CATEGORY"] ?? "").toString(),
          (joke["CATEGORY_NAME"] ?? "").toString(),
          joke["distributor_name"].toString());
      jokes.add(newJoke);
    }
    return jokes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // --- BACK BUTTON (Fixed) ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () {
            // Simply pop the current page off the stack
            Navigator.pop(context);
          },
        ),
        // ---------------------------
        title: const Text(
          "Our Products",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black87),
            onPressed: () {},
          )
        ],
      ),
      body: FutureBuilder(
        future: _getJokes(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          } else if (snapshot.data == null || snapshot.data.isEmpty) {
            return Center(child: Text("No products found"));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                var i = snapshot.data![index];
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
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                            child: Image.network(
                              i.image.toString(),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Center(
                                      child: Icon(Icons.image_not_supported,
                                          color: Colors.grey, size: 50)),
                                );
                              },
                            ),
                          ),
                          // Category Chip
                          Positioned(
                            top: 15,
                            left: 15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                i.CATEGORY_NAME.toString().toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
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
                                    "Seller: ${i.distributor_name}",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green.shade100),
                                  ),
                                  child: Text(
                                    "${i.quantity} Left",
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            Text(
                              i.product_name.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),

                            Text(
                              "₹${i.price}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.indigo[700],
                              ),
                            ),
                            const SizedBox(height: 12),

                            Text(
                              i.description.toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                height: 1.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(onPressed: () async {

                            }, child: Text("Add product"))
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
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
  final String distributor_name;
  Joke(this.id, this.product_name, this.price, this.image, this.description,
      this.quantity, this.CATEGORY, this.CATEGORY_NAME, this.distributor_name);
}




