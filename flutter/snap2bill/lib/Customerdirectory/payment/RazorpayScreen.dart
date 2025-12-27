// pubspec
// razorpay_flutter: ^1.4.0
// #  razorpay_web: ^1.0.0
// js: ^0.6.7
// web: ^0.1.4-beta

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snap2bill/Customerdirectory/customer_home_page.dart';
import 'package:snap2bill/widgets/CustomerNavigationBar.dart';
import 'mobile_razorpay_helper.dart'
if (dart.library.js) 'web_razorpay_helper.dart' as razorpay_helper;
import 'package:razorpay_flutter/razorpay_flutter.dart' as razorpay_flutter;

class RazorpayScreen extends StatefulWidget {
  @override
  _RazorpayScreenState createState() => _RazorpayScreenState();
}

class _RazorpayScreenState extends State<RazorpayScreen> {
  razorpay_flutter.Razorpay? _razorpay;
  String fee = "0";
  String _paymentMode = "online"; // Default selection

  @override
  void initState() {
    loadfee();
    super.initState();
    if (!kIsWeb) {
      _razorpay = razorpay_flutter.Razorpay();
      _razorpay?.on(razorpay_flutter.Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay?.on(razorpay_flutter.Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay?.on(razorpay_flutter.Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  Future<void> loadfee() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    setState(() {
      fee = sh.getString("amount") ?? "0";
    });
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_HKCAwYtLt0rwQe',
      'amount': '${double.parse(fee) * 100}',
      'name': 'Snap2bill',
      'description': 'Test Payment',
      'prefill': {
        'contact': '7736967001',
        'email': 'test@snap2bill.in',
      },
      'theme': {'color': '#3399cc'}
    };

    if (kIsWeb) {
      razorpay_helper.openRazorpayWeb(
        options,
        onSuccess: (paymentId) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment Successful: $paymentId')),
          );
          updatepaymentstatus();
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment Failed: $error')),
          );
        },
      );
    } else {
      _razorpay?.open(options);
    }
  }

  void _handlePaymentSuccess(razorpay_flutter.PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful: ${response.paymentId}")),
    );
    updatepaymentstatus();
  }

  void _handlePaymentError(razorpay_flutter.PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(razorpay_flutter.ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Wallet Selected: ${response.walletName}")),
    );
  }

  Future<void> updatepaymentstatus() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    await http.post(
      Uri.parse("${sh.getString("ip")}/make_payment"),
      body: {
        "id": sh.getString("id"),
        "cid": sh.getString("cid"),
        "amount": sh.getString("amount"),
        "mode": _paymentMode,
      },
    );
    Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerNavigationBar()));
  }

  @override
  void dispose() {
    if (!kIsWeb) _razorpay?.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('Payment Options'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_balance_wallet, size: 60, color: Colors.blueAccent),
                SizedBox(height: 10),
                Text(
                  'Select Your Payment Method',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                SizedBox(height: 25),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(Icons.wifi, color: Colors.green),
                            SizedBox(width: 10),
                            Text('Online Payment'),
                          ],
                        ),
                        value: 'online',
                        groupValue: _paymentMode,
                        onChanged: (value) {
                          setState(() => _paymentMode = value!);
                        },
                      ),
                      Divider(height: 0),
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(Icons.money_off, color: Colors.redAccent),
                            SizedBox(width: 10),
                            Text('Offline Payment'),
                          ],
                        ),
                        value: 'offline',
                        groupValue: _paymentMode,
                        onChanged: (value) {
                          setState(() => _paymentMode = value!);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (_paymentMode == 'online') {
                      _openCheckout();
                    } else {
                      updatepaymentstatus();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    backgroundColor: _paymentMode == 'online'
                        ? Colors.green
                        : Colors.orangeAccent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _paymentMode == 'online' ? Icons.payment : Icons.check_circle_outline,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        _paymentMode == 'online'
                            ? 'Pay ₹$fee Online'
                            : 'Confirm Offline Booking',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '* All payments are secure and encrypted',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}



//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:snap2bill/Customerdirectory/customer_home_page.dart';
// import 'package:snap2bill/widgets/CustomerNavigationBar.dart';
//
// // Conditional imports for Web/Mobile Razorpay
// import 'mobile_razorpay_helper.dart'
// if (dart.library.js) 'web_razorpay_helper.dart' as razorpay_helper;
// import 'package:razorpay_flutter/razorpay_flutter.dart' as razorpay_flutter;
//
// class RazorpayScreen extends StatefulWidget {
//   @override
//   _RazorpayScreenState createState() => _RazorpayScreenState();
// }
//
// class _RazorpayScreenState extends State<RazorpayScreen> {
//   razorpay_flutter.Razorpay? _razorpay;
//   String fee = "0";
//   String _paymentMode = "online"; // Default selection
//
//   @override
//   void initState() {
//     loadfee();
//     super.initState();
//     if (!kIsWeb) {
//       _razorpay = razorpay_flutter.Razorpay();
//       _razorpay?.on(razorpay_flutter.Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//       _razorpay?.on(razorpay_flutter.Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//       _razorpay?.on(razorpay_flutter.Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     }
//   }
//
//   Future<void> loadfee() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     setState(() {
//       fee = sh.getString("amount") ?? "0";
//     });
//   }
//
//   void _openCheckout() {
//     var options = {
//       'key': 'rzp_test_HKCAwYtLt0rwQe',
//       'amount': '${int.parse(fee) * 100}',
//       'name': 'Snap2bill',
//       'description': 'Order Payment',
//       'prefill': {
//         'contact': '7736967001',
//         'email': 'test@snap2bill.in',
//       },
//       'theme': {'color': '#1E88E5'} // Blue to match your viewOrder theme
//     };
//
//     if (kIsWeb) {
//       razorpay_helper.openRazorpayWeb(
//         options,
//         onSuccess: (paymentId) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Payment Successful'), backgroundColor: Colors.green),
//           );
//           updatepaymentstatus();
//         },
//         onError: (error) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Payment Failed: $error'), backgroundColor: Colors.red),
//           );
//         },
//       );
//     } else {
//       _razorpay?.open(options);
//     }
//   }
//
//   void _handlePaymentSuccess(razorpay_flutter.PaymentSuccessResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Payment Successful: ${response.paymentId}"), backgroundColor: Colors.green),
//     );
//     updatepaymentstatus();
//   }
//
//   void _handlePaymentError(razorpay_flutter.PaymentFailureResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Payment Failed: ${response.message}"), backgroundColor: Colors.red),
//     );
//   }
//
//   void _handleExternalWallet(razorpay_flutter.ExternalWalletResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Wallet Selected: ${response.walletName}")),
//     );
//   }
//
//   Future<void> updatepaymentstatus() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String? ip = sh.getString("ip");
//     if(ip != null) {
//       await http.post(
//         Uri.parse("$ip/make_payment"),
//         body: {
//           "cid": sh.getString("cid") ?? "",
//           "amount": sh.getString("amount") ?? "0",
//           "mode": _paymentMode,
//           // "id": sh.getString("id") ?? "", // Uncomment if you need to send Order ID
//         },
//       );
//     }
//     if (mounted) {
//       Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => CustomerNavigationBar())
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     if (!kIsWeb) _razorpay?.clear();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Matching Theme variables from your viewOrder
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final bgColor = isDark ? theme.scaffoldBackgroundColor : Colors.grey[50];
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final cardColor = theme.cardColor;
//     final hintColor = isDark ? Colors.white38 : Colors.grey[500];
//
//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
//           onPressed: () {
//             if (Navigator.canPop(context)) Navigator.pop(context);
//           },
//         ),
//         title: Text(
//           "Checkout",
//           style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//
//             // 1. Amount Summary Card (Styled like your viewOrder card)
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: cardColor,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
//                     blurRadius: 15,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     "Total Payable Amount",
//                     style: TextStyle(fontSize: 14, color: hintColor),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     "₹$fee",
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue.shade700, // Matching the highlight color
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Divider(color: Colors.grey.withOpacity(0.1), thickness: 1),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.shield_outlined, size: 16, color: hintColor),
//                       const SizedBox(width: 8),
//                       Text(
//                         "100% Secure Payment",
//                         style: TextStyle(fontSize: 12, color: hintColor),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 30),
//
//             Padding(
//               padding: const EdgeInsets.only(left: 5, bottom: 15),
//               child: Text(
//                 "Payment Method",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: textColor,
//                 ),
//               ),
//             ),
//
//             // 2. Online Payment Option
//             _buildPaymentOption(
//               value: "online",
//               title: "Pay Online",
//               subtitle: "Cards, UPI, NetBanking",
//               icon: Icons.credit_card,
//               cardColor: cardColor,
//               textColor: textColor,
//               hintColor: hintColor!,
//               isDark: isDark,
//             ),
//
//             const SizedBox(height: 15),
//
//             // 3. Offline Payment Option
//             _buildPaymentOption(
//               value: "offline",
//               title: "Pay Offline",
//               subtitle: "Cash / Direct Payment",
//               icon: Icons.storefront, // Using storefront icon to match distributor feel
//               cardColor: cardColor,
//               textColor: textColor,
//               hintColor: hintColor,
//               isDark: isDark,
//             ),
//
//             const SizedBox(height: 40),
//
//             // 4. Main Action Button
//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 onPressed: () {
//                   if (_paymentMode == 'online') {
//                     _openCheckout();
//                   } else {
//                     updatepaymentstatus();
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue.shade600, // Matching viewOrder button
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 child: Text(
//                   _paymentMode == 'online' ? "Pay Now" : "Confirm Booking",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPaymentOption({
//     required String value,
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color cardColor,
//     required Color textColor,
//     required Color hintColor,
//     required bool isDark,
//   }) {
//     bool isSelected = _paymentMode == value;
//     Color activeColor = Colors.blue.shade600;
//
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _paymentMode = value;
//         });
//       },
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         padding: const EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           color: cardColor,
//           borderRadius: BorderRadius.circular(20),
//           border: isSelected ? Border.all(color: activeColor, width: 2) : null,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
//               blurRadius: 15,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             // Icon Box
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: isSelected ? activeColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 icon,
//                 color: isSelected ? activeColor : Colors.grey,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 15),
//
//             // Text Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: isSelected ? activeColor : textColor,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: TextStyle(fontSize: 12, color: hintColor),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Checkmark
//             if (isSelected)
//               Icon(Icons.check_circle, color: activeColor)
//             else
//               Icon(Icons.circle_outlined, color: Colors.grey.withOpacity(0.5)),
//           ],
//         ),
//       ),
//     );
//   }
// }