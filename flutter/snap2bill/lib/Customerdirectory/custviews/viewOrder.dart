//
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Customerdirectory/custviews/viewOrderitem.dart';
// import 'package:snap2bill/Customerdirectory/payment/RazorpayScreen.dart';
// import 'package:snap2bill/theme/colors.dart';
// import 'package:snap2bill/widgets/app_button.dart';
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
//   Future<List<OrderModel>>? _ordersFuture;
//
//
//
//   late Color successColor;
//   late Color dangerColor;
//   late Color cardColor;
//   late Color textColor;
//   late Color subTextColor;
//   late Color primaryColor;
//
//   Future<void> _handleRefresh() async {
//     setState(() {
//       _ordersFuture = _getOrders();
//     });
//     await _ordersFuture;
//   }
//
//   Future<List<OrderModel>> _getOrders() async {
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
//       List<OrderModel> list = [];
//       if (jsonData["data"] != null) {
//         for (var item in jsonData["data"]) {
//           list.add(OrderModel.fromJson(item));
//         }
//       }
//       return list;
//     } catch (e) {
//       debugPrint("Error fetching orders: $e");
//       return [];
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _ordersFuture = _getOrders();
//     _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
//       if (mounted) setState(() { _ordersFuture = _getOrders(); });
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
//     successColor = AppColors.getSuccessColor(context);
//     dangerColor = AppColors.getDangerColor(context);
//     final bgColor = AppColors.getScaffoldBg(context);
//     cardColor = AppColors.getCardColor(context);
//     textColor = AppColors.getTextColor(context);
//     subTextColor = AppColors.getTextSubColor(context);
//     primaryColor = AppColors.getPrimaryColor(context);
//
//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: ThemeNavbar(
//         title: "My Orders",
//         leadingIcon: Icons.arrow_back_ios_rounded,
//         onLeadingPressed: () {
//           if (Navigator.canPop(context)) Navigator.pop(context);
//         },
//         centerTitle: true,
//       ),
//       body: RefreshIndicator(
//         onRefresh: _handleRefresh,
//         color: primaryColor,
//         backgroundColor: cardColor,
//         child: FutureBuilder<List<OrderModel>>(
//           future: _ordersFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             final items = snapshot.data ?? [];
//             if (items.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.assignment_outlined, size: 70, color: subTextColor),
//                     const SizedBox(height: 10),
//                     Text("No orders found", style: TextStyle(color: subTextColor)),
//                   ],
//                 ),
//               );
//             }
//             return ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               itemCount: items.length,
//               itemBuilder: (context, index) => _buildOrderCard(items[index]),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOrderCard(OrderModel item) {
//     String status = item.paymentStatus.toLowerCase();
//
//     // 🚀 Logic Definitions
//     bool isCompleted = status == 'paid' || status == 'online' || status == 'offline';
//     bool isOfflineBill = item.orderType.toLowerCase().contains("offline");
//
//     String labelTitle = isOfflineBill ? "BILL ID" : "ORDER ID";
//     Color labelColor = isOfflineBill ? AppColors.premiumDarkBlue : subTextColor;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(25),
//         border: Border.all(color: AppColors.getBorderColor(context).withValues(alpha:0.1), width: 1.5),
//         boxShadow: [
//           BoxShadow(color: AppColors.BlackColor.withValues(alpha:0.05), blurRadius: 15, offset: const Offset(0, 5)),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text("$labelTitle: ${item.orderId}",
//                   style: TextStyle(color: labelColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
//               _statusBadge(item.paymentStatus),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(item.distributor,
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
//           const SizedBox(height: 4),
//           Row(
//             children: [
//               Icon(Icons.access_time_rounded, size: 14, color: subTextColor),
//               const SizedBox(width: 6),
//               Text(item.date, style: TextStyle(color: subTextColor, fontSize: 12)),
//             ],
//           ),
//           const Divider(height: 10, thickness: 1),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text("Amount Payable", style: TextStyle(color: subTextColor, fontWeight: FontWeight.w500)),
//               Text("₹${item.amount}",
//                   style:  TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color:primaryColor)),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               // 1. PRIMARY ACTION (Pay Now or View Items)
//               Expanded(
//                 child: AppButton(
//                   height: 40,
//                   text: isCompleted ? "View Items" : "Pay Now",
//                   icon: isCompleted ? Icons.visibility_outlined : Icons.account_balance_wallet_outlined,
//                   onPressed: () async {
//                     SharedPreferences prefs = await SharedPreferences.getInstance();
//                     prefs.setString("id", item.id);
//                     prefs.setString("order_payment_status", item.paymentStatus);
//                     if (isCompleted) {
//                       Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewOrderItems()));
//                     } else {
//                       prefs.setString("amount", item.amount);
//                       Navigator.push(context, MaterialPageRoute(builder: (_) => RazorpayScreen()));
//                     }
//                   },
//                 ),
//               ),
//
//               if (!isOfflineBill && !isCompleted) ...[
//                 const SizedBox(width: 12),
//                 EditButton(
//                   size: 40,
//                   onPressed: () async {
//                     SharedPreferences prefs = await SharedPreferences.getInstance();
//                     prefs.setString("id", item.id);
//                     prefs.setString("order_payment_status", item.paymentStatus);
//                     Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewOrderItems()));
//                   },
//                 ),
//                 const SizedBox(width: 12),
//                 DeleteButton(
//                   size: 40,
//                   onPressed: () => _showDeleteConfirmation(item.id),
//                 ),
//               ],
//
//               if (isOfflineBill && !isCompleted) ...[
//                 const SizedBox(width: 12),
//                 IconButton(
//                   onPressed: () async {
//                     SharedPreferences prefs = await SharedPreferences.getInstance();
//                     prefs.setString("id", item.id);
//                     prefs.setString("order_payment_status", item.paymentStatus);
//                     Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewOrderItems()));
//                   },
//                   icon: Icon(Icons.receipt_long, color: primaryColor),
//                 )
//               ]
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showDeleteConfirmation(String orderId) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: AppColors.WhiteColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text("Remove Record?",style: TextStyle(color: AppColors.BlackColor),),
//         content: const Text("Are you sure you want to delete this order? This action cannot be undone.",style: TextStyle(color: AppColors.BlackColor)),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
//               decoration: BoxDecoration(
//                   color: Colors.transparent,
//                   border: Border.all(color: AppColors.BlackColor),
//                   borderRadius: BorderRadius.circular(30)
//               ),
//               child:  const Text("Cancel",style: TextStyle(color: AppColors.BlackColor),))),
//           TextButton(
//             onPressed: () async {
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               await http.post(Uri.parse("${prefs.getString("ip")}/delete_order"), body: {"id": orderId});
//               if(mounted) Navigator.pop(context);
//             },
//             child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
//                 decoration: BoxDecoration(
//                     color: dangerColor,
//                     border: Border.all(color: dangerColor),
//                     borderRadius: BorderRadius.circular(30)
//                 ),
//                 child:  const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _statusBadge(String status) {
//     Color color;
//     String label = status.toLowerCase();
//     if (label == 'paid' || label == 'online') {
//       color = successColor;
//     } else if (label == 'offline') {
//       color = primaryColor;
//     } else {
//       color = AppColors.orangeColor;
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha:0.12),
//         borderRadius: BorderRadius.circular(50),
//         border: Border.all(color: color.withValues(alpha:0.4), width: 1),
//       ),
//       child: Text(
//         status.toUpperCase(),
//         style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
//       ),
//     );
//   }
// }
//
// class OrderModel {
//   final String id, paymentStatus, paymentDate, date, amount, username, distributor, orderId, orderType;
//
//   OrderModel({
//     required this.id,
//     required this.paymentStatus,
//     required this.paymentDate,
//     required this.date,
//     required this.amount,
//     required this.username,
//     required this.distributor,
//     required this.orderId,
//     required this.orderType,
//   });
//
//   factory OrderModel.fromJson(Map<String, dynamic> json) {
//     return OrderModel(
//       id: json["id"].toString(),
//       paymentStatus: json["payment_status"].toString(),
//       paymentDate: json["payment_date"].toString(),
//       date: json["date"].toString(),
//       amount: json["amount"].toString(),
//       username: json["username"].toString(),
//       distributor: json["distributor"].toString(),
//       orderId: json["orderid"].toString(),
//       orderType: json["order_type"]?.toString() ?? "online",
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Customerdirectory/custviews/viewOrderitem.dart';
import 'package:snap2bill/Customerdirectory/payment/RazorpayScreen.dart';
import 'package:snap2bill/theme/colors.dart';
import 'package:snap2bill/widgets/app_button.dart';

import '../../widgets/Navbar.dart';

class viewOrder extends StatefulWidget {
  const viewOrder({Key? key}) : super(key: key);

  @override
  State<viewOrder> createState() => _viewOrderState();
}

class _viewOrderState extends State<viewOrder> {
  Timer? _timer;
  Future<List<OrderModel>>? _ordersFuture;

  // 🚀 1. NEW VARIABLE FOR DATE FILTER
  DateTime? _selectedDate;

  late Color successColor;
  late Color dangerColor;
  late Color cardColor;
  late Color textColor;
  late Color subTextColor;
  late Color primaryColor;

  Future<void> _handleRefresh() async {
    setState(() {
      _ordersFuture = _getOrders();
    });
    await _ordersFuture;
  }

  // 🚀 2. DATE PICKER FUNCTION
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor), // Calendar colors
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _ordersFuture = _getOrders(); // Reload orders with filter
      });
    }
  }

  // 🚀 3. CLEAR FILTER FUNCTION
  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
      _ordersFuture = _getOrders();
    });
  }

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
          OrderModel order = OrderModel.fromJson(item);

          // 🚀 4. FILTERING LOGIC
          if (_selectedDate != null) {
            // Convert Selected Date to String (YYYY-MM-DD)
            String filterStr = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

            // Backend date usually looks like "2024-02-14 10:30:00" or just "2024-02-14"
            // We check if order date contains the selected date string
            if (order.date.contains(filterStr)) {
              list.add(order);
            }
          } else {
            // If no date selected, add all
            list.add(order);
          }
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
        centerTitle: true,
        leadingIcon:Icon(Icons.arrow_back_ios_rounded, ),

        onLeadingPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          }, title: 'My Orders',

        actions: [
          _selectedDate != null
              ? IconButton(
            icon: Icon(Icons.filter_alt_off, color: dangerColor),
            onPressed: _clearDateFilter,
            tooltip: "Clear Filter",
          )
              : IconButton(
            icon: Icon(Icons.calendar_month_rounded, color: primaryColor),
            onPressed: _pickDate,
            tooltip: "Filter by Date",
          ),
        ],
        ),

      body: Column(
        children: [
          // 🚀 6. SHOW SELECTED DATE CHIP (Optional Design)
          if (_selectedDate != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              color: primaryColor.withOpacity(0.1),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Showing orders for: ${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _clearDateFilter,
                    child: Icon(Icons.close, size: 18, color: primaryColor),
                  )
                ],
              ),
            ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: primaryColor,
              backgroundColor: cardColor,
              child: FutureBuilder<List<OrderModel>>(
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
                          Text(
                              _selectedDate != null ? "No orders on this date" : "No orders found",
                              style: TextStyle(color: subTextColor)
                          ),
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
            ),
          ),
        ],
      ),
    );
  }

  // ... (Baki ka _buildOrderCard aur _statusBadge same rahega) ...

  Widget _buildOrderCard(OrderModel item) {
    // Paste your existing _buildOrderCard code here
    String status = item.paymentStatus.toLowerCase();
    bool isCompleted = status == 'paid' || status == 'online' || status == 'offline';
    bool isOfflineBill = item.orderType.toLowerCase().contains("offline");
    String labelTitle = isOfflineBill ? "BILL ID" : "ORDER ID";
    Color labelColor = isOfflineBill ? AppColors.premiumDarkBlue : subTextColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.getBorderColor(context).withValues(alpha:0.1), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.BlackColor.withValues(alpha:0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$labelTitle: ${item.orderId}",
                  style: TextStyle(color: labelColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
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
                  style:  TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color:primaryColor)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
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

              if (!isOfflineBill && !isCompleted) ...[
                const SizedBox(width: 12),
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
                DeleteButton(
                  size: 40,
                  onPressed: () => _showDeleteConfirmation(item.id),
                ),
              ],

              if (isOfflineBill && !isCompleted) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString("id", item.id);
                    prefs.setString("order_payment_status", item.paymentStatus);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewOrderItems()));
                  },
                  icon: Icon(Icons.receipt_long, color: primaryColor),
                )
              ]
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String orderId) {
    // Paste your existing delete dialog logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.WhiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Remove Record?",style: TextStyle(color: AppColors.BlackColor),),
        content: const Text("Are you sure you want to delete this order? This action cannot be undone.",style: TextStyle(color: AppColors.BlackColor)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: AppColors.BlackColor),
                  borderRadius: BorderRadius.circular(30)
              ),
              child:  const Text("Cancel",style: TextStyle(color: AppColors.BlackColor),))),
          TextButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await http.post(Uri.parse("${prefs.getString("ip")}/delete_order"), body: {"id": orderId});
              if(mounted) Navigator.pop(context);
            },
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                decoration: BoxDecoration(
                    color: dangerColor,
                    border: Border.all(color: dangerColor),
                    borderRadius: BorderRadius.circular(30)
                ),
                child:  const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    // Paste your existing status badge logic
    Color color;
    String label = status.toLowerCase();
    if (label == 'paid' || label == 'online') {
      color = successColor;
    } else if (label == 'offline') {
      color = primaryColor;
    } else {
      color = AppColors.orangeColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha:0.4), width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
      ),
    );
  }
}

class OrderModel {
  final String id, paymentStatus, paymentDate, date, amount, username, distributor, orderId, orderType;

  OrderModel({
    required this.id,
    required this.paymentStatus,
    required this.paymentDate,
    required this.date,
    required this.amount,
    required this.username,
    required this.distributor,
    required this.orderId,
    required this.orderType,
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
      orderType: json["order_type"]?.toString() ?? "online",
    );
  }
}