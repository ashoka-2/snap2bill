//
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:snap2bill/theme/colors.dart';
// import 'dart:typed_data';
//
// import 'package:snap2bill/widgets/distributorNavigationbar.dart';
//
// import '../../widgets/Navbar.dart';
// import '../../widgets/SnackBar.dart';
//
// class edit_distributor_profile_sub extends StatefulWidget {
//   final dynamic id, name, email, phone, bio, address, pincode, place, post, latitude, longitude;
//
//   const edit_distributor_profile_sub({
//     required this.id, required this.name, required this.email, required this.phone,
//     required this.bio, required this.address, required this.place, required this.pincode,
//     required this.post, required this.latitude, required this.longitude,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<edit_distributor_profile_sub> createState() => _edit_distributor_profile_subState();
// }
//
// class _edit_distributor_profile_subState extends State<edit_distributor_profile_sub> {
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
//   PlatformFile? _selectedFile1;
//   Uint8List? _webFileBytes1;
//
//   bool _isLoading = false;
//
//   late Color successColor;
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
//   Future<void> _pickFile(bool isProfile) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: false,
//       type: isProfile ? FileType.image : FileType.any,
//     );
//     if (result != null) {
//       setState(() {
//         if (isProfile) {
//           _selectedFile = result.files.first;
//           if (kIsWeb) _webFileBytes = result.files.first.bytes;
//         } else {
//           _selectedFile1 = result.files.first;
//           if (kIsWeb) _webFileBytes1 = result.files.first.bytes;
//         }
//       });
//     }
//   }
//
//   bool _validateForm() {
//     if (phone.text.length != 10) return _showErr("Phone must be 10 digits");
//     if (pincode.text.length != 6) return _showErr("Pincode must be 6 digits");
//     try {
//       if (latitude.text.isNotEmpty) double.parse(latitude.text);
//       if (longitude.text.isNotEmpty) double.parse(longitude.text);
//     } catch (e) { return _showErr("Invalid Latitude/Longitude format"); }
//     return true;
//   }
//
//   bool _showErr(String msg) {
//     CustomSnackBar.show(context,Text(msg) as String, backgroundColor: AppColors.dangerColor);
//
//     return false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     successColor = AppColors.getSuccessColor(context);
//
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
// final textColor = AppColors.getTextColor(context);
//
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//
//       appBar: ThemeNavbar(title: "Update Profile",
//         leadingIcon: Icons.close,
//         onLeadingPressed: ()=>{
//           if (Navigator.canPop(context)) Navigator.pop(context)
//         },
//         centerTitle: true,
//         actions: [
//           IconButton(onPressed: _isLoading ? null : _updateProfile
//               , icon:Icon(Icons.save))
//         ],
//
//       ),
//
//       body: Stack(
//         children: [
//           ListView(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             physics: const BouncingScrollPhysics(),
//             children: [
//               const SizedBox(height: 10),
//               _buildAvatarPicker(theme, isDark),
//               const SizedBox(height: 30),
//               _buildSectionTitle("Business Identity"),
//               _buildField("Business Name", name, Icons.business_center_outlined, textColor, theme),
//               _buildField("Short Bio", bio, Icons.edit_note_rounded, textColor, theme, maxLines: 3),
//               const SizedBox(height: 20),
//               _buildSectionTitle("Contact Details"),
//               _buildField("Email Address", email, Icons.alternate_email_rounded, textColor, theme, enabled: false),
//               _buildField("Mobile Number", phone, Icons.phone_iphone_rounded, textColor, theme,
//                   keyboardType: TextInputType.number,
//                   formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]),
//               const SizedBox(height: 20),
//               _buildSectionTitle("Location & Logistics"),
//               _buildField("Office Address", address, Icons.location_on_outlined, textColor, theme),
//               Row(
//                 children: [
//                   Expanded(child: _buildField("Pincode", pincode, Icons.pin_drop_outlined, textColor, theme,
//                       keyboardType: TextInputType.number,
//                       formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)])),
//                   const SizedBox(width: 15),
//                   Expanded(child: _buildField("Post", post, Icons.local_post_office_outlined, textColor, theme)),
//                 ],
//               ),
//               _buildField("Place / City", place, Icons.map_outlined, textColor, theme),
//               Row(
//                 children: [
//                   Expanded(child: _buildField("Latitude", latitude, Icons.explore_outlined, textColor, theme)),
//                   const SizedBox(width: 15),
//                   Expanded(child: _buildField("Longitude", longitude, Icons.explore_outlined, textColor, theme)),
//                 ],
//               ),
//               const SizedBox(height: 15),
//               _buildFileUpload(isDark, textColor),
//               const SizedBox(height: 100),
//             ],
//           ),
//           if (_isLoading) _buildLoader(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAvatarPicker(ThemeData theme, bool isDark) {
//     return Center(
//       child: Stack(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: AppColors.getPrimaryColor(context).withValues(alpha:0.5), width: 2),
//             ),
//             child: CircleAvatar(
//               radius: 55,
//               backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
//               backgroundImage: _getProfileImage(),
//               child: (_selectedFile == null && _webFileBytes == null)
//                   ? Icon(Icons.add_a_photo_outlined, size: 35, color: AppColors.getPrimaryColor(context).withValues(alpha:0.5))
//                   : null,
//             ),
//           ),
//           Positioned(
//             bottom: 0, right: 0,
//             child: GestureDetector(
//               onTap: () => _pickFile(true),
//               child:  CircleAvatar(
//                 radius: 18, backgroundColor: AppColors.getPrimaryColor(context),
//                 child: Icon(Icons.camera_alt, color: Colors.white, size: 16),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12, left: 5),
//       child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
//     );
//   }
//
//   Widget _buildField(String label, TextEditingController ctrl, IconData icon, Color textColor, ThemeData theme, {bool enabled = true, int maxLines = 1, TextInputType? keyboardType, List<TextInputFormatter>? formatters}) {
//     final isDark = theme.brightness == Brightness.dark;
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: TextField(
//         controller: ctrl,
//         enabled: enabled,
//         maxLines: maxLines,
//         keyboardType: keyboardType,
//         inputFormatters: formatters,
//         style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(icon, size: 20, color: AppColors.getPrimaryColor(context)),
//           filled: true,
//           fillColor: isDark ? Colors.white.withValues(alpha:0.05) : Colors.grey.shade50,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFileUpload(bool isDark, Color textColor) {
//     return GestureDetector(
//       onTap: () => _pickFile(false),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(color: AppColors.getPrimaryColor(context).withValues(alpha:0.3), style: BorderStyle.solid),
//           color: isDark ? Colors.white.withValues(alpha:0.05) : AppColors.getPrimaryColor(context).withValues(alpha:0.05),
//         ),
//         child: Row(
//           children: [
//              Icon(Icons.cloud_upload_outlined, color: AppColors.getPrimaryColor(context)),
//             const SizedBox(width: 15),
//             Expanded(child: Text(_selectedFile1?.name ?? "Update Proof Document", style: TextStyle(color: textColor.withValues(alpha:0.6)))),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoader() {
//     return Container(color: Colors.black45, child:  Center(child: CircularProgressIndicator(color: AppColors.getPrimaryColor(context))));
//   }
//
//   ImageProvider? _getProfileImage() {
//     if (kIsWeb && _webFileBytes != null) return MemoryImage(_webFileBytes!);
//     if (_selectedFile != null && _selectedFile!.path != null) return FileImage(File(_selectedFile!.path!));
//     return null;
//   }
//
//   Future<void> _updateProfile() async {
//     if (!_validateForm()) return;
//     setState(() => _isLoading = true);
//
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       final String ip = prefs.getString("ip")!;
//       var request = http.MultipartRequest('POST', Uri.parse('$ip/edit_distributor_profile'));
//
//       request.fields.addAll({
//         'name': name.text, 'email': email.text, 'phone': phone.text, 'address': address.text,
//         'pincode': pincode.text, 'place': place.text, 'post': post.text, 'bio': bio.text,
//         'latitude': latitude.text, 'longitude': longitude.text, 'uid': prefs.getString("uid")!,
//       });
//
//       if (_selectedFile != null) {
//         if (kIsWeb) request.files.add(http.MultipartFile.fromBytes('file', _webFileBytes!, filename: _selectedFile!.name));
//         else request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path!));
//       }
//       if (_selectedFile1 != null) {
//         if (kIsWeb) request.files.add(http.MultipartFile.fromBytes('file1', _webFileBytes1!, filename: _selectedFile1!.name));
//         else request.files.add(await http.MultipartFile.fromPath('file1', _selectedFile1!.path!));
//       }
//
//       var res = await request.send();
//       var response = await http.Response.fromStream(res);
//       if (json.decode(response.body)['status'] == 'ok') _showSuccess();
//       else _showErr("Failed to update profile");
//     } catch (e) { _showErr("Error: $e"); }
//     finally { if (mounted) setState(() => _isLoading = false); }
//   }
//
//   void _showSuccess() {
//     showDialog(
//       context: context, barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//                Icon(Icons.verified_rounded, color: successColor, size: 60),
//             const SizedBox(height: 15),
//             const Text("Profile Synchronized", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//             const SizedBox(height: 25),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: AppColors.getPrimaryColor(context), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
//                 onPressed: () {
//                   // ✅ Navigation stack cleared to remove back-button
//                   Navigator.pushAndRemoveUntil(
//                     context, MaterialPageRoute(builder: (context) => DistributorNavigationBar(initialIndex: 4)), (route) => false,
//                   );
//                 },
//                 child: const Text("CONTINUE"),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart'; // 🚀 IMPORTED
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:snap2bill/theme/colors.dart';
import 'dart:typed_data';

import 'package:snap2bill/widgets/distributorNavigationbar.dart';
import '../../widgets/Navbar.dart';
import '../../widgets/SnackBar.dart';

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
  late Color successColor;

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
    CustomSnackBar.show(context, Text(msg) as String, backgroundColor: AppColors.dangerColor);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    successColor = AppColors.getSuccessColor(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
final textColor = AppColors.getTextColor(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: ThemeNavbar(
        title: "Update Profile",
        // 🚀 HUGE ICON: Close
        leadingIcon: HugeIcons.strokeRoundedCancel01,
        onLeadingPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _updateProfile,
            // 🚀 HUGE ICON: Save
            icon:  HugeIcon(icon: HugeIcons.strokeRoundedTick02, color: AppColors.getIconColor(context), size: 24), // Navbar icons usually contrast appbar
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
              // 🚀 HUGE ICONS
              _buildField("Business Name", name, HugeIcons.strokeRoundedStore01, textColor, theme),
              _buildField("Short Bio", bio, HugeIcons.strokeRoundedNoteEdit, textColor, theme, maxLines: 3),

              const SizedBox(height: 20),
              _buildSectionTitle("Contact Details"),
              _buildField("Email Address", email, HugeIcons.strokeRoundedMail01, textColor, theme, enabled: false),
              _buildField("Mobile Number", phone, HugeIcons.strokeRoundedSmartPhone01, textColor, theme,
                  keyboardType: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]),

              const SizedBox(height: 20),
              _buildSectionTitle("Location & Logistics"),
              _buildField("Office Address", address, HugeIcons.strokeRoundedLocation01, textColor, theme),

              Row(
                children: [
                  Expanded(child: _buildField("Pincode", pincode, HugeIcons.strokeRoundedPinLocation03, textColor, theme,
                      keyboardType: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)])),
                  const SizedBox(width: 15),
                  Expanded(child: _buildField("Post", post, HugeIcons.strokeRoundedMailbox01, textColor, theme)),
                ],
              ),
              _buildField("Place / City", place, HugeIcons.strokeRoundedCity01, textColor, theme),

              Row(
                children: [
                  Expanded(child: _buildField("Latitude", latitude, HugeIcons.strokeRoundedCompass01, textColor, theme)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildField("Longitude", longitude, HugeIcons.strokeRoundedCompass01, textColor, theme)),
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
              border: Border.all(color: AppColors.getPrimaryColor(context).withValues(alpha:0.5), width: 2),
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
              backgroundImage: _getProfileImage(),
              child: (_selectedFile == null && _webFileBytes == null)
              // 🚀 HUGE ICON: Add Photo
                  ? HugeIcon(icon: HugeIcons.strokeRoundedCameraAdd01, size: 35, color: AppColors.getPrimaryColor(context).withValues(alpha:0.5))
                  : null,
            ),
          ),
          Positioned(
            bottom: 0, right: 0,
            child: GestureDetector(
              onTap: () => _pickFile(true),
              child: CircleAvatar(
                radius: 18, backgroundColor: AppColors.getPrimaryColor(context),
                // 🚀 HUGE ICON: Camera
                child: const HugeIcon(icon: HugeIcons.strokeRoundedCamera01, color: Colors.white, size: 16),
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

  // 🚀 UPDATED: Now accepts dynamic icon to support HugeIcons
  Widget _buildField(String label, TextEditingController ctrl, dynamic icon, Color textColor, ThemeData theme, {bool enabled = true, int maxLines = 1, TextInputType? keyboardType, List<TextInputFormatter>? formatters}) {
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
          // 🚀 HUGE ICON RENDERED HERE
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: HugeIcon(icon: icon, size: 20, color: AppColors.getPrimaryColor(context)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          filled: true,
          fillColor: isDark ? Colors.white.withValues(alpha:0.05) : Colors.grey.shade50,
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
          border: Border.all(color: AppColors.getPrimaryColor(context).withValues(alpha:0.3), style: BorderStyle.solid),
          color: isDark ? Colors.white.withValues(alpha:0.05) : AppColors.getPrimaryColor(context).withValues(alpha:0.05),
        ),
        child: Row(
          children: [
            // 🚀 HUGE ICON: Cloud Upload
            HugeIcon(icon: HugeIcons.strokeRoundedCloudUpload, color: AppColors.getPrimaryColor(context), size: 24),
            const SizedBox(width: 15),
            Expanded(child: Text(_selectedFile1?.name ?? "Update Proof Document", style: TextStyle(color: textColor.withValues(alpha:0.6)))),
          ],
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return Container(color: Colors.black45, child: Center(child: CircularProgressIndicator(color: AppColors.getPrimaryColor(context))));
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
      var request = http.MultipartRequest('POST', Uri.parse('$ip/edit_distributor_profile'));

      request.fields.addAll({
        'name': name.text, 'email': email.text, 'phone': phone.text, 'address': address.text,
        'pincode': pincode.text, 'place': place.text, 'post': post.text, 'bio': bio.text,
        'latitude': latitude.text, 'longitude': longitude.text, 'uid': prefs.getString("uid")!,
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
            // 🚀 HUGE ICON: Success Tick
            HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle02, color: successColor, size: 60),
            const SizedBox(height: 15),
            const Text("Profile Synchronized", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.getPrimaryColor(context), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
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