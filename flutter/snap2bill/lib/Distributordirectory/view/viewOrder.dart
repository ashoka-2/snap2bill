// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
//
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
//
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String b = prefs.getString("lid").toString();
//     String foodimage="";
//     var data =
//     await http.post(Uri.parse(prefs.getString("ip").toString()+"/view_distributor_orders"),
//         body: {"uid":prefs.getString("uid").toString()}
//     );
//
//     var jsonData = json.decode(data.body);
// //    print(jsonData);
//     List<Joke> jokes = [];
//     for (var joke in jsonData["data"]) {
//       print(joke);
//       Joke newJoke = Joke(
//           joke["id"].toString(),
//           joke["payment_status"].toString(),
//           joke["payment_date"].toString(),
//         joke["date"].toString(),
//         joke["amount"].toString(),
//         joke["username"].toString(),
//         joke["distributor"].toString(),
//       );
//       jokes.add(newJoke);
//     }
//     return jokes;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
//           onPressed: () {
//             if (Navigator.canPop(context)) Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           "Orders",
//           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body:Container(
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
//                             _buildRow("ID", i.id.toString()),
//                             _buildRow("Customer Name", i.username.toString()),
//                             _buildRow("Payment Status:", i.payment_status.toString()),
//                             _buildRow("Payment Date:", i.payment_date.toString()),
//                             _buildRow("Date:", i.date.toString()),
//                             _buildRow("Amount:", i.amount.toString()),
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
//     );
//   }
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
// }
//
//
//
//
//
//
//
// class Joke {
//   final String id;
//   final String payment_status;
//   final String payment_date;
//   final String date;
//   final String amount;
//   final String username;
//   final String distributor;
//
//   Joke(
//       this.id,
//       this.payment_status,
//       this.payment_date,
//       this.date,
//       this.amount,
//       this.username,
//       this.distributor,
//       );
// }




import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<List<Joke>> _getOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString("ip");
    String? uid = prefs.getString("uid"); // Keeping your original logic

    if (ip == null || uid == null) return [];

    try {
      var data = await http.post(
          Uri.parse("$ip/view_distributor_orders"),
          body: {"uid": uid}
      );

      if (data.statusCode != 200) return [];

      var jsonData = json.decode(data.body);

      // Safety check if data is null
      if (jsonData["data"] == null) return [];

      List<Joke> orders = [];
      for (var item in jsonData["data"]) {
        Joke newOrder = Joke(
          item["id"].toString(),
          item["payment_status"].toString(),
          item["payment_date"].toString(),
          item["date"].toString(),
          item["amount"].toString(),
          item["username"].toString(),
          item["distributor"].toString(),
        );
        orders.add(newOrder);
      }
      return orders;
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme consistency variables
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = theme.cardColor;
    final hintColor = isDark ? Colors.white38 : Colors.grey[500];

    return Scaffold(
      backgroundColor: bgColor,
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
          "Orders",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Joke>>(
        future: _getOrders(),
        builder: (BuildContext context, AsyncSnapshot<List<Joke>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading orders", style: TextStyle(color: textColor)));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: hintColor),
                  const SizedBox(height: 16),
                  Text(
                    "No orders found",
                    style: TextStyle(color: hintColor, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildOrderCard(items[index], cardColor, textColor, hintColor!, isDark);
            },
          );
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID and Date
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

            // Body: Customer Name and Amount
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
                  child: const Icon(Icons.person, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 15),

                // Text Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.username,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Amount",
                        style: TextStyle(fontSize: 12, color: hintColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "₹${item.amount}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
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

            const SizedBox(height: 12),

            // Footer: Payment Details
            if (item.payment_date != "null" && item.payment_date.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(
                      "Payment Date: ${item.payment_date}",
                      style: TextStyle(fontSize: 12, color: hintColor),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Renamed 'Joke' to 'Joke' for clarity, but fields match your backend
class Joke {
  final String id;
  final String payment_status;
  final String payment_date;
  final String date;
  final String amount;
  final String username;
  final String distributor;

  Joke(
      this.id,
      this.payment_status,
      this.payment_date,
      this.date,
      this.amount,
      this.username,
      this.distributor,
      );
}