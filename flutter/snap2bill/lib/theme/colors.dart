// File: lib/theme/colors.dart

import 'package:flutter/material.dart';

class AppColors {


  static const Color dangerColor = Color(0xFFEE1C1C);



  // Light Mode
  static const Color primaryLight = Color(0xFF4B9FFF);
  static const Color backgroundLight = Color(0xFFF0F4F8);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textMainLight = Color(0xFF1A1D1E);
  static const Color textSubLight = Color(0xFF6A6C7B);
  static const Color inputFillLight = Color(0xFFF5F6FA);

  static const Color buttonColorLight = Color(0xFFFFFFFF);
  static const Color iconColorLight = Color(0xFF000000);

  static const Color greyButton = Color(0xA1676767);
  static const Color borderColor = Color(0xc7c7c7);
  static const Color pillColor = Color(0xff23afda);
  static const Color whiteTextColor = Color(0xE5FFFFFF);
  static const Color borderColorLight = Color(0xFF000000);

  // Dark Mode
  static const Color buttonColorDark = Color(0xFF000000);
  static const Color iconColorDark = Color(0xFFFFFFFF);

  static const Color primaryDark = Color(0xFF3361F5);
  static const Color backgroundDark = Color(0xED121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color textMainDark = Color(0xFFFFFFFF);
  static const Color textSubDark = Color(0xFFAAAAAA);
  static const Color inputFillDark = Color(0xFF2C2C2C);
  static const Color borderColorDark = Color(0xFFFFFFFF);

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

  static Color getPillBg(BuildContext context) =>
      isDarkMode(context) ? Colors.grey.shade800 : Colors.grey.shade100;

  static Color getTextColor(BuildContext context) =>
      isDarkMode(context) ? textMainDark : textMainLight;

  static Color getIconColor(BuildContext context) =>
      isDarkMode(context) ? iconColorDark : iconColorLight;

  static Color getBorderColor(BuildContext context) =>
      isDarkMode(context) ? borderColorDark : borderColorLight;

  static Color getScaffoldBg(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;



}
