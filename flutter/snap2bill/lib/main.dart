
import 'dart:async';
import 'package:http/http.dart' as http; // 🚀 Required for Ping
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
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


  //Render overflow error hata tha hai
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint("UI Error Hidden: ${details.exceptionAsString()}");
    return const SizedBox.shrink();
  };
  //Render overflow error hata tha hai



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
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: Builder(
          builder: (context) {
            return ResponsiveScaledBox(
              // 🔥 FIX: <double?> use kiya aur defaultValue: null add kiya
              width: ResponsiveValue<double?>(
                context,
                defaultValue: null, // Badi screens par scaling off rahegi (Normal view)
                conditionalValues: [
                  const Condition.smallerThan(name: TABLET, value: 400.0), // Choti screens ke liye 400.0
                ],
              ).value,
              child: child!,
            );
          },
        ),
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),     // Choti screens
          const Breakpoint(start: 451, end: 800, name: TABLET),   // Medium screens
          const Breakpoint(start: 801, end: 1920, name: DESKTOP), // Badi screens (Web/Windows)
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'), // Extra large screens
        ],
      ),
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
  late Color dangerColor;
  late Color successColor;


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
    }
    else {
      // ✅ Server Alive -> Check Login Status (🚀 WITH "null" STRING PROTECTION)
      bool isCustomer = cid != null && cid.trim().isNotEmpty && cid != "null";
      bool isDistributor = uid != null && uid.trim().isNotEmpty && uid != "null";

      if (isCustomer) {
        _navigateTo(const CustomerNavigationBar(initialIndex: 0));
      } else if (isDistributor) {
        _navigateTo(DistributorNavigationBar(initialIndex: 0));
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
    final primaryColor = AppColors.getPrimaryColor(context);
    successColor = AppColors.getSuccessColor(context);
    dangerColor = AppColors.getDangerColor(context);
    final bgColor = AppColors.getScaffoldBg(context);
    final cardColor = AppColors.getCardColor(context);
    final textColor = AppColors.getTextColor(context);
    final subTextColor = AppColors.getTextSubColor(context);
    final inputFill = AppColors.getInputFieldColor(context);
    final iconColor = AppColors.getIconColor(context);
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.2),
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
  final TextEditingController ipController = TextEditingController(text: "");
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
    final bgColor = AppColors.getScaffoldBg(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor:bgColor,
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
                            : [primaryColor, primaryColor.withValues(alpha:0.7)],
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

                                bool isCustomer = cid != null && cid.trim().isNotEmpty && cid != "null";
                                bool isDistributor = uid != null && uid.trim().isNotEmpty && uid != "null";

                                if (!mounted) return;

                                if (isCustomer) {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerNavigationBar(initialIndex: 0)));
                                } else if (isDistributor) {
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