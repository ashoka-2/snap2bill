//
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Customerdirectory/custviews/viewOrderitem.dart';
// import 'package:snap2bill/Customerdirectory/payment/RazorpayScreen.dart';
//
// import '../../widgets/Navbar.dart';
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
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String ip = prefs.getString("ip") ?? "";
//     String cid = prefs.getString("cid") ?? "";
//     String did = prefs.getString("selected_distributor_id") ?? "";
//
//     try {
//       var response = await http.post(
//         Uri.parse("$ip/view_orders"),
//         body: {"cid": cid, "did": did},
//       );
//       var jsonData = json.decode(response.body);
//       List<Joke> list = [];
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
//     } catch (e) { return []; }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _ordersFuture = _getJokes();
//     _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
//       if (mounted) setState(() { _ordersFuture = _getJokes(); });
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
//       appBar: ThemeNavbar(title: "My Orders",
//         leadingIcon: Icons.arrow_back_ios_rounded,
//         onLeadingPressed: ()=>{
//           if (Navigator.canPop(context)) Navigator.pop(context)
//         },
//         centerTitle: true,
//
//       ),      body: FutureBuilder<List<Joke>>(
//         future: _ordersFuture,
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//           final items = snapshot.data!;
//           if (items.isEmpty) return const Center(child: Text("No orders found"));
//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: items.length,
//             itemBuilder: (context, index) => _buildCard(items[index], isDark),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildCard(Joke item, bool isDark) {
//     String status = item.payment_status.toLowerCase();
//     // ✅ Updated logic: Hide buttons if Paid, Online, OR Offline
//     bool isCompleted = status == 'paid' || status == 'online' || status == 'offline';
//
//     return GestureDetector(
//       onTap: () async {
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         prefs.setString("id", item.id);
//         prefs.setString("order_payment_status", item.payment_status);
//         Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewOrderItems()));
//       },
//       child: Card(
//         margin: const EdgeInsets.only(bottom: 15),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Bill ID: ${item.orderid}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
//                   _statusBadge(item.payment_status),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Text(item.distributor, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               Text("Date: ${item.date}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
//               const Divider(height: 25),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text("Total Payable", style: TextStyle(color: Colors.grey)),
//                   Text("₹${item.amount}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
//                 ],
//               ),
//               const SizedBox(height: 15),
//               Row(
//                 children: [
//                   if (!isCompleted)
//                     Expanded(
//                       flex: 2,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueAccent,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                         ),
//                         onPressed: () async {
//                           SharedPreferences prefs = await SharedPreferences.getInstance();
//                           prefs.setString("amount", item.amount);
//                           prefs.setString("id", item.id);
//                           Navigator.push(context, MaterialPageRoute(builder: (_) => RazorpayScreen()));
//                         },
//                         child: const Text("Pay Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                       ),
//                     ),
//                   if (!isCompleted) const SizedBox(width: 8),
//                   Expanded(
//                     flex: 2,
//                     child: OutlinedButton(
//                       style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
//                       onPressed: () async {
//                         SharedPreferences prefs = await SharedPreferences.getInstance();
//                         prefs.setString("id", item.id);
//                         prefs.setString("order_payment_status", item.payment_status);
//                         Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewOrderItems()));
//                       },
//                       child: Text(isCompleted ? "View Items" : "Edit Order"),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
//                     child: IconButton(
//                       icon: const Icon(Icons.delete_outline, color: Colors.red),
//                       onPressed: () => _showDeleteConfirmation(item.id),
//                     ),
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
//   void _showDeleteConfirmation(String orderId) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Delete Order?"),
//         content: const Text("Do you want to remove this order record?"),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//           TextButton(
//             onPressed: () async {
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               await http.post(Uri.parse("${prefs.getString("ip")}/delete_order"), body: {"id": orderId});
//               Navigator.pop(context);
//             },
//             child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _statusBadge(String status) {
//     Color color;
//     String label = status.toLowerCase();
//
//     if (label == 'paid' || label == 'online') {
//       color = Colors.green;
//     } else if (label == 'offline') {
//       color = Colors.blueGrey; // ✅ Pill color for Offline
//     } else {
//       color = Colors.orange;
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Text(status.toUpperCase(),
//           style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
//     );
//   }
// }
//
// class Joke {
//   final String id, payment_status, payment_date, date, amount, username, distributor, orderid;
//   Joke(this.id, this.payment_status, this.payment_date, this.date, this.amount, this.username, this.distributor, this.orderid);
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Customerdirectory/custviews/viewOrderitem.dart';
import 'package:snap2bill/Customerdirectory/payment/RazorpayScreen.dart';
import 'package:snap2bill/theme/colors.dart';
import 'package:snap2bill/widgets/app_button.dart'; // Contains AppButton, EditButton, and DeleteButton

import '../../widgets/Navbar.dart';

class viewOrder extends StatefulWidget {
  const viewOrder({Key? key}) : super(key: key);

  @override
  State<viewOrder> createState() => _viewOrderState();
}

class _viewOrderState extends State<viewOrder> {
  Timer? _timer;
  Future<List<OrderModel>>? _ordersFuture;

  /// --- API FETCH LOGIC ---
  Future<List<OrderModel>> _getOrders() async {
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
      List<OrderModel> list = [];
      if (jsonData["data"] != null) {
        for (var item in jsonData["data"]) {
          list.add(OrderModel.fromJson(item));
        }
      }
      return list;
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _ordersFuture = _getOrders();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) setState(() { _ordersFuture = _getOrders(); });
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
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];

    return Scaffold(
      backgroundColor: AppColors.getScaffoldBg(context),
      appBar: ThemeNavbar(
        title: "My Orders",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
        centerTitle: true,
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 70, color: subTextColor),
                  const SizedBox(height: 10),
                  Text("No orders found", style: TextStyle(color: subTextColor)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildOrderCard(items[index]),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextColor(context);
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];

    String status = item.paymentStatus.toLowerCase();
    bool isCompleted = status == 'paid' || status == 'online' || status == 'offline';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.getBorderColor(context).withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("BILL ID: ${item.orderId}",
                  style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
              _statusBadge(item.paymentStatus),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.distributor,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: subTextColor),
              const SizedBox(width: 6),
              Text(item.date, style: TextStyle(color: subTextColor, fontSize: 12)),
            ],
          ),
          const Divider(height: 10, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Amount Payable", style: TextStyle(color: subTextColor, fontWeight: FontWeight.w500)),
              Text("₹${item.amount}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // 1. PRIMARY ACTION (AppButton)
              Expanded(
                child: AppButton(
                  height: 40,
                  text: isCompleted ? "View Items" : "Pay Now",
                  icon: isCompleted ? Icons.visibility_outlined : Icons.account_balance_wallet_outlined,
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString("id", item.id);
                    prefs.setString("order_payment_status", item.paymentStatus);
                    if (isCompleted) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewOrderItems()));
                    } else {
                      prefs.setString("amount", item.amount);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => RazorpayScreen()));
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),

              // 2. EDIT ACTION (Circular EditButton) - Only if not completed
              if (!isCompleted) ...[
                EditButton(
                  size: 40,
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString("id", item.id);
                    prefs.setString("order_payment_status", item.paymentStatus);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewOrderItems()));
                  },
                ),
                const SizedBox(width: 12),
              ],

              // 3. DELETE ACTION (Circular DeleteButton)
              DeleteButton(
                size: 40,
                onPressed: () => _showDeleteConfirmation(item.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(

        backgroundColor: AppColors.WhiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Remove Record?",style: TextStyle(color: AppColors.BlackColor),),
        content: const Text("Are you sure you want to delete this order? This action cannot be undone.",style: TextStyle(color: AppColors.BlackColor)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Container(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: AppColors.BlackColor),
                  borderRadius: BorderRadius.circular(30)
              ),
              child:  Text("Cancel",style: TextStyle(color: AppColors.BlackColor),))),
          TextButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await http.post(Uri.parse("${prefs.getString("ip")}/delete_order"), body: {"id": orderId});
              Navigator.pop(context);
            },
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                decoration: BoxDecoration(
                  color: AppColors.dangerbgColor,
                  border: Border.all(color: AppColors.dangerColor),
                  borderRadius: BorderRadius.circular(30)
                ),
                child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
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
      color = Colors.blueGrey;
    } else {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
      ),
    );
  }
}

class OrderModel {
  final String id, paymentStatus, paymentDate, date, amount, username, distributor, orderId;

  OrderModel({
    required this.id,
    required this.paymentStatus,
    required this.paymentDate,
    required this.date,
    required this.amount,
    required this.username,
    required this.distributor,
    required this.orderId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json["id"].toString(),
      paymentStatus: json["payment_status"].toString(),
      paymentDate: json["payment_date"].toString(),
      date: json["date"].toString(),
      amount: json["amount"].toString(),
      username: json["username"].toString(),
      distributor: json["distributor"].toString(),
      orderId: json["orderid"].toString(),
    );
  }
}