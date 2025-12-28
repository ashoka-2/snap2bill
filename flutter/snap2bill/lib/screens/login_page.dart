import 'dart:convert';
import 'dart:io'; // Import for SocketException
import 'dart:async'; // Import for TimeoutException
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Use package imports to avoid duplicate canonical names
import 'package:snap2bill/screens/registration_page.dart';

// Shared resources (colors and button widget)
import 'package:snap2bill/theme/colors.dart';
import 'package:snap2bill/widgets/CustomerNavigationBar.dart';
import 'package:snap2bill/widgets/app_button.dart';
import 'package:snap2bill/widgets/distributorNavigationbar.dart';

import '../password/forgotemail.dart';

const List<Color> _blobGradient1 = AppColors.blobGradient1;
const List<Color> _blobGradient2 = AppColors.blobGradient2;

class login_page extends StatefulWidget {
  const login_page({Key? key}) : super(key: key);

  @override
  State<login_page> createState() => _login_pageState();
}

class _login_pageState extends State<login_page>
    with SingleTickerProviderStateMixin {

  final TextEditingController username = TextEditingController(text: "s526@tlsy.amritavidyalayam.edu.in");
  final TextEditingController password = TextEditingController(text: "Password123");

  // UI state
  bool _obscureText = true;
  bool _isLoading = false;
  bool _usernameError = false;
  bool _passwordError = false;
  String? _invalidError;

  // Simple shake animation for error feedback
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    // small animation value used to compute a shake offset
    _shakeAnim = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    username.dispose();
    password.dispose();
    super.dispose();
  }

  /// The login function with specific error handling
  Future<void> _login() async {
    // 1. Reset Errors
    setState(() {
      _usernameError = username.text.trim().isEmpty;
      _passwordError = password.text.trim().isEmpty;
      _invalidError = null;
    });

    if (_usernameError || _passwordError) {
      _shakeController.forward(from: 0);
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? "";

      // Check if IP is set
      if (ip.isEmpty) {
        throw const SocketException("IP not found");
      }

      // 2. Network Request with Timeout
      final response = await http.post(
        Uri.parse('$ip/login_page'),
        body: {
          'username': username.text.trim(),
          'password': password.text.trim(),
        },
      ).timeout(const Duration(seconds: 5)); // 5s timeout

      // 3. Handle Status Code 200 (Server Reached)
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        String status = decoded['status'] ?? "";

        // --- SUCCESS LOGIC ---
        if (status == 'custok') {
          await sh.remove("uid");
          await sh.setString("cid", decoded['cid'].toString());
          await sh.setString("pwd", password.text); // Note: Saving plain text password is insecure

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login successful'), backgroundColor: Colors.green)
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CustomerNavigationBar(initialIndex: 0,)),
          );
        } else if (status == 'distok') {
          await sh.remove("cid");
          await sh.setString("uid", decoded['uid'].toString());
          await sh.setString("pwd1", password.text);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login successful'), backgroundColor: Colors.green)
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DistributorNavigationBar(initialIndex: 0,)),
          );
        }

        // --- FAILURE LOGIC (Specific Messages) ---
        else {
          String msg = decoded['message']?.toString().toLowerCase() ?? "";

          // Check backend message to show specific user error
          if (msg.contains("password")) {
            setState(() => _invalidError = "Password is wrong");
          } else if (msg.contains("email") || msg.contains("user") || msg.contains("account")) {
            setState(() => _invalidError = "Email is wrong");
          } else {
            setState(() => _invalidError = "Invalid credentials");
          }
          _shakeController.forward(from: 0);
        }
      } else {
        // Handle non-200 status codes gracefully
        setState(() => _invalidError = "Server Error (${response.statusCode})");
        _shakeController.forward(from: 0);
      }
    } on SocketException {
      // This catches "IP is wrong" or "Server Down"
      setState(() => _invalidError = "Connection error");
      _shakeController.forward(from: 0);
    } on TimeoutException {
      // This catches slow connection/wrong IP
      setState(() => _invalidError = "Connection timed out");
      _shakeController.forward(from: 0);
    } catch (e) {
      // Fallback for other errors (e.g., JSON parsing)
      setState(() => _invalidError = "An unexpected error occurred");
      _shakeController.forward(from: 0);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final subTextColor = isDark ? AppColors.textSubDark : AppColors.textSubLight;
    final inputFill = isDark ? AppColors.inputFillDark : AppColors.inputFillLight;
    final iconColor = isDark?AppColors.iconColorDark:AppColors.iconColorLight;
    final primaryColor = isDark?AppColors.primaryLight:AppColors.primaryDark;
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background decorative blobs
          Positioned(
            top: -100,
            left: -50,
            child: _buildBlob(250, _blobGradient1),
          ),
          Positioned(
            top: 50,
            right: -80,
            child: _buildBlob(180, _blobGradient2),
          ),

          Column(
            children: [
              // leave space on top for blob area
              SizedBox(height: MediaQuery.of(context).size.height * 0.22),

              // Main card sheet
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 40,
                      ),
                      child: AnimatedBuilder(
                        animation: _shakeAnim,
                        builder: (context, child) {
                          // Only shake if there is an error
                          final offsetX = (_usernameError || _passwordError || _invalidError != null)
                              ? math.sin(_shakeAnim.value) * 10
                              : 0.0;
                          return Transform.translate(
                            offset: Offset(offsetX, 0),
                            child: child,
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Center(
                              child: Column(
                                children: [
                                  lottie.Lottie.asset(
                                      'assets/lotties/Welcome.json',
                                      height: 150
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Enter your details to access your account",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: subTextColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Username field
                            _buildInputField(
                              controller: username,
                              label: "Email / Username",
                              icon: Icons.person_outline_rounded,
                              isError: _usernameError,
                              fillColor: inputFill,
                              textColor: textColor,
                              hintColor: subTextColor,
                              themePrimary: iconColor,
                            ),
                            const SizedBox(height: 20),

                            // Password field
                            _buildInputField(
                              controller: password,
                              label: "Password",
                              icon: Icons.lock_outline_rounded,
                              isObscure: true,
                              isError: _passwordError,
                              fillColor: inputFill,
                              textColor: textColor,
                              hintColor: subTextColor,
                              themePrimary:iconColor,
                            ),

                            // SPECIFIC ERROR MESSAGE DISPLAY
                            if (_invalidError != null) ...[
                              const SizedBox(height: 15),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.redAccent.withOpacity(0.5))
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      _invalidError!,
                                      style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {

                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>forgotemail()));



                                },
                                child: Text(
                                  "Forgot password?",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Sign in button
                            AppButton(
                              text: "Sign in",
                              isLoading: _isLoading,
                              onPressed: _login,
                            ),
                            const SizedBox(height: 40),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: subTextColor.withOpacity(0.3),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    "OR",
                                    style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: subTextColor.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // Register links
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildRegisterLink(
                                    "Register Distributor",
                                        () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                          const RegistrationPage(isDistributor: true),
                                        ),
                                      );
                                    },
                                    primaryColor,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text("|", style: TextStyle(color: subTextColor)),
                                  ),
                                  _buildRegisterLink("Register Customer", () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const RegistrationPage(isDistributor: false),
                                      ),
                                    );
                                  }, primaryColor),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helper widgets ---

  Widget _buildBlob(double size, List<Color> colors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isObscure = false,
    bool isError = false,
    required Color fillColor,
    required Color textColor,
    required Color hintColor,
    required Color themePrimary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: hintColor,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(12),
              border: isError
                  ? Border.all(color: Colors.red, width: 1.5)
                  : null,
            ),
            child: TextField(
              controller: controller,
              obscureText: isObscure ? _obscureText : false,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              onChanged: (_) {
                if (isError || _invalidError != null) {
                  setState(() {
                    _usernameError = false;
                    _passwordError = false;
                    _invalidError = null;
                  });
                }
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                prefixIcon: Icon(icon, color: themePrimary),
                suffixIcon: isObscure
                    ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: hintColor,
                  ),
                  onPressed: () =>
                      setState(() => _obscureText = !_obscureText),
                )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink(
      String text,
      VoidCallback onTap,
      Color primaryColor,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}