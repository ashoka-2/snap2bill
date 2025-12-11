import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // REQUIRED FOR INPUT FORMATTERS
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
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
  State<edit_customer_profile_sub> createState() =>
      _edit_customer_profile_subState();
}

class _edit_customer_profile_subState
    extends State<edit_customer_profile_sub> {

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
  void initState() {
    super.initState();
    name.text = widget.name.toString();
    email.text = widget.email.toString();
    phone.text = widget.phone.toString();
    address.text = widget.address.toString();
    pincode.text = widget.pincode.toString();
    place.text = widget.place.toString();
    post.text = widget.post.toString();
    bio.text = widget.bio.toString();
  }

  // --- FILE PICKER ---
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
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

  // --- VALIDATION LOGIC ---
  bool _validateForm() {
    // 1. Phone: Strictly 10 Digits
    if (phone.text.length != 10) {
      _showSnack("Phone number must be exactly 10 digits.");
      return false;
    }

    // 2. Pincode: Strictly 6 Digits
    if (pincode.text.length != 6) {
      _showSnack("Pincode must be exactly 6 digits.");
      return false;
    }

    // 3. Basic Empty Checks
    if (name.text.isEmpty) {
      _showSnack("Name cannot be empty.");
      return false;
    }

    return true;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            icon: const Icon(Icons.check, color: Colors.blueAccent),
            onPressed: _isLoading ? null : _updateProfile,
          )
        ],
      ),
      body: Stack(
        children: [
          // MAIN SCROLLABLE FORM
          SingleChildScrollView(
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
                        child: const Text(
                          "Change Profile Photo",
                          style: TextStyle(
                            color: Colors.blueAccent,
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

                // PUBLIC INFO
                _buildThemeField(
                    "Name", name, Icons.person, theme,
                    textColor: textColor
                ),
                _buildThemeField(
                    "Bio", bio, Icons.info_outline, theme,
                    textColor: textColor
                ),

                const SizedBox(height: 20),
                Text("Private Information", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 15),

                // EMAIL (Read Only)
                _buildThemeField(
                    "Email", email, Icons.email, theme,
                    enabled: false, textColor: textColor
                ),

                // PHONE (10 Digits Only)
                _buildThemeField(
                    "Phone", phone, Icons.phone_android, theme,
                    textColor: textColor,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10), // Limit to 10
                    ]
                ),

                // ADDRESS
                _buildThemeField(
                    "Address", address, Icons.home, theme,
                    textColor: textColor
                ),

                // PINCODE (6 Digits Only) & POST
                Row(
                  children: [
                    Expanded(
                        child: _buildThemeField(
                            "Pincode", pincode, Icons.pin_drop, theme,
                            textColor: textColor,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6), // Limit to 6
                            ]
                        )
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _buildThemeField(
                            "Post", post, Icons.local_post_office, theme,
                            textColor: textColor
                        )
                    ),
                  ],
                ),

                _buildThemeField(
                    "Place", place, Icons.place, theme,
                    textColor: textColor
                ),

                const SizedBox(height: 50), // Bottom spacing
              ],
            ),
          ),

          // LOADING OVERLAY
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // --- API LOGIC ---
  Future<void> _updateProfile() async {
    // 1. Run Validation
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      final String? ip = sh.getString("ip");
      final String? cid = sh.getString("cid");

      if (ip == null || cid == null) {
        throw Exception("Session expired or IP not found");
      }

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
      request.fields['cid'] = cid;

      // File handling
      if (_selectedFile != null) {
        if (kIsWeb) {
          if (_webFileBytes != null) {
            request.files.add(http.MultipartFile.fromBytes(
              'file',
              _webFileBytes!,
              filename: _selectedFile!.name,
            ));
          }
        } else {
          if (_selectedFile!.path != null) {
            request.files.add(await http.MultipartFile.fromPath(
              'file',
              _selectedFile!.path!,
            ));
          }
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var decodeddata = json.decode(response.body);

      if (decodeddata['status'] == 'ok') {
        if (!mounted) return;
        _showSuccessDialog();
      } else {
        throw Exception("Failed to update profile");
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
    // Could add a default network image here if available in widget.photo
    return null;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 10),
            Text("Success"),
          ],
        ),
        content: const Text("Profile Updated Successfully", textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              // Navigate back to Profile/Home (Index 0 or Profile Tab)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CustomerNavigationBar(initialIndex: 4,)), // Assuming profile is at index 3
              );
            },
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildThemeField(
      String label,
      TextEditingController controller,
      IconData icon,
      ThemeData theme,
      {
        bool enabled = true,
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        required Color textColor
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: theme.primaryColor, size: 20),
              filled: true,
              fillColor: theme.brightness == Brightness.dark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}