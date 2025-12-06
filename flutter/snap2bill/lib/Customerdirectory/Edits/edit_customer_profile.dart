import 'dart:convert';
import 'dart:io'; // Required for FileImage
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snap2bill/Customerdirectory/customer_home_page.dart';
import 'package:snap2bill/Customerdirectory/profile_page.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'dart:typed_data';

import 'package:snap2bill/widgets/CustomerNavigationBar.dart';


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
  // Controllers
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final pincode = TextEditingController();
  final place = TextEditingController();
  final post = TextEditingController();
  final bio = TextEditingController();

  // File Picker State
  PlatformFile? _selectedFile;
  Uint8List? _webFileBytes;

  bool _isLoading = false;

  @override
  void initState(){
    super.initState();
    name.text = widget.name;
    email.text = widget.email;
    phone.text = widget.phone;
    address.text = widget.address;
    pincode.text = widget.pincode;
    place.text = widget.place;
    post.text = widget.post;
    bio.text = widget.bio;
  }

  // --- FILE PICKER ---
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image, // Prefer image for profile
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
        if (kIsWeb) {
          _webFileBytes = result.files.first.bytes;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. GET THEME DATA
    final theme = Theme.of(context);

    // Determine text colors
    final bool isDark = theme.brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          "Edit Profile",
          style: TextStyle(
              color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: theme.primaryColor),
            onPressed: _isLoading ? null : _updateProfile,
          )
        ],
      ),
      body: Column(
        children: [
          // --- SCROLLABLE FORM ---
          Expanded(
            child: Container(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // PROFILE PHOTO
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickFile,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: theme.cardColor,
                              backgroundImage: _getProfileImage(),
                              child: (_selectedFile == null && _webFileBytes == null)
                                  ? Icon(Icons.person, size: 50, color: theme.disabledColor)
                                  : null,
                            ),
                          ),
                          TextButton(
                            onPressed: _pickFile,
                            child: Text(
                              "Change Profile Photo",
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    // FIELDS
                    _buildThemeField("Name", name, Icons.person, theme),
                    _buildThemeField("Bio", bio, Icons.info_outline, theme),

                    const SizedBox(height: 20),
                    Text("Private Information", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 15),

                    _buildThemeField("Email", email, Icons.email, theme, enabled: false),
                    _buildThemeField("Phone", phone, Icons.phone_android, theme, keyboardType: TextInputType.phone),

                    _buildThemeField("Address", address, Icons.home, theme),

                    Row(
                      children: [
                        Expanded(child: _buildThemeField("Pincode", pincode, Icons.pin_drop, theme, keyboardType: TextInputType.number)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildThemeField("Post", post, Icons.local_post_office, theme)),
                      ],
                    ),

                    _buildThemeField("Place", place, Icons.place, theme),

                    const SizedBox(height: 30), // Space for bottom scrolling
                  ],
                ),
              ),
            ),
          ),

          // --- STICKY BOTTOM BUTTON ---
        ],
      ),
    );
  }

  // --- LOGIC ---
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
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
      request.fields['cid'] = sh.getString("cid").toString();

      // File handling
      if (_selectedFile != null) {
        if (kIsWeb) {
          if (_webFileBytes == null) {
            _showSnack('File bytes are empty (web).');
            return;
          }
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            _webFileBytes!,
            filename: _selectedFile!.name,
          ));
        } else {
          if (_selectedFile?.path == null) {
            _showSnack('File path empty.');
            return;
          }
          request.files.add(await http.MultipartFile.fromPath(
            'file',
            _selectedFile!.path!,
          ));
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var decodeddata = json.decode(response.body);

      if (decodeddata['status'] == 'ok') {
        if (!mounted) return;
        _showSuccessDialog();
      } else {
        if (!mounted) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const CustomerNavigationBar()));
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HELPERS ---

  ImageProvider? _getProfileImage() {
    if (kIsWeb && _webFileBytes != null) return MemoryImage(_webFileBytes!);
    if (_selectedFile != null && _selectedFile!.path != null) return FileImage(File(_selectedFile!.path!));
    return null;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Profile Updated Successfully"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CustomerNavigationBar()),
              );
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Widget _buildThemeField(String label, TextEditingController controller, IconData icon, ThemeData theme,
      {bool enabled = true, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: theme.primaryColor),
          // Themes handle colors automatically
        ),
      ),
    );
  }
}