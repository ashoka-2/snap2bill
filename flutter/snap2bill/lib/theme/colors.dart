// File: lib/theme/colors.dart

import 'package:flutter/material.dart';

class AppColors {

  // The Top-Left / Start Color (Bright Blue)
  static const Color premiumBlue = Color(0xe87fbbe1);

  // The Bottom-Right / End Color (Rich Purple/Magenta)
  static const Color premiumPurple = Color(0xFFB85EE6);

  // A secondary deeper variant for dark mode logic
  static const Color premiumDarkBlue = Color(0xff0377ea);

  // Reusable Gradient Object
  static const RadialGradient premiumGradient = RadialGradient(
    // Shift center to top-left to simulate light hitting a curved surface
    center: Alignment(-0.7, -0.1),
    radius: 3,
    colors: [
      Color(0xff2388da), // 1. Light Highlight (Light Blue)
      premiumBlue,       // 2. Main Brand Color
      premiumDarkBlue,     // 3. Deep Edge Color (The Purple from your image)
    ],
    stops: [0.0, 0.4, 1.0], // Controls the spread of the "light"
  );


  static const Color dangerColor = Color(0xf0cb0101);
  static const Color dangerbgColor = Color(0x54912727);

  static const Color successLightColor = Color(0xf01fc43c);
  static const Color successDarkColor = Color(0xf0027029);
  static const Color successbgColor = Color(0x6b1cff4a);

  static const Color orangeColor = Color(0xf0ff6d05);


  // Light Mode
  static const Color primaryLight = Color(0xff23afda);
  static const Color backgroundLight = Color(0xFFF0F4F8);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textMainLight = Color(0xFF1A1D1E);
  static const Color textSubLight = Color(0xFF6A6C7B);
  static const Color inputFillLight = Color(0xFFF5F6FA);

  static const Color buttonColorLight = Color(0xFFFFFFFF);
  static const Color iconColorLight = Color(0xFF000000);

  static const Color disabledColor = Color(0xA1676767);
  // static const Color borderColor = Color(0x212121);
  static const Color pillColor = Color(0xff23afda);
  static Color pillbgColor = const Color(0xff23afda).withValues(alpha: 0.2);
  static const Color whiteTextColor = Color(0xE5FFFFFF);
  static const Color borderColorLight = Color(0xFF000000);

  static const Color BlackColor = Color(0xFF000000);
  static const Color WhiteColor = Color(0xFFFFFFFF);

  // Dark Mode
  static const Color buttonColorDark = Color(0xFF000000);
  static const Color iconColorDark = Color(0xFFFFFFFF);

  static const Color primaryDark = Color(0xff23afda);
  static const Color backgroundDark = Color(0xED121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color textMainDark = Color(0xFFFFFFFF);
  static const Color textSubDark = Color(0xFFAAAAAA);
  static const Color inputFillDark = Color(0xFF2C2C2C);
  static const Color borderColorDark = Color(0xD8FFFFFF);

  static const List<Color> blobGradient1 = [
    Color(0xFF1138F5),
    Color(0xFF2E3F8F),
  ];
  static const List<Color> blobGradient2 = [
    Color(0xFF6E85FF),
    Color(0xFF0D34F1),
  ];


  static bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color getButtonColor(BuildContext context) =>
      isDarkMode(context) ? AppColors.WhiteColor: Colors.black;

  static Color getPillBg(BuildContext context) =>
      isDarkMode(context) ? Colors.grey.shade800 : Colors.grey.shade100;

  static Color getButtonBg(BuildContext context) =>
      isDarkMode(context) ? primaryDark : primaryLight;

  static Color getPrimaryColor(BuildContext context) =>
      isDarkMode(context) ? primaryDark : primaryLight;

  static Color getTextColor(BuildContext context) =>
      isDarkMode(context) ? textMainDark : textMainLight;

  static Color getTextSubColor(BuildContext context) =>
      isDarkMode(context) ? textSubDark : textSubLight;

  static Color getTextColor2(BuildContext context) =>
      isDarkMode(context) ? textMainLight : textMainDark;

  static Color getTextSubColor2(BuildContext context) =>
      isDarkMode(context) ? textSubLight : textSubDark;

  static Color getIconColor(BuildContext context) =>
      isDarkMode(context) ? iconColorDark : iconColorLight;

  static Color getBorderColor(BuildContext context) =>
      isDarkMode(context) ? borderColorDark : borderColorLight;

  static Color getCardColor(BuildContext context) =>
      isDarkMode(context) ? cardDark : cardLight;

  static Color getSuccessColor(BuildContext context) =>
      isDarkMode(context) ? successDarkColor : successLightColor;

  static Color getDangerColor(BuildContext context) =>
      isDarkMode(context) ? dangerColor : dangerColor;

  static Color getInputFieldColor(BuildContext context) =>
      isDarkMode(context) ? inputFillDark : inputFillLight;


  static Color? getHintColor(BuildContext context) =>
      isDarkMode(context) ? Colors.white38 : Colors.grey[500];

  static Color? getSecondaryButtonBg(BuildContext context) =>
      isDarkMode(context) ? Colors.grey.shade800 : Colors.grey.shade800;


  static Color? getPlaceHolderColor(BuildContext context)=>
    isDarkMode(context) ? Colors.grey[800] : Colors.grey[300];

  static Color getScaffoldBg(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;



}
