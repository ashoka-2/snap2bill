
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/screens/Login_page.dart';
import 'package:snap2bill/theme/colors.dart';
import 'package:snap2bill/widgets/Navbar.dart';
import '../../widgets/app_button.dart';
import 'forgototp.dart';

class forgotemail extends StatefulWidget {
  const forgotemail({Key? key}) : super(key: key);

  @override
  State<forgotemail> createState() => _forgotemailState();
}

class _forgotemailState extends State<forgotemail> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late Color successColor;

  late Color dangerColor;

  Future<void> _checkEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ip = prefs.getString("ip");

      var res = await http.post(
        Uri.parse("$ip/forgotemail"),
        body: {'email': emailController.text.trim()},
      );

      var decode = json.decode(res.body);

      if (decode["status"] == "ok") {
        await prefs.setString("email", emailController.text.trim());
        await prefs.setString("otpp", decode['otpp'].toString());
        // Save generation time for the OTP timer logic
        await prefs.setString("otp_generated_time", DateTime.now().toIso8601String());

        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (context) => const forgototp()));
      } else {
        _showCustomDialog(
          title: "Email Not Found",
          message: "This email address is not registered in our system.",
          isSuccess: false,
        );
      }
    } catch (e) {
      _showCustomDialog(
        title: "Connection Error",
        message: "Unable to connect to the server. Please check your IP settings.",
        isSuccess: false,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCustomDialog({required String title, required String message, required bool isSuccess}) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                  size: 60,
                  color: isSuccess ? successColor : dangerColor,
                ),
                const SizedBox(height: 20),
                Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? AppColors.WhiteColor: Colors.black87)),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[600])),
                const SizedBox(height: 24),
                AppButton(
                  text: "Retry",
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    dangerColor = AppColors.getDangerColor(context);
    successColor = AppColors.getSuccessColor(context);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
final textColor = AppColors.getTextColor(context);
final subTextColor = AppColors.getTextSubColor(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: ThemeNavbar(
        leadingIcon: Icons.arrow_back_ios_new,
          onLeadingPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())),
        title: 'Forgot Password',
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Header Icon
              Container(
                height: 100, width: 100,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : dangerColor.withValues(alpha:0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.email_outlined, size: 50, color: isDark ? AppColors.WhiteColor: dangerColor.withValues(alpha:0.5)),
              ),
              const SizedBox(height: 30),
              Text("Forgot Password", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 10),
              Text(
                "Enter your email address to receive a 6-digit verification code.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: subTextColor),
              ),
              const SizedBox(height: 40),

              // Responsive Input Card
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark? Colors.black.withValues(alpha:0.3): Colors.black.withValues(alpha:0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your email';
                          if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$").hasMatch(value)) return 'Enter a valid email';
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Email Address",
                          hintStyle: TextStyle(color: subTextColor),
                          prefixIcon: Icon(Icons.alternate_email, color: textColor.withValues(alpha:0.5)),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: theme.primaryColor, width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Styled Button
              AppButton(
                text: "Send OTP",
                onPressed: () => _checkEmail(),
                isLoading: _isLoading,
                color: isDark ? AppColors.WhiteColor: Colors.black,
                textColor: isDark ? AppColors.BlackColor: Colors.white,
              ),

              const SizedBox(height: 30),
              // Help Info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 16, color: subTextColor),
                  const SizedBox(width: 8),
                  Text("Check your spam folder for the code", style: TextStyle(fontSize: 12, color: subTextColor)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}