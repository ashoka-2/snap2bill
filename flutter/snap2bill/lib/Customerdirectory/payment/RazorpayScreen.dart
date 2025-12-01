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
      'amount': '${int.parse(fee) * 100}',
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
        "cid": sh.getString("cid"),
        "amount": sh.getString("amount"),
        "mode": _paymentMode,
      },
    );
    Navigator.push(context, MaterialPageRoute(builder: (context) => customer_home_page()));
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
