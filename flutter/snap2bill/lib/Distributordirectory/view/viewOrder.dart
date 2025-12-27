//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Distributordirectory/view/viewOrderItems.dart';
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
//     String ip = prefs.getString("ip").toString();
//     String uid = prefs.getString("uid").toString();
//
//     // Check if we are filtering by a specific customer
//     String? cid = prefs.getString("selected_customer_id");
//
//     var data = await http.post(
//       Uri.parse("$ip/view_distributor_orders"),
//       body: {
//         "uid": uid,
//         "cid": cid ?? "", // Pass customer ID if it exists, otherwise empty
//       },
//     );
//
//     var jsonData = json.decode(data.body);
//     List<Joke> jokes = [];
//
//     if (jsonData["status"] == "ok") {
//       for (var joke in jsonData["data"]) {
//         Joke newJoke = Joke(
//           joke["id"].toString(),
//           joke["payment_status"].toString(),
//           joke["payment_date"].toString(),
//           joke["date"].toString(),
//           joke["amount"].toString(),
//           joke["username"].toString(),
//           joke["distributor"] ?? "",
//         );
//         jokes.add(newJoke);
//       }
//     }
//     return jokes;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
//           onPressed: () async {
//             // Clear the specific customer filter when leaving the page
//             SharedPreferences prefs = await SharedPreferences.getInstance();
//             await prefs.remove("selected_customer_id");
//
//             if (Navigator.canPop(context)) Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           "Order History",
//           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: FutureBuilder<List<Joke>>(
//         future: _getJokes(),
//         builder: (BuildContext context, AsyncSnapshot<List<Joke>> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.assignment_late_outlined, size: 60, color: Colors.grey[400]),
//                   const SizedBox(height: 10),
//                   Text("No orders found", style: TextStyle(color: Colors.grey[600])),
//                 ],
//               ),
//             );
//           }
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: snapshot.data!.length,
//             itemBuilder: (BuildContext context, int index) {
//               var item = snapshot.data![index];
//               return _buildModernOrderCard(item);
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildModernOrderCard(Joke item) {
//     bool isPending = item.payment_status.toLowerCase() == "pending";
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: () async {
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           prefs.setString("id", item.id);
//           Navigator.push(context, MaterialPageRoute(builder: (context) => const viewOrderItems()));
//         },
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header: Order ID and Status Chip
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Order #${item.id}",
//                     style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: isPending ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       item.payment_status.toUpperCase(),
//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         color: isPending ? Colors.orange[800] : Colors.green[800],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 12),
//                 child: Divider(height: 1),
//               ),
//
//               // Body Details
//               _buildInfoRow(Icons.person_outline, "Customer", item.username),
//               _buildInfoRow(Icons.calendar_today_outlined, "Order Date", item.date),
//               _buildInfoRow(Icons.payments_outlined, "Payment Date",
//                   item.payment_date == "None" || item.payment_date == "null" ? "---" : item.payment_date),
//
//               const SizedBox(height: 12),
//
//               // Footer: Amount
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text("Total Amount", style: TextStyle(color: Colors.grey, fontSize: 13)),
//                   Text(
//                     "₹${item.amount}",
//                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Icon(icon, size: 16, color: Colors.grey[400]),
//           const SizedBox(width: 8),
//           Text("$label: ", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
//               overflow: TextOverflow.ellipsis,
//             ),
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
//
//   Joke(this.id, this.payment_status, this.payment_date, this.date, this.amount, this.username, this.distributor);
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
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
        Uri.parse("$ip/view_distributor_orders"),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : Colors.black87, size: 20),
          onPressed: () async {
            // ✅ CRITICAL: Clear the customer filter when leaving the page
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove("selected_customer_id");
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          "Order History",
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
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
                    style: GoogleFonts.poppins(
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
                    style: GoogleFonts.poppins(
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