

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomSnackBar {
  static void show(
      BuildContext context,
      String message, {
        int durationMs = 2000,
        Color backgroundColor = Colors.black,
        Color textColor = Colors.white,
      }) {
    FToast fToast = FToast();
    fToast.init(context);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Text(
        message,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(milliseconds: durationMs),
    );
  }
}