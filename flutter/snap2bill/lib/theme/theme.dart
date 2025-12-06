import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';

// ----------------------- LIGHT THEME -----------------------
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryLight,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  fontFamily: 'Roboto',
  colorScheme: const ColorScheme.light(primary: AppColors.primaryLight),
  cardColor: AppColors.cardLight,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.inputFillLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
);

// ----------------------- DARK THEME -----------------------
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryDark,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  fontFamily: 'Roboto',
  colorScheme: const ColorScheme.dark(primary: AppColors.primaryDark),
  cardColor: AppColors.cardDark,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.inputFillDark,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
);




class ThemeService {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  static const String _key = 'isDarkMode';

  bool isDarkMode = false;

  /// Load theme from SharedPreferences
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool(_key) ?? false;
  }

  /// Toggle theme and save
  Future<void> toggle() async {
    isDarkMode = !isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDarkMode);
  }
}
