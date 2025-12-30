import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Cameracapturemain extends StatelessWidget {
  const Cameracapturemain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CameraCapture(),
    debugShowCheckedModeBanner: false,
    );
  }
}


class CameraCapture extends StatefulWidget {
  @override
  _CameraCaptureState createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraCapture> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _captureImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _sendImage() async {
    if (_image == null) return;
    SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip") ?? "";

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${ip}/scanItem"));

      request.files.add(
      http.MultipartFile(
      'image',
      _image!.readAsBytes().asStream(),
      _image!.lengthSync(),
      filename: _image!.path.split('/').last,
    ),
    );

    request.fields['uid'] = sh.getString("uid").toString();
    var response = await request.send();

    if (response.statusCode == 200) {
    print('Image uploaded successfully!');
    } else {
    print('Error uploading image: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Capture'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _image == null
                    ? Text('No image captured')
                    : Image.file(_image!),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _captureImage,
                  child: Text('Capture Image'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sendImage,
                  child: Text('Send Image'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}