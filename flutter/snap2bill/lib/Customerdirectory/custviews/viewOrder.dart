// // import 'dart:convert';
// //
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // import '../Edits/editOrder.dart';
// // import '../payment/RazorpayScreen.dart';
// //
// // class viewOrder extends StatelessWidget {
// //   const viewOrder({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return const viewOrder();
// //   }
// // }
// //
// // class viewOrder extends StatefulWidget {
// //   const viewOrder({Key? key}) : super(key: key);
// //
// //   @override
// //   State<viewOrder> createState() => _viewOrderState();
// // }
// //
// // class _viewOrderState extends State<viewOrder> {
// //   Future<List<Joke>> _getJokes() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     String b = prefs.getString("lid").toString();
// //     String foodimage = "";
// //     var data = await http.post(
// //       Uri.parse(prefs.getString("ip").toString() + "/view_orders"),
// //       body: {"orderid": prefs.getString("orderid").toString()},
// //       // body: {"cid":prefs.getString("cid").toString(),"uid":prefs.getString("uid").toString()}
// //     );
// //
// //     var jsonData = json.decode(data.body);
// //     //    print(jsonData);
// //     List<Joke> jokes = [];
// //     for (var joke in jsonData["data"]) {
// //       print(joke);
// //       Joke newJoke = Joke(
// //         joke["id"].toString(),
// //         joke["payment_status"].toString(),
// //         joke["payment_date"].toString(),
// //         joke["date"].toString(),
// //         joke["amount"].toString(),
// //         joke["username"].toString(),
// //         joke["distributor"].toString(),
// //         joke["orderid"].toString(),
// //       );
// //       jokes.add(newJoke);
// //     }
// //     return jokes;
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         centerTitle: true,
// //         leading: IconButton(
// //           icon: const Icon(
// //             Icons.arrow_back_ios_new,
// //             color: Colors.black87,
// //             size: 20,
// //           ),
// //           onPressed: () {
// //             if (Navigator.canPop(context)) Navigator.pop(context);
// //           },
// //         ),
// //         title: const Text(
// //           "Orders",
// //           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
// //         ),
// //       ),
// //       body: Container(
// //         child: FutureBuilder(
// //           future: _getJokes(),
// //           builder: (BuildContext context, AsyncSnapshot snapshot) {
// //             //              print("snapshot"+snapshot.toString());
// //             if (snapshot.data == null) {
// //               return Container(child: Center(child: Text("Loading...")));
// //             } else {
// //               return ListView.builder(
// //                 itemCount: snapshot.data.length,
// //                 itemBuilder: (BuildContext context, int index) {
// //                   var i = snapshot.data![index];
// //                   return Padding(
// //                     padding: const EdgeInsets.all(8.0),
// //                     child: Card(
// //                       elevation: 3,
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(10),
// //                         side: BorderSide(color: Colors.grey.shade300),
// //                       ),
// //                       child: Padding(
// //                         padding: const EdgeInsets.all(16.0),
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             SizedBox(height: 10),
// //                             _buildRow("ID", i.id.toString()),
// //
// //                             _buildRow(
// //                               "Distributor Name",
// //                               i.distributor.toString(),
// //                             ),
// //                             _buildRow(
// //                               "Payment Status:",
// //                               i.payment_status.toString(),
// //                             ),
// //                             _buildRow(
// //                               "Payment Date:",
// //                               i.payment_date.toString(),
// //                             ),
// //                             _buildRow("Date:", i.date.toString()),
// //                             _buildRow("Amount:", i.amount.toString()),
// //
// //                             Row(
// //                               children: [
// //                                 ElevatedButton(
// //                                   onPressed: () async {
// //                                     SharedPreferences sh =
// //                                         await SharedPreferences.getInstance();
// //                                     sh.setString("amount", i.amount.toString());
// //                                     sh.setString("id", i.id.toString());
// //
// //                                     Navigator.push(
// //                                       context,
// //                                       MaterialPageRoute(
// //                                         builder: (context) => RazorpayScreen(),
// //                                       ),
// //                                     );
// //                                   },
// //                                   child: Text("Make payment"),
// //                                 ),
// //                                 ElevatedButton(
// //                                   onPressed: () async {
// //                                     SharedPreferences sh =
// //                                         await SharedPreferences.getInstance();
// //                                     sh.setString("id", i.id.toString());
// //                                     var data = await http.post(
// //                                       Uri.parse(
// //                                         sh.getString("ip").toString() + "/edit_order",),
// //                                       body: {'id': sh.getString("id")},
// //                                     );
// //
// //                                     Navigator.push(
// //                                       context,
// //                                       MaterialPageRoute(
// //                                         builder: (context) => editOrder(),
// //                                       ),
// //                                     );
// //                                   },
// //                                   child: Text("Edit Order"),
// //                                 ),
// //
// //                                 ElevatedButton(
// //                                   onPressed: () async {
// //                                     SharedPreferences sh =
// //                                         await SharedPreferences.getInstance();
// //
// //                                     var data = await http.post(
// //                                       Uri.parse(
// //                                         sh.getString("ip").toString() + "/delete_order",),
// //                                       body: {
// //                                         "id": i.orderid.toString(),
// //                                       },
// //                                     );
// //                                     Navigator.push(context, MaterialPageRoute(builder: (context)=>viewOrder()));
// //                                   },
// //                                   child: Text("Delete Order"),
// //                                 ),
// //                               ],
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   );
// //                 },
// //               );
// //             }
// //           },
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 4),
// //       child: Row(
// //         children: [
// //           SizedBox(
// //             width: 100,
// //             child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
// //           ),
// //           SizedBox(width: 5),
// //           Flexible(
// //             child: Text(value, style: TextStyle(color: Colors.grey.shade800)),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class Joke {
// //   final String id;
// //   final String payment_status;
// //   final String payment_date;
// //   final String date;
// //   final String amount;
// //   final String username;
// //   final String distributor;
// //   final String orderid;
// //
// //   Joke(
// //     this.id,
// //     this.payment_status,
// //     this.payment_date,
// //     this.date,
// //     this.amount,
// //     this.username,
// //     this.distributor, this.orderid,
// //   );
// // }
//

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Customerdirectory/custviews/viewOrderitem.dart';
// import 'package:snap2bill/Customerdirectory/payment/RazorpayScreen.dart';
//
// class viewOrder extends StatelessWidget {
//   const viewOrder({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const viewOrder();
//   }
// }
//
// class viewOrder extends StatefulWidget {
//   const viewOrder({Key? key}) : super(key: key);
//
//   @override
//   State<viewOrder> createState() => _viewOrderState();
// }
//
// class _viewOrderState extends State<viewOrder> {
//
//   Timer? _timer;
//   Future<List<Joke>>? _ordersFuture;
//
//   // ---------------- API ----------------
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? ip = prefs.getString("ip");
//     String? cid = prefs.getString("cid");
//
//     if (ip == null || cid == null) return [];
//
//     try {
//       var response = await http.post(
//         Uri.parse("$ip/view_orders"),
//         body: {"cid": cid},
//       );
//
//       var jsonData = json.decode(response.body);
//       List<Joke> list = [];
//
//       if (jsonData["data"] != null) {
//         for (var item in jsonData["data"]) {
//           list.add(Joke(
//             item["id"].toString(),
//             item["payment_status"].toString(),
//             item["payment_date"].toString(),
//             item["date"].toString(),
//             item["amount"].toString(),
//             item["username"].toString(),
//             item["distributor"].toString(),
//             item["orderid"].toString(),
//           ));
//         }
//       }
//       return list;
//     } catch (e) {
//       debugPrint("API error: $e");
//       return [];
//     }
//   }
//
//   // ---------------- INIT ----------------
//   @override
//   void initState() {
//     super.initState();
//
//     _ordersFuture = _getJokes();
//
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (!mounted) return;
//       setState(() {
//         _ordersFuture = _getJokes();
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   // ---------------- UI ----------------
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("My Orders")),
//       body: FutureBuilder<List<Joke>>(
//         future: _ordersFuture,
//         builder: (context, snapshot) {
//
//           if (_ordersFuture == null) {
//             return const SizedBox();
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting &&
//               !snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           final items = snapshot.data ?? [];
//
//           if (items.isEmpty) {
//             return const Center(child: Text("No orders found"));
//           }
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: items.length,
//             itemBuilder: (context, index) {
//               return _buildCard(items[index]);
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   // ---------------- CARD ----------------
//   Widget _buildCard(Joke item) {
//
//     bool isPaid = item.payment_status.toLowerCase() == 'paid';
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Order ID: ${item.orderid}"),
//                 Text(item.payment_status.toUpperCase(),
//                     style: TextStyle(
//                         color: isPaid ? Colors.green : Colors.orange)),
//               ],
//             ),
//
//             const SizedBox(height: 10),
//
//             Text(item.distributor,
//                 style: const TextStyle(
//                     fontSize: 16, fontWeight: FontWeight.bold)),
//
//             const SizedBox(height: 8),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Sub ID: ${item.id}"),
//                 Text("₹${item.amount}",
//                     style: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold)),
//               ],
//             ),
//
//             const SizedBox(height: 12),
//
//             Row(
//               children: [
//
//                if(item.payment_status.toLowerCase() == "pending")...[
//                  Expanded(
//                    child: ElevatedButton(
//                      onPressed: isPaid ? null : () async {
//                        SharedPreferences sh =
//                        await SharedPreferences.getInstance();
//                        sh.setString("amount", item.amount);
//                        sh.setString("id", item.id);
//                        Navigator.push(context,
//                            MaterialPageRoute(builder: (_) => RazorpayScreen()));
//                      },
//                      child: Text(isPaid ? "Paid" : "Pay Now"),
//                    ),
//                  ),
//                ],
//
//                 const SizedBox(width: 10),
//
//                 IconButton(
//                   icon: const Icon(Icons.edit),
//                   onPressed: () async {
//                     SharedPreferences sh =
//                     await SharedPreferences.getInstance();
//                     sh.setString("id", item.id);
//                     Navigator.push(context,
//                         MaterialPageRoute(builder: (_) => ViewOrderItems()));
//                   },
//                 ),
//                 Container(
//                 decoration: BoxDecoration(
//                 color: Colors.red.withValues(alpha: 0.2),
//                 borderRadius: BorderRadius.circular(50)
//                 ),
//                 child: IconButton(
//                 icon: const Icon(Icons.delete_outline,color: Colors.red),
//                 onPressed: () async {
//                 SharedPreferences sh =
//                 await SharedPreferences.getInstance();
//                 var data = await http.post(Uri.parse(sh.getString("ip").toString() + "/delete_order",),
//                 body: {
//                 "id": item.id,
//                 },
//                 );
//                 },
//                 ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ---------------- MODEL ----------------
// class Joke {
//   final String id;
//   final String payment_status;
//   final String payment_date;
//   final String date;
//   final String amount;
//   final String username;
//   final String distributor;
//   final String orderid;
//
//   Joke(
//       this.id,
//       this.payment_status,
//       this.payment_date,
//       this.date,
//       this.amount,
//       this.username,
//       this.distributor,
//       this.orderid,
//       );
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Customerdirectory/custviews/viewOrderitem.dart';
import 'package:snap2bill/Customerdirectory/payment/RazorpayScreen.dart';
import 'package:snap2bill/widgets/CustomerNavigationBar.dart';



class viewOrder extends StatefulWidget {
  const viewOrder({Key? key}) : super(key: key);

  @override
  State<viewOrder> createState() => _viewOrderState();
}

class _viewOrderState extends State<viewOrder> {
  Timer? _timer;
  Future<List<Joke>>? _ordersFuture;

  // ---------------- API ----------------
  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString("ip");
    String? cid = prefs.getString("cid");

    // NEW: Check for Distributor Filter from the Distributor List Page
    String? did = prefs.getString("selected_distributor_id");

    if (ip == null || cid == null) return [];

    try {
      var response = await http.post(
        Uri.parse("$ip/view_orders"),
        body: {
          "cid": cid,
          "did": did ?? "", // Send filter if user clicked a specific distributor
        },
      );

      var jsonData = json.decode(response.body);
      List<Joke> list = [];

      if (jsonData["data"] != null) {
        for (var item in jsonData["data"]) {
          list.add(Joke(
            item["id"].toString(),
            item["payment_status"].toString(),
            item["payment_date"].toString(),
            item["date"].toString(),
            item["amount"].toString(),
            item["username"].toString(),
            item["distributor"].toString(),
            item["orderid"].toString(),
          ));
        }
      }
      return list;
    } catch (e) {
      debugPrint("API error: $e");
      return [];
    }
  }

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    _ordersFuture = _getJokes();
    // Keeps UI updated every second as per your original logic
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _ordersFuture = _getJokes();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF232323) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () async {
            // Clear the specific distributor filter so it doesn't "stick"
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove("selected_distributor_id");

            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Fallback if there is no route to pop (e.g., opened from notification)
              Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => const CustomerNavigationBar(initialIndex: 0)
              ));
            }
          },
        ),
        title: const Text(
          "My Orders", // You can also make this dynamic based on the filter
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),      body: FutureBuilder<List<Joke>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text("No orders found"));
          }

          return ListView.builder(

            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildCard(items[index], isDark);
            },
          );
        },
      ),
    );
  }

  // ---------------- CARD ----------------
  Widget _buildCard(Joke item, bool isDark) {
    bool isPaid = item.payment_status.toLowerCase() == 'paid' ||
        item.payment_status.toLowerCase() == 'online';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark?Colors.black45:Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Bill ID: ${item.orderid}",
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.payment_status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isPaid ? Colors.green[800] : Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.distributor,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Date: ${item.date}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Sub ID: ${item.id}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text("₹${item.amount}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Show Pay button only if pending
                if (item.payment_status.toLowerCase() == "pending")
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        SharedPreferences sh = await SharedPreferences.getInstance();
                        sh.setString("amount", item.amount);
                        sh.setString("id", item.id);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => RazorpayScreen()));
                      },
                      child: const Text("Pay Now", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                const SizedBox(width: 8),
                // Edit Button
                if (item.payment_status.toLowerCase() == "pending")
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    SharedPreferences sh = await SharedPreferences.getInstance();
                    sh.setString("id", item.id);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ViewOrderItems()));
                  },
                ),
                // Delete Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      SharedPreferences sh = await SharedPreferences.getInstance();
                      await http.post(
                        Uri.parse("${sh.getString("ip")}/delete_order"),
                        body: {"id": item.id},
                      );
                      // Timer will naturally pick up the change in 1 second
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- MODEL ----------------
class Joke {
  final String id;
  final String payment_status;
  final String payment_date;
  final String date;
  final String amount;
  final String username;
  final String distributor;
  final String orderid;

  Joke(this.id, this.payment_status, this.payment_date, this.date, this.amount, this.username, this.distributor, this.orderid);
}