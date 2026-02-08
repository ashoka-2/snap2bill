// import 'dart:convert';
// import 'dart:io'; // Import for SocketException
// import 'dart:async'; // Import for TimeoutException
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart' as lottie;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// // Use package imports to avoid duplicate canonical names
// import 'package:snap2bill/screens/registration_page.dart';
//
// // Shared resources (colors and button widget)
// import 'package:snap2bill/theme/colors.dart';
// import 'package:snap2bill/widgets/CustomerNavigationBar.dart';
// import 'package:snap2bill/widgets/app_button.dart';
// import 'package:snap2bill/widgets/distributorNavigationbar.dart';
//
// import '../password/forgotemail.dart';
// import '../widgets/SnackBar.dart';
//
// const List<Color> _blobGradient1 = AppColors.blobGradient1;
// const List<Color> _blobGradient2 = AppColors.blobGradient2;
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage>
//     with SingleTickerProviderStateMixin {
//
//   final TextEditingController username = TextEditingController(text: "s526@tlsy.amritavidyalayam.edu.in");
//   final TextEditingController password = TextEditingController(text: "Password123");
//
//   // UI state
//   bool _obscureText = true;
//   bool _isLoading = false;
//   bool _usernameError = false;
//   bool _passwordError = false;
//   String? _invalidError;
//
//   // Simple shake animation for error feedback
//   late AnimationController _shakeController;
//   late Animation<double> _shakeAnim;
//
//   late Color successColor;
//   late Color dangerColor;
//
//   @override
//   void initState() {
//     super.initState();
//     _shakeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     // small animation value used to compute a shake offset
//     _shakeAnim = Tween<double>(begin: 0, end: 2 * math.pi).animate(
//       CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
//     );
//   }
//
//   @override
//   void dispose() {
//     _shakeController.dispose();
//     username.dispose();
//     password.dispose();
//     super.dispose();
//   }
//
//   /// The login function with specific error handling
//   Future<void> _login() async {
//     // 1. Reset Errors
//     setState(() {
//       _usernameError = username.text.trim().isEmpty;
//       _passwordError = password.text.trim().isEmpty;
//       _invalidError = null;
//     });
//
//     if (_usernameError || _passwordError) {
//       _shakeController.forward(from: 0);
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String ip = prefs.getString("ip") ?? "";
//
//       // Check if IP is set
//       if (ip.isEmpty) {
//         throw const SocketException("IP not found");
//       }
//
//       // 2. Network Request with Timeout
//       final response = await http.post(
//         Uri.parse('$ip/login_page'),
//         body: {
//           'username': username.text.trim(),
//           'password': password.text.trim(),
//         },
//       ).timeout(const Duration(seconds: 5)); // 5s timeout
//
//       // 3. Handle Status Code 200 (Server Reached)
//       if (response.statusCode == 200) {
//         final decoded = json.decode(response.body);
//         String status = decoded['status'] ?? "";
//
//         // --- SUCCESS LOGIC ---
//         if (status == 'custok') {
//           await prefs.remove("uid");
//           await prefs.setString("cid", decoded['cid'].toString());
//           await prefs.setString("pwd", password.text); // Note: Saving plain text password is insecure
//
//           if (!mounted) return;
//           CustomSnackBar.show(context, "Login Successful",
//               backgroundColor: successColor);
//
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => CustomerNavigationBar(initialIndex: 0,)),
//           );
//         } else if (status == 'distok') {
//           await prefs.remove("cid");
//           await prefs.setString("uid", decoded['uid'].toString());
//           await prefs.setString("pwd1", password.text);
//
//           if (!mounted) return;
//           CustomSnackBar.show(context, "Login Successful",
//               backgroundColor: successColor);
//
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => DistributorNavigationBar(initialIndex: 0,)),
//           );
//         }
//
//         // --- FAILURE LOGIC (Specific Messages) ---
//         else {
//           String msg = decoded['message']?.toString().toLowerCase() ?? "";
//
//           // Check backend message to show specific user error
//           if (msg.contains("password")) {
//             setState(() => _invalidError = "Password is wrong");
//           } else if (msg.contains("email") || msg.contains("user") || msg.contains("account")) {
//             setState(() => _invalidError = "Email is wrong");
//           } else {
//             setState(() => _invalidError = "Invalid credentials");
//           }
//           _shakeController.forward(from: 0);
//         }
//       } else {
//         // Handle non-200 status codes gracefully
//         setState(() => _invalidError = "Server Error (${response.statusCode})");
//         _shakeController.forward(from: 0);
//       }
//     } on SocketException {
//       // This catches "IP is wrong" or "Server Down"
//       setState(() => _invalidError = "Connection error");
//       _shakeController.forward(from: 0);
//     } on TimeoutException {
//       // This catches slow connection/wrong IP
//       setState(() => _invalidError = "Connection timed out");
//       _shakeController.forward(from: 0);
//     } catch (e) {
//       // Fallback for other errors (e.g., JSON parsing)
//       setState(() => _invalidError = "An unexpected error occurred");
//       _shakeController.forward(from: 0);
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     successColor = AppColors.getSuccessColor(context);
//     dangerColor = AppColors.getDangerColor(context);
//     final bgColor = AppColors.getScaffoldBg(context);
//     final cardColor = AppColors.getCardColor(context);
//     final textColor = AppColors.getTextColor(context);
//     final subTextColor = AppColors.getTextSubColor(context);
//     final inputFill = AppColors.getInputFieldColor(context);
//     final iconColor = AppColors.getIconColor(context);
//     final primaryColor = AppColors.getPrimaryColor(context);
//
//     return Scaffold(
//       backgroundColor: bgColor,
//       body: Stack(
//         children: [
//           // Background decorative blobs
//           Positioned(
//             top: -100,
//             left: -50,
//             child: _buildBlob(250, _blobGradient1),
//           ),
//           Positioned(
//             top: 50,
//             right: -80,
//             child: _buildBlob(180, _blobGradient2),
//           ),
//
//           Column(
//             children: [
//               // leave space on top for blob area
//               SizedBox(height: MediaQuery.of(context).size.height * 0.22),
//
//               // Main card sheet
//               Expanded(
//                 child: ClipRRect(
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(40),
//                     topRight: Radius.circular(40),
//                   ),
//                   child: Container(
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: cardColor,
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(40),
//                         topRight: Radius.circular(40),
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withValues(alpha:0.1),
//                           blurRadius: 20,
//                           offset: const Offset(0, -5),
//                         ),
//                       ],
//                     ),
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 30,
//                         vertical: 40,
//                       ),
//                       child: AnimatedBuilder(
//                         animation: _shakeAnim,
//                         builder: (context, child) {
//                           // Only shake if there is an error
//                           final offsetX = (_usernameError || _passwordError || _invalidError != null)
//                               ? math.sin(_shakeAnim.value) * 10
//                               : 0.0;
//                           return Transform.translate(
//                             offset: Offset(offsetX, 0),
//                             child: child,
//                           );
//                         },
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Header
//                             Center(
//                               child: Column(
//                                 children: [
//                                   lottie.Lottie.asset(
//                                       'assets/lotties/Welcome.json',
//                                       height: 150
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Text(
//                                     "Enter your details to access your account",
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: subTextColor,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 40),
//
//                             // Username field
//                             _buildInputField(
//                               controller: username,
//                               label: "Email / Username",
//                               icon: Icons.person_outline_rounded,
//                               isError: _usernameError,
//                               fillColor: inputFill,
//                               textColor: textColor,
//                               hintColor: subTextColor,
//                               themePrimary: iconColor,
//                             ),
//                             const SizedBox(height: 20),
//
//                             // Password field
//                             _buildInputField(
//                               controller: password,
//                               label: "Password",
//                               icon: Icons.lock_outline_rounded,
//                               isObscure: true,
//                               isError: _passwordError,
//                               fillColor: inputFill,
//                               textColor: textColor,
//                               hintColor: subTextColor,
//                               themePrimary:iconColor,
//                             ),
//
//                             // SPECIFIC ERROR MESSAGE DISPLAY
//                             if (_invalidError != null) ...[
//                               const SizedBox(height: 15),
//                               Container(
//                                 width: double.infinity,
//                                 padding: const EdgeInsets.all(10),
//                                 decoration: BoxDecoration(
//                                     color: dangerColor.withValues(alpha:0.1),
//                                     borderRadius: BorderRadius.circular(8),
//                                     border: Border.all(color: dangerColor.withValues(alpha:0.5))
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                      Icon(Icons.error_outline, color: dangerColor, size: 18),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       _invalidError!,
//                                       style:  TextStyle(
//                                           color: dangerColor,
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: 13
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                             const SizedBox(height: 10),
//
//                             // Forgot password
//                             Align(
//                               alignment: Alignment.centerRight,
//                               child: TextButton(
//                                 onPressed: () {
//
//                                   Navigator.push(context, MaterialPageRoute(builder: (context)=>forgotemail()));
//
//
//
//                                 },
//                                 child: Text(
//                                   "Forgot password?",
//                                   style: TextStyle(
//                                     color: primaryColor,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 30),
//
//                             // Sign in button
//                             AppButton(
//                               text: "Sign in",
//                               isLoading: _isLoading,
//                               onPressed: _login,
//                             ),
//                             const SizedBox(height: 40),
//
//                             // Divider
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Divider(
//                                     color: subTextColor.withValues(alpha:0.3),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 10,
//                                   ),
//                                   child: Text(
//                                     "OR",
//                                     style: TextStyle(
//                                         color: subTextColor,
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Divider(
//                                     color: subTextColor.withValues(alpha:0.3),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 30),
//
//                             // Register links
//                             Center(
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   _buildRegisterLink(
//                                     "Register Distributor",
//                                         () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                           const RegistrationPage(isDistributor: true),
//                                         ),
//                                       );
//                                     },
//                                     primaryColor,
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                     ),
//                                     child: Text("|", style: TextStyle(color: subTextColor)),
//                                   ),
//                                   _buildRegisterLink("Register Customer", () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                         const RegistrationPage(isDistributor: false),
//                                       ),
//                                     );
//                                   }, primaryColor),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- Helper widgets ---
//
//   Widget _buildBlob(double size, List<Color> colors) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: LinearGradient(
//           colors: colors,
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool isObscure = false,
//     bool isError = false,
//     required Color fillColor,
//     required Color textColor,
//     required Color hintColor,
//     required Color themePrimary,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: hintColor,
//             fontWeight: FontWeight.w500,
//             fontSize: 13,
//           ),
//         ),
//         const SizedBox(height: 8),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             decoration: BoxDecoration(
//               color: fillColor,
//               borderRadius: BorderRadius.circular(12),
//               border: isError
//                   ? Border.all(color: dangerColor, width: 1.5)
//                   : null,
//             ),
//             child: TextField(
//               controller: controller,
//               obscureText: isObscure ? _obscureText : false,
//               style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
//               onChanged: (_) {
//                 if (isError || _invalidError != null) {
//                   setState(() {
//                     _usernameError = false;
//                     _passwordError = false;
//                     _invalidError = null;
//                   });
//                 }
//               },
//               decoration: InputDecoration(
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 16,
//                 ),
//                 prefixIcon: Icon(icon, color: themePrimary),
//                 suffixIcon: isObscure
//                     ? IconButton(
//                   icon: Icon(
//                     _obscureText
//                         ? Icons.visibility_off
//                         : Icons.visibility,
//                     color: hintColor,
//                   ),
//                   onPressed: () =>
//                       setState(() => _obscureText = !_obscureText),
//                 )
//                     : null,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildRegisterLink(
//       String text,
//       VoidCallback onTap,
//       Color primaryColor,
//       ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Text(
//         text,
//         style: TextStyle(
//           color: primaryColor,
//           fontWeight: FontWeight.bold,
//           fontSize: 13,
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import for SVG
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:snap2bill/screens/registration_page.dart';
import 'package:snap2bill/theme/colors.dart';
import 'package:snap2bill/widgets/CustomerNavigationBar.dart';
import 'package:snap2bill/widgets/app_button.dart';
import 'package:snap2bill/widgets/distributorNavigationbar.dart';
import '../password/forgotemail.dart';
import '../widgets/SnackBar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {

  // Controllers
  final TextEditingController username = TextEditingController(text: "s526@tlsy.amritavidyalayam.edu.in");
  final TextEditingController password = TextEditingController(text: "Password123");

  // UI state
  bool _obscureText = true;
  bool _isLoading = false;
  bool _usernameError = false;
  bool _passwordError = false;
  String? _invalidError;

  // Animation
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  // Colors
  late Color successColor, dangerColor, primaryColor;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
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

  /// ----------------------------------------------------------------
  /// LOGIN LOGIC
  /// ----------------------------------------------------------------
  Future<void> _login() async {
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "";

      if (ip.isEmpty) throw const SocketException("IP not found");

      final response = await http.post(
        Uri.parse('$ip/login_page'),
        body: {
          'username': username.text.trim(),
          'password': password.text.trim(),
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        String status = decoded['status'] ?? "";

        if (status == 'custok') {
          await prefs.remove("uid");
          await prefs.setString("cid", decoded['cid'].toString());
          await prefs.setString("pwd", password.text);

          if (!mounted) return;
          CustomSnackBar.show(context, "Login Successful", backgroundColor: successColor);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CustomerNavigationBar(initialIndex: 0)));

        } else if (status == 'distok') {
          await prefs.remove("cid");
          await prefs.setString("uid", decoded['uid'].toString());
          await prefs.setString("pwd1", password.text);

          if (!mounted) return;
          CustomSnackBar.show(context, "Login Successful", backgroundColor: successColor);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DistributorNavigationBar(initialIndex: 0)));

        } else {
          String msg = decoded['message']?.toString().toLowerCase() ?? "";
          setState(() {
            _invalidError = msg.contains("password") ? "Incorrect password" :
            (msg.contains("email") || msg.contains("user")) ? "Account not found" : "Invalid credentials";
          });
          _shakeController.forward(from: 0);
        }
      } else {
        setState(() => _invalidError = "Server Error (${response.statusCode})");
        _shakeController.forward(from: 0);
      }
    } catch (e) {
      setState(() => _invalidError = "Connection Failed");
      _shakeController.forward(from: 0);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// ----------------------------------------------------------------
  /// BUILD UI
  /// ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Init Colors
    successColor = AppColors.getSuccessColor(context);
    dangerColor = AppColors.getDangerColor(context);
    primaryColor = AppColors.getPrimaryColor(context);
    final bgColor = AppColors.getScaffoldBg(context);
    final cardColor = AppColors.getCardColor(context);
    final textColor = AppColors.getTextColor(context);
    final subTextColor = AppColors.getTextSubColor(context);
    final inputFill = AppColors.getInputFieldColor(context);
    final iconColor = AppColors.getIconColor(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. FIXED BACKGROUND HEADER (Stays at top)
          Container(
            height: 350, // Fixed height for background
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),

          // 2. SCROLLABLE CONTENT (Covers everything)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [

                    // --- TOP HEADER CONTENT ---
                    const SizedBox(height: 20),

                    // 🚀 LOGO REPLACEMENT
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        'assets/images/snap2bill_logo.svg',
                        height: 100,
                      ),
                    ),

                    const SizedBox(height: 15),
                    const Text(
                      "Welcome Back",
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Sign in to continue",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 40), // Spacing between header and card

                    // --- LOGIN CARD ---
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: _shakeAnim,
                        builder: (context, child) {
                          final offsetX = (_usernameError || _passwordError || _invalidError != null)
                              ? math.sin(_shakeAnim.value) * 10
                              : 0.0;
                          return Transform.translate(offset: Offset(offsetX, 0), child: child);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
                            const SizedBox(height: 25),

                            // Username
                            _buildInput(username, "Email / Username", Icons.alternate_email_rounded, inputFill, textColor, subTextColor, iconColor, false, _usernameError),
                            const SizedBox(height: 20),

                            // Password
                            _buildInput(password, "Password", Icons.lock_outline_rounded, inputFill, textColor, subTextColor, iconColor, true, _passwordError),

                            // Error Msg
                            if (_invalidError != null) ...[
                              const SizedBox(height: 15),
                              Container(
                                padding: const EdgeInsets.all(12),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: dangerColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(_invalidError!, style: TextStyle(color: dangerColor, fontWeight: FontWeight.bold)),
                              ),
                            ],

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => forgotemail())),
                                child: Text("Forgot Password?", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 🚀 SIGN IN BUTTON WITH ICON
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: AppButton(
                                  text: "Sign In",
                                  icon: Icons.login_rounded, // Icon Added
                                  isTrailingIcon: true,      // Icon on right side
                                  isLoading: _isLoading,
                                  onPressed: _login
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- REGISTER LINKS ---
                    Column(
                      children: [
                        Text("Don't have an account?", style: TextStyle(color: subTextColor, fontSize: 14)),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 🚀 BETTER REGISTER ICONS
                            _buildRegisterBtn("Customer", Icons.person_add_alt_1_rounded, false),
                            const SizedBox(width: 15),
                            _buildRegisterBtn("Distributor", Icons.storefront_rounded, true),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ----------------------------------------------------------------
  /// WIDGET HELPERS
  /// ----------------------------------------------------------------

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, Color fill, Color text, Color hint, Color iconC, bool isPass, bool isErr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: hint, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isErr ? dangerColor : Colors.transparent, width: 1.5),
          ),
          child: TextField(
            controller: ctrl,
            obscureText: isPass ? _obscureText : false,
            style: TextStyle(color: text, fontWeight: FontWeight.w600),
            onChanged: (_) {
              if (isErr || _invalidError != null) setState(() { _usernameError = false; _passwordError = false; _invalidError = null; });
            },
            decoration: InputDecoration(
              hintText: "Enter $label",
              hintStyle: TextStyle(color: hint.withOpacity(0.5)),
              prefixIcon: Icon(icon, color: iconC),
              suffixIcon: isPass ? IconButton(
                icon: Icon(_obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: iconC),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterBtn(String label, IconData icon, bool isDist) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationPage(isDistributor: isDist))),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: primaryColor), // Slightly larger icon
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}