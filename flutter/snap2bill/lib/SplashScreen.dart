import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snap2bill/theme/colors.dart';
import 'main.dart'; // MyApp_sub

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyApp_sub()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors
              .backgroundDark // dark theme color
        : AppColors.backgroundLight; // light theme color

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SvgPicture.asset(
          "assets/images/snap2bill_logo.svg",
          width: 150,
          height: 200,
        ),
      ),
    );
  }
}
