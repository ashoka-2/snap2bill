
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:snap2bill/theme/colors.dart';
import 'dart:typed_data';

import 'package:snap2bill/widgets/CustomerNavigationBar.dart';

import '../../widgets/Navbar.dart';
import '../../widgets/SnackBar.dart';

class edit_customer_profile extends StatefulWidget {
  final dynamic id, name, email, phone, bio, address, pincode, place, post;

  const edit_customer_profile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    required this.address,
    required this.place,
    required this.pincode,
    required this.post,
    Key? key,
  }) : super(key: key);

  @override
  State<edit_customer_profile> createState() => _edit_customer_profileState();
}

class _edit_customer_profileState extends State<edit_customer_profile> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final pincode = TextEditingController();
  final place = TextEditingController();
  final post = TextEditingController();
  final bio = TextEditingController();

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

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
        if (kIsWeb) _webFileBytes = result.files.first.bytes;
      });
    }
  }

  bool _validateForm() {
    if (phone.text.length != 10) return _showErr("Phone must be 10 digits");
    if (pincode.text.length != 6) return _showErr("Pincode must be 6 digits");
    if (name.text.isEmpty) return _showErr("Name is required");
    return true;
  }

  bool _showErr(String msg) {

    CustomSnackBar.show(
      context,
      '$msg',
      backgroundColor: AppColors.dangerColor,
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: ThemeNavbar(title: "Update Profile",
        leadingIcon: Icons.close,
        onLeadingPressed: ()=>{
          if (Navigator.canPop(context)) Navigator.pop(context)
        },
        centerTitle: true,
        actions: [
          IconButton(onPressed: _isLoading ? null : _updateProfile,icon: Icon(Icons.save))
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 10),
              _buildAvatarSection(theme),
              const SizedBox(height: 32),
              _buildSectionTitle("Public Profile"),
              _buildField("Full Name", name, Icons.person_outline_rounded),
              _buildField("Bio", bio, Icons.notes_rounded, maxLines: 3),
              const SizedBox(height: 24),
              _buildSectionTitle("Private Information"),
              _buildField("Email Address", email, Icons.alternate_email_rounded, enabled: false),
              _buildField("Phone Number", phone, Icons.phone_android_rounded,
                  keyboard: TextInputType.phone,
                  formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]),
              _buildField("Residential Address", address, Icons.location_on_outlined),
              Row(
                children: [
                  Expanded(child: _buildField("Pincode", pincode, Icons.pin_drop_outlined,
                      keyboard: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)])),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField("Post", post, Icons.mark_as_unread_outlined)),
                ],
              ),
              _buildField("City / Place", place, Icons.map_outlined),
              const SizedBox(height: 120), // Bottom space for comfort
            ],
          ),
          if (_isLoading) _buildLoader(),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent.withOpacity(0.2), width: 4),
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
              backgroundImage: _getProfileImage(),
              child: (_selectedFile == null && _webFileBytes == null)
                  ? Icon(Icons.person, size: 50, color: Colors.blueAccent.withOpacity(0.4))
                  : null,
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.grey,
            letterSpacing: 1.5
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon,
      {bool enabled = true, int maxLines = 1, TextInputType keyboard = TextInputType.text, List<TextInputFormatter>? formatters}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: ctrl,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboard,
        inputFormatters: formatters,
        style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
          floatingLabelStyle: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
          prefixIcon: Icon(icon, size: 22, color: Colors.blueAccent.withOpacity(0.7)),
          filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return Container(
      color: Colors.black45,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (kIsWeb && _webFileBytes != null) return MemoryImage(_webFileBytes!);
    if (_selectedFile != null && _selectedFile!.path != null) return FileImage(File(_selectedFile!.path!));
    return null;
  }

  Future<void> _updateProfile() async {
    if (!_validateForm()) return;
    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String ip = prefs.getString("ip")!;
      final String cid = prefs.getString("cid")!;

      var request = http.MultipartRequest('POST', Uri.parse('$ip/edit_customer_profile'));
      request.fields.addAll({
        'name': name.text, 'email': email.text, 'phone': phone.text,
        'address': address.text, 'pincode': pincode.text, 'place': place.text,
        'post': post.text, 'bio': bio.text, 'cid': cid,
      });

      if (_selectedFile != null) {
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes('file', _webFileBytes!, filename: _selectedFile!.name));
        } else {
          request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path!));
        }
      }

      var res = await request.send();
      var response = await http.Response.fromStream(res);
      var body = json.decode(response.body);

      if (body['status'] == 'ok') {
        _showSuccess();
      } else {
        _showErr("Update failed: ${body['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      _showErr("Connection Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("Profile Updated", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
            const SizedBox(height: 12),
            const Text("Your changes have been saved successfully.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerNavigationBar(initialIndex: 3)),
                        (route) => false,
                  );
                },
                child: const Text("Continue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}