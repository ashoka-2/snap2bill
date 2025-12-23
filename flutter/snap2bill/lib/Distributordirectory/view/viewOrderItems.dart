


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class viewOrderItems extends StatelessWidget {
  const viewOrderItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const viewOrderItemsSub();
  }
}

class viewOrderItemsSub extends StatefulWidget {
  const viewOrderItemsSub({Key? key}) : super(key: key);

  @override
  State<viewOrderItemsSub> createState() => _viewOrderItemsSubState();
}

class _viewOrderItemsSubState extends State<viewOrderItemsSub> {

  Future<List<Joke>> _getOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString("ip");
    String? uid = prefs.getString("uid"); // Keeping your original logic

    if (ip == null || uid == null) return [];

    try {
      var data = await http.post(
          Uri.parse("$ip/view_distributor_ordersitems"),
          body: {"uid": uid,
          "id":prefs.getString("id"),
          }
      );

      if (data.statusCode != 200) return [];

      var jsonData = json.decode(data.body);

      // Safety check if data is null
      if (jsonData["data"] == null) return [];

      List<Joke> orders = [];
      for (var item in jsonData["data"]) {
        Joke newOrder = Joke(
          item["id"].toString(),
          // item["payment_status"].toString(),
          item["payment_date"] == null || item["payment_date"] == "null" ? "Pending" : item["payment_date"].toString(),
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
    // bool isPaid = item.payment_status.toLowerCase() == 'paid';
    // Color statusColor = isPaid ? Colors.green : Colors.orange;
    // String statusText = item.payment_status.toUpperCase();

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

              ],
            ),

            const SizedBox(height: 12),


          ],
        ),
      ),
    );
  }
}

// Renamed 'Joke' to 'Joke' for clarity, but fields match your backend
class Joke {
  final String id;
  // final String payment_status;
  final String payment_date;
  final String date;
  final String amount;
  final String username;
  final String distributor;

  Joke(
      this.id,
      // this.payment_status,
      this.payment_date,
      this.date,
      this.amount,
      this.username,
      this.distributor,
      );
}