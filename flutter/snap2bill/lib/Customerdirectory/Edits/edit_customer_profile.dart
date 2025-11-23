import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snap2bill/Customerdirectory/customer_home_page.dart';
import 'package:snap2bill/Customerdirectory/profile_page.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'dart:typed_data';


class edit_customer_profile_sub extends StatefulWidget {
  final id;
  final name;
  final email;
  final phone;
  final bio;
  final address;
  final pincode;
  final place;
  final post;

  const edit_customer_profile_sub({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    required this.address,
    required this.place,
    required this.pincode,
    required this.post,
  }) : super();


  @override
  State<edit_customer_profile_sub> createState() => _edit_customer_profile_subState();
}

class _edit_customer_profile_subState extends State<edit_customer_profile_sub> {
  final name=new TextEditingController();
  final email=new TextEditingController();
  final phone=new TextEditingController();
  final address=new TextEditingController();
  final pincode=new TextEditingController();
  final place=new TextEditingController();
  final post=new TextEditingController();
  final bio=new TextEditingController();

  PlatformFile? _selectedFile;
  Uint8List? _webFileBytes;
  String? _result;
  bool _isLoading = false;




  @override
  void initState(){
    name.text=widget.name;
    email.text=widget.email;
    phone.text=widget.phone;
    address.text=widget.address;
    pincode.text=widget.pincode;
    place.text=widget.place;
    post.text=widget.post;
    bio.text=widget.bio;
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
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
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Select File"),
                    onPressed: _pickFile,
                  ),
                  if (_selectedFile != null) ...[
                    const SizedBox(height: 10),
                    Text("Selected: ${_selectedFile!.name}"),
                  ],
                  const SizedBox(height: 20),

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



                        Uri uri = Uri.parse('${ip}/edit_customer_profile');


                        var request = http.MultipartRequest('POST', uri);


                        request.fields['name'] = name.text;
                        request.fields['email'] = email.text;
                        request.fields['phone'] = phone.text;

                        request.fields['address'] = address.text;
                        request.fields['pincode'] = pincode.text;
                        request.fields['place'] = place.text;
                        request.fields['post'] = post.text;
                        request.fields['bio'] = bio.text;

                        request.fields['cid']=sh.getString("cid").toString();


                        if (_selectedFile != null) {
                          if (kIsWeb) {
                            if (_webFileBytes == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('First file bytes are empty (web).')),
                              );
                              setState(() {
                                _isLoading = false;
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
                                          const customer_home_page()),
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
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>customer_home_page()));
                        }

                        setState(() {
                          _isLoading = false;
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
