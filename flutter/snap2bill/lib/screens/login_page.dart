// // import 'dart:convert';
// //
// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:snap2bill/Distributordirectory/home_page.dart';
// // import 'package:snap2bill/distributor_registration.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:snap2bill/customer_registration.dart';
// //
// // import 'Customerdirectory/customer_home_page.dart';
// //
// //
// // void main(){
// //   runApp(login_page());
// // }
// //
// // class login_page extends StatelessWidget {
// //   const login_page({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(home: login_page_sub(),);
// //   }
// // }
// //
// // class login_page_sub extends StatefulWidget {
// //   const login_page_sub({Key? key}) : super(key: key);
// //
// //   @override
// //   State<login_page_sub> createState() => _login_page_subState();
// // }
// //
// // class _login_page_subState extends State<login_page_sub> {
// //   TextEditingController username = TextEditingController();
// //   TextEditingController password = TextEditingController();
// //
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //         appBar: PreferredSize(
// //           preferredSize: Size.fromHeight(80),
// //           child: Container(
// //             decoration: BoxDecoration(
// //               color: Colors.blue,
// //               borderRadius: BorderRadius.vertical(
// //                 bottom: Radius.circular(30),
// //               ),
// //             ),
// //             child: AppBar(
// //               centerTitle: true,
// //               title: Text('LOGIN' , style: TextStyle(fontSize: 40),),
// //               backgroundColor: Colors.transparent, // make AppBar background transparent
// //               elevation: 0,
// //             ),
// //           ),
// //         ),
// //         backgroundColor: Colors.cyan.shade100, body:
// //
// //     Column(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //
// //         Center(child:
// //         Container(
// //
// //           width:400,
// //           height:400,
// //           decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.black38,),
// //           // decoration: BoxDecoration(borderRadius: BorderRadius.only(
// //           //   topLeft: Radius.circular(30),
// //           //   topRight: Radius.circular(10),
// //           //   bottomLeft: Radius.circular(50),
// //           //   bottomRight: Radius.circular(0),
// //           // ),color: Colors.black38,),
// //           margin: EdgeInsets.all(10),
// //           child:Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),child:
// //           Column(children: [
// //             // Text("Log In",style: TextStyle(fontSize: 30),),
// //
// //             SizedBox(height: 8,),
// //             TextFormField(decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),), labelText: 'username', fillColor: Colors.white38, filled: true,),controller: username,),
// //
// //             SizedBox(height: 8,),
// //             TextFormField(decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),), labelText: 'password', fillColor: Colors.white38, filled: true,),controller: password,),
// //             SizedBox(height: 8,),
// //
// //             ElevatedButton(onPressed: () async {
// //               print("Username:${username.text}");
// //               print("Password: ${password.text}");
// //               SharedPreferences sh = await SharedPreferences.getInstance();
// //               String ip = sh.getString("ip").toString();
// //               // print("Password:", sh.getString("ip").toString());
// //               try {
// //                 var response = await http.post(
// //                   Uri.parse('${ip}/login_page'),
// //                   body: {'username': username.text, 'password': password.text},
// //                 );
// //
// //                 var decodeddata=await json.decode(response.body);
// //                 if (decodeddata['status'] == 'custok') {
// //                   print(response);
// //                   var contentType = response.headers['content-type'];
// //                   print("Content-Type: $contentType");
// //                   if (contentType != null && contentType.contains('application/json')) {
// //                     // Proceed with decoding the JSON response
// //                     var decode = json.decode(response.body);
// //                     sh.setString("cid", decodeddata['cid']);
// //                     print(decode);  // Check response
// //                     ScaffoldMessenger.of(context).showSnackBar(
// //                       SnackBar(
// //                         content: Text('Login successful'),
// //                       ),
// //                     );
// //                     Navigator.push(context, MaterialPageRoute(builder: (context)=>customer_home_page()));
// //                   }
// //                   else {
// //                     print("Invalid Content-Type. Expected application/json.");
// //                   }
// //
// //                 }
// //
// //                 else if(decodeddata['status'] == 'distok'){
// //                   sh.setString("uid", decodeddata['uid']);
// //                   print(response);
// //                   var contentType = response.headers['content-type'];
// //                   print("Content-Type: $contentType");
// //                   Navigator.push(context, MaterialPageRoute(builder: (context)=>home_page()));
// //                 }
// //                 else {
// //                   print('Failed to fetch data. Status code: ${response.statusCode}');
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     SnackBar(
// //                       content: Text('Invalid details'),
// //                     ),
// //                   );
// //                 }
// //               } catch (e) {
// //                 print("Request failed: $e");
// //               }
// //
// //
// //
// //             }, child: Text('submit')),
// //
// //             TextButton(onPressed: () async{
// //               Navigator.push(context, MaterialPageRoute(builder: (context)=>distributor_registration()));
// //
// //               },child: Text("Register now")),
// //             TextButton(onPressed: () async{
// //               Navigator.push(context, MaterialPageRoute(builder: (context)=>customer_registration()));
// //
// //
// //             },child: Text("Customer Register")),
// //
// //
// //
// //
// //
// //
// //
// //           ],)
// //           ),
// //
// //         )),
// //       ],
// //     ));
// //   }
// // }
// //
//
// //
// //
// // import 'dart:convert';
// // import 'dart:math' as math;
// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:snap2bill/Distributordirectory/home_page.dart';
// // import 'package:snap2bill/distributor_registration.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:snap2bill/customer_registration.dart';
// // import 'Customerdirectory/customer_home_page.dart';
// //
// // class login_page extends StatelessWidget {
// //   const login_page({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       home: login_page_sub(),
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //     );
// //   }
// // }
// //
// // class login_page_sub extends StatefulWidget {
// //   const login_page_sub({Key? key}) : super(key: key);
// //
// //   @override
// //   State<login_page_sub> createState() => _login_page_subState();
// // }
// //
// // class _login_page_subState extends State<login_page_sub>
// //     with SingleTickerProviderStateMixin {
// //   TextEditingController username = TextEditingController(text: "ashoka@gmail.com");
// //   TextEditingController password = TextEditingController(text: "password");
// //   bool _obscureText = true;
// //
// //   bool _usernameError = false;
// //   bool _passwordError = false;
// //   String? _invalidError;
// //
// //   late AnimationController _shakeController;
// //   late Animation<double> _shakeAnim;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _shakeController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 400),
// //     );
// //     _shakeAnim = Tween<double>(begin: 0, end: 2 * math.pi).animate(
// //       CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     _shakeController.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _login() async {
// //     setState(() {
// //       _usernameError = username.text.isEmpty;
// //       _passwordError = password.text.isEmpty;
// //       _invalidError = null;
// //     });
// //
// //     if (_usernameError || _passwordError) {
// //       _shakeController.forward(from: 0);
// //       return;
// //     }
// //
// //     SharedPreferences sh = await SharedPreferences.getInstance();
// //     String ip = sh.getString("ip").toString();
// //
// //     try {
// //       var response = await http.post(
// //         Uri.parse('$ip/login_page'),
// //         body: {
// //           'username': username.text,
// //           'password': password.text,
// //         },
// //       );
// //
// //       var decoded = json.decode(response.body);
// //
// //       if (decoded['status'] == 'custok') {
// //         sh.setString("cid", decoded['cid']);
// //         sh.setString("pwd", password.text);
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Login successful')),
// //         );
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(builder: (context) => customer_home_page()),
// //         );
// //       } else if (decoded['status'] == 'distok') {
// //         sh.setString("uid", decoded['uid']);
// //         sh.setString("pwd1", password.text);
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Login successful')),
// //         );
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(builder: (context) => home_page()),
// //         );
// //       } else {
// //         setState(() {
// //           _invalidError = "Invalid username or password!";
// //         });
// //         _shakeController.forward(from: 0);
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _invalidError = "Connection error. Please check your IP.";
// //       });
// //       _shakeController.forward(from: 0);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: AnimatedBuilder(
// //         animation: _shakeAnim,
// //         builder: (context, child) {
// //           final offsetX = (_usernameError || _passwordError || _invalidError != null)
// //               ? math.sin(_shakeAnim.value) * 10
// //               : 0.0;
// //
// //           return Transform.translate(
// //             offset: Offset(offsetX, 0),
// //             child: child,
// //           );
// //         },
// //         child: Container(
// //           width: double.infinity,
// //           height: double.infinity,
// //           decoration: const BoxDecoration(
// //             gradient: LinearGradient(
// //               colors: [Color(0xFF74ABE2), Color(0xFFA7E2F8)],
// //               begin: Alignment.topCenter,
// //               end: Alignment.bottomCenter,
// //             ),
// //           ),
// //           child: SingleChildScrollView(
// //             child: Column(
// //               children: [
// //                 const SizedBox(height: 80),
// //                 Text(
// //                   "LOGIN",
// //                   style: TextStyle(
// //                     fontSize: 38,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.white.withOpacity(0.95),
// //                     letterSpacing: 1.2,
// //                     shadows: [
// //                       const Shadow(
// //                           color: Colors.black26,
// //                           blurRadius: 10,
// //                           offset: Offset(0, 4))
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 50),
// //                 Center(
// //                   child: Container(
// //                     width: 400,
// //                     padding:
// //                     const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.95),
// //                       borderRadius: BorderRadius.circular(20),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black26.withOpacity(0.15),
// //                           blurRadius: 20,
// //                           offset: const Offset(0, 10),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Column(
// //                       mainAxisSize: MainAxisSize.min,
// //                       children: [
// //                         TextFormField(
// //                           controller: username,
// //                           onChanged: (_) {
// //                             if (_usernameError || _invalidError != null) {
// //                               setState(() {
// //                                 _usernameError = false;
// //                                 _invalidError = null;
// //                               });
// //                             }
// //                           },
// //                           decoration: InputDecoration(
// //                             labelText: 'Username',
// //                             prefixIcon: const Icon(Icons.person_outline,
// //                                 color: Colors.blueAccent),
// //                             filled: true,
// //                             fillColor: _usernameError
// //                                 ? Colors.red.shade50
// //                                 : Colors.blue.shade50,
// //                             labelStyle: const TextStyle(color: Colors.black54),
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(12),
// //                               borderSide: BorderSide.none,
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 20),
// //                         TextFormField(
// //                           controller: password,
// //                           obscureText: _obscureText,
// //                           onChanged: (_) {
// //                             if (_passwordError || _invalidError != null) {
// //                               setState(() {
// //                                 _passwordError = false;
// //                                 _invalidError = null;
// //                               });
// //                             }
// //                           },
// //                           decoration: InputDecoration(
// //                             labelText: 'Password',
// //                             prefixIcon: const Icon(Icons.lock_outline,
// //                                 color: Colors.blueAccent),
// //                             suffixIcon: IconButton(
// //                               icon: Icon(
// //                                 _obscureText
// //                                     ? Icons.visibility_off
// //                                     : Icons.visibility,
// //                                 color: Colors.grey,
// //                               ),
// //                               onPressed: () {
// //                                 setState(() {
// //                                   _obscureText = !_obscureText;
// //                                 });
// //                               },
// //                             ),
// //                             filled: true,
// //                             fillColor: _passwordError
// //                                 ? Colors.red.shade50
// //                                 : Colors.blue.shade50,
// //                             labelStyle: const TextStyle(color: Colors.black54),
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(12),
// //                               borderSide: BorderSide.none,
// //                             ),
// //                           ),
// //                         ),
// //                         if (_invalidError != null) ...[
// //                           const SizedBox(height: 10),
// //                           Text(
// //                             _invalidError!,
// //                             style: const TextStyle(
// //                                 color: Colors.red, fontWeight: FontWeight.w500),
// //                           ),
// //                         ],
// //
// //
// //
// //
// //
// //                         const SizedBox(height: 30),
// //                         SizedBox(
// //                           width: double.infinity,
// //                           height: 50,
// //                           child: ElevatedButton(
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: Colors.blue.shade600,
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(12),
// //                               ),
// //                               elevation: 4,
// //                               shadowColor: Colors.blueAccent,
// //                             ),
// //                             onPressed: _login,
// //                             child: const Text(
// //                               'Submit',
// //                               style: TextStyle(
// //                                 fontSize: 18,
// //                                 letterSpacing: 0.5,
// //                                 color: Colors.white,
// //                                 fontWeight: FontWeight.w600,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 20),
// //                         Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                           children: [
// //                             TextButton(
// //                               onPressed: () {
// //                                 Navigator.push(
// //                                   context,
// //                                   MaterialPageRoute(
// //                                       builder: (context) =>
// //                                           distributor_registration()),
// //                                 );
// //                               },
// //                               child: const Text(
// //                                 "Distributor Register",
// //                                 style: TextStyle(
// //                                     color: Colors.blueAccent, fontSize: 15),
// //                               ),
// //                             ),
// //                             Container(
// //                               width: 1,
// //                               height: 20,
// //                               color: Colors.grey.shade400,
// //                             ),
// //                             TextButton(
// //                               onPressed: () {
// //                                 Navigator.push(
// //                                   context,
// //                                   MaterialPageRoute(
// //                                       builder: (context) =>
// //                                           customer_registration()),
// //                                 );
// //                               },
// //                               child: const Text(
// //                                 "Customer Register",
// //                                 style: TextStyle(
// //                                     color: Colors.blueAccent, fontSize: 15),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// import 'dart:convert';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// // Note: Ensure you have these imports available in your project structure
// // or comment them out to test the UI only.
// import 'package:snap2bill/Distributordirectory/home_page.dart';
// import 'package:snap2bill/distributor_registration.dart';
// import 'package:snap2bill/customer_registration.dart';
// import 'Customerdirectory/customer_home_page.dart';
//
// // --- 1. DESIGN CONSTANTS & VARIABLES ---
// class AppColors {
//   // Light Mode Colors
//   static const Color primaryLight = Color(0xFF4A69FF);
//   static const Color backgroundLight = Color(0xFFF0F4F8);
//   static const Color cardLight = Colors.white;
//   static const Color textMainLight = Color(0xFF1A1D1E);
//   static const Color textSubLight = Color(0xFF6A6C7B);
//   static const Color inputFillLight = Color(0xFFF5F6FA);
//
//   // Dark Mode Colors
//   static const Color primaryDark = Color(0xFF5C7AE6);
//   static const Color backgroundDark = Color(0xFF121212);
//   static const Color cardDark = Color(0xFF1E1E1E);
//   static const Color textMainDark = Color(0xFFFFFFFF);
//   static const Color textSubDark = Color(0xFFAAAAAA);
//   static const Color inputFillDark = Color(0xFF2C2C2C);
//
//   // Gradients for the background blobs
//   static const List<Color> blobGradient1 = [Color(0xFF4A69FF), Color(0xFF2E3F8F)];
//   static const List<Color> blobGradient2 = [Color(0xFF6E85FF), Color(0xFF4A69FF)];
// }
//
// class AppText {
//   static const String welcomeTitle = "Welcome Back!";
//   static const String welcomeSub = "Enter your details to access your account";
//   static const String emailLabel = "Email / Username";
//   static const String passwordLabel = "Password";
//   static const String loginBtn = "Sign in";
//   static const String forgotPass = "Forgot password?";
//   static const String orLoginWith = "Sign in with";
// }
//
// // --- 2. MAIN WIDGET ---
// class login_page extends StatefulWidget {
//   const login_page({Key? key}) : super(key: key);
//
//   @override
//   State<login_page> createState() => _login_pageState();
// }
//
// class _login_pageState extends State<login_page> {
//   // Theme State
//   ThemeMode _themeMode = ThemeMode.light;
//
//   void toggleTheme() {
//     setState(() {
//       _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       themeMode: _themeMode,
//       theme: ThemeData(
//         brightness: Brightness.light,
//         primaryColor: AppColors.primaryLight,
//         scaffoldBackgroundColor: AppColors.backgroundLight,
//         fontFamily: 'Roboto', // Or your preferred font
//       ),
//       darkTheme: ThemeData(
//         brightness: Brightness.dark,
//         primaryColor: AppColors.primaryDark,
//         scaffoldBackgroundColor: AppColors.backgroundDark,
//       ),
//       // Pass the toggle callback to the sub page
//       home: login_page_sub(
//           onThemeChanged: toggleTheme,
//           isDarkMode: _themeMode == ThemeMode.dark
//       ),
//     );
//   }
// }
//
// // --- 3. SUB WIDGET (LOGIC + UI) ---
// class login_page_sub extends StatefulWidget {
//   final VoidCallback? onThemeChanged;
//   final bool isDarkMode;
//
//   // Added parameters for theme handling
//   const login_page_sub({Key? key, this.onThemeChanged, this.isDarkMode = false}) : super(key: key);
//
//   @override
//   State<login_page_sub> createState() => _login_page_subState();
// }
//
// class _login_page_subState extends State<login_page_sub>
//     with SingleTickerProviderStateMixin {
//
//   // --- EXISTING LOGIC STARTS HERE ---
//   TextEditingController username = TextEditingController(text: "ashoka@gmail.com");
//   TextEditingController password = TextEditingController(text: "password");
//   bool _obscureText = true;
//
//   bool _usernameError = false;
//   bool _passwordError = false;
//   String? _invalidError;
//
//   late AnimationController _shakeController;
//   late Animation<double> _shakeAnim;
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
//   Future<void> _login() async {
//     setState(() {
//       _usernameError = username.text.isEmpty;
//       _passwordError = password.text.isEmpty;
//       _invalidError = null;
//     });
//
//     if (_usernameError || _passwordError) {
//       _shakeController.forward(from: 0);
//       return;
//     }
//
//     // -- API Logic --
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String ip = sh.getString("ip").toString();
//
//     try {
//       var response = await http.post(
//         Uri.parse('$ip/login_page'),
//         body: {
//           'username': username.text,
//           'password': password.text,
//         },
//       );
//
//       var decoded = json.decode(response.body);
//
//       if (decoded['status'] == 'custok') {
//         sh.setString("cid", decoded['cid']);
//         sh.setString("pwd", password.text);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Login successful')),
//         );
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => customer_home_page()),
//         );
//       } else if (decoded['status'] == 'distok') {
//         sh.setString("uid", decoded['uid']);
//         sh.setString("pwd1", password.text);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Login successful')),
//         );
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => home_page()),
//         );
//       } else {
//         setState(() {
//           _invalidError = "Invalid username or password!";
//         });
//         _shakeController.forward(from: 0);
//       }
//     } catch (e) {
//       // For testing UI without server, comment out the try/catch block or use this logic
//       setState(() {
//         _invalidError = "Connection error or Invalid IP.";
//       });
//       _shakeController.forward(from: 0);
//     }
//   }
//   // --- EXISTING LOGIC ENDS HERE ---
//
//   @override
//   Widget build(BuildContext context) {
//     // Determine colors based on current mode
//     final isDark = widget.isDarkMode;
//     final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
//     final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
//     final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;
//     final subTextColor = isDark ? AppColors.textSubDark : AppColors.textSubLight;
//     final inputFill = isDark ? AppColors.inputFillDark : AppColors.inputFillLight;
//
//     return Scaffold(
//       backgroundColor: bgColor,
//       // Stack allows us to put the background "blobs" behind the content
//       body: Stack(
//         children: [
//           // 1. ABSTRACT BACKGROUND BLOBS
//           Positioned(
//             top: -100,
//             left: -50,
//             child: _buildBlob(250, AppColors.blobGradient1),
//           ),
//           Positioned(
//             top: 50,
//             right: -80,
//             child: _buildBlob(180, AppColors.blobGradient2),
//           ),
//
//           // 2. THEME TOGGLE BUTTON (Top Right)
//           Positioned(
//             top: 50,
//             right: 20,
//             child: InkWell(
//               onTap: widget.onThemeChanged,
//               child: Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white.withOpacity(0.5)),
//                 ),
//                 child: Icon(
//                   isDark ? Icons.light_mode : Icons.dark_mode,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//             ),
//           ),
//
//           // 3. MAIN CONTENT (Bottom Sheet Style)
//           Column(
//             children: [
//               // Spacer for the top abstract area
//               SizedBox(height: MediaQuery.of(context).size.height * 0.25),
//
//               // The White/Dark Sheet
//               Expanded(
//                 child: Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: cardColor,
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(40),
//                       topRight: Radius.circular(40),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 20,
//                         offset: const Offset(0, -5),
//                       ),
//                     ],
//                   ),
//                   child: SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
//                     child: AnimatedBuilder(
//                       animation: _shakeAnim,
//                       builder: (context, child) {
//                         // Apply shake effect to the form
//                         final offsetX = (_usernameError || _passwordError || _invalidError != null)
//                             ? math.sin(_shakeAnim.value) * 10
//                             : 0.0;
//                         return Transform.translate(
//                           offset: Offset(offsetX, 0),
//                           child: child,
//                         );
//                       },
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Header Text
//                           Center(
//                             child: Column(
//                               children: [
//                                 Text(
//                                   AppText.welcomeTitle,
//                                   style: TextStyle(
//                                     fontSize: 28,
//                                     fontWeight: FontWeight.bold,
//                                     color: textColor,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 10),
//                                 Text(
//                                   AppText.welcomeSub,
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: subTextColor,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 40),
//
//                           // USERNAME FIELD
//                           _buildInputField(
//                             controller: username,
//                             label: AppText.emailLabel,
//                             icon: Icons.person_outline_rounded,
//                             isError: _usernameError,
//                             fillColor: inputFill,
//                             textColor: textColor,
//                             hintColor: subTextColor,
//                           ),
//
//                           const SizedBox(height: 20),
//
//                           // PASSWORD FIELD
//                           _buildInputField(
//                             controller: password,
//                             label: AppText.passwordLabel,
//                             icon: Icons.lock_outline_rounded,
//                             isObscure: true,
//                             isError: _passwordError,
//                             fillColor: inputFill,
//                             textColor: textColor,
//                             hintColor: subTextColor,
//                           ),
//
//                           // ERROR MESSAGE
//                           if (_invalidError != null) ...[
//                             const SizedBox(height: 15),
//                             Center(
//                               child: Text(
//                                 _invalidError!,
//                                 style: const TextStyle(
//                                     color: Colors.redAccent,
//                                     fontWeight: FontWeight.w600
//                                 ),
//                               ),
//                             ),
//                           ],
//
//                           const SizedBox(height: 10),
//
//                           // Forgot Password
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: TextButton(
//                               onPressed: () {},
//                               child: Text(
//                                 AppText.forgotPass,
//                                 style: TextStyle(
//                                   color: AppColors.primaryLight,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                           const SizedBox(height: 30),
//
//                           // SIGN IN BUTTON
//                           SizedBox(
//                             width: double.infinity,
//                             height: 55,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: AppColors.primaryLight,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                                 elevation: 5,
//                                 shadowColor: AppColors.primaryLight.withOpacity(0.4),
//                               ),
//                               onPressed: _login,
//                               child: const Text(
//                                 AppText.loginBtn,
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                           const SizedBox(height: 40),
//
//                           // Social Login / Divider
//                           Row(
//                             children: [
//                               Expanded(child: Divider(color: subTextColor.withOpacity(0.3))),
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                                 child: Text(
//                                   AppText.orLoginWith,
//                                   style: TextStyle(color: subTextColor, fontSize: 12),
//                                 ),
//                               ),
//                               Expanded(child: Divider(color: subTextColor.withOpacity(0.3))),
//                             ],
//                           ),
//
//                           const SizedBox(height: 20),
//
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               _buildSocialBtn(Icons.facebook, Colors.blue[800]!),
//                               const SizedBox(width: 20),
//                               _buildSocialBtn(Icons.g_mobiledata, Colors.red[600]!), // Google Placeholder
//                               const SizedBox(width: 20),
//                               _buildSocialBtn(Icons.apple, Colors.black),
//                             ],
//                           ),
//
//                           const SizedBox(height: 30),
//
//                           // Register Links
//                           Center(
//                             child: Row(
//                               children: [
//                                 Wrap(
//                                   alignment: WrapAlignment.center,
//                                   // spacing: 1,
//                                   children: [
//                                     _buildRegisterLink("Register Distributor", () {
//                                       Navigator.push(context, MaterialPageRoute(builder: (c) => distributor_registration()));
//                                     }),
//                                     Text("|", style: TextStyle(color: subTextColor, height: 2.5)),
//                                     _buildRegisterLink("Register Customer", () {
//                                       Navigator.push(context, MaterialPageRoute(builder: (c) => customer_registration()));
//                                     }),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
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
//   // --- HELPER WIDGETS ---
//
//   // 1. Abstract Background Blob
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
//   // 2. Custom Input Field
//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool isObscure = false,
//     bool isError = false,
//     required Color fillColor,
//     required Color textColor,
//     required Color hintColor,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: TextStyle(color: hintColor, fontWeight: FontWeight.w500, fontSize: 13)),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             color: fillColor,
//             borderRadius: BorderRadius.circular(12),
//             border: isError ? Border.all(color: Colors.red, width: 1.5) : null,
//           ),
//           child: TextField(
//             controller: controller,
//             obscureText: isObscure ? _obscureText : false,
//             style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
//             onChanged: (_) {
//               if (isError || _invalidError != null) {
//                 setState(() {
//                   _usernameError = false;
//                   _passwordError = false;
//                   _invalidError = null;
//                 });
//               }
//             },
//             decoration: InputDecoration(
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               prefixIcon: Icon(icon, color: AppColors.primaryLight),
//               suffixIcon: isObscure
//                   ? IconButton(
//                 icon: Icon(
//                   _obscureText ? Icons.visibility_off : Icons.visibility,
//                   color: hintColor,
//                 ),
//                 onPressed: () => setState(() => _obscureText = !_obscureText),
//               )
//                   : null,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // 3. Social Media Button
//   Widget _buildSocialBtn(IconData icon, Color color) {
//     return InkWell(
//       onTap: () {},
//       child: Container(
//         width: 50,
//         height: 50,
//         decoration: BoxDecoration(
//           color: Colors.grey.withOpacity(0.1),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: color, size: 28),
//       ),
//     );
//   }
//
//   // 4. Register Text Link
//   Widget _buildRegisterLink(String text, VoidCallback onTap) {
//     return TextButton(
//       onPressed: onTap,
//       child: Text(
//         text,
//         style: const TextStyle(
//           color: AppColors.primaryLight,
//           fontWeight: FontWeight.w600,
//           fontSize: 14,
//         ),
//       ),
//     );
//   }
// }

// File: lib/screens/login_page.dart

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Use package imports to avoid duplicate canonical names
import 'package:snap2bill/Customerdirectory/customer_home_page.dart';
import 'package:snap2bill/Distributordirectory/home_page.dart'; // using home_page class for distributor
import 'package:snap2bill/screens/customer_registration.dart';
import 'package:snap2bill/screens/distributor_registration.dart';

// Shared resources (colors and button widget)
import 'package:snap2bill/theme/colors.dart';
import 'package:snap2bill/widgets/CustomerNavigationBar.dart';
import 'package:snap2bill/widgets/app_button.dart';
import 'package:snap2bill/widgets/distributorNavigationbar.dart';

// If you also had theme_service in theme.dart, we DO NOT use it here (no theme toggles here)

const List<Color> _blobGradient1 = AppColors.blobGradient1;
const List<Color> _blobGradient2 = AppColors.blobGradient2;

class login_page extends StatefulWidget {
  const login_page({Key? key}) : super(key: key);

  @override
  State<login_page> createState() => _login_pageState();
}

class _login_pageState extends State<login_page>
    with SingleTickerProviderStateMixin {
  // Controllers with example default values so you can test quickly
  final TextEditingController username = TextEditingController(
    text: "ashoka@gmail.com",
  );
  final TextEditingController password = TextEditingController(
    text: "password",
  );

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

  /// The login function: validates inputs, reads saved IP, makes POST call,
  /// handles response and navigates to either customer or distributor home pages.
  Future<void> _login() async {
    // Validate
    setState(() {
      _usernameError = username.text.trim().isEmpty;
      _passwordError = password.text.trim().isEmpty;
      _invalidError = null;
    });

    if (_usernameError || _passwordError) {
      // play shake to indicate missing fields
      _shakeController.forward(from: 0);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Read IP saved earlier in SharedPreferences (if not present, fallback)
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip =
          sh.getString("ip") ??
          "http://10.0.2.2:8000"; // emulator-friendly default

      // Make HTTP POST to the login endpoint (server must accept form fields)
      final response = await http.post(
        Uri.parse('$ip/login_page'),
        body: {
          'username': username.text.trim(),
          'password': password.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Your backend returns status strings: 'custok' or 'distok'
        if (decoded['status'] == 'custok') {
          // Save customer id locally and password if required (not recommended to save plain password)
          await sh.setString("cid", decoded['cid'].toString());
          await sh.setString("pwd", password.text);

          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful')));

          // Navigate to customer home
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CustomerNavigationBar()),
          );
        } else if (decoded['status'] == 'distok') {
          // Distributor login success: save uid and navigate to distributor home
          await sh.setString("uid", decoded['uid'].toString());
          await sh.setString("pwd1", password.text);

          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful')));

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DistributorNavigationBar()),
          );
        } else {
          // Invalid credentials
          setState(() {
            _invalidError = "Invalid username or password!";
          });
          _shakeController.forward(from: 0);
        }
      } else {
        // Non-200 server response
        setState(() {
          _invalidError = "Server Error: ${response.statusCode}";
        });
        _shakeController.forward(from: 0);
      }
    } catch (e) {
      // Network / parsing error
      setState(() {
        _invalidError = "Connection error. Check IP or network.";
      });
      _shakeController.forward(from: 0);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme colors via Theme.of(context) and shared AppColors
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final subTextColor = isDark
        ? AppColors.textSubDark
        : AppColors.textSubLight;
    final inputFill = isDark
        ? AppColors.inputFillDark
        : AppColors.inputFillLight;

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
              SizedBox(height: MediaQuery.of(context).size.height * 0.25),

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
                          final offsetX =
                              (_usernameError ||
                                  _passwordError ||
                                  _invalidError != null)
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
                                  Text(
                                    "Welcome Back!",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
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
                              themePrimary: AppColors.iconColor,
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
                              themePrimary: AppColors.iconColor,
                            ),

                            // Error message if login failed
                            if (_invalidError != null) ...[
                              const SizedBox(height: 15),
                              Center(
                                child: Text(
                                  _invalidError!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Forgot password?",
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Sign in button (uses shared AppButton)
                            AppButton(
                              text: "Sign in",
                              isLoading: _isLoading,
                              onPressed: _login,
                            ),
                            const SizedBox(height: 40),

                            // Sign in with social (visual only)
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
                                    "Sign in with",
                                    style: TextStyle(
                                      color: subTextColor,
                                      fontSize: 12,
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
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialBtn(
                                  Icons.facebook,
                                  Colors.blue[800]!,
                                ),
                                const SizedBox(width: 20),
                                _buildSocialBtn(
                                  Icons.g_mobiledata,
                                  Colors.red[600]!,
                                ),
                                const SizedBox(width: 20),
                                _buildSocialBtn(Icons.apple, Colors.black),
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
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const distributor_registration(),
                                        ),
                                      );
                                    },
                                    theme.primaryColor,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 1,
                                    ),
                                    child: Text("|"),
                                  ),
                                  _buildRegisterLink("Register Customer", () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const customer_registration(),
                                      ),
                                    );
                                  }, theme.primaryColor),
                                ],
                              ),
                            ),
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

  // --- Helper widgets below (kept simple and readable) ---

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

  Widget _buildSocialBtn(IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget _buildRegisterLink(
    String text,
    VoidCallback onTap,
    Color primaryColor,
  ) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
