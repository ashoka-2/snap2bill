
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snap2bill/Distributordirectory/view/viewOrderItems.dart';

import '../../widgets/Navbar.dart';

class viewAllOrders extends StatelessWidget {
  const viewAllOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const viewAllOrdersSub();
  }
}

class viewAllOrdersSub extends StatefulWidget {
  const viewAllOrdersSub({Key? key}) : super(key: key);

  @override
  State<viewAllOrdersSub> createState() => _viewAllOrdersSubState();
}

class _viewAllOrdersSubState extends State<viewAllOrdersSub> {
  late Future<List<Joke>> _orderFuture;

  @override
  void initState() {
    super.initState();
    _orderFuture = _getJokes();
  }

  /// ---------------- REFRESH LOGIC ----------------
  Future<void> _handleRefresh() async {
    setState(() {
      _orderFuture = _getJokes();
    });
    await _orderFuture;
  }

  /// ---------------- API CALL ----------------
  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("ip") ?? "";
    String uid = prefs.getString("uid") ?? "";

    // Check if we are filtering by a specific customer (sent from Customer Page)
    String? cid = prefs.getString("selected_customer_id");

    try {
      var data = await http.post(
        Uri.parse("$ip/view_distributor_allorders"),
        body: {
          "uid": uid,
          "cid": cid ?? "", // Filter by customer ID if it exists
        },
      );

      var jsonData = json.decode(data.body);
      List<Joke> jokes = [];

      if (jsonData["status"] == "ok") {
        for (var joke in jsonData["data"]) {
          jokes.add(Joke(
            joke["id"].toString(),
            joke["payment_status"].toString(),
            joke["payment_date"].toString(),
            joke["date"].toString(),
            joke["amount"].toString(),
            joke["username"].toString(),
            joke["distributor"] ?? "",
          ));
        }
      }
      return jokes;
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: ThemeNavbar(title: "Order History",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: ()=>{
          if (Navigator.canPop(context)) Navigator.pop(context)
        },
        centerTitle: true,

      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.primaryColor,
        child: FutureBuilder<List<Joke>>(
          future: _orderFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState(theme);
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _buildModernOrderCard(snapshot.data![index], theme, isDark);
              },
            );
          },
        ),
      ),
    );
  }

  /// ---------------- EMPTY STATE ----------------
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment:MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No orders found",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  /// ---------------- ORDER CARD ----------------
  Widget _buildModernOrderCard(Joke item, ThemeData theme, bool isDark) {
    bool isPending = item.payment_status.toLowerCase() == "pending";
    Color statusColor = isPending ? Colors.orange : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: InkWell(
        onTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("id", item.id); // Set the order ID for the next page
          Navigator.push(context, MaterialPageRoute(builder: (context) => const viewOrderItems()));
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #${item.id}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.primaryColor
                    ),
                  ),
                  _buildStatusChip(item.payment_status.toUpperCase(), statusColor),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, thickness: 0.5),
              ),

              // Detail Rows
              _buildInfoRow(Icons.person_outline, "Customer", item.username, isDark),
              const SizedBox(height: 10),
              _buildInfoRow(Icons.calendar_today_outlined, "Placed on", item.date, isDark),
              const SizedBox(height: 10),
              _buildInfoRow(Icons.payments_outlined, "Paid on",
                  item.payment_date == "None" || item.payment_date == "null" ? "Awaiting" : item.payment_date, isDark),

              const SizedBox(height: 20),

              // Footer: Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Bill Amount", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text(
                    "₹${item.amount}",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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