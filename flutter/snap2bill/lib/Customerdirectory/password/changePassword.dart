import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/screens/login_page.dart';

// Make sure these point to your actual file locations
import '../../theme/colors.dart';
import '../../widgets/app_button.dart';

class changePassword extends StatelessWidget {
  const changePassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const changePasswordSub();
  }
}

class changePasswordSub extends StatefulWidget {
  const changePasswordSub({Key? key}) : super(key: key);

  @override
  State<changePasswordSub> createState() => _changePasswordSubState();
}

class _changePasswordSubState extends State<changePasswordSub> {
  final TextEditingController oldpassword = TextEditingController();
  final TextEditingController newpassword = TextEditingController();
  final TextEditingController confirmpassword = TextEditingController();

  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // --- Update Logic ---
  Future<void> _updatePassword() async {
    String pass = newpassword.text;

    // 1. Basic Empty Check
    if (oldpassword.text.isEmpty || pass.isEmpty || confirmpassword.text.isEmpty) {
      _showCustomDialog(
        title: "Missing Fields",
        message: "Please fill in all the password fields.",
        isSuccess: false,
      );
      return;
    }

    // 2. STRONG PASSWORD VALIDATION
    // Regex: At least 1 lowercase, 1 uppercase, 1 digit, min 6 chars
    RegExp strongPasswordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$');

    if (!strongPasswordRegex.hasMatch(pass)) {
      _showCustomDialog(
        title: "Weak Password",
        message: "Password must contain:\n• At least 1 Uppercase Letter\n• At least 1 Lowercase Letter\n• At least 1 Number\n• Minimum 6 characters",
        isSuccess: false,
      );
      return;
    }

    // 3. Match New & Confirm
    if (pass != confirmpassword.text) {
      _showCustomDialog(
        title: "Mismatch",
        message: "New password and Confirm password do not match.",
        isSuccess: false,
      );
      return;
    }

    // 4. Check Local Old Password (using 'pwd' key for customer)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedOldPass = prefs.getString("pwd");

    if (storedOldPass != null && oldpassword.text != storedOldPass) {
      _showCustomDialog(
        title: "Incorrect Password",
        message: "The old password you entered is incorrect.",
        isSuccess: false,
      );
      return;
    }

    // 5. API Call
    setState(() => _isLoading = true);

    try {
      String? ip = prefs.getString("ip");
      String? cid = prefs.getString("cid"); // Using CID for customer

      if (ip != null && cid != null) {
        var response = await http.post(
            Uri.parse("$ip/customer_change_password"), // Customer Endpoint
            body: {
              'cid': cid,
              "newpassword": pass,
            }
        );

        if (response.statusCode == 200) {
          if (!mounted) return;

          _showCustomDialog(
              title: "Success!",
              message: "Your password has been updated successfully. Please login again.",
              isSuccess: true,
              onOkay: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const login_page()),
                        (route) => false
                );
              }
          );
        } else {
          _showCustomDialog(
              title: "Failed",
              message: "Server returned error: ${response.statusCode}",
              isSuccess: false
          );
        }
      } else {
        _showCustomDialog(
            title: "Session Error",
            message: "Please logout and login again.",
            isSuccess: false
        );
      }
    } catch (e) {
      _showCustomDialog(
          title: "Connection Error",
          message: "Could not connect to server: $e",
          isSuccess: false
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- CUSTOM DIALOG ---
  void _showCustomDialog({
    required String title,
    required String message,
    required bool isSuccess,
    VoidCallback? onOkay,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          backgroundColor: theme.cardColor,
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    height: 1.5,
                  ),
                ),
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
                    child: Text(
                      isSuccess ? "Continue to Login" : "Try Again",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
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

    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = theme.cardColor;
    final hintColor = isDark ? Colors.white38 : Colors.grey[500];
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;
    final inputFillColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[50];
    final buttonColor = isDark ? Colors.white : Colors.black;
    final buttonTextColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          "Change Password",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
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
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.teal.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    Icons.lock_reset_rounded,
                    size: 50,
                    color: isDark ? Colors.white : Colors.teal.shade400
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Secure Account",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "Must include upper, lower case & number.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: hintColor),
              ),
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPasswordField(
                      controller: oldpassword,
                      hint: "Current Password",
                      isObscure: _obscureOld,
                      textColor: textColor,
                      hintColor: hintColor!,
                      borderColor: borderColor,
                      onToggle: () => setState(() => _obscureOld = !_obscureOld),
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      controller: newpassword,
                      hint: "New Password",
                      isObscure: _obscureNew,
                      textColor: textColor,
                      hintColor: hintColor,
                      borderColor: borderColor,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      controller: confirmpassword,
                      hint: "Confirm New Password",
                      isObscure: _obscureConfirm,
                      textColor: textColor,
                      hintColor: hintColor,
                      borderColor: borderColor,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              AppButton(
                text: "Update Password",
                onPressed: _updatePassword,
                isLoading: _isLoading,
                color: buttonColor,
                textColor: buttonTextColor,
                icon: Icons.check_circle_outline,
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
          icon: Icon(
              isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: textColor.withOpacity(0.5),
              size: 20
          ),
          onPressed: onToggle,
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: textColor, width: 1),
        ),
      ),
    );
  }
}