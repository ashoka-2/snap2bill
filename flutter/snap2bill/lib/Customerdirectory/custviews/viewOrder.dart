
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Customerdirectory/custviews/viewOrderitem.dart';
// import 'package:snap2bill/Customerdirectory/payment/RazorpayScreen.dart';
// import 'package:snap2bill/widgets/CustomerNavigationBar.dart';
//
//
//
// class viewOrder extends StatefulWidget {
//   const viewOrder({Key? key}) : super(key: key);
//
//   @override
//   State<viewOrder> createState() => _viewOrderState();
// }
//
// class _viewOrderState extends State<viewOrder> {
//   Timer? _timer;
//   Future<List<Joke>>? _ordersFuture;
//
//   // ---------------- API ----------------
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? ip = prefs.getString("ip");
//     String? cid = prefs.getString("cid");
//
//     // NEW: Check for Distributor Filter from the Distributor List Page
//     String? did = prefs.getString("selected_distributor_id");
//
//     if (ip == null || cid == null) return [];
//
//     try {
//       var response = await http.post(
//         Uri.parse("$ip/view_orders"),
//         body: {
//           "cid": cid,
//           "did": did ?? "", // Send filter if user clicked a specific distributor
//         },
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
//     _ordersFuture = _getJokes();
//     // Keeps UI updated every second as per your original logic
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
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF232323) : const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
//           onPressed: () async {
//             // Clear the specific distributor filter so it doesn't "stick"
//             SharedPreferences prefs = await SharedPreferences.getInstance();
//             await prefs.remove("selected_distributor_id");
//
//             if (Navigator.canPop(context)) {
//               Navigator.pop(context);
//             } else {
//               // Fallback if there is no route to pop (e.g., opened from notification)
//               Navigator.pushReplacement(context, MaterialPageRoute(
//                   builder: (context) => const CustomerNavigationBar(initialIndex: 0)
//               ));
//             }
//           },
//         ),
//         title: const Text(
//           "My Orders", // You can also make this dynamic based on the filter
//           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
//         ),
//       ),      body: FutureBuilder<List<Joke>>(
//         future: _ordersFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           final items = snapshot.data ?? [];
//           if (items.isEmpty) {
//             return const Center(child: Text("No orders found"));
//           }
//
//           return ListView.builder(
//
//             padding: const EdgeInsets.all(12),
//             itemCount: items.length,
//             itemBuilder: (context, index) {
//               return _buildCard(items[index], isDark);
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   // ---------------- CARD ----------------
//   Widget _buildCard(Joke item, bool isDark) {
//     bool isPaid = item.payment_status.toLowerCase() == 'paid' ||
//         item.payment_status.toLowerCase() == 'online';
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       color: isDark?Colors.black45:Colors.white,
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Bill ID: ${item.orderid}",
//                     style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     item.payment_status.toUpperCase(),
//                     style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       color: isPaid ? Colors.green[800] : Colors.orange[800],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(item.distributor,
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 4),
//             Text("Date: ${item.date}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
//             const Divider(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Sub ID: ${item.id}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                 Text("₹${item.amount}",
//                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 // Show Pay button only if pending
//                 if (item.payment_status.toLowerCase() == "pending")
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blueAccent,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                       ),
//                       onPressed: () async {
//                         SharedPreferences sh = await SharedPreferences.getInstance();
//                         sh.setString("amount", item.amount);
//                         sh.setString("id", item.id);
//                         Navigator.push(context, MaterialPageRoute(builder: (_) => RazorpayScreen()));
//                       },
//                       child: const Text("Pay Now", style: TextStyle(color: Colors.white)),
//                     ),
//                   ),
//                 const SizedBox(width: 8),
//                 // Edit Button
//                 if (item.payment_status.toLowerCase() == "pending")
//                 IconButton(
//                   icon: const Icon(Icons.edit, color: Colors.blue),
//                   onPressed: () async {
//                     SharedPreferences sh = await SharedPreferences.getInstance();
//                     sh.setString("id", item.id);
//                     Navigator.push(context, MaterialPageRoute(builder: (_) => ViewOrderItems()));
//                   },
//                 ),
//                 // Delete Button
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.delete_outline, color: Colors.red),
//                     onPressed: () async {
//                       SharedPreferences sh = await SharedPreferences.getInstance();
//                       await http.post(
//                         Uri.parse("${sh.getString("ip")}/delete_order"),
//                         body: {"id": item.id},
//                       );
//                       // Timer will naturally pick up the change in 1 second
//                     },
//                   ),
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
//   Joke(this.id, this.payment_status, this.payment_date, this.date, this.amount, this.username, this.distributor, this.orderid);
// }
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("ip") ?? "";
    String cid = prefs.getString("cid") ?? "";
    String did = prefs.getString("selected_distributor_id") ?? "";

    try {
      var response = await http.post(
        Uri.parse("$ip/view_orders"),
        body: {"cid": cid, "did": did},
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
    } catch (e) { return []; }
  }

  @override
  void initState() {
    super.initState();
    _ordersFuture = _getJokes();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) setState(() { _ordersFuture = _getJokes(); });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("My Orders", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<List<Joke>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          if (items.isEmpty) return const Center(child: Text("No orders found"));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildCard(items[index], isDark),
          );
        },
      ),
    );
  }

  Widget _buildCard(Joke item, bool isDark) {
    String status = item.payment_status.toLowerCase();
    // ✅ Updated logic: Hide buttons if Paid, Online, OR Offline
    bool isCompleted = status == 'paid' || status == 'online' || status == 'offline';

    return GestureDetector(
      onTap: () async {
        SharedPreferences sh = await SharedPreferences.getInstance();
        sh.setString("id", item.id);
        sh.setString("order_payment_status", item.payment_status);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewOrderItems()));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Bill ID: ${item.orderid}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  _statusBadge(item.payment_status),
                ],
              ),
              const SizedBox(height: 10),
              Text(item.distributor, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Date: ${item.date}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Payable", style: TextStyle(color: Colors.grey)),
                  Text("₹${item.amount}", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  if (!isCompleted)
                    Expanded(
                      flex: 2,
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
                        child: const Text("Pay Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (!isCompleted) const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: () async {
                        SharedPreferences sh = await SharedPreferences.getInstance();
                        sh.setString("id", item.id);
                        sh.setString("order_payment_status", item.payment_status);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewOrderItems()));
                      },
                      child: Text(isCompleted ? "View Items" : "Edit Order"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(item.id),
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

  void _showDeleteConfirmation(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Order?"),
        content: const Text("Do you want to remove this order record?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              SharedPreferences sh = await SharedPreferences.getInstance();
              await http.post(Uri.parse("${sh.getString("ip")}/delete_order"), body: {"id": orderId});
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String label = status.toLowerCase();

    if (label == 'paid' || label == 'online') {
      color = Colors.green;
    } else if (label == 'offline') {
      color = Colors.blueGrey; // ✅ Pill color for Offline
    } else {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(status.toUpperCase(),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}

class Joke {
  final String id, payment_status, payment_date, date, amount, username, distributor, orderid;
  Joke(this.id, this.payment_status, this.payment_date, this.date, this.amount, this.username, this.distributor, this.orderid);
}