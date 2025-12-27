

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/screens/Login_page.dart';
import '../../theme/colors.dart';
import '../../widgets/app_button.dart';
import 'forgotemail.dart';

class forgotpass extends StatefulWidget {
  const forgotpass({Key? key}) : super(key: key);

  @override
  State<forgotpass> createState() => _forgotpassState();
}

class _forgotpassState extends State<forgotpass> {
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmpassword = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _resetPassword() async {
    String pass = password.text;

    // 1. Validation
    if (pass.isEmpty || confirmpassword.text.isEmpty) {
      _showCustomDialog(
        title: "Missing Fields",
        message: "Please fill in all the password fields.",
        isSuccess: false,
      );
      return;
    }

    if (pass.length < 6) {
      _showCustomDialog(
        title: "Weak Password",
        message: "Password must be at least 6 characters long.",
        isSuccess: false,
      );
      return;
    }

    if (pass != confirmpassword.text) {
      _showCustomDialog(
        title: "Mismatch",
        message: "Passwords do not match.",
        isSuccess: false,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? ip = sh.getString("ip");
      String? email = sh.getString('email');

      var response = await http.post(
        Uri.parse("$ip/forgotpass"),
        body: {
          'email': email,
          'password': pass,
          'confirmpassword': confirmpassword.text
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        _showCustomDialog(
          title: "Success!",
          message: "Your password has been reset successfully.",
          isSuccess: true,
          onOkay: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const login_page()),
                  (route) => false,
            );
          },
        );
      } else {
        throw Exception("Server Error");
      }
    } catch (e) {
      _showCustomDialog(
        title: "Error",
        message: "Failed to reset password. Please try again.",
        isSuccess: false,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCustomDialog({
    required String title,
    required String message,
    required bool isSuccess,
    VoidCallback? onOkay,
  }) {
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
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle_rounded : Icons.warning_rounded,
                    size: 40,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey[600])),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onOkay != null) onOkay();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuccess ? Colors.green : Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isSuccess ? "Back to Login" : "Try Again", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white38 : Colors.grey[500];
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Reset Password", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_open_rounded, size: 50, color: isDark ? Colors.white : Colors.blue.shade400),
              ),
              const SizedBox(height: 30),
              Text("Create New Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 8),
              Text("Your new password must be different from previously used passwords.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: hintColor)),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 20, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    _buildPasswordField(
                      controller: password,
                      hint: "New Password",
                      isObscure: _obscurePassword,
                      textColor: textColor,
                      hintColor: hintColor!,
                      borderColor: borderColor,
                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      controller: confirmpassword,
                      hint: "Confirm Password",
                      isObscure: _obscureConfirmPassword,
                      textColor: textColor,
                      hintColor: hintColor,
                      borderColor: borderColor,
                      onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              AppButton(
                text: "Reset Password",
                onPressed: _resetPassword,
                isLoading: _isLoading,
                color: isDark ? Colors.white : Colors.black,
                textColor: isDark ? Colors.black : Colors.white,
                icon: Icons.vpn_key_outlined,
                isTrailingIcon: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isObscure,
    required VoidCallback onToggle,
    required Color textColor,
    required Color hintColor,
    required Color borderColor,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 14),
        prefixIcon: Icon(Icons.lock_outline, color: textColor.withOpacity(0.5), size: 20),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: textColor.withOpacity(0.5), size: 20),
          onPressed: onToggle,
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: textColor, width: 1)),
      ),
    );
  }
}