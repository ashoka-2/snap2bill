// //
// //
// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:snap2bill/screens/login_page.dart';
// // import 'package:flutter_svg/flutter_svg.dart';
// //
// // import 'theme/colors.dart';
// // import 'theme/theme.dart';
// // // 1. IMPORT YOUR CUSTOM WIDGET HERE
// // import 'widgets/app_button.dart';
// //
// // const List<Color> _blobGradient1 = AppColors.blobGradient1;
// // const List<Color> _blobGradient2 = AppColors.blobGradient2;
// //
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await ThemeService.instance.load();
// //   runApp(const MyApp());
// // }
// //
// // class MyApp extends StatefulWidget {
// //   const MyApp({Key? key}) : super(key: key);
// //
// //   static void changeTheme(BuildContext context) {
// //     _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
// //     state?.changeTheme();
// //   }
// //
// //   @override
// //   State<MyApp> createState() => _MyAppState();
// // }
// //
// // class _MyAppState extends State<MyApp> {
// //   ThemeMode _mode = ThemeService.instance.isDarkMode
// //       ? ThemeMode.dark
// //       : ThemeMode.light;
// //
// //
// //
// //   void changeTheme() {
// //     setState(() {
// //       ThemeService.instance.toggle();
// //       _mode = ThemeService.instance.isDarkMode
// //           ? ThemeMode.dark
// //           : ThemeMode.light;
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       theme: lightTheme,
// //       darkTheme: darkTheme,
// //       themeMode: _mode,
// //
// //       home: const MyApp_sub(),
// //     );
// //   }
// // }
// //
// // class MyApp_sub extends StatefulWidget {
// //   const MyApp_sub({Key? key}) : super(key: key);
// //
// //   @override
// //   State<MyApp_sub> createState() => _MyApp_subState();
// // }
// //
// // class _MyApp_subState extends State<MyApp_sub> {
// //   TextEditingController ip = TextEditingController(text: "10.64.180.28");
// //   // TextEditingController ip = TextEditingController(text: "192.168.1.15");
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     final isDark = Theme.of(context).brightness == Brightness.dark;
// //     final iconColor = isDark?AppColors.iconColorDark:AppColors.iconColorLight;
// //     return GestureDetector(
// //       onTap: () => FocusScope.of(context).unfocus(),
// //
// //       child: Scaffold(
// //         backgroundColor: theme.scaffoldBackgroundColor,
// //         //extend the body to be visible in the back of appbar
// //         extendBodyBehindAppBar: true,
// //
// //         appBar: AppBar(
// //           backgroundColor: Colors.transparent,
// //           elevation: 0,
// //           actions: [
// //             Container(
// //               padding: EdgeInsets.all(5),
// //
// //               decoration: BoxDecoration(
// //                 color: AppColors.getPillBg(context),
// //                 borderRadius: BorderRadius.circular(50),
// //               ),
// //               child: IconButton(
// //                 icon: Icon(
// //                   ThemeService.instance.isDarkMode
// //                       ? Icons.light_mode
// //                       : Icons.dark_mode,
// //                   color:iconColor,
// //                 ),
// //                 onPressed: () {
// //                   MyApp.changeTheme(context);
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //         body: SingleChildScrollView(
// //           child: Stack(
// //             children: [
// //               Positioned(
// //                 top: -70,
// //                 left: -50,
// //                 child: _buildBlob(250, _blobGradient1),
// //               ),
// //               Positioned(
// //                 top: 150,
// //                 right: -80,
// //                 child: _buildBlob(180, _blobGradient2),
// //               ),
// //
// //
// //               Column(
// //
// //                 children: [
// //                   SizedBox(height: MediaQuery.of(context).size.height * 0.25),
// //
// //                   Center(
// //                     child: Container(
// //                       width: double.infinity,
// //                       decoration: BoxDecoration(
// //                         color: theme.cardColor,
// //                         borderRadius: BorderRadius.circular(20),
// //
// //                       ),
// //                       margin: const EdgeInsets.all(20),
// //                       child: Padding(
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 30,
// //                           vertical: 40,
// //                         ),
// //                         child: Column(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: [
// //                             CircleAvatar(
// //                                 radius: 60,
// //                                 backgroundColor: Colors.transparent,
// //                                 child: SvgPicture.asset('assets/images/snap2bill_logo.svg',height:100,)),
// //                             SizedBox(height: 10,),
// //                             Text(
// //                               "Enter Your IP Address",
// //
// //                               style: TextStyle(
// //                                 color: AppColors.primaryLight,
// //                                 fontSize: 20,
// //                               ),
// //                             ),
// //
// //                             const SizedBox(height: 20),
// //                             TextFormField(
// //                               controller: ip,
// //                               style: TextStyle(
// //                                 color: ThemeService.instance.isDarkMode
// //                                     ? Colors.white
// //                                     : Colors.black,
// //                               ),
// //                               decoration: InputDecoration(
// //                                 labelText: 'IP Address',
// //                                 prefixIcon: const Icon(Icons.wifi),
// //                                 prefixIconColor: iconColor,
// //                               ),
// //                             ),
// //
// //                             const SizedBox(height: 20),
// //
// //                             // ------------------------------------------------
// //                             // 2. HERE IS YOUR NEW CUSTOM BUTTON
// //                             // ------------------------------------------------
// //                             AppButton(
// //                               text: "Submit",
// //                               // icon: Icons.upload,
// //                               // isTrailingIcon: true,
// //                               onPressed: () async {
// //                                 SharedPreferences prefs =
// //                                     await SharedPreferences.getInstance();
// //                                 prefs.setString("ip", "http://${ip.text}:8000");
// //
// //                                 if (context.mounted) {
// //                                   Navigator.pushReplacement(
// //                                     context,
// //                                     MaterialPageRoute(
// //                                       builder: (context) => LoginPage(),
// //                                     ),
// //                                   );
// //                                 }
// //                               },
// //                             ),
// //
// //                             // ------------------------------------------------
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // Widget _buildBlob(double size, List<Color> colors) {
// //   return Container(
// //     width: size,
// //     height: size,
// //     decoration: BoxDecoration(
// //       shape: BoxShape.circle,
// //       gradient: LinearGradient(
// //         colors: colors,
// //         begin: Alignment.topLeft,
// //         end: Alignment.bottomRight,
// //       ),
// //     ),
// //   );
// // }
//
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/screens/login_page.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// import 'theme/colors.dart';
// import 'theme/theme.dart';
// import 'widgets/app_button.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await ThemeService.instance.load();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   static void changeTheme(BuildContext context) {
//     _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
//     state?.changeTheme();
//   }
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   ThemeMode _mode = ThemeService.instance.isDarkMode
//       ? ThemeMode.dark
//       : ThemeMode.light;
//
//   void changeTheme() {
//     setState(() {
//       ThemeService.instance.toggle();
//       _mode = ThemeService.instance.isDarkMode
//           ? ThemeMode.dark
//           : ThemeMode.light;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Snap2Bill',
//       theme: lightTheme,
//       darkTheme: darkTheme,
//       themeMode: _mode,
//       home: const MyApp_sub(),
//     );
//   }
// }
//
// class MyApp_sub extends StatefulWidget {
//   const MyApp_sub({Key? key}) : super(key: key);
//
//   @override
//   State<MyApp_sub> createState() => _MyApp_subState();
// }
//
// class _MyApp_subState extends State<MyApp_sub> {
//   // Default IP (Useful for development)
//   // final TextEditingController ipController = TextEditingController(text: "192.168.1.5");
//   final TextEditingController ipController = TextEditingController(text: "10.64.180.28");
//
//   bool _isLoading = false;
//
//   @override
//   Widget build(BuildContext context) {
//     // Colors & Theme
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final primaryColor = AppColors.getPrimaryColor(context);
//     final bgColor = AppColors.getScaffoldBg(context);
//     final cardColor = AppColors.getCardColor(context);
//     final textColor = AppColors.getTextColor(context);
//     final subTextColor = AppColors.getTextSubColor(context);
//     final inputFill = AppColors.getInputFieldColor(context);
//     final iconColor = AppColors.getIconColor(context);
//
//     // Screen Size
//     final size = MediaQuery.of(context).size;
//
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         backgroundColor: bgColor,
//         body: SingleChildScrollView(
//           child: SizedBox(
//             height: size.height,
//             child: Stack(
//               children: [
//                 // 1. HEADER SECTION (Gradient Background)
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   right: 0,
//                   height: size.height * 0.45,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: isDark
//                             ? [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)]
//                             : [primaryColor, primaryColor.withOpacity(0.7)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: const BorderRadius.only(
//                         bottomLeft: Radius.circular(40),
//                         bottomRight: Radius.circular(40),
//                       ),
//                     ),
//                     child: SafeArea(
//                       child: Column(
//                         children: [
//                           // Theme Toggle Button (Top Right)
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(50),
//                                   ),
//                                   child: IconButton(
//                                     icon: Icon(
//                                       ThemeService.instance.isDarkMode
//                                           ? Icons.wb_sunny_rounded
//                                           : Icons.nightlight_round,
//                                       color: Colors.white,
//                                     ),
//                                     onPressed: () => MyApp.changeTheme(context),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           const SizedBox(height: 10),
//
//                           // Logo & Title
//                           Container(
//                             padding: const EdgeInsets.all(15),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.15),
//                               shape: BoxShape.circle,
//                             ),
//                             child: SvgPicture.asset(
//                               'assets/images/snap2bill_logo.svg',
//                               height: 70,
//
//                               // Use colorFilter if SVG has specific colors you want to override
//                             ),
//                           ),
//                           const SizedBox(height: 15),
//                           const Text(
//                             "Server Connection",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 1,
//                             ),
//                           ),
//                           Text(
//                             "Connect to your backend",
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.8),
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // 2. MAIN CARD SECTION
//                 Positioned(
//                   top: size.height * 0.38, // Overlap the header
//                   left: 20,
//                   right: 20,
//                   child: Container(
//                     padding: const EdgeInsets.all(30),
//                     decoration: BoxDecoration(
//                       color: cardColor,
//                       borderRadius: BorderRadius.circular(30),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 30,
//                           offset: const Offset(0, 10),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Configuration",
//                           style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: textColor
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         Text(
//                           "Enter the host IP address to proceed.",
//                           style: TextStyle(
//                               fontSize: 13,
//                               color: subTextColor
//                           ),
//                         ),
//                         const SizedBox(height: 25),
//
//                         // Custom Input Field
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "IP Address",
//                               style: TextStyle(
//                                 color: subTextColor,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 12,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: inputFill,
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               child: TextField(
//                                 controller: ipController,
//                                 style: TextStyle(
//                                   color: textColor,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 16,
//                                 ),
//                                 decoration: InputDecoration(
//                                   hintText: "e.g. 192.168.1.5",
//                                   hintStyle: TextStyle(color: subTextColor.withOpacity(0.5)),
//                                   prefixIcon: Icon(Icons.wifi_rounded, color: primaryColor),
//                                   border: InputBorder.none,
//                                   contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         const SizedBox(height: 30),
//
//                         // Connect Button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: AppButton(
//                             text: "Connect",
//                             icon: Icons.arrow_forward_rounded,
//                             isTrailingIcon: true,
//                             isLoading: _isLoading,
//                             onPressed: () async {
//                               setState(() => _isLoading = true);
//
//                               // Small delay to show animation (optional)
//                               await Future.delayed(const Duration(milliseconds: 500));
//
//                               SharedPreferences prefs = await SharedPreferences.getInstance();
//
//                               // Save IP without http prefix first for clean logic, or with it if your app expects it
//                               String rawIp = ipController.text.trim();
//                               String fullUrl = rawIp.startsWith("http") ? rawIp : "http://$rawIp:8000";
//
//                               await prefs.setString("ip", fullUrl);
//
//                               if (context.mounted) {
//                                 Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => const LoginPage(),
//                                   ),
//                                 );
//                               }
//                               setState(() => _isLoading = false);
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // 3. FOOTER
//                 Positioned(
//                   bottom: 30,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: Text(
//                       "Snap2Bill v1.0",
//                       style: TextStyle(
//                           color: subTextColor.withOpacity(0.5),
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:io'; // For SocketException
import 'package:http/http.dart' as http; // 🚀 Required for Ping
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

// SCREEN IMPORTS
import 'package:snap2bill/screens/login_page.dart';
import 'package:snap2bill/widgets/CustomerNavigationBar.dart';
import 'package:snap2bill/widgets/distributorNavigationbar.dart';
import 'widgets/app_button.dart';

// THEME IMPORTS
import 'theme/colors.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void changeTheme(BuildContext context) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeTheme();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _mode = ThemeService.instance.isDarkMode
      ? ThemeMode.dark
      : ThemeMode.light;

  void changeTheme() {
    setState(() {
      ThemeService.instance.toggle();
      _mode = ThemeService.instance.isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snap2Bill',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _mode,
      home: const SplashPage(),
    );
  }
}

/// ============================================================
/// 1. SPLASH PAGE (THE SMART GATEKEEPER)
/// ============================================================
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    _checkConnectionAndLogin();
  }

  Future<void> _checkConnectionAndLogin() async {
    // 1. Load Data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString("ip");
    String? cid = prefs.getString("cid");
    String? uid = prefs.getString("uid");

    // 2. Agar IP hi nahi hai, to seedha Config Page
    if (ip == null || ip.isEmpty) {
      _navigateTo(const IpConfigPage());
      return;
    }

    // 3. 🚀 SERVER PING TEST (Is IP valid?)
    bool isServerAlive = await _pingServer(ip);

    if (!isServerAlive) {
      // ❌ Server unreachable -> IP Config Page (User needs to update IP)
      if(mounted) {
        // Optional: Show a quick toast or log
        debugPrint("Server unreachable. Redirecting to IP Config.");
        _navigateTo(const IpConfigPage());
      }
    } else {
      // ✅ Server Alive -> Check Login Status
      if (cid != null && cid.isNotEmpty) {
        _navigateTo(const CustomerNavigationBar(initialIndex: 0));
      } else if (uid != null && uid.isNotEmpty) {
        _navigateTo( DistributorNavigationBar(initialIndex: 0));
      } else {
        _navigateTo(const LoginPage());
      }
    }
  }

  // 🚀 Helper Function to Ping Server
  Future<bool> _pingServer(String ip) async {
    try {
      // Hum server ke root ya kisi lightweight URL par request bhejenge
      // Timeout 3 seconds rakha hai taaki user zyada wait na kare
      final response = await http.get(Uri.parse("$ip/"))
          .timeout(const Duration(seconds: 3));

      // Agar response aaya (chahe 404 ho ya 200), matlab server zinda hai
      return true;
    } catch (e) {
      // SocketException, TimeoutException matlab IP galat hai ya server band hai
      return false;
    }
  }

  void _navigateTo(Widget page) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.getPrimaryColor(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/images/snap2bill_logo.svg',
                height: 80,
              ),
            ),
            const SizedBox(height: 20),
            // Loading text to inform user
            const Text(
              "Connecting to server...",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 15),
            const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// 2. IP CONFIG PAGE (With Modern Design)
/// ============================================================
class IpConfigPage extends StatefulWidget {
  const IpConfigPage({Key? key}) : super(key: key);

  @override
  State<IpConfigPage> createState() => _IpConfigPageState();
}

class _IpConfigPageState extends State<IpConfigPage> {
  // 🚀 FIX: Default empty rakha hai taaki user naya IP daale,
  // ya aap purana IP pre-fill kar sakte hain agar chahein.
  final TextEditingController ipController = TextEditingController(text: "10.64.180.28");
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentIp();
  }

  // Pre-fill existing IP for convenience
  void _loadCurrentIp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentIp = prefs.getString("ip");
    // Extract numeric IP from "http://192.168.x.x:8000"
    if (currentIp != null && currentIp.isNotEmpty) {
      String cleanIp = currentIp.replaceAll("http://", "").replaceAll(":8000", "");
      ipController.text = cleanIp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = AppColors.getPrimaryColor(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.getScaffoldBg(context),
        body: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            child: Stack(
              children: [
                // Header Gradient
                Positioned(
                  top: 0, left: 0, right: 0, height: size.height * 0.45,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)]
                            : [primaryColor, primaryColor.withOpacity(0.7)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20, top: 10),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(ThemeService.instance.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round, color: Colors.white),
                                onPressed: () => MyApp.changeTheme(context),
                              ),
                            ),
                          ),
                          SvgPicture.asset('assets/images/snap2bill_logo.svg', height: 70,),
                          const SizedBox(height: 15),
                          const Text("Server Connection", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          const Text("Connect to your local backend", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),

                // Card
                Positioned(
                  top: size.height * 0.38, left: 20, right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: AppColors.getCardColor(context),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 30, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Configuration", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.getTextColor(context))),
                        const SizedBox(height: 5),
                        Text("Your IP seems to have changed. Please enter the new one.", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 25),

                        Text("IP Address", style: TextStyle(color: AppColors.getTextSubColor(context), fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(color: AppColors.getInputFieldColor(context), borderRadius: BorderRadius.circular(15)),
                          child: TextField(
                            controller: ipController,
                            style: TextStyle(color: AppColors.getTextColor(context)),
                            decoration: InputDecoration(
                              hintText: "e.g. 192.168.1.5",
                              prefixIcon: Icon(Icons.wifi, color: primaryColor),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity, height: 50,
                          child: AppButton(
                            text: "Connect",
                            isLoading: _isLoading,
                            onPressed: () async {
                              if(ipController.text.isEmpty) return;

                              setState(() => _isLoading = true);
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String rawIp = ipController.text.trim();
                              String fullUrl = rawIp.startsWith("http") ? rawIp : "http://$rawIp:8000";

                              // 1. Save new IP
                              await prefs.setString("ip", fullUrl);

                              // 2. Check if this new IP works? (Optional but good UX)
                              try {
                                await http.get(Uri.parse("$fullUrl/")).timeout(const Duration(seconds: 2));

                                // Success! Navigate logic
                                String? cid = prefs.getString("cid");
                                String? uid = prefs.getString("uid");

                                if (!mounted) return;

                                if (cid != null) {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerNavigationBar(initialIndex: 0)));
                                } else if (uid != null) {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>  DistributorNavigationBar(initialIndex: 0)));
                                } else {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                                }

                              } catch (e) {
                                if (!mounted) return;
                                // IP abhi bhi galat hai
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Cannot connect to $rawIp. Check IP and try again."), backgroundColor: Colors.red),
                                );
                              } finally {
                                if(mounted) setState(() => _isLoading = false);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}