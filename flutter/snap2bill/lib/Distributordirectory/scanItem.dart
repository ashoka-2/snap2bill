// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Distributordirectory/distributorsends/addToBill.dart';
// import 'dart:convert';
//
// import '../Distributordirectory/search_page.dart';
//
// class Cameracapturemain extends StatelessWidget {
//   const Cameracapturemain({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: CameraCapture(),
//     debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
//
// class CameraCapture extends StatefulWidget {
//   @override
//   _CameraCaptureState createState() => _CameraCaptureState();
// }
//
// class _CameraCaptureState extends State<CameraCapture> {
//   File? _image;
//   final picker = ImagePicker();
//
//   Future<void> _captureImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//
//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//       }
//     });
//   }
//
//   Future<void> _sendImage() async {
//     if (_image == null) return;
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String ip = sh.getString("ip") ?? "";
//
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse("${ip}/scanItem"));
//
//       request.files.add(
//       http.MultipartFile(
//       'image',
//       _image!.readAsBytes().asStream(),
//       _image!.lengthSync(),
//       filename: _image!.path.split('/').last,
//     ),
//     );
//
//     request.fields['uid'] = sh.getString("uid").toString();
//     var response = await request.send();
//
//     var responseString = await response.stream.bytesToString();
//     var decoded = json.decode(responseString);
//
//     if (decoded['status'] == 'ok') {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       sh.setString("stock_id", decoded['stock_id'].toString());
//       sh.setString("pname", decoded['product_name']);
//       var pname= decoded['product_name'];
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Showing product details for " + pname),
//         ),
//       );
//       print("item Scanned and sent");
//       Navigator.push(context, MaterialPageRoute(builder: (context) => const addToBill()));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Cant recognise product",style: TextStyle(backgroundColor: Colors.red,color: Colors.black),),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Camera Capture'),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _image == null
//                     ? Text('No image captured')
//                     : Image.file(_image!),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _captureImage,
//                   child: Text('Capture Image'),
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _sendImage,
//                   child: Text('Send Image'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/distributorsends/addToBill.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

// Import your custom widgets
import '../../widgets/app_button.dart';



class CameraCapture extends StatefulWidget {
  @override
  _CameraCaptureState createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraCapture> {
  File? _image;
  XFile? _pickedFile;
  final picker = ImagePicker();
  bool _isScanning = false;

  Future<void> _captureImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _pickedFile = pickedFile;
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _sendImage() async {
    if (_pickedFile == null) return;

    setState(() => _isScanning = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? "";

      var request = http.MultipartRequest('POST', Uri.parse("${ip}/scanItem"));

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          await _pickedFile!.readAsBytes(),
          filename: _pickedFile!.name,
        ));
      } else {
        request.files.add(http.MultipartFile(
          'image',
          _image!.readAsBytes().asStream(),
          _image!.lengthSync(),
          filename: _image!.path.split('/').last,
        ));
      }

      request.fields['uid'] = sh.getString("uid").toString();
      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      var decoded = json.decode(responseString);

      if (decoded['status'] == 'ok') {
        sh.setString("stock_id", decoded['stock_id'].toString());
        sh.setString("pname", decoded['product_name']);

        Navigator.push(context, MaterialPageRoute(builder: (context) => const addToBill()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not recognize product"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = theme.cardColor;
    final buttonColor = isDark ? Colors.white : Colors.black;
    final buttonTextColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Scan Product',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // --- Image Preview Container ---
              Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _pickedFile == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_outlined, size: 60, color: textColor.withOpacity(0.3)),
                      const SizedBox(height: 10),
                      Text('No image captured', style: TextStyle(color: textColor.withOpacity(0.5))),
                    ],
                  )
                      : kIsWeb
                      ? Image.network(_pickedFile!.path, fit: BoxFit.cover)
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 40),

              // --- BUTTONS SECTION ---
              if (_pickedFile == null)
              // Only "Open Camera" shown if no image
                AppButton(
                  text: "Open Camera",
                  onPressed: _captureImage,
                  color: buttonColor,
                  textColor: buttonTextColor,
                  icon: Icons.photo_camera_rounded,
                )
              else
              // Row layout for Retake and Scan buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: "Retake",
                        onPressed: _captureImage,
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        textColor: textColor,
                        icon: Icons.refresh_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: "Scan",
                        onPressed: _sendImage,
                        isLoading: _isScanning,
                        color: buttonColor,
                        textColor: buttonTextColor,
                        icon: Icons.search_rounded,
                        isTrailingIcon: true,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 40),

              // --- Instructions Text ---
              Text(
                "Position the product clearly in the frame\nfor a better match.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}