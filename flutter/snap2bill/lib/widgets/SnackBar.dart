//
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// class CustomSnackBar {
//   static void show(
//       BuildContext context,
//       String message, {
//         int durationMs = 2000,
//         Color backgroundColor = Colors.black,
//         Color textColor = Colors.white,
//       }) {
//     FToast fToast = FToast();
//     fToast.init(context);
//
//     Widget toast = Container(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(25.0),
//         color: backgroundColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black,
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           )
//         ],
//       ),
//       child: Text(
//         message,
//         style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
//       ),
//     );
//
//     fToast.showToast(
//       child: toast,
//       gravity: ToastGravity.BOTTOM,
//       toastDuration: Duration(milliseconds: durationMs),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomSnackBar {
  // 🚀 1. Static variable banaya taaki purane toast ka record rahe
  static FToast? _fToast;

  static void show(
      BuildContext context,
      String message, {
        int durationMs = 2000,
        Color backgroundColor = Colors.black,
        Color textColor = Colors.white,
      }) {

    // 🚀 2. Agar _fToast null hai toh naya banayenge, warna purana hi use karenge
    _fToast ??= FToast();
    _fToast!.init(context);

    // 🔥 MAGIC LINES: Naya toast dikhane se pehle purane saare toasts turant gayab kar do
    _fToast!.removeCustomToast();
    _fToast!.removeQueuedCustomToasts();

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: backgroundColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26, // Thoda soft shadow kiya hai
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Text(
        message,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );

    // 🚀 3. Naya toast show karo
    _fToast!.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(milliseconds: durationMs),
    );
  }
}
