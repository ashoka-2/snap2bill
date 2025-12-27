
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/colors.dart';
import '../../widgets/app_button.dart';
import 'forgotemail.dart';
import 'forgotpass.dart';

class forgototp extends StatefulWidget {
  const forgototp({Key? key}) : super(key: key);

  @override
  State<forgototp> createState() => _forgototpState();
}

class _forgototpState extends State<forgototp> {
  // Digit controllers and focus nodes for the 6-box OTP entry
  final List<TextEditingController> otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  int _otpExpirySeconds = 600; // 10 Minutes
  Timer? _resendTimer;
  Timer? _expiryTimer;
  bool _isOtpExpired = false;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
    _startOtpExpiryTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _expiryTimer?.cancel();
    for (var c in otpControllers) c.dispose();
    for (var f in focusNodes) f.dispose();
    super.dispose();
  }

  void _startOtpExpiryTimer() {
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpExpirySeconds > 0) {
        setState(() => _otpExpirySeconds--);
      } else {
        setState(() => _isOtpExpired = true);
        timer.cancel();
      }
    });
  }

  void _startResendCooldown() {
    setState(() => _resendCooldown = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Verification Logic
  Future<void> _verifyOTP() async {
    String otp = otpControllers.map((c) => c.text).join();

    if (otp.length < 6) {
      _showCustomDialog(
          title: "Incomplete",
          message: "Please enter all 6 digits of the OTP.",
          isSuccess: false
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? storedOtp = sh.getString('otpp');

      if (otp == storedOtp) {
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (context) => const forgotpass()));
      } else {
        _showCustomDialog(
            title: "Invalid OTP",
            message: "The code you entered is incorrect. Please try again.",
            isSuccess: false
        );
      }
    } catch (e) {
      _showCustomDialog(
          title: "Error",
          message: "An unexpected error occurred. Please try again.",
          isSuccess: false
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _isResending = true);
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? ip = sh.getString("ip");
      String? email = sh.getString("email");

      var res = await http.post(
        Uri.parse("$ip/forgotemail"),
        body: {'email': email},
      );

      var decode = json.decode(res.body);
      if (decode["status"] == "ok") {
        await sh.setString("otpp", decode['otpp'].toString());
        _startResendCooldown();
        setState(() {
          _otpExpirySeconds = 600;
          _isOtpExpired = false;
        });
        _showCustomDialog(title: "Sent!", message: "A new OTP has been sent to your email.", isSuccess: true);
      }
    } catch (e) {
      _showCustomDialog(title: "Failed", message: "Check your internet connection.", isSuccess: false);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showCustomDialog({required String title, required String message, required bool isSuccess}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isSuccess ? Icons.check_circle : Icons.error_outline,
                  size: 60, color: isSuccess ? Colors.green : Colors.red),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              AppButton(text: "OK", onPressed: () => Navigator.pop(context))
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];

    // Responsive box size calculation
    double screenWidth = MediaQuery.of(context).size.width;
    double boxWidth = (screenWidth - 100) / 6;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              height: 100, width: 100,
              decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.blue.shade50,
                  shape: BoxShape.circle),
              child: Icon(Icons.mark_email_read_outlined, size: 50,
                  color: isDark ? Colors.white : Colors.blue.shade400),
            ),
            const SizedBox(height: 30),
            Text("Verify OTP", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 10),
            Text("We sent a code to your email", style: TextStyle(color: subTextColor)),
            const SizedBox(height: 40),

            // OTP Input Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) => _buildOtpBox(index, boxWidth, theme, textColor)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isOtpExpired ? "Code Expired" : "Expires in ${_formatTime(_otpExpirySeconds)}",
                    style: TextStyle(
                        color: _isOtpExpired ? Colors.red : Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // FIXED APP BUTTON LOGIC
            AppButton(
              text: _isOtpExpired ? "OTP EXPIRED" : "Verify & Proceed",
              onPressed: (_isOtpExpired || _isLoading)
                  ? () {} // Use empty function to prevent "null" error if button is non-nullable
                  : () { _verifyOTP(); },
              isLoading: _isLoading,
              color: isDark ? Colors.white : Colors.black,
              textColor: isDark ? Colors.black : Colors.white,
            ),

            const SizedBox(height: 30),
            _resendCooldown > 0
                ? Text("Resend code in $_resendCooldown s", style: TextStyle(color: subTextColor))
                : TextButton(
              onPressed: _isResending ? () {} : () => _resendOTP(),
              child: const Text("Resend OTP",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index, double width, ThemeData theme, Color textColor) {
    return Container(
      width: width.clamp(40.0, 60.0), // Responsive constraint
      height: 60,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? const Color(0xFF2C2C2C) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: focusNodes[index].hasFocus ? Colors.blue : Colors.transparent,
            width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),

        child: Center(
          child: TextField(
            controller: otpControllers[index],
            focusNode: focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
            decoration: const InputDecoration(counterText: "", border: InputBorder.none),
            onChanged: (value) {
              // Focus navigation logic
              if (value.isNotEmpty && index < 5) {
                focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                focusNodes[index - 1].requestFocus();
              }
              setState(() {}); // Updates border colors on focus change
            },
          ),
        ),
      ),
    );
  }
}