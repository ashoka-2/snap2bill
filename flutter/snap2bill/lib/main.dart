// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:snap2bill/Login_page.dart';
// //
// // void main(){
// //   runApp(MyApp());
// // }
// //
// //
// // class MyApp extends StatelessWidget {
// //   const MyApp({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(home: MyApp_sub(),);
// //   }
// // }
// //
// //
// // class MyApp_sub extends StatefulWidget {
// //   const MyApp_sub({Key? key}) : super(key: key);
// //
// //   @override
// //   State<MyApp_sub> createState() => _MyApp_subState();
// // }
// //
// // class _MyApp_subState extends State<MyApp_sub> {
// //   // TextEditingController ip = TextEditingController(text: "192.168.29.3");
// //   TextEditingController ip = TextEditingController(text: "10.218.83.28");
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(body: Center(child: Container(
// //       width:400,
// //       height:400,
// //       color: Colors.blue.shade300,
// //       margin: EdgeInsets.all(10),
// //       child:Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),child:
// //       Column(children: [
// //         SizedBox(height: 8,),
// //         TextFormField(decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),), labelText: 'ip', fillColor: Colors.white38, filled: true,),controller: ip,),
// //
// //         SizedBox(height: 8,),
// //         ElevatedButton(onPressed: () async {
// //           SharedPreferences sh = await SharedPreferences.getInstance();
// //
// //           sh.setString("ip","http://${ip.text}:8000");
// //           Navigator.push(context, MaterialPageRoute(builder: (context)=>login_page()));
// //
// //         }, child: Text('submit')),
// //
// //
// //
// //
// //       ],)
// //       ),
// //
// //     )));
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Login_page.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: MyApp_sub(),
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         scaffoldBackgroundColor: const Color(0xFFF3F4F6),
//
//       ),
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
// class _MyApp_subState extends State<MyApp_sub>
//     with SingleTickerProviderStateMixin {
//   // TextEditingController ip = TextEditingController(text: "192.168.29.5");
//
//   TextEditingController ip = TextEditingController(text: "10.223.211.28");
//
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     );
//     _scaleAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.elasticOut,
//     );
//
//     _controller.forward();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   Future<void> _onSubmit() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     sh.setString("ip", "http://${ip.text}:8000");
//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (_, __, ___) => login_page(),
//         transitionsBuilder: (_, anim, __, child) =>
//             FadeTransition(opacity: anim, child: child),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Center(
//           child: ScaleTransition(
//             scale: _scaleAnimation,
//             child: Container(
//               width: 380,
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.blueAccent.withOpacity(0.15),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const SizedBox(height: 10),
//                   Text(
//                     "Enter IP Address",
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.blue.shade800,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     decoration: InputDecoration(
//                       labelText: 'IP Address',
//                       labelStyle: TextStyle(color: Colors.grey[700]),
//                       filled: true,
//                       fillColor: Colors.blue.shade50,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       prefixIcon: const Icon(
//                         Icons.wifi,
//                         color: Colors.blueAccent,
//                       ),
//                     ),
//                     controller: ip,
//                   ),
//                   const SizedBox(height: 24),
//                   AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     curve: Curves.easeInOut,
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue.shade600,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 4,
//                         shadowColor: Colors.blueAccent,
//                       ),
//                       onPressed: _onSubmit,
//                       child: const Text(
//                         'Submit',
//                         style: TextStyle(
//                           fontSize: 18,
//                           letterSpacing: 0.5,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:ui';
import 'Login_page.dart'; // adjust path if needed

// ----------------- ThemeService (embedded, persists isDarkMode) -----------------
class ThemeService {
  ThemeService._private();
  static final ThemeService instance = ThemeService._private();

  final ValueNotifier<bool> isDark = ValueNotifier<bool>(false);
  static const _key = 'isDarkMode';

  Future<void> load() async {
    final sh = await SharedPreferences.getInstance();
    isDark.value = sh.getBool(_key) ?? false;
  }

  Future<void> toggle() async {
    final sh = await SharedPreferences.getInstance();
    isDark.value = !isDark.value;
    await sh.setBool(_key, isDark.value);
  }

  Future<void> setDark(bool value) async {
    final sh = await SharedPreferences.getInstance();
    isDark.value = value;
    await sh.setBool(_key, value);
  }
}

// ----------------- App color constants (match login style) -----------------
class AppColors {
  static const Color primaryLight = Color(0xFF4A69FF);
  static const Color backgroundTop = Color(0xFF74ABE2);
  static const Color backgroundBottom = Color(0xFFA7E2F8);

  static const Color primaryDark = Color(0xFF5C7AE6);
  static const Color darkBg = Color(0xFF0F1724);

  static const List<Color> blob1 = [Color(0xFF4A69FF), Color(0xFF2E3F8F)];
  static const List<Color> blob2 = [Color(0xFF6E85FF), Color(0xFF4A69FF)];
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.instance.isDark,
      builder: (context, isDark, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: AppColors.primaryLight,
            scaffoldBackgroundColor: Colors.transparent, // we draw gradient in body
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: AppColors.primaryDark,
            scaffoldBackgroundColor: AppColors.darkBg,
            fontFamily: 'Roboto',
          ),
          home: const MyApp_sub(),
        );
      },
    );
  }
}

class MyApp_sub extends StatefulWidget {
  const MyApp_sub({Key? key}) : super(key: key);

  @override
  State<MyApp_sub> createState() => _MyApp_subState();
}

class _MyApp_subState extends State<MyApp_sub> with SingleTickerProviderStateMixin {
  final TextEditingController ip = TextEditingController(text: "10.223.211.28");

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    ip.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    setState(() => _saving = true);
    SharedPreferences sh = await SharedPreferences.getInstance();
    await sh.setString("ip", "http://${ip.text}:8000");
    // small delay for UX
    await Future.delayed(const Duration(milliseconds: 250));
    setState(() => _saving = false);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const login_page(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use ThemeService to show icon state
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.instance.isDark,
      builder: (context, isDark, _) {
        return Scaffold(
          // We set scaffold background transparent and draw our own gradient background
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // gradient background
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkBg, AppColors.darkBg]
                        : [AppColors.backgroundTop, AppColors.backgroundBottom],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // decorative blobs (like login page)
              Positioned(
                top: -120,
                left: -60,
                child: _blob(320, AppColors.blob1, isDark),
              ),
              Positioned(
                top: 40,
                right: -100,
                child: _blob(200, AppColors.blob2, isDark),
              ),

              // theme toggle overlay (top-right)
              Positioned(
                top: 44,
                right: 18,
                child: GestureDetector(
                  onTap: () => ThemeService.instance.toggle(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.white.withOpacity(0.22),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                    ),
                    child: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: isDark ? Colors.white : Colors.black,
                      size: 22,
                    ),
                  ),
                ),
              ),

              // main centered card (styled like login)
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: MediaQuery.of(context).size.width > 420 ? 420 : MediaQuery.of(context).size.width * 0.92,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26.withOpacity(isDark ? 0.6 : 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            "SETUP IP",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white.withOpacity(0.95) : Colors.black87,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black26.withOpacity(isDark ? 0.6 : 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            "Enter your server IP address so the app can connect. Example: 192.168.0.5",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 22),
                          // IP input
                          TextFormField(
                            controller: ip,
                            keyboardType: TextInputType.url,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'IP Address',
                              labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                              filled: true,
                              fillColor: isDark ? Colors.white10 : Colors.blue.shade50,
                              prefixIcon: Icon(Icons.wifi, color: AppColors.primaryLight),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryLight,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 6,
                                shadowColor: AppColors.primaryLight.withOpacity(0.36),
                              ),
                              onPressed: _saving ? null : _onSubmit,
                              child: _saving
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                                  : const Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const login_page()));
                                },
                                child: Text(
                                  "Skip",
                                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // decorative blob helper
  Widget _blob(double size, List<Color> colors, bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isDark
            ? RadialGradient(colors: [Colors.white10, Colors.white12])
            : LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
    );
  }
}
