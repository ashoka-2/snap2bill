// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // REQUIRED FOR INPUT FORMATTERS
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'dart:typed_data';
//
// import 'package:snap2bill/Distributordirectory/home_page.dart';
// import 'package:snap2bill/widgets/distributorNavigationbar.dart';
//
// class edit_distributor_profile_sub extends StatefulWidget {
//   final id;
//   final name;
//   final email;
//   final phone;
//   final bio;
//   final address;
//   final pincode;
//   final place;
//   final post;
//   final latitude;
//   final longitude;
//
//   const edit_distributor_profile_sub({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.bio,
//     required this.address,
//     required this.place,
//     required this.pincode,
//     required this.post,
//     required this.latitude,
//     required this.longitude,
//   }) : super();
//
//   @override
//   State<edit_distributor_profile_sub> createState() =>
//       _edit_distributor_profile_subState();
// }
//
// class _edit_distributor_profile_subState
//     extends State<edit_distributor_profile_sub> {
//
//   // Controllers
//   final name = TextEditingController();
//   final email = TextEditingController();
//   final phone = TextEditingController();
//   final address = TextEditingController();
//   final pincode = TextEditingController();
//   final place = TextEditingController();
//   final post = TextEditingController();
//   final bio = TextEditingController();
//   final latitude = TextEditingController();
//   final longitude = TextEditingController();
//
//   PlatformFile? _selectedFile;
//   Uint8List? _webFileBytes;
//
//   PlatformFile? _selectedFile1;
//   Uint8List? _webFileBytes1;
//
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     name.text = widget.name.toString();
//     email.text = widget.email.toString();
//     phone.text = widget.phone.toString();
//     address.text = widget.address.toString();
//     pincode.text = widget.pincode.toString();
//     place.text = widget.place.toString();
//     post.text = widget.post.toString();
//     bio.text = widget.bio.toString();
//     latitude.text = widget.latitude.toString();
//     longitude.text = widget.longitude.toString();
//   }
//
//   // --- FILE PICKERS ---
//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: false,
//       type: FileType.image,
//     );
//
//     if (result != null) {
//       setState(() {
//         _selectedFile = result.files.first;
//         if (kIsWeb) {
//           _webFileBytes = result.files.first.bytes;
//         }
//       });
//     }
//   }
//
//   Future<void> _pickFile1() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: false,
//       type: FileType.any,
//     );
//
//     if (result != null) {
//       setState(() {
//         _selectedFile1 = result.files.first;
//         if (kIsWeb) {
//           _webFileBytes1 = result.files.first.bytes;
//         }
//       });
//     }
//   }
//
//   // --- VALIDATION LOGIC ---
//   bool _validateForm() {
//     // 1. Phone: 10 Digits
//     if (phone.text.length != 10) {
//       _showError("Phone number must be exactly 10 digits.");
//       return false;
//     }
//
//     // 2. Pincode: 6 Digits
//     if (pincode.text.length != 6) {
//       _showError("Pincode must be exactly 6 digits.");
//       return false;
//     }
//
//     // 3. Lat/Long: Valid Float
//     try {
//       if (latitude.text.isNotEmpty) double.parse(latitude.text);
//       if (longitude.text.isNotEmpty) double.parse(longitude.text);
//     } catch (e) {
//       _showError("Latitude and Longitude must be valid decimal numbers (e.g. 12.3456)");
//       return false;
//     }
//
//     return true;
//   }
//
//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: Colors.red),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final bool isDark = theme.brightness == Brightness.dark;
//     final Color textColor = isDark ? Colors.white : Colors.black;
//
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: theme.scaffoldBackgroundColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.close, color: textColor),
//           onPressed: () {
//             if (Navigator.canPop(context)) Navigator.pop(context);
//           },
//         ),
//         title: Text(
//           "Edit Profile",
//           style: TextStyle(
//               color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           // Save Button (Icon style)
//           IconButton(
//             icon: Icon(Icons.check, color: Colors.blueAccent),
//             onPressed: _isLoading ? null : _updateProfile,
//           )
//         ],
//       ),
//       body: Stack(
//         children: [
//           // MAIN FORM
//           SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             physics: const BouncingScrollPhysics(),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 20),
//
//                 // PROFILE PHOTO
//                 Center(
//                   child: Column(
//                     children: [
//                       GestureDetector(
//                         onTap: _pickFile,
//                         child: CircleAvatar(
//                           radius: 50,
//                           backgroundColor: theme.cardColor,
//                           backgroundImage: _getProfileImage(),
//                           child: (_selectedFile == null && _webFileBytes == null)
//                               ? Icon(Icons.person, size: 50, color: theme.disabledColor)
//                               : null,
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: _pickFile,
//                         child: const Text(
//                           "Change Profile Photo",
//                           style: TextStyle(
//                             color: Colors.blueAccent,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//                 const Divider(),
//                 const SizedBox(height: 10),
//
//                 // BASIC INFO
//                 _buildThemeField(
//                     "Name", name, Icons.person, theme,
//                     textColor: textColor
//                 ),
//                 _buildThemeField(
//                     "Bio", bio, Icons.info_outline, theme,
//                     textColor: textColor
//                 ),
//
//                 const SizedBox(height: 20),
//                 Text("Contact Information", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
//                 const SizedBox(height: 15),
//
//                 // EMAIL (Read Only usually)
//                 _buildThemeField(
//                     "Email", email, Icons.email, theme,
//                     textColor: textColor, enabled: false
//                 ),
//
//                 // PHONE (10 Digits Validation)
//                 _buildThemeField(
//                     "Phone", phone, Icons.phone_android, theme,
//                     textColor: textColor,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(10), // Limit to 10
//                     ]
//                 ),
//
//                 // ADDRESS
//                 _buildThemeField(
//                     "Address", address, Icons.home, theme,
//                     textColor: textColor
//                 ),
//
//                 // PINCODE (6 Digits) & POST
//                 Row(
//                   children: [
//                     Expanded(
//                         child: _buildThemeField(
//                             "Pincode", pincode, Icons.pin_drop, theme,
//                             textColor: textColor,
//                             keyboardType: TextInputType.number,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.digitsOnly,
//                               LengthLimitingTextInputFormatter(6), // Limit to 6
//                             ]
//                         )
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                         child: _buildThemeField(
//                             "Post", post, Icons.local_post_office, theme,
//                             textColor: textColor
//                         )
//                     ),
//                   ],
//                 ),
//
//                 _buildThemeField(
//                     "Place", place, Icons.place, theme,
//                     textColor: textColor
//                 ),
//
//                 // LATITUDE & LONGITUDE (Double)
//                 Row(
//                   children: [
//                     Expanded(
//                         child: _buildThemeField(
//                           "Latitude", latitude, Icons.explore, theme,
//                           textColor: textColor,
//                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                           // Allows digits and decimal point only
//                           inputFormatters: [
//                             FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
//                           ],
//                         )
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                         child: _buildThemeField(
//                           "Longitude", longitude, Icons.explore, theme,
//                           textColor: textColor,
//                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                           inputFormatters: [
//                             FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
//                           ],
//                         )
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 10),
//
//                 // DOCUMENT UPLOAD
//                 GestureDetector(
//                   onTap: _pickFile1,
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
//                     decoration: BoxDecoration(
//                       color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.file_copy_outlined, color: Colors.blueAccent),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             _selectedFile1 != null ? _selectedFile1!.name : "Update Proof Document",
//                             style: TextStyle(
//                               color: _selectedFile1 != null ? textColor : Colors.grey,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 50),
//               ],
//             ),
//           ),
//
//           // LOADING OVERLAY
//           if (_isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   // --- LOGIC ---
//   Future<void> _updateProfile() async {
//     // 1. Run Validation
//     if (!_validateForm()) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       final String? ip = sh.getString("ip");
//
//       Uri uri = Uri.parse('${ip}/edit_distributor_profile');
//       var request = http.MultipartRequest('POST', uri);
//
//       request.fields['name'] = name.text;
//       request.fields['email'] = email.text;
//       request.fields['phone'] = phone.text;
//       request.fields['address'] = address.text;
//       request.fields['pincode'] = pincode.text;
//       request.fields['place'] = place.text;
//       request.fields['post'] = post.text;
//       request.fields['bio'] = bio.text;
//       request.fields['latitude'] = latitude.text;
//       request.fields['longitude'] = longitude.text;
//       request.fields['uid'] = sh.getString("uid").toString();
//
//       // File Logic
//       if (_selectedFile != null) {
//         if (kIsWeb) {
//           request.files.add(http.MultipartFile.fromBytes('file', _webFileBytes!, filename: _selectedFile!.name));
//         } else {
//           request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path!));
//         }
//       }
//
//       if (_selectedFile1 != null) {
//         if (kIsWeb) {
//           request.files.add(http.MultipartFile.fromBytes('file1', _webFileBytes1!, filename: _selectedFile1!.name));
//         } else {
//           request.files.add(await http.MultipartFile.fromPath('file1', _selectedFile1!.path!));
//         }
//       }
//
//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);
//       var decodeddata = json.decode(response.body);
//
//       if (decodeddata['status'] == 'ok') {
//         if (!mounted) return;
//         _showSuccessDialog();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update profile')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   // --- HELPERS ---
//   ImageProvider? _getProfileImage() {
//     if (kIsWeb && _webFileBytes != null) return MemoryImage(_webFileBytes!);
//     if (_selectedFile != null && _selectedFile!.path != null) return FileImage(File(_selectedFile!.path!));
//     // If you have a default online image or local asset, you can return it here
//     return null;
//   }
//
//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Column(
//           children: [
//             Icon(Icons.check_circle, color: Colors.green, size: 50),
//             SizedBox(height: 10),
//             Text("Updated!"),
//           ],
//         ),
//         content: const Text("Your profile has been updated successfully.", textAlign: TextAlign.center),
//         actions: [
//           TextButton(
//             onPressed: () {
//               // Navigate to Profile Tab (Index 4 usually)
//               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  DistributorNavigationBar(initialIndex: 4,)));
//             },
//             child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _buildThemeField(
//       String label,
//       TextEditingController controller,
//       IconData icon,
//       ThemeData theme,
//       {
//         bool enabled = true,
//         TextInputType keyboardType = TextInputType.text,
//         List<TextInputFormatter>? inputFormatters,
//         required Color textColor
//       }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
//           const SizedBox(height: 5),
//           TextField(
//             controller: controller,
//             enabled: enabled,
//             keyboardType: keyboardType,
//             inputFormatters: inputFormatters,
//             style: TextStyle(color: textColor),
//             decoration: InputDecoration(
//               prefixIcon: Icon(icon, color: theme.primaryColor, size: 20),
//               filled: true,
//               fillColor: theme.brightness == Brightness.dark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
//               contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

import 'package:snap2bill/widgets/distributorNavigationbar.dart';

class edit_distributor_profile_sub extends StatefulWidget {
  final dynamic id, name, email, phone, bio, address, pincode, place, post, latitude, longitude;

  const edit_distributor_profile_sub({
    required this.id, required this.name, required this.email, required this.phone,
    required this.bio, required this.address, required this.place, required this.pincode,
    required this.post, required this.latitude, required this.longitude,
    Key? key,
  }) : super(key: key);

  @override
  State<edit_distributor_profile_sub> createState() => _edit_distributor_profile_subState();
}

class _edit_distributor_profile_subState extends State<edit_distributor_profile_sub> {
  // Controllers
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
    name.text = widget.name.toString();
    email.text = widget.email.toString();
    phone.text = widget.phone.toString();
    address.text = widget.address.toString();
    pincode.text = widget.pincode.toString();
    place.text = widget.place.toString();
    post.text = widget.post.toString();
    bio.text = widget.bio.toString();
    latitude.text = widget.latitude.toString();
    longitude.text = widget.longitude.toString();
  }

  Future<void> _pickFile(bool isProfile) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: isProfile ? FileType.image : FileType.any,
    );
    if (result != null) {
      setState(() {
        if (isProfile) {
          _selectedFile = result.files.first;
          if (kIsWeb) _webFileBytes = result.files.first.bytes;
        } else {
          _selectedFile1 = result.files.first;
          if (kIsWeb) _webFileBytes1 = result.files.first.bytes;
        }
      });
    }
  }

  bool _validateForm() {
    if (phone.text.length != 10) return _showErr("Phone must be 10 digits");
    if (pincode.text.length != 6) return _showErr("Pincode must be 6 digits");
    try {
      if (latitude.text.isNotEmpty) double.parse(latitude.text);
      if (longitude.text.isNotEmpty) double.parse(longitude.text);
    } catch (e) { return _showErr("Invalid Latitude/Longitude format"); }
    return true;
  }

  bool _showErr(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Edit Profile", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateProfile,
            child: const Text("SAVE", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900)),
          )
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 10),
              _buildAvatarPicker(theme, isDark),
              const SizedBox(height: 30),
              _buildSectionTitle("Business Identity"),
              _buildField("Business Name", name, Icons.business_center_outlined, textColor, theme),
              _buildField("Short Bio", bio, Icons.edit_note_rounded, textColor, theme, maxLines: 3),
              const SizedBox(height: 20),
              _buildSectionTitle("Contact Details"),
              _buildField("Email Address", email, Icons.alternate_email_rounded, textColor, theme, enabled: false),
              _buildField("Mobile Number", phone, Icons.phone_iphone_rounded, textColor, theme,
                  keyboardType: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]),
              const SizedBox(height: 20),
              _buildSectionTitle("Location & Logistics"),
              _buildField("Office Address", address, Icons.location_on_outlined, textColor, theme),
              Row(
                children: [
                  Expanded(child: _buildField("Pincode", pincode, Icons.pin_drop_outlined, textColor, theme,
                      keyboardType: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)])),
                  const SizedBox(width: 15),
                  Expanded(child: _buildField("Post", post, Icons.local_post_office_outlined, textColor, theme)),
                ],
              ),
              _buildField("Place / City", place, Icons.map_outlined, textColor, theme),
              Row(
                children: [
                  Expanded(child: _buildField("Latitude", latitude, Icons.explore_outlined, textColor, theme)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildField("Longitude", longitude, Icons.explore_outlined, textColor, theme)),
                ],
              ),
              const SizedBox(height: 15),
              _buildFileUpload(isDark, textColor),
              const SizedBox(height: 100),
            ],
          ),
          if (_isLoading) _buildLoader(),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker(ThemeData theme, bool isDark) {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
              backgroundImage: _getProfileImage(),
              child: (_selectedFile == null && _webFileBytes == null)
                  ? Icon(Icons.add_a_photo_outlined, size: 35, color: Colors.blueAccent.withOpacity(0.5))
                  : null,
            ),
          ),
          Positioned(
            bottom: 0, right: 0,
            child: GestureDetector(
              onTap: () => _pickFile(true),
              child: const CircleAvatar(
                radius: 18, backgroundColor: Colors.blueAccent,
                child: Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 5),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, Color textColor, ThemeData theme, {bool enabled = true, int maxLines = 1, TextInputType? keyboardType, List<TextInputFormatter>? formatters}) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: ctrl,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.blueAccent),
          filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildFileUpload(bool isDark, Color textColor) {
    return GestureDetector(
      onTap: () => _pickFile(false),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3), style: BorderStyle.solid),
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.blue.withOpacity(0.05),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_upload_outlined, color: Colors.blueAccent),
            const SizedBox(width: 15),
            Expanded(child: Text(_selectedFile1?.name ?? "Update Proof Document", style: TextStyle(color: textColor.withOpacity(0.6)))),
          ],
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Colors.blueAccent)));
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
      SharedPreferences sh = await SharedPreferences.getInstance();
      final String ip = sh.getString("ip")!;
      var request = http.MultipartRequest('POST', Uri.parse('$ip/edit_distributor_profile'));

      request.fields.addAll({
        'name': name.text, 'email': email.text, 'phone': phone.text, 'address': address.text,
        'pincode': pincode.text, 'place': place.text, 'post': post.text, 'bio': bio.text,
        'latitude': latitude.text, 'longitude': longitude.text, 'uid': sh.getString("uid")!,
      });

      if (_selectedFile != null) {
        if (kIsWeb) request.files.add(http.MultipartFile.fromBytes('file', _webFileBytes!, filename: _selectedFile!.name));
        else request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path!));
      }
      if (_selectedFile1 != null) {
        if (kIsWeb) request.files.add(http.MultipartFile.fromBytes('file1', _webFileBytes1!, filename: _selectedFile1!.name));
        else request.files.add(await http.MultipartFile.fromPath('file1', _selectedFile1!.path!));
      }

      var res = await request.send();
      var response = await http.Response.fromStream(res);
      if (json.decode(response.body)['status'] == 'ok') _showSuccess();
      else _showErr("Failed to update profile");
    } catch (e) { _showErr("Error: $e"); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  void _showSuccess() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_rounded, color: Colors.green, size: 60),
            const SizedBox(height: 15),
            const Text("Profile Synchronized", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  // ✅ Navigation stack cleared to remove back-button
                  Navigator.pushAndRemoveUntil(
                    context, MaterialPageRoute(builder: (context) => DistributorNavigationBar(initialIndex: 4)), (route) => false,
                  );
                },
                child: const Text("CONTINUE"),
              ),
            )
          ],
        ),
      ),
    );
  }
}