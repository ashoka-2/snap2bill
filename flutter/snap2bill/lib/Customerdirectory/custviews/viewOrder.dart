// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../Edits/editOrder.dart';
// import '../payment/RazorpayScreen.dart';
//
// class viewOrder extends StatelessWidget {
//   const viewOrder({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const viewOrderSub();
//   }
// }
//
// class viewOrderSub extends StatefulWidget {
//   const viewOrderSub({Key? key}) : super(key: key);
//
//   @override
//   State<viewOrderSub> createState() => _viewOrderSubState();
// }
//
// class _viewOrderSubState extends State<viewOrderSub> {
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String b = prefs.getString("lid").toString();
//     String foodimage = "";
//     var data = await http.post(
//       Uri.parse(prefs.getString("ip").toString() + "/view_orders"),
//       body: {"orderid": prefs.getString("orderid").toString()},
//       // body: {"cid":prefs.getString("cid").toString(),"uid":prefs.getString("uid").toString()}
//     );
//
//     var jsonData = json.decode(data.body);
//     //    print(jsonData);
//     List<Joke> jokes = [];
//     for (var joke in jsonData["data"]) {
//       print(joke);
//       Joke newJoke = Joke(
//         joke["id"].toString(),
//         joke["payment_status"].toString(),
//         joke["payment_date"].toString(),
//         joke["date"].toString(),
//         joke["amount"].toString(),
//         joke["username"].toString(),
//         joke["distributor"].toString(),
//         joke["orderid"].toString(),
//       );
//       jokes.add(newJoke);
//     }
//     return jokes;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_new,
//             color: Colors.black87,
//             size: 20,
//           ),
//           onPressed: () {
//             if (Navigator.canPop(context)) Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           "Orders",
//           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: Container(
//         child: FutureBuilder(
//           future: _getJokes(),
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             //              print("snapshot"+snapshot.toString());
//             if (snapshot.data == null) {
//               return Container(child: Center(child: Text("Loading...")));
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
//                             SizedBox(height: 10),
//                             _buildRow("ID", i.id.toString()),
//
//                             _buildRow(
//                               "Distributor Name",
//                               i.distributor.toString(),
//                             ),
//                             _buildRow(
//                               "Payment Status:",
//                               i.payment_status.toString(),
//                             ),
//                             _buildRow(
//                               "Payment Date:",
//                               i.payment_date.toString(),
//                             ),
//                             _buildRow("Date:", i.date.toString()),
//                             _buildRow("Amount:", i.amount.toString()),
//
//                             Row(
//                               children: [
//                                 ElevatedButton(
//                                   onPressed: () async {
//                                     SharedPreferences sh =
//                                         await SharedPreferences.getInstance();
//                                     sh.setString("amount", i.amount.toString());
//                                     sh.setString("id", i.id.toString());
//
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => RazorpayScreen(),
//                                       ),
//                                     );
//                                   },
//                                   child: Text("Make payment"),
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () async {
//                                     SharedPreferences sh =
//                                         await SharedPreferences.getInstance();
//                                     sh.setString("id", i.id.toString());
//                                     var data = await http.post(
//                                       Uri.parse(
//                                         sh.getString("ip").toString() + "/edit_order",),
//                                       body: {'id': sh.getString("id")},
//                                     );
//
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => editOrder(),
//                                       ),
//                                     );
//                                   },
//                                   child: Text("Edit Order"),
//                                 ),
//
//                                 ElevatedButton(
//                                   onPressed: () async {
//                                     SharedPreferences sh =
//                                         await SharedPreferences.getInstance();
//
//                                     var data = await http.post(
//                                       Uri.parse(
//                                         sh.getString("ip").toString() + "/delete_order",),
//                                       body: {
//                                         "id": i.orderid.toString(),
//                                       },
//                                     );
//                                     Navigator.push(context, MaterialPageRoute(builder: (context)=>viewOrderSub()));
//                                   },
//                                   child: Text("Delete Order"),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//           SizedBox(width: 5),
//           Flexible(
//             child: Text(value, style: TextStyle(color: Colors.grey.shade800)),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
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
//     this.id,
//     this.payment_status,
//     this.payment_date,
//     this.date,
//     this.amount,
//     this.username,
//     this.distributor, this.orderid,
//   );
// }



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Keeping your original imports
import '../Edits/editOrder.dart';
import '../payment/RazorpayScreen.dart';

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

  // --- API Logic (Kept exactly as yours) ---
  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Using the logic from your Customer side code
    var data = await http.post(
      Uri.parse(prefs.getString("ip").toString() + "/view_orders"),
      body: {"orderid": prefs.getString("orderid").toString()},
    );

    var jsonData = json.decode(data.body);
    List<Joke> jokes = [];

    if (jsonData["data"] != null) {
      for (var joke in jsonData["data"]) {
        Joke newJoke = Joke(
          joke["id"].toString(),
          joke["payment_status"].toString(),
          joke["payment_date"].toString(),
          joke["date"].toString(),
          joke["amount"].toString(),
          joke["username"].toString(),
          joke["distributor"].toString(),
          joke["orderid"].toString(),
        );
        jokes.add(newJoke);
      }
    }
    return jokes;
  }

  @override
  Widget build(BuildContext context) {
    // Theme consistency variables
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor; // Or Colors.grey[50] for consistency
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = theme.cardColor;
    final hintColor = isDark ? Colors.white38 : Colors.grey[500];

    return Scaffold(
      backgroundColor: isDark ? bgColor : Colors.grey[50], // Light grey background for card pop
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          "My Orders",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Joke>>(
        future: _getJokes(),
        builder: (BuildContext context, AsyncSnapshot<List<Joke>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: hintColor),
                  const SizedBox(height: 16),
                  Text(
                    "No orders found",
                    style: TextStyle(color: hintColor, fontSize: 16),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                var item = snapshot.data![index];
                return _buildOrderCard(item, cardColor, textColor, hintColor!, isDark);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildOrderCard(Joke item, Color cardColor, Color textColor, Color hintColor, bool isDark) {
    // Logic for Status Color
    bool isPaid = item.payment_status.toLowerCase() == 'paid';
    Color statusColor = isPaid ? Colors.green : Colors.orange;
    String statusText = item.payment_status.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: ID and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${item.id}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: hintColor,
                  ),
                ),
                Text(
                  item.date,
                  style: TextStyle(fontSize: 12, color: hintColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.withOpacity(0.1), thickness: 1),
            const SizedBox(height: 12),

            // 2. Body: Distributor Name and Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 15),

                // Text Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.distributor, // Displaying Distributor Name
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Distributor",
                        style: TextStyle(fontSize: 12, color: hintColor),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 3. Amount and Payment Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Amount", style: TextStyle(fontSize: 11, color: hintColor)),
                    const SizedBox(height: 2),
                    Text(
                      "₹${item.amount}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700, // Highlight color
                      ),
                    ),
                  ],
                ),
                if (item.payment_date != "null" && item.payment_date.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Paid On", style: TextStyle(fontSize: 11, color: hintColor)),
                      const SizedBox(height: 2),
                      Text(
                        item.payment_date,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // 4. Action Buttons (Pay, Edit, Delete)
            // Using a Row with custom button designs to match the theme
            Row(
              children: [
                // PAY BUTTON
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () async {
                      SharedPreferences sh = await SharedPreferences.getInstance();
                      sh.setString("amount", item.amount.toString());
                      sh.setString("id", item.id.toString());
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RazorpayScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Pay Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(width: 10),

                // EDIT BUTTON
                InkWell(
                  onTap: () async {
                    SharedPreferences sh = await SharedPreferences.getInstance();
                    sh.setString("id", item.id.toString());
                    await http.post(
                      Uri.parse(sh.getString("ip").toString() + "/edit_order"),
                      body: {'id': sh.getString("id")},
                    );
                    Navigator.push(context, MaterialPageRoute(builder: (context) => editOrder()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.edit, color: Colors.blueGrey, size: 20),
                  ),
                ),

                const SizedBox(width: 10),

                // DELETE BUTTON
                InkWell(
                  onTap: () async {
                    // Added a confirmation dialog for better UX
                    bool confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Order"),
                          content: const Text("Are you sure?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                          ],
                        )
                    ) ?? false;

                    if (confirm) {
                      SharedPreferences sh = await SharedPreferences.getInstance();
                      await http.post(
                        Uri.parse(sh.getString("ip").toString() + "/delete_order"),
                        body: {"id": item.orderid.toString()},
                      );
                      // Reload page
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const viewOrderSub()));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delete_outline, color: Colors.red, size: 20),
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

// Model Class - Kept names exact
class Joke {
  final String id;
  final String payment_status;
  final String payment_date;
  final String date;
  final String amount;
  final String username;
  final String distributor;
  final String orderid; // Included orderid as per your customer logic

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