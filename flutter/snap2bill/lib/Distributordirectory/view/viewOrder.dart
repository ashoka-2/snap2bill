
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/view/viewOrderItems.dart';

import '../../theme/colors.dart';
import '../../widgets/Navbar.dart';

class ViewOrder extends StatelessWidget {
  const ViewOrder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ViewOrderSub();
  }
}

class ViewOrderSub extends StatefulWidget {
  const ViewOrderSub({Key? key}) : super(key: key);

  @override
  State<ViewOrderSub> createState() => _ViewOrderSubState();
}

class _ViewOrderSubState extends State<ViewOrderSub> {
  late Future<List<Joke>> _orderFuture;

  late Color successColor;
  late Color dangerColor;
  late Color cardColor;
  late Color textColor;
  late Color subTextColor;
  late Color primaryColor;

  @override
  void initState() {
    super.initState();
    _orderFuture = _getJokes();
  }

  // 🚀 Refresh Function
  Future<void> _handleRefresh() async {
    setState(() {
      _orderFuture = _getJokes();
    });
    await _orderFuture;
  }

  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("ip") ?? "";
    String uid = prefs.getString("uid") ?? "";
    String? cid = prefs.getString("selected_customer_id");

    try {
      var data = await http.post(
        Uri.parse("$ip/view_distributor_orders"),
        body: {
          "uid": uid,
          "cid": cid ?? "",
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
            joke["order_type"].toString(),
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
    successColor = AppColors.getSuccessColor(context);
    dangerColor = AppColors.getDangerColor(context);
    final bgColor = AppColors.getScaffoldBg(context);
    cardColor = AppColors.getCardColor(context);
    textColor = AppColors.getTextColor(context);
    subTextColor = AppColors.getTextSubColor(context);
    primaryColor = AppColors.getPrimaryColor(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: ThemeNavbar(
        title: "Order History",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () => Navigator.pop(context),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: primaryColor,
        child: FutureBuilder<List<Joke>>(
          future: _orderFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // ScrollView is needed for RefreshIndicator to work on empty state
              return ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  _buildEmptyState(),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(), // 🚀 Important for Refresh
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => _buildModernOrderCard(snapshot.data![index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No orders found", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildModernOrderCard(Joke item) {
    bool isPending = item.payment_status.toLowerCase() == "pending";
    Color statusColor = isPending ? AppColors.orangeColor : successColor;
    bool isOffline = item.type.toLowerCase().contains("offline");
    String labelTitle = isOffline ? "BILL ID" : "ORDER ID";
    Color labelColor = isOffline ? AppColors.premiumDarkBlue : primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.getBorderColor(context).withValues(alpha:0.1), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.BlackColor.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: InkWell(
        onTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("id", item.id);

          // 🚀 AUTO-RELOAD LOGIC:
          // Wait for the next page to close, then refresh data
          await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ViewOrderItems())
          );

          // Jab user wapas aayega, ye line trigger hogi
          _handleRefresh();
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$labelTitle: ${item.id}",
                    style: TextStyle(color: labelColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)
                  ),
                  _buildStatusChip(item.payment_status.toUpperCase(), statusColor),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, thickness: 0.5),
              ),
              _buildInfoRow(Icons.person_outline, "Customer", item.username),
              const SizedBox(height: 5),
              _buildInfoRow(Icons.calendar_today_outlined, "Placed on", item.date),
              const SizedBox(height: 5),
              _buildInfoRow(
                Icons.payments_outlined,
                "Paid on",
                item.payment_date == "None" || item.payment_date == "null" ? "Awaiting" : item.payment_date,
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Bill Amount", style: TextStyle(color: subTextColor, fontSize: 14)),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        "₹${item.amount}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor),
                      ),
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 10),
        Text("$label: ", style: TextStyle(color: subTextColor, fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
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
  final String type; // 🚀 Added type here

  Joke(this.id, this.payment_status, this.payment_date, this.date, this.amount, this.username, this.distributor, this.type);
}
