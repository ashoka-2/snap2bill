
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/view/viewOrderItems.dart';

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

  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("ip").toString();
    String uid = prefs.getString("uid").toString();

    // Check if we are filtering by a specific customer
    String? cid = prefs.getString("selected_customer_id");

    var data = await http.post(
      Uri.parse("$ip/view_distributor_orders"),
      body: {
        "uid": uid,
        "cid": cid ?? "", // Pass customer ID if it exists, otherwise empty
      },
    );

    var jsonData = json.decode(data.body);
    List<Joke> jokes = [];

    if (jsonData["status"] == "ok") {
      for (var joke in jsonData["data"]) {
        Joke newJoke = Joke(
          joke["id"].toString(),
          joke["payment_status"].toString(),
          joke["payment_date"].toString(),
          joke["date"].toString(),
          joke["amount"].toString(),
          joke["username"].toString(),
          joke["distributor"] ?? "",
        );
        jokes.add(newJoke);
      }
    }
    return jokes;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () async {
            // Clear the specific customer filter when leaving the page
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove("selected_customer_id");

            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          "Order History",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Joke>>(
        future: _getJokes(),
        builder: (BuildContext context, AsyncSnapshot<List<Joke>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late_outlined, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text("No orders found", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              var item = snapshot.data![index];
              return _buildModernOrderCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildModernOrderCard(Joke item) {
    bool isPending = item.payment_status.toLowerCase() == "pending";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("id", item.id);
          Navigator.push(context, MaterialPageRoute(builder: (context) => const viewOrderItems()));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order ID and Status Chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #${item.id}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.payment_status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPending ? Colors.orange[800] : Colors.green[800],
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),

              // Body Details
              _buildInfoRow(Icons.person_outline, "Customer", item.username),
              _buildInfoRow(Icons.calendar_today_outlined, "Order Date", item.date),
              _buildInfoRow(Icons.payments_outlined, "Payment Date",
                  item.payment_date == "None" || item.payment_date == "null" ? "---" : item.payment_date),

              const SizedBox(height: 12),

              // Footer: Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Amount", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text(
                    "₹${item.amount}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Text("$label: ", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class Joke {
  final String id;
  final String payment_status;
  final String payment_date;
  final String date;
  final String amount;
  final String username;
  final String distributor;

  Joke(this.id, this.payment_status, this.payment_date, this.date, this.amount, this.username, this.distributor);
}