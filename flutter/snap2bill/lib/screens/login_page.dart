//
//
// import 'dart:convert';
// import 'dart:io';
// import 'dart:async';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Import for SVG
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import 'package:snap2bill/screens/registration_page.dart';
// import 'package:snap2bill/theme/colors.dart';
// import 'package:snap2bill/widgets/CustomerNavigationBar.dart';
// import 'package:snap2bill/widgets/app_button.dart';
// import 'package:snap2bill/widgets/distributorNavigationbar.dart';
// import '../password/forgotemail.dart';
// import '../widgets/SnackBar.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
//
//   // Controllers
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
//   // Animation
//   late AnimationController _shakeController;
//   late Animation<double> _shakeAnim;
//
//   // Colors
//   late Color successColor, dangerColor, primaryColor;
//
//   @override
//   void initState() {
//     super.initState();
//     _shakeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
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
//   /// ----------------------------------------------------------------
//   /// LOGIN LOGIC
//   /// ----------------------------------------------------------------
//   Future<void> _login() async {
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
//       if (ip.isEmpty) throw const SocketException("IP not found");
//
//       final response = await http.post(
//         Uri.parse('$ip/login_page'),
//         body: {
//           'username': username.text.trim(),
//           'password': password.text.trim(),
//         },
//       ).timeout(const Duration(seconds: 5));
//
//       if (response.statusCode == 200) {
//         final decoded = json.decode(response.body);
//         String status = decoded['status'] ?? "";
//
//         if (status == 'custok') {
//           await prefs.remove("uid");
//           await prefs.setString("cid", decoded['cid'].toString());
//           await prefs.setString("pwd", password.text);
//
//           if (!mounted) return;
//           CustomSnackBar.show(context, "Login Successful", backgroundColor: successColor);
//           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CustomerNavigationBar(initialIndex: 0)));
//
//         } else if (status == 'distok') {
//           await prefs.remove("cid");
//           await prefs.setString("uid", decoded['uid'].toString());
//           await prefs.setString("pwd1", password.text);
//
//           if (!mounted) return;
//           CustomSnackBar.show(context, "Login Successful", backgroundColor: successColor);
//           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DistributorNavigationBar(initialIndex: 0)));
//
//         } else {
//           String msg = decoded['message']?.toString().toLowerCase() ?? "";
//           setState(() {
//             _invalidError = msg.contains("password") ? "Incorrect password" :
//             (msg.contains("email") || msg.contains("user")) ? "Account not found" : "Invalid credentials";
//           });
//           _shakeController.forward(from: 0);
//         }
//       } else {
//         setState(() => _invalidError = "Server Error (${response.statusCode})");
//         _shakeController.forward(from: 0);
//       }
//     } catch (e) {
//       setState(() => _invalidError = "Connection Failed");
//       _shakeController.forward(from: 0);
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   /// ----------------------------------------------------------------
//   /// BUILD UI
//   /// ----------------------------------------------------------------
//   @override
//   Widget build(BuildContext context) {
//     // Init Colors
//     successColor = AppColors.getSuccessColor(context);
//     dangerColor = AppColors.getDangerColor(context);
//     primaryColor = AppColors.getPrimaryColor(context);
//     final bgColor = AppColors.getScaffoldBg(context);
//     final cardColor = AppColors.getCardColor(context);
//     final textColor = AppColors.getTextColor(context);
//     final subTextColor = AppColors.getTextSubColor(context);
//     final inputFill = AppColors.getInputFieldColor(context);
//     final iconColor = AppColors.getIconColor(context);
//
//     return Scaffold(
//       backgroundColor: bgColor,
//       body: Stack(
//         children: [
//           // 1. FIXED BACKGROUND HEADER (Stays at top)
//           Container(
//             height: 350, // Fixed height for background
//             width: double.infinity,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [primaryColor, primaryColor.withOpacity(0.7)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(50),
//                 bottomRight: Radius.circular(50),
//               ),
//             ),
//           ),
//
//           // 2. SCROLLABLE CONTENT (Covers everything)
//           SafeArea(
//             child: Center(
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//                 child: Column(
//                   children: [
//
//                     // --- TOP HEADER CONTENT ---
//                     const SizedBox(height: 20),
//
//                     // 🚀 LOGO REPLACEMENT
//                     Container(
//                       padding: const EdgeInsets.all(15),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.15),
//                         shape: BoxShape.circle,
//                       ),
//                       child: SvgPicture.asset(
//                         'assets/images/snap2bill_logo.svg',
//                         height: 100,
//                       ),
//                     ),
//
//                     const SizedBox(height: 15),
//                     const Text(
//                       "Welcome Back",
//                       style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
//                     ),
//                     const Text(
//                       "Sign in to continue",
//                       style: TextStyle(color: Colors.white70, fontSize: 16),
//                     ),
//                     const SizedBox(height: 40), // Spacing between header and card
//
//                     // --- LOGIN CARD ---
//                     Container(
//                       padding: const EdgeInsets.all(30),
//                       decoration: BoxDecoration(
//                         color: cardColor,
//                         borderRadius: BorderRadius.circular(30),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 20,
//                             offset: const Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: AnimatedBuilder(
//                         animation: _shakeAnim,
//                         builder: (context, child) {
//                           final offsetX = (_usernameError || _passwordError || _invalidError != null)
//                               ? math.sin(_shakeAnim.value) * 10
//                               : 0.0;
//                           return Transform.translate(offset: Offset(offsetX, 0), child: child);
//                         },
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
//                             const SizedBox(height: 25),
//
//                             // Username
//                             _buildInput(username, "Email / Username", Icons.alternate_email_rounded, inputFill, textColor, subTextColor, iconColor, false, _usernameError),
//                             const SizedBox(height: 20),
//
//                             // Password
//                             _buildInput(password, "Password", Icons.lock_outline_rounded, inputFill, textColor, subTextColor, iconColor, true, _passwordError),
//
//                             // Error Msg
//                             if (_invalidError != null) ...[
//                               const SizedBox(height: 15),
//                               Container(
//                                 padding: const EdgeInsets.all(12),
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(
//                                   color: dangerColor.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Text(_invalidError!, style: TextStyle(color: dangerColor, fontWeight: FontWeight.bold)),
//                               ),
//                             ],
//
//                             // Forgot Password
//                             Align(
//                               alignment: Alignment.centerRight,
//                               child: TextButton(
//                                 onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => forgotemail())),
//                                 child: Text("Forgot Password?", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//
//                             // 🚀 SIGN IN BUTTON WITH ICON
//                             SizedBox(
//                               width: double.infinity,
//                               height: 50,
//                               child: AppButton(
//                                   text: "Sign In",
//                                   icon: Icons.login_rounded, // Icon Added
//                                   isTrailingIcon: true,      // Icon on right side
//                                   isLoading: _isLoading,
//                                   onPressed: _login
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 30),
//
//                     // --- REGISTER LINKS ---
//                     Column(
//                       children: [
//                         Text("Don't have an account?", style: TextStyle(color: subTextColor, fontSize: 14)),
//                         const SizedBox(height: 15),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             // 🚀 BETTER REGISTER ICONS
//                             _buildRegisterBtn("Customer", Icons.person_add_alt_1_rounded, false),
//                             const SizedBox(width: 15),
//                             _buildRegisterBtn("Distributor", Icons.storefront_rounded, true),
//                           ],
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 20), // Bottom padding
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// ----------------------------------------------------------------
//   /// WIDGET HELPERS
//   /// ----------------------------------------------------------------
//
//   Widget _buildInput(TextEditingController ctrl, String label, IconData icon, Color fill, Color text, Color hint, Color iconC, bool isPass, bool isErr) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: TextStyle(color: hint, fontWeight: FontWeight.w600, fontSize: 13)),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             color: fill,
//             borderRadius: BorderRadius.circular(15),
//             border: Border.all(color: isErr ? dangerColor : Colors.transparent, width: 1.5),
//           ),
//           child: TextField(
//             controller: ctrl,
//             obscureText: isPass ? _obscureText : false,
//             style: TextStyle(color: text, fontWeight: FontWeight.w600),
//             onChanged: (_) {
//               if (isErr || _invalidError != null) setState(() { _usernameError = false; _passwordError = false; _invalidError = null; });
//             },
//             decoration: InputDecoration(
//               hintText: "Enter $label",
//               hintStyle: TextStyle(color: hint.withOpacity(0.5)),
//               prefixIcon: Icon(icon, color: iconC),
//               suffixIcon: isPass ? IconButton(
//                 icon: Icon(_obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: iconC),
//                 onPressed: () => setState(() => _obscureText = !_obscureText),
//               ) : null,
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildRegisterBtn(String label, IconData icon, bool isDist) {
//     return InkWell(
//       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationPage(isDistributor: isDist))),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 20, color: primaryColor), // Slightly larger icon
//             const SizedBox(width: 8),
//             Text(label, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
//           ],
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart'; // 🚀 IMPORTED
import 'package:hugeicons/hugeicons.dart'; // 🚀 IMPORTED

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

  // Google Sign In
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // UI state
  bool _obscureText = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
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
  /// GOOGLE LOGIN LOGIC
  /// ----------------------------------------------------------------
  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isGoogleLoading = false);
        return; // User canceled
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "";
      if (ip.isEmpty) throw const SocketException("IP not configured");

      // Send to Backend
      final response = await http.post(
        Uri.parse('$ip/auth_google'),
        body: json.encode({
          'email': googleUser.email,
          'name': googleUser.displayName,
          'photoUrl': googleUser.photoUrl,
          'type': 'unknown', // Login page doesn't know type yet
        }),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        String status = decoded['status'];

        if (status == 'custok') {
          await prefs.remove("uid");
          await prefs.setString("cid", decoded['cid'].toString());
          if (!mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CustomerNavigationBar(initialIndex: 0)));
        } else if (status == 'distok') {
          await prefs.remove("cid");
          await prefs.setString("uid", decoded['uid'].toString());
          if (!mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DistributorNavigationBar(initialIndex: 0)));
        } else {
          CustomSnackBar.show(context, "Account not found. Please Register first.", backgroundColor: dangerColor);
          _googleSignIn.signOut();
        }
      } else {
        CustomSnackBar.show(context, "Server Error", backgroundColor: dangerColor);
      }
    } catch (e) {
      CustomSnackBar.show(context, "Google Sign-In Failed: $e", backgroundColor: dangerColor);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  /// ----------------------------------------------------------------
  /// STANDARD LOGIN LOGIC
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

  @override
  Widget build(BuildContext context) {
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
          Container(
            height: 350,
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

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 40),

                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
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

                            _buildInput(username, "Email / Username", HugeIcons.strokeRoundedMail01, inputFill, textColor, subTextColor, iconColor, false, _usernameError),
                            const SizedBox(height: 20),
                            _buildInput(password, "Password", HugeIcons.strokeRoundedLock, inputFill, textColor, subTextColor, iconColor, true, _passwordError),

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

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => forgotemail())),
                                child: Text("Forgot Password?", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: AppButton(
                                  text: "Sign In",
                                  icon: HugeIcons.strokeRoundedLogin01,
                                  isTrailingIcon: true,
                                  isLoading: _isLoading,
                                  onPressed: _login
                              ),
                            ),

                            const SizedBox(height: 15),

                            // 🚀 GOOGLE BUTTON
                            _isGoogleLoading
                                ? Center(child: CircularProgressIndicator(color: primaryColor))
                                : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: _handleGoogleLogin,
                                icon: const HugeIcon(icon: HugeIcons.strokeRoundedGoogle, color: Colors.red, size: 24),
                                label: Text("Sign in with Google", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    side: BorderSide(color: subTextColor.withOpacity(0.3))
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    Column(
                      children: [
                        Text("Don't have an account?", style: TextStyle(color: subTextColor, fontSize: 14)),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildRegisterBtn("Customer", HugeIcons.strokeRoundedUserAdd01, false),
                            const SizedBox(width: 15),
                            _buildRegisterBtn("Distributor", HugeIcons.strokeRoundedStore01, true),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, dynamic icon, Color fill, Color text, Color hint, Color iconC, bool isPass, bool isErr) {
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
              prefixIcon: Padding(
                padding: const EdgeInsets.all(10.0),
                child: HugeIcon(icon: icon, color: iconC, size: 10),
              ),
              suffixIcon: isPass ? IconButton(
                icon: HugeIcon(icon: _obscureText ? HugeIcons.strokeRoundedViewOff : HugeIcons.strokeRoundedView, color: iconC, size: 22),
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

  Widget _buildRegisterBtn(String label, dynamic icon, bool isDist) {
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
            HugeIcon(icon: icon, size: 20, color: primaryColor),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}