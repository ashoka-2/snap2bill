import 'package:flutter/material.dart';

class CustomSnackBar {
  /// Displays a customizable SnackBar.
  ///
  /// [message] is the text to show.
  /// [durationMs] allows overriding the default 100ms duration.
  static void show(
      BuildContext context,
      String message, {
        int durationMs = 1000, // Default duration: 100ms
        Color backgroundColor = Colors.black87,
        Color textColor = Colors.white,
      }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: textColor),
      ),
      backgroundColor: backgroundColor,
      // Sets the display duration
      duration: Duration(milliseconds: durationMs),
      // Floating behavior is required to apply custom shapes and margins
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // Border radius of 30
      ),
      // Optional: adds padding/margin to make it look "floating"
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );

    // Clear existing SnackBars and show the new one
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}