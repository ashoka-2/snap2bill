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
// //     return const viewOrderSub();
// //   }
// // }
// //
// // class viewOrderSub extends StatefulWidget {
// //   const viewOrderSub({Key? key}) : super(key: key);
// //
// //   @override
// //   State<viewOrderSub> createState() => _viewOrderSubState();
// // }
// //
// // class _viewOrderSubState extends State<viewOrderSub> {
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
// //                                     Navigator.push(context, MaterialPageRoute(builder: (context)=>viewOrderSub()));
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

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Customerdirectory/custviews/viewOrderitem.dart';
import 'package:snap2bill/Customerdirectory/payment/RazorpayScreen.dart';

class viewOrder extends StatelessWidget {
  const viewOrder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const viewOrderSub();
  }
}

class viewOrderSub extends StatefulWidget {
  const viewOrderSub({Key? key}) : super(key: key);

  @override
  State<viewOrderSub> createState() => _viewOrderSubState();
}

class _viewOrderSubState extends State<viewOrderSub> {

  Timer? _timer;
  Future<List<Joke>>? _ordersFuture;

  // ---------------- API ----------------
  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString("ip");
    String? cid = prefs.getString("cid");

    if (ip == null || cid == null) return [];

    try {
      var response = await http.post(
        Uri.parse("$ip/view_orders"),
        body: {"cid": cid},
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

    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: FutureBuilder<List<Joke>>(
        future: _ordersFuture,
        builder: (context, snapshot) {

          if (_ordersFuture == null) {
            return const SizedBox();
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
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
              return _buildCard(items[index]);
            },
          );
        },
      ),
    );
  }

  // ---------------- CARD ----------------
  Widget _buildCard(Joke item) {

    bool isPaid = item.payment_status.toLowerCase() == 'paid';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order ID: ${item.orderid}"),
                Text(item.payment_status.toUpperCase(),
                    style: TextStyle(
                        color: isPaid ? Colors.green : Colors.orange)),
              ],
            ),

            const SizedBox(height: 10),

            Text(item.distributor,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Sub ID: ${item.id}"),
                Text("₹${item.amount}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [

               if(item.payment_status.toLowerCase() == "pending")...[
                 Expanded(
                   child: ElevatedButton(
                     onPressed: isPaid ? null : () async {
                       SharedPreferences sh =
                       await SharedPreferences.getInstance();
                       sh.setString("amount", item.amount);
                       sh.setString("id", item.id);
                       Navigator.push(context,
                           MaterialPageRoute(builder: (_) => RazorpayScreen()));
                     },
                     child: Text(isPaid ? "Paid" : "Pay Now"),
                   ),
                 ),
               ],

                const SizedBox(width: 10),

                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    SharedPreferences sh =
                    await SharedPreferences.getInstance();
                    sh.setString("id", item.id);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ViewOrderItems()));
                  },
                ),
                Container(
                decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(50)
                ),
                child: IconButton(
                icon: const Icon(Icons.delete_outline,color: Colors.red),
                onPressed: () async {
                SharedPreferences sh =
                await SharedPreferences.getInstance();
                var data = await http.post(Uri.parse(sh.getString("ip").toString() + "/delete_order",),
                body: {
                "id": item.id,
                },
                );
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

  Joke(
      this.id,
      this.payment_status,
      this.payment_date,
      this.date,
      this.amount,
      this.username,
      this.distributor,
      this.orderid,
      );
}
