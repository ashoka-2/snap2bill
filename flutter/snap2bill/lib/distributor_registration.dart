import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snap2bill/Login_page.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'dart:typed_data';



void main() {
  runApp(distributor_registration());
}

class distributor_registration extends StatelessWidget {
  const distributor_registration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: distributor_registration_sub());
  }
}

class distributor_registration_sub extends StatefulWidget {
  const distributor_registration_sub({Key? key}) : super(key: key);

  @override
  State<distributor_registration_sub> createState() =>
      _distributor_registration_subState();
}

class _distributor_registration_subState
    extends State<distributor_registration_sub> {
  final name = new TextEditingController();
  final email = new TextEditingController();
  final phone = new TextEditingController();
  final password = new TextEditingController();
  final confirmpassword = new TextEditingController();
  final address = new TextEditingController();
  final pincode = new TextEditingController();
  final place = new TextEditingController();
  final post = new TextEditingController();
  final bio = new TextEditingController();
  final latitude = new TextEditingController();
  final longitude = new TextEditingController();

  PlatformFile? _selectedFile;
  Uint8List? _webFileBytes;
  String? _result;
  bool _isLoading = false;

  PlatformFile? _selectedFile1;
  Uint8List? _webFileBytes1;
  String? _result1;
  bool _isLoading1 = false;

  // =====================================================
  // 📸 PICK FILE FUNCTION
  // =====================================================
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any, // Any file type allowed
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
        _result = null;
      });

      if (kIsWeb) {
        _webFileBytes = result.files.first.bytes;
      }
    }
  }

  Future<void> _pickFile1() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any, // Any file type allowed
    );

    if (result != null) {
      setState(() {
        _selectedFile1 = result.files.first;
        _result1 = null;
      });

      if (kIsWeb) {
        _webFileBytes1 = result.files.first.bytes;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
        title: Text("Hello world"),
      ),
      // backgroundColor: Colors.cyan,
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                width: 400,
                // height: 1000,
                decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(21)),
                child: Padding(
                  padding:
                  const EdgeInsets.only(left: 10, top: 20, right: 10, bottom: 15),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.upload_file),
                        label: Text("Select File"),
                        onPressed: _pickFile,
                      ),
                      if (_selectedFile != null) ...[
                        SizedBox(height: 10),
                        Text("Selected: ${_selectedFile!.name}"),
                      ],
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: name,
                        decoration: InputDecoration(
                          hintText: 'Enter your name ',
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.abc_rounded),
                          filled: true,
                          fillColor: Colors.white70,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: email,
                        decoration: InputDecoration(
                            hintText: 'Enter your Email',
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: phone,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter your number',
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_android),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: password,
                        decoration: InputDecoration(
                          hintText: "Enter password",
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.password),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: confirmpassword,
                        decoration: InputDecoration(
                          hintText: "Enter password",
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.password),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: address,
                        decoration: InputDecoration(
                            hintText: 'Enter your Address',
                            labelText: 'Address',
                            prefixIcon: Icon(Icons.location_city),
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: pincode,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: 'Enter your pincode',
                            labelText: 'Pincode',
                            prefixIcon: Icon(Icons.location_on_sharp),
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: place,
                        decoration: InputDecoration(
                            hintText: 'Enter your Place',
                            labelText: 'Place',
                            prefixIcon: Icon(Icons.place),
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: post,
                        decoration: InputDecoration(
                            hintText: 'Enter your post',
                            labelText: 'Post',
                            prefixIcon: Icon(Icons.place_sharp),
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: bio,
                        decoration: InputDecoration(
                            hintText: 'Enter description',
                            labelText: 'Bio',
                            prefixIcon: Icon(Icons.abc_sharp),
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: latitude,
                        decoration: InputDecoration(
                            hintText: 'Enter your Latitude',
                            labelText: 'Latitude',
                            prefixIcon: Icon(Icons.abc_sharp),
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: longitude,
                        decoration: InputDecoration(
                            hintText: 'Enter your Longitude',
                            labelText: 'Longitude',
                            prefixIcon: Icon(Icons.abc_sharp),
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: Icon(Icons.upload_file),
                        label: Text("Select File"),
                        onPressed: _pickFile1,
                      ),
                      if (_selectedFile1 != null) ...[
                        SizedBox(height: 10),
                        Text("Selected: ${_selectedFile1!.name}"),
                      ],
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                          onPressed: () async {

                            if (_selectedFile == null && _selectedFile1 == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please select at least one file first')),
                              );
                              return;
                            }

                            SharedPreferences sh = await SharedPreferences.getInstance();
                            String? ip = sh.getString('ip');



                            var uri = Uri.parse('$ip/distributor_registration');
                            var request = http.MultipartRequest('POST', uri);

                            // 🔹 Normal Form Data
                            request.fields['name'] = name.text;
                            request.fields['email'] = email.text;
                            request.fields['phone'] = phone.text;
                            request.fields['password'] = password.text;
                            request.fields['confirmpassword'] = confirmpassword.text;
                            request.fields['address'] = address.text;
                            request.fields['pincode'] = pincode.text;
                            request.fields['place'] = place.text;
                            request.fields['post'] = post.text;
                            request.fields['bio'] = bio.text;
                            request.fields['latitude'] = latitude.text;
                            request.fields['longitude'] = longitude.text;

                            request.fields['uid'] = sh.getString('uid')?.toString() ?? '';


                            if (_selectedFile != null) {
                              if (kIsWeb) {
                                if (_webFileBytes == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('First file bytes are empty (web).')));
                                  setState(() {
                                    _isLoading = false;
                                    _isLoading1 = false;
                                  });
                                  return;
                                }
                                request.files.add(http.MultipartFile.fromBytes(
                                  'file',
                                  _webFileBytes!,
                                  filename: _selectedFile!.name,
                                ));
                              } else {
                                if (_selectedFile?.path == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('First selected file path is empty.')));
                                  setState(() {
                                    _isLoading = false;
                                    _isLoading1 = false;
                                  });
                                  return;
                                }
                                request.files.add(await http.MultipartFile.fromPath(
                                  'file',
                                  _selectedFile!.path!,
                                ));
                              }
                            }

                            // file1 (second)
                            if (_selectedFile1 != null) {
                              if (kIsWeb) {
                                if (_webFileBytes1 == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Second file bytes are empty (web).')));
                                  setState(() {
                                    _isLoading = false;
                                    _isLoading1 = false;
                                  });
                                  return;
                                }
                                request.files.add(http.MultipartFile.fromBytes(
                                  'file1',
                                  _webFileBytes1!,
                                  filename: _selectedFile1!.name,
                                ));
                              } else {
                                if (_selectedFile1?.path == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Second selected file path is empty.')));
                                  setState(() {
                                    _isLoading = false;
                                    _isLoading1 = false;
                                  });
                                  return;
                                }
                                request.files.add(await http.MultipartFile.fromPath(
                                  'file1',
                                  _selectedFile1!.path!,
                                ));
                              }
                            }

                            var streamedResponse = await request.send();
                            var responseString = await streamedResponse.stream.bytesToString();

                            var decoded = json.decode(responseString);



                            if (decoded['status'] == 'ok') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Registration successful!')),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => login_page()),
                              );
                            } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => login_page()));
                            };
                          },
                          child: Text("Register")),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
