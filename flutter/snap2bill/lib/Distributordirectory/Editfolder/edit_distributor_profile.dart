import 'dart:convert';
import 'dart:io'; // Required for FileImage
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snap2bill/Distributordirectory/home_page.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'dart:typed_data';

import 'package:snap2bill/widgets/distributorNavigationbar.dart';

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

  PlatformFile? _selectedFile1;
  Uint8List? _webFileBytes1;

  bool _isLoading = false;

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

  // --- FILE PICKERS ---
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

  Future<void> _pickFile1() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _selectedFile1 = result.files.first;
        if (kIsWeb) {
          _webFileBytes1 = result.files.first.bytes;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. GET THEME DATA
    final theme = Theme.of(context);

    // Determine text colors based on brightness (handled by theme usually, but good for custom widgets)
    final bool isDark = theme.brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor, // Matches background
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor), // "X" looks more like Instagram edit
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
          // Instagram Style: "Done" button in AppBar is also common, but we will keep bottom button as requested
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
              margin: EdgeInsets.only(bottom: 50),

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

                    Row(
                      children: [
                        Expanded(child: _buildThemeField("Latitude", latitude, Icons.explore, theme, keyboardType: TextInputType.number)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildThemeField("Longitude", longitude, Icons.explore, theme, keyboardType: TextInputType.number)),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // DOCUMENT UPLOAD BOX
                    GestureDetector(
                      onTap: _pickFile1,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        decoration: BoxDecoration(
                          color: theme.inputDecorationTheme.fillColor, // Use theme fill
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.description, color: theme.primaryColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedFile1 != null ? _selectedFile1!.name : "Update Proof Document",
                                style: TextStyle(
                                  color: _selectedFile1 != null ? textColor : theme.hintColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30), // Space for bottom scrolling
                  ],
                ),
              ),
            ),
          ),

          // --- STICKY BOTTOM BUTTON ---
          // SafeArea ensures this sits ABOVE the system navigation bar
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
      request.fields['uid'] = sh.getString("uid").toString();

      if (_selectedFile != null) {
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes('file', _webFileBytes!, filename: _selectedFile!.name));
        } else {
          request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path!));
        }
      }

      if (_selectedFile1 != null) {
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes('file1', _webFileBytes1!, filename: _selectedFile1!.name));
        } else {
          request.files.add(await http.MultipartFile.fromPath('file1', _selectedFile1!.path!));
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
            context, MaterialPageRoute(builder: (context) => const Home_page()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Profile Updated Successfully"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DistributorNavigationBar()));
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  // Uses Theme.of(context).inputDecorationTheme automatically
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
          // Filled color and borders are handled by theme.dart
        ),
      ),
    );
  }
}