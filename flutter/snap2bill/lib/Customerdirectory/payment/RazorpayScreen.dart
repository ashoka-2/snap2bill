// // pubspec
// // razorpay_flutter: ^1.4.0
// // #  razorpay_web: ^1.0.0
// // js: ^0.6.7
// // web: ^0.1.4-beta
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
//
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:snap2bill/Customerdirectory/customer_home_page.dart';
// import 'package:snap2bill/widgets/CustomerNavigationBar.dart';
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
//       'amount': '${double.parse(fee) * 100}',
//       'name': 'Snap2bill',
//       'description': 'Test Payment',
//       'prefill': {
//         'contact': '7736967001',
//         'email': 'test@snap2bill.in',
//       },
//       'theme': {'color': '#3399cc'}
//     };
//
//     if (kIsWeb) {
//       razorpay_helper.openRazorpayWeb(
//         options,
//         onSuccess: (paymentId) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Payment Successful: $paymentId')),
//           );
//           updatepaymentstatus();
//         },
//         onError: (error) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Payment Failed: $error')),
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
//       SnackBar(content: Text("Payment Successful: ${response.paymentId}")),
//     );
//     updatepaymentstatus();
//   }
//
//   void _handlePaymentError(razorpay_flutter.PaymentFailureResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Payment Failed: ${response.message}")),
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
//     await http.post(
//       Uri.parse("${sh.getString("ip")}/make_payment"),
//       body: {
//         "id": sh.getString("id"),
//         "cid": sh.getString("cid"),
//         "amount": sh.getString("amount"),
//         "mode": _paymentMode,
//       },
//     );
//     Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerNavigationBar()));
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
//     return Scaffold(
//       backgroundColor: Colors.blueGrey[50],
//       appBar: AppBar(
//         title: Text('Payment Options'),
//         backgroundColor: Colors.blueAccent,
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(horizontal: 24),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               gradient: LinearGradient(
//                 colors: [Colors.white, Colors.blue[50]!],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 15,
//                   spreadRadius: 5,
//                 ),
//               ],
//             ),
//             padding: EdgeInsets.all(25),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.account_balance_wallet, size: 60, color: Colors.blueAccent),
//                 SizedBox(height: 10),
//                 Text(
//                   'Select Your Payment Method',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
//                 ),
//                 SizedBox(height: 25),
//                 AnimatedContainer(
//                   duration: Duration(milliseconds: 300),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[100],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     children: [
//                       RadioListTile<String>(
//                         title: Row(
//                           children: [
//                             Icon(Icons.wifi, color: Colors.green),
//                             SizedBox(width: 10),
//                             Text('Online Payment'),
//                           ],
//                         ),
//                         value: 'online',
//                         groupValue: _paymentMode,
//                         onChanged: (value) {
//                           setState(() => _paymentMode = value!);
//                         },
//                       ),
//                       Divider(height: 0),
//                       RadioListTile<String>(
//                         title: Row(
//                           children: [
//                             Icon(Icons.money_off, color: Colors.redAccent),
//                             SizedBox(width: 10),
//                             Text('Offline Payment'),
//                           ],
//                         ),
//                         value: 'offline',
//                         groupValue: _paymentMode,
//                         onChanged: (value) {
//                           setState(() => _paymentMode = value!);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 30),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_paymentMode == 'online') {
//                       _openCheckout();
//                     } else {
//                       updatepaymentstatus();
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     elevation: 8,
//                     backgroundColor: _paymentMode == 'online'
//                         ? Colors.green
//                         : Colors.orangeAccent,
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         _paymentMode == 'online' ? Icons.payment : Icons.check_circle_outline,
//                         color: Colors.white,
//                       ),
//                       SizedBox(width: 10),
//                       Text(
//                         _paymentMode == 'online'
//                             ? 'Pay ₹$fee Online'
//                             : 'Confirm Offline Booking',
//                         style: TextStyle(fontSize: 16, color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   '* All payments are secure and encrypted',
//                   style: TextStyle(fontSize: 12, color: Colors.grey),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
// }
//
//
//


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snap2bill/widgets/CustomerNavigationBar.dart';

// Conditional imports for Web/Mobile Razorpay
import 'mobile_razorpay_helper.dart'
if (dart.library.js) 'web_razorpay_helper.dart' as razorpay_helper;
import 'package:razorpay_flutter/razorpay_flutter.dart' as razorpay_flutter;

class RazorpayScreen extends StatefulWidget {
  const RazorpayScreen({Key? key}) : super(key: key);

  @override
  _RazorpayScreenState createState() => _RazorpayScreenState();
}

class _RazorpayScreenState extends State<RazorpayScreen> {
  razorpay_flutter.Razorpay? _razorpay;
  String fee = "0";
  String _paymentMode = "online"; // Default selection
  bool _isProcessing = false;

  @override
  void initState() {
    loadfee();
    super.initState();
    // Initialize Razorpay only on mobile platforms
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
    // Convert amount to paisa (multiply by 100)
    int amountInPaisa = (double.parse(fee) * 100).toInt();

    var options = {
      'key': 'rzp_test_HKCAwYtLt0rwQe',
      'amount': amountInPaisa,
      'name': 'Snap2bill',
      'description': 'Order Payment',
      'prefill': {
        'contact': '7736967001',
        'email': 'test@snap2bill.in',
      },
      'theme': {'color': '#1E88E5'} // Blue theme
    };

    if (kIsWeb) {
      razorpay_helper.openRazorpayWeb(
        options,
        onSuccess: (paymentId) {
          _showSnackBar('Payment Successful', Colors.green);
          updatepaymentstatus();
        },
        onError: (error) {
          _showSnackBar('Payment Failed: $error', Colors.red);
        },
      );
    } else {
      _razorpay?.open(options);
    }
  }

  // --- Handlers for Mobile ---
  void _handlePaymentSuccess(razorpay_flutter.PaymentSuccessResponse response) {
    _showSnackBar("Payment Successful: ${response.paymentId}", Colors.green);
    updatepaymentstatus();
  }

  void _handlePaymentError(razorpay_flutter.PaymentFailureResponse response) {
    _showSnackBar("Payment Failed: ${response.message}", Colors.red);
  }

  void _handleExternalWallet(razorpay_flutter.ExternalWalletResponse response) {
    _showSnackBar("Wallet Selected: ${response.walletName}", Colors.blue);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> updatepaymentstatus() async {
    setState(() => _isProcessing = true);
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? ip = sh.getString("ip");

    if (ip != null) {
      try {
        await http.post(
          Uri.parse("$ip/make_payment"),
          body: {
            "id": sh.getString("id") ?? "",
            "cid": sh.getString("cid") ?? "",
            "amount": fee,
            "mode": _paymentMode,
          },
        );
      } catch (e) {
        debugPrint("Payment Update Error: $e");
      }
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CustomerNavigationBar()),
            (route) => false,
      );
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) _razorpay?.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = theme.cardColor;
    final hintColor = isDark ? Colors.white38 : Colors.grey[500];

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Checkout",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Amount Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text("Total Payable Amount", style: TextStyle(fontSize: 14, color: hintColor)),
                  const SizedBox(height: 8),
                  Text(
                    "₹$fee",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: hintColor),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user_outlined, size: 16, color: Colors.green.shade400),
                      const SizedBox(width: 8),
                      Text("Secured by Razorpay", style: TextStyle(fontSize: 12, color: hintColor)),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 32),
            Text("Select Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 16),

            // 2. Online Option
            _paymentTile(
              value: "online",
              title: "Online Payment",
              subtitle: "UPI, Cards, Wallets, NetBanking",
              icon: Icons.account_balance_wallet_outlined,
              isSelected: _paymentMode == "online",
              theme: theme,
              isDark: isDark,
            ),

            const SizedBox(height: 12),

            // 3. Offline Option
            _paymentTile(
              value: "offline",
              title: "Offline Payment",
              subtitle: "Pay directly to Distributor",
              icon: Icons.handshake_outlined,
              isSelected: _paymentMode == "offline",
              theme: theme,
              isDark: isDark,
            ),

            const SizedBox(height: 48),

            // 4. Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_paymentMode == 'online') {
                    _openCheckout();
                  } else {
                    updatepaymentstatus();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: theme.primaryColor.withOpacity(0.4),
                ),
                child: Text(
                  _paymentMode == 'online' ? "Pay Now" : "Confirm Booking",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentTile({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required ThemeData theme,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _paymentMode = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withOpacity(0.08) : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isSelected ? theme.primaryColor : (isDark ? Colors.white10 : Colors.grey.shade100),
              child: Icon(icon, color: isSelected ? Colors.white : Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? theme.primaryColor : null)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? theme.primaryColor : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
