import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snap2bill/Distributordirectory/home_page.dart';
import 'package:snap2bill/Distributordirectory/profile_page.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'dart:typed_data';

class edit_distributor_profile_sub extends StatefulWidget {
  final id;
  final name;
  final email;
  final phone;
  final bio;
  final address;
  final pincode;
  final place;
  final post;
  final latitude;
  final longitude;

  const edit_distributor_profile_sub({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    required this.address,
    required this.place,
    required this.pincode,
    required this.post,
    required this.latitude,
    required this.longitude,
  }) : super();

  @override
  State<edit_distributor_profile_sub> createState() =>
      _edit_distributor_profile_subState();
}

class _edit_distributor_profile_subState
    extends State<edit_distributor_profile_sub> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final pincode = TextEditingController();
  final place = TextEditingController();
  final post = TextEditingController();
  final bio = TextEditingController();
  final latitude = TextEditingController();
  final longitude = TextEditingController();

  PlatformFile? _selectedFile;
  Uint8List? _webFileBytes;
  String? _result;
  bool _isLoading = false;

  PlatformFile? _selectedFile1;
  Uint8List? _webFileBytes1;
  String? _result1;
  bool _isLoading1 = false;

  @override
  void initState() {
    super.initState();
    name.text = widget.name;
    email.text = widget.email;
    phone.text = widget.phone;
    address.text = widget.address;
    pincode.text = widget.pincode;
    place.text = widget.place;
    post.text = widget.post;
    bio.text = widget.bio;
    latitude.text = widget.latitude;
    longitude.text = widget.longitude;
  }

  // =====================================================
  // 📸 PICK FILE FUNCTIONS
  // =====================================================
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
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
      type: FileType.any,
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
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 400,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  buildTextField("Name", name, Icons.person),
                  const SizedBox(height: 12),
                  buildTextField("Email", email, Icons.email_outlined,
                      enabled: false),
                  const SizedBox(height: 12),
                  buildTextField("Phone Number", phone, Icons.phone_android,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  buildTextField("Address", address, Icons.home),
                  const SizedBox(height: 12),
                  buildTextField("Pincode", pincode, Icons.pin_drop,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  buildTextField("Place", place, Icons.place),
                  const SizedBox(height: 12),
                  buildTextField("Post", post, Icons.location_on),
                  const SizedBox(height: 12),
                  buildTextField("Bio", bio, Icons.info_outline),
                  const SizedBox(height: 12),
                  buildTextField("Latitude", latitude, Icons.explore),
                  const SizedBox(height: 12),
                  buildTextField(
                      "Longitude", longitude, Icons.explore_outlined),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Select File"),
                    onPressed: _pickFile,
                  ),
                  if (_selectedFile != null) ...[
                    const SizedBox(height: 10),
                    Text("Selected: ${_selectedFile!.name}"),
                  ],
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Select File"),
                    onPressed: _pickFile1,
                  ),
                  if (_selectedFile1 != null) ...[
                    const SizedBox(height: 10),
                    Text("Selected: ${_selectedFile1!.name}"),
                  ],
                  const SizedBox(height: 25),

                  // ✅ Update button (no try-catch)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {


                        SharedPreferences sh =
                        await SharedPreferences.getInstance();
                        final String? ip = sh.getString("ip");



                        Uri uri = Uri.parse('${ip}/edit_distributor_profile');


                        var request = http.MultipartRequest('POST', uri);


                        request.fields['name'] = name.text;
                        request.fields['email'] = email.text;
                        request.fields['phone'] = phone.text;

                        request.fields['address'] = address.text;
                        request.fields['pincode'] = pincode.text;
                        request.fields['place'] = place.text;
                        request.fields['post'] = post.text;
                        request.fields['bio'] = bio.text;
                        request.fields['latitude'] = latitude.text;
                        request.fields['longitude'] = longitude.text;
                        request.fields['uid']=sh.getString("uid").toString();


                        if (_selectedFile != null) {
                          if (kIsWeb) {
                            if (_webFileBytes == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('First file bytes are empty (web).')),
                              );
                              setState(() {
                                _isLoading = false;
                                _isLoading1 = false;
                              });
                              return;
                            }
                            request.files.add(
                              http.MultipartFile.fromBytes(
                                'file',
                                _webFileBytes!,
                                filename: _selectedFile!.name,
                              ),
                            );
                          } else {
                            if (_selectedFile?.path == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('First file path empty.')),
                              );

                              return;
                            }
                            request.files.add(await http.MultipartFile.fromPath(
                              'file',
                              _selectedFile!.path!,
                            ));
                          }
                        }


                        if (_selectedFile1 != null) {
                          if (kIsWeb) {
                            if (_webFileBytes1 == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Second file bytes empty (web).')),
                              );

                              return;
                            }
                            request.files.add(
                              http.MultipartFile.fromBytes(
                                'file1',
                                _webFileBytes1!,
                                filename: _selectedFile1!.name,
                              ),
                            );
                          } else {
                            if (_selectedFile1?.path == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Second file path empty.')),
                              );

                              return;
                            }
                            request.files.add(await http.MultipartFile.fromPath(
                              'file1',
                              _selectedFile1!.path!,
                            ));
                          }
                        }

                        // ========== SEND REQUEST ==========
                        var streamedResponse = await request.send();
                        var response = await http.Response.fromStream(streamedResponse);


                          var decodeddata = json.decode(response.body);

                          if (decodeddata['status'] == 'ok') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                title: const Text("Profile Updated",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold)),
                                content: const Text(
                                    "Your profile has been successfully updated."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const home_page()),
                                      );
                                    },
                                    child: const Text(
                                      "OK",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                           Navigator.push(context, MaterialPageRoute(builder: (context)=>home_page()));
                          }

                        setState(() {
                          _isLoading = false;
                          _isLoading1 = false;
                        });
                      },
                      child: const Text(
                        "Update Profile",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label,
      TextEditingController controller,
      IconData icon, {
        bool enabled = true,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 1.8),
        ),
      ),
    );
  }
}
