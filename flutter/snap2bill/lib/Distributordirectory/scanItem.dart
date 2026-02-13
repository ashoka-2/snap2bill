

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/distributorsends/addProduct.dart';
import 'package:snap2bill/Distributordirectory/distributorsends/addToBill.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:snap2bill/Distributordirectory/view/viewBillItems.dart';

// Import your custom widgets
import '../../widgets/app_button.dart';
import '../theme/colors.dart';
import '../widgets/Navbar.dart';
import '../widgets/SnackBar.dart';



class CameraCapture extends StatefulWidget {
  @override
  _CameraCaptureState createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraCapture> {
  File? _image;
  XFile? _pickedFile;
  final picker = ImagePicker();
  bool _isScanning = false;
  bool _showAddButton = false;

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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "";

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

      request.fields['uid'] = prefs.getString("uid").toString();
      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      var decoded = json.decode(responseString);

      if (decoded['status'] == 'ok') {
        prefs.setString("sid", decoded['sid'].toString());
        prefs.setString("pname", decoded['product_name']);

        Navigator.push(context, MaterialPageRoute(builder: (context) => const addToBill()));
      } else {
        setState(() => _showAddButton = true);

        CustomSnackBar.show(context,"Could not recognize Product!",
            backgroundColor: AppColors.dangerColor);
      }
    } catch (e) {

      CustomSnackBar.show(context, Text('Error: $e') as String,
          backgroundColor: AppColors.dangerColor);
    } finally {
      setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
final textColor = AppColors.getTextColor(context);
    final cardColor = theme.cardColor;
    final buttonColor = isDark ? AppColors.WhiteColor: Colors.black;
    final buttonTextColor = isDark ? AppColors.BlackColor: Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar:ThemeNavbar(title: "Scan Product",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: ()=>{
          if (Navigator.canPop(context)) Navigator.pop(context)
        },
        centerTitle: true,

          actions:_showAddButton
              ? [
            IconButton(
              onPressed: () {
                // Navigate to your products list so they can pick manually
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  add_product(capturedFile: _pickedFile,))
                );
              },
              icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedAddSquare,
                  color: isDark ? AppColors.WhiteColor: Colors.black
              ),
            )
          ]
              : null,

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
                      color: isDark? Colors.black.withValues(alpha:0.3): Colors.black.withValues(alpha:0.05),
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
                      Icon(Icons.camera_outlined, size: 60, color: textColor.withValues(alpha:0.3)),
                      const SizedBox(height: 10),
                      Text('No image captured', style: TextStyle(color: textColor.withValues(alpha:0.5))),
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
                  color: textColor.withValues(alpha:0.5),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20,),
              AppButton(
                text: "View Bill",
                onPressed: () async {
                  // SharedPreferences prefs = await SharedPreferences.getInstance();
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>viewBillItems()));
                },
                color: buttonColor,
                textColor: buttonTextColor,
                icon: Icons.receipt,
              )
            ],
          ),
        ),
      ),
    );
  }
}