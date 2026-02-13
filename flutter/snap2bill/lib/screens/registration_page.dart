//
//
// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:hugeicons/hugeicons.dart'; // 🚀 IMPORTED
// import 'package:google_sign_in/google_sign_in.dart'; // 🚀 IMPORTED
// import 'package:snap2bill/screens/Login_page.dart';
//
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
//
// import '../theme/colors.dart';
// import '../widgets/SnackBar.dart';
// import '../widgets/app_button.dart';
//
// class RegistrationPage extends StatefulWidget {
//   final bool isDistributor;
//
//   const RegistrationPage({Key? key, required this.isDistributor}) : super(key: key);
//
//   @override
//   State<RegistrationPage> createState() => _RegistrationPageState();
// }
//
// class _RegistrationPageState extends State<RegistrationPage> {
//   final _formKeys = [
//     GlobalKey<FormState>(),
//     GlobalKey<FormState>(),
//     GlobalKey<FormState>(),
//     GlobalKey<FormState>(),
//   ];
//
//   final name = TextEditingController();
//   final email = TextEditingController();
//   final phone = TextEditingController();
//   final password = TextEditingController();
//   final confirmpassword = TextEditingController();
//   final address = TextEditingController();
//   final pincode = TextEditingController();
//   final place = TextEditingController();
//   final post = TextEditingController();
//   final bio = TextEditingController();
//   final latitude = TextEditingController();
//   final longitude = TextEditingController();
//
//   final PageController _pageController = PageController();
//   // 🚀 Google Sign In Instance
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//
//   int _currentPage = 0;
//   bool _isLoading = false;
//   bool _isLocating = false;
//   final int _totalPages = 4;
//   bool _obscurePass = true;
//   bool _obscureConfirm = true;
//
//   PlatformFile? _file1;
//   Uint8List? _file1Bytes;
//   PlatformFile? _file2;
//   Uint8List? _file2Bytes;
//
//   @override
//   void dispose() {
//     name.dispose(); email.dispose(); phone.dispose();
//     password.dispose(); confirmpassword.dispose();
//     address.dispose(); pincode.dispose(); place.dispose();
//     post.dispose(); bio.dispose(); latitude.dispose(); longitude.dispose();
//     super.dispose();
//   }
//
//   // ✅ PRE-FILL FROM GOOGLE
//   Future<void> _prefillWithGoogle() async {
//     try {
//       // 1. Sign in with Google
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return; // User canceled
//
//       // 2. Pre-fill Fields
//       setState(() {
//         name.text = googleUser.displayName ?? "";
//         email.text = googleUser.email;
//       });
//
//       CustomSnackBar.show(context, "Details fetched from Google!", backgroundColor: AppColors.getSuccessColor(context));
//
//       // Optional: Sign out immediately so they can use a different account next time
//       _googleSignIn.signOut();
//
//     } catch (e) {
//       CustomSnackBar.show(context, "Google Sign-In Error: $e", backgroundColor: AppColors.dangerColor);
//     }
//   }
//
//   // ... (Validation Logic kept same as previous) ...
//   String? _validateName(String? value) {
//     if (value == null || value.trim().isEmpty) return "Name is required";
//     if (value.trim().length < 3) return "Enter a valid name (min 3 chars)";
//     return null;
//   }
//
//   String? _validateEmail(String? value) {
//     if (value == null || value.trim().isEmpty) return "Email is required";
//     final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//     if (!emailRegex.hasMatch(value.trim())) return "Enter a valid email address";
//     return null;
//   }
//   String? _validatePhone(String? value) {
//     if (value == null || value.trim().isEmpty) return "Phone number is required";
//     if (value.trim().length != 10) return "Phone number must be 10 digits";
//     if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) return "Only numbers allowed";
//     return null;
//   }
//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) return "Password is required";
//     if (value.length < 6) return "Password must be at least 6 characters";
//     return null;
//   }
//
//   Future<void> _handleLocationDetection() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//     setState(() => _isLocating = true);
//     try {
//       serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         _showError("GPS is disabled. Please turn on location.");
//         setState(() => _isLocating = false);
//         return;
//       }
//       permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           _showError("Location permissions are denied.");
//           setState(() => _isLocating = false);
//           return;
//         }
//       }
//       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//       latitude.text = position.latitude.toString();
//       longitude.text = position.longitude.toString();
//       List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
//       if (placemarks.isNotEmpty) {
//         Placemark p = placemarks[0];
//         setState(() {
//           place.text = p.locality ?? "";
//           pincode.text = p.postalCode ?? "";
//           post.text = p.subLocality ?? "";
//           address.text = "${p.street}, ${p.subLocality}, ${p.locality}";
//         });
//       }
//     } catch (e) {
//       _showError("Could not fetch location.");
//     } finally {
//       setState(() => _isLocating = false);
//     }
//   }
//
//   Future<void> _pickFile(bool isSecondFile) async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
//       if (result != null) {
//         setState(() {
//           if (isSecondFile) {
//             _file2 = result.files.first;
//             if (kIsWeb) _file2Bytes = result.files.first.bytes;
//           } else {
//             _file1 = result.files.first;
//             if (kIsWeb) _file1Bytes = result.files.first.bytes;
//           }
//         });
//       }
//     } catch (e) { debugPrint("Error picking file: $e"); }
//   }
//
//   void _nextPage() {
//     if (!_formKeys[_currentPage].currentState!.validate()) return;
//     if (_currentPage == 2) {
//       if (_file1 == null) { _showError("Upload profile image."); return; }
//       if (widget.isDistributor && _file2 == null) { _showError("Upload proof image."); return; }
//     }
//     _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
//     setState(() => _currentPage++);
//   }
//
//   void _prevPage() {
//     _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
//     setState(() => _currentPage--);
//   }
//
//   void _showError(String msg) {
//     CustomSnackBar.show(context, Text(msg) as String , backgroundColor: AppColors.dangerColor);
//   }
//
//   Future<void> _register() async {
//     if (!_formKeys[3].currentState!.validate()) return;
//     if (password.text != confirmpassword.text) { _showError("Passwords mismatch"); return; }
//     setState(() => _isLoading = true);
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String ip = prefs.getString("ip") ?? "http://10.0.2.2:8000";
//       String endpoint = widget.isDistributor ? '/distributor_registration' : '/customer_registration';
//       var request = http.MultipartRequest('POST', Uri.parse('$ip$endpoint'));
//       request.fields.addAll({
//         'name': name.text.trim(),
//         'email': email.text.trim(),
//         'phone': phone.text.trim(),
//         'password': password.text.trim(),
//         'confirmpassword': confirmpassword.text.trim(),
//         'address': address.text.trim(),
//         'pincode': pincode.text.trim(),
//         'place': place.text.trim(),
//         'post': post.text.trim(),
//         'bio': bio.text.trim(),
//       });
//       if (widget.isDistributor) {
//         request.fields['latitude'] = latitude.text.trim();
//         request.fields['longitude'] = longitude.text.trim();
//       }
//       if (_file1 != null) {
//         if (kIsWeb) request.files.add(http.MultipartFile.fromBytes('file', _file1Bytes!, filename: _file1!.name));
//         else request.files.add(await http.MultipartFile.fromPath('file', _file1!.path!));
//       }
//       if (widget.isDistributor && _file2 != null) {
//         if (kIsWeb) request.files.add(http.MultipartFile.fromBytes('file1', _file2Bytes!, filename: _file2!.name));
//         else request.files.add(await http.MultipartFile.fromPath('file1', _file2!.path!));
//       }
//       var response = await request.send();
//       var responseString = await response.stream.bytesToString();
//       var decoded = json.decode(responseString);
//       if (decoded['status'] == 'ok') {
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
//       } else {
//         _showError("Registration failed: ${decoded['status']}");
//       }
//     } catch (e) { _showError("Connection Error: Make sure IP is correct and server is running."); }
//     finally { if (mounted) setState(() => _isLoading = false); }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final iconColor = isDark ? AppColors.iconColorDark : AppColors.iconColorLight;
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(theme),
//             Expanded(
//               child: PageView(
//                 controller: _pageController,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: [
//                   _buildPersonalPage(iconColor),
//                   _buildLocationPage(iconColor, theme),
//                   _buildFilesPage(iconColor, theme),
//                   _buildSecurityPage(iconColor),
//                 ],
//               ),
//             ),
//             if (_currentPage < _totalPages - 1) _buildBottomNav(theme),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(ThemeData theme) {
//     final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
//     return Container(
//       padding: EdgeInsets.all(isLandscape ? 10 : 20),
//       decoration: BoxDecoration(color: theme.cardColor, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
//       child: Column(children: [
//         Row(children: [
//           IconButton(
//               icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, size: isLandscape ? 18 : 24, color: Theme.of(context).iconTheme.color!),
//               onPressed: () => _currentPage > 0 ? _prevPage() : Navigator.pop(context)
//           ),
//           Expanded(child: Center(child: Text(widget.isDistributor ? "Distributor Register" : "Customer Register", maxLines: 1, style: TextStyle(fontSize: isLandscape ? 16 : 20, fontWeight: FontWeight.w900, color: AppColors.isDarkMode(context) ? AppColors.textMainDark : AppColors.textMainLight)))),
//           SizedBox(width: isLandscape ? 30 : 40),
//         ]),
//         SizedBox(height: isLandscape ? 5 : 15),
//         Row(children: List.generate(_totalPages, (i) => Expanded(child: Container(height: isLandscape ? 4 : 6, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: i <= _currentPage ? theme.primaryColor : theme.disabledColor.withValues(alpha:0.2)))))),
//         const SizedBox(height: 5),
//         Text("Step ${_currentPage + 1} of $_totalPages", style: theme.textTheme.bodySmall),
//       ]),
//     );
//   }
//
//   Widget _buildLocationPage(Color iconColor, ThemeData theme) {
//     return _buildPage(
//       title: "Location Details",
//       subtitle: "Where are you located?",
//       formKey: _formKeys[1],
//       children: [
//         SizedBox(
//           width: double.infinity,
//           child: OutlinedButton.icon(
//             onPressed: _isLocating ? null : _handleLocationDetection,
//             icon: _isLocating
//                 ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
//                 : const HugeIcon(icon: HugeIcons.strokeRoundedGps01, color: Colors.blue, size: 20),
//             label: Text(_isLocating ? "Locating..." : "Auto-Detect My Location"),
//             style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: theme.primaryColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
//           ),
//         ),
//         const SizedBox(height: 20),
//         _buildField(address, "Address", HugeIcons.strokeRoundedHome01, iconColor: iconColor, maxLines: 2, v: (v) => v!.trim().isEmpty ? "Address is required" : null),
//         const SizedBox(height: 15),
//         Row(children: [
//           Expanded(child: _buildField(place, "City/Place", HugeIcons.strokeRoundedCity01, iconColor: iconColor, v: (v) => v!.trim().isEmpty ? "Place is required" : null)),
//           const SizedBox(width: 10),
//           Expanded(child: _buildField(pincode, "Pincode", HugeIcons.strokeRoundedPinLocation03, iconColor: iconColor, type: TextInputType.number, maxLength: 6, v: (v) { if(v == null || v.isEmpty) return "Required"; if(v.length != 6) return "Must be 6 digits"; return null; })),
//         ]),
//         const SizedBox(height: 15),
//         _buildField(post, "Post Office", HugeIcons.strokeRoundedMailbox01, iconColor: iconColor, v: (v) => v!.trim().isEmpty ? "Required" : null),
//         if (widget.isDistributor) ...[
//           const SizedBox(height: 15),
//           Row(children: [
//             Expanded(child: _buildField(latitude, "Latitude", HugeIcons.strokeRoundedCompass01, iconColor: iconColor, type: TextInputType.number, v: (v) => v!.isEmpty ? "Required" : null)),
//             const SizedBox(width: 10),
//             Expanded(child: _buildField(longitude, "Longitude", HugeIcons.strokeRoundedCompass01, iconColor: iconColor, type: TextInputType.number, v: (v) => v!.isEmpty ? "Required" : null)),
//           ]),
//         ]
//       ],
//     );
//   }
//
//   // 🚀 PERSONAL PAGE WITH GOOGLE FILL BUTTON
//   Widget _buildPersonalPage(Color iconColor) => _buildPage(title: "Personal", subtitle: "Let's get started", formKey: _formKeys[0], children: [
//
//     // Google Prefill Button
//     SizedBox(
//       width: double.infinity,
//       child: OutlinedButton.icon(
//         onPressed: _prefillWithGoogle,
//         icon: const HugeIcon(icon: HugeIcons.strokeRoundedGoogle, color: Colors.red, size: 20),
//         label: const Text("Fill details from Google"),
//         style: OutlinedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       ),
//     ),
//     const SizedBox(height: 20),
//
//     _buildField(name, "Full Name", HugeIcons.strokeRoundedUser, iconColor: iconColor, v: _validateName),
//     const SizedBox(height: 15),
//     _buildField(email, "Email", HugeIcons.strokeRoundedMail01, iconColor: iconColor, type: TextInputType.emailAddress, v: _validateEmail),
//     const SizedBox(height: 15),
//     _buildField(phone, "Phone", HugeIcons.strokeRoundedSmartPhone01, iconColor: iconColor, type: TextInputType.phone, maxLength: 10, prefix: "+91 ", v: _validatePhone),
//   ]);
//
//   Widget _buildFilesPage(Color iconColor, ThemeData theme) => _buildPage(title: "Proofs", subtitle: "Upload images only", formKey: _formKeys[2], children: [
//     _buildField(bio, "Bio", HugeIcons.strokeRoundedNoteEdit, iconColor: iconColor, maxLines: 3, v: (v) => v!.isEmpty ? "Bio is required" : null),
//     const SizedBox(height: 25),
//     _buildFileCard("Profile Image", _file1, () => _pickFile(false), theme),
//     if (widget.isDistributor) ...[const SizedBox(height: 15), _buildFileCard("Proof Image", _file2, () => _pickFile(true), theme)]
//   ]);
//
//   Widget _buildSecurityPage(Color iconColor) => _buildPage(title: "Security", subtitle: "Set Password", formKey: _formKeys[3], children: [
//     _buildField(password, "Password", HugeIcons.strokeRoundedSecurityPassword, iconColor: iconColor, isPass: true, obscure: _obscurePass, togglePass: () => setState(() => _obscurePass = !_obscurePass), v: _validatePassword),
//     const SizedBox(height: 15),
//     _buildField(confirmpassword, "Confirm", HugeIcons.strokeRoundedSecurityCheck, iconColor: iconColor, isPass: true, obscure: _obscureConfirm, togglePass: () => setState(() => _obscureConfirm = !_obscureConfirm), v: (v) {
//       if(v == null || v.isEmpty) return "Confirm your password";
//       if(v != password.text) return "Passwords do not match";
//       return null;
//     }),
//     const SizedBox(height: 40),
//     AppButton(text: "REGISTER", isLoading: _isLoading, onPressed: _register),
//   ]);
//
//   Widget _buildBottomNav(ThemeData theme) => Container(padding: const EdgeInsets.all(20), color: theme.cardColor, child: AppButton(text: "Next Step", onPressed: _nextPage, isTrailingIcon: true, icon: HugeIcons.strokeRoundedArrowRight01));
//
//   Widget _buildPage({required String title, required String subtitle, required List<Widget> children, required GlobalKey<FormState> formKey}) => SingleChildScrollView(padding: const EdgeInsets.all(24), child: Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.isDarkMode(context) ? AppColors.textMainDark : AppColors.textMainLight)), const SizedBox(height: 5), Text(subtitle, style: TextStyle(color: AppColors.isDarkMode(context) ? AppColors.textSubDark : AppColors.textSubLight)), const SizedBox(height: 30), ...children, const SizedBox(height: 100)])));
//
//   Widget _buildField(TextEditingController c, String label, dynamic icon, {required Color iconColor, bool isPass = false, bool obscure = false, VoidCallback? togglePass, TextInputType type = TextInputType.text, int maxLines = 1, int? maxLength, String? prefix, String? Function(String?)? v}) {
//     return TextFormField(
//         controller: c,
//         obscureText: isPass ? obscure : false,
//         keyboardType: type,
//         maxLines: maxLines,
//         maxLength: maxLength,
//         validator: v,
//         style: TextStyle(color: AppColors.isDarkMode(context) ? AppColors.textMainDark : AppColors.textMainLight),
//         decoration: InputDecoration(
//             labelText: label,
//             labelStyle: TextStyle(color: AppColors.isDarkMode(context) ? AppColors.textSubDark : AppColors.textSubLight),
//             prefixIcon: Padding(padding: const EdgeInsets.all(10.0), child: HugeIcon(icon: icon, color: iconColor, size: 10)),
//             prefixText: prefix,
//             counterText: "",
//             suffixIcon: isPass ? IconButton(icon: HugeIcon(icon: obscure ? HugeIcons.strokeRoundedViewOff : HugeIcons.strokeRoundedView, color: iconColor, size: 20), onPressed: togglePass) : null
//         )
//     );
//   }
//
//   Widget _buildFileCard(String label, PlatformFile? file, VoidCallback onTap, ThemeData theme) {
//     bool isSet = file != null;
//     return InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(color: theme.cardColor, border: Border.all(color: isSet ? theme.primaryColor : theme.dividerColor), borderRadius: BorderRadius.circular(12)),
//             child: Row(children: [
//               HugeIcon(icon: isSet ? HugeIcons.strokeRoundedCheckmarkCircle02 : HugeIcons.strokeRoundedImage01, color: isSet ? theme.primaryColor : theme.disabledColor, size: 24),
//               const SizedBox(width: 15),
//               Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.isDarkMode(context) ? AppColors.textMainDark : AppColors.textMainLight)),
//                 Text(file != null ? file.name : "Tap to upload image", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.isDarkMode(context) ? AppColors.textSubDark : AppColors.textSubLight))
//               ]))]
//             )
//         )
//     );
//   }
// }


import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For formatters
import 'package:file_picker/file_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart'; // 🚀 IMPORTED
import 'package:google_sign_in/google_sign_in.dart'; // 🚀 IMPORTED
import 'package:snap2bill/screens/Login_page.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../theme/colors.dart';
import '../widgets/SnackBar.dart';
import '../widgets/app_button.dart';

class RegistrationPage extends StatefulWidget {
  final bool isDistributor;

  const RegistrationPage({Key? key, required this.isDistributor}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final confirmpassword = TextEditingController();
  final address = TextEditingController();
  final pincode = TextEditingController();
  final place = TextEditingController();
  final post = TextEditingController();
  final bio = TextEditingController();
  final latitude = TextEditingController();
  final longitude = TextEditingController();

  final PageController _pageController = PageController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  int _currentPage = 0;
  bool _isLoading = false;
  bool _isLocating = false;
  final int _totalPages = 4;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // 🚀 NEW VARIABLE: Track if data came from Google
  bool _isGoogleLinked = false;

  PlatformFile? _file1;
  Uint8List? _file1Bytes;
  PlatformFile? _file2;
  Uint8List? _file2Bytes;

  @override
  void dispose() {
    name.dispose(); email.dispose(); phone.dispose();
    password.dispose(); confirmpassword.dispose();
    address.dispose(); pincode.dispose(); place.dispose();
    post.dispose(); bio.dispose(); latitude.dispose(); longitude.dispose();
    super.dispose();
  }

  // ✅ PRE-FILL FROM GOOGLE
  Future<void> _prefillWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled

      setState(() {
        name.text = googleUser.displayName ?? "";
        email.text = googleUser.email;

        // 🚀 Set this to TRUE to lock the field
        _isGoogleLinked = true;
      });

      CustomSnackBar.show(context, "Details fetched from Google!", backgroundColor: AppColors.getSuccessColor(context));
      await _googleSignIn.signOut();

    } catch (e) {
      CustomSnackBar.show(context, "Google Sign-In Error: $e", backgroundColor: AppColors.dangerColor);
    }
  }

  // ✅ CLEAR GOOGLE DATA (Optional utility if user wants to reset)
  void _clearGoogleData() {
    setState(() {
      name.clear();
      email.clear();
      _isGoogleLinked = false;
    });
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return "Name is required";
    if (value.trim().length < 3) return "Enter a valid name (min 3 chars)";
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return "Email is required";
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return "Enter a valid email address";
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return "Phone number is required";
    if (value.trim().length != 10) return "Phone number must be 10 digits";
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) return "Only numbers allowed";
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  Future<void> _handleLocationDetection() async {
    bool serviceEnabled;
    LocationPermission permission;
    setState(() => _isLocating = true);
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError("GPS is disabled. Please turn on location.");
        setState(() => _isLocating = false);
        return;
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError("Location permissions are denied.");
          setState(() => _isLocating = false);
          return;
        }
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      latitude.text = position.latitude.toString();
      longitude.text = position.longitude.toString();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark p = placemarks[0];
        setState(() {
          place.text = p.locality ?? "";
          pincode.text = p.postalCode ?? "";
          post.text = p.subLocality ?? "";
          address.text = "${p.street}, ${p.subLocality}, ${p.locality}";
        });
      }
    } catch (e) {
      _showError("Could not fetch location.");
    } finally {
      setState(() => _isLocating = false);
    }
  }

  Future<void> _pickFile(bool isSecondFile) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
      if (result != null) {
        setState(() {
          if (isSecondFile) {
            _file2 = result.files.first;
            if (kIsWeb) _file2Bytes = result.files.first.bytes;
          } else {
            _file1 = result.files.first;
            if (kIsWeb) _file1Bytes = result.files.first.bytes;
          }
        });
      }
    } catch (e) { debugPrint("Error picking file: $e"); }
  }

  void _nextPage() {
    if (!_formKeys[_currentPage].currentState!.validate()) return;
    if (_currentPage == 2) {
      if (_file1 == null) { _showError("Upload profile image."); return; }
      if (widget.isDistributor && _file2 == null) { _showError("Upload proof image."); return; }
    }
    _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    setState(() => _currentPage++);
  }

  void _prevPage() {
    _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    setState(() => _currentPage--);
  }

  void _showError(String msg) {
    CustomSnackBar.show(context, Text(msg) as String , backgroundColor: AppColors.dangerColor);
  }

  Future<void> _register() async {
    if (!_formKeys[3].currentState!.validate()) return;
    if (password.text != confirmpassword.text) { _showError("Passwords mismatch"); return; }
    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "http://10.0.2.2:8000";
      String endpoint = widget.isDistributor ? '/distributor_registration' : '/customer_registration';
      var request = http.MultipartRequest('POST', Uri.parse('$ip$endpoint'));
      request.fields.addAll({
        'name': name.text.trim(),
        'email': email.text.trim(),
        'phone': phone.text.trim(),
        'password': password.text.trim(),
        'confirmpassword': confirmpassword.text.trim(),
        'address': address.text.trim(),
        'pincode': pincode.text.trim(),
        'place': place.text.trim(),
        'post': post.text.trim(),
        'bio': bio.text.trim(),
      });
      if (widget.isDistributor) {
        request.fields['latitude'] = latitude.text.trim();
        request.fields['longitude'] = longitude.text.trim();
      }
      if (_file1 != null) {
        if (kIsWeb) request.files.add(http.MultipartFile.fromBytes('file', _file1Bytes!, filename: _file1!.name));
        else request.files.add(await http.MultipartFile.fromPath('file', _file1!.path!));
      }
      if (widget.isDistributor && _file2 != null) {
        if (kIsWeb) request.files.add(http.MultipartFile.fromBytes('file1', _file2Bytes!, filename: _file2!.name));
        else request.files.add(await http.MultipartFile.fromPath('file1', _file2!.path!));
      }
      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      var decoded = json.decode(responseString);
      if (decoded['status'] == 'ok') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      } else {
        _showError("Registration failed: ${decoded['status']}");
      }
    } catch (e) { _showError("Connection Error: Make sure IP is correct and server is running."); }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? AppColors.iconColorDark : AppColors.iconColorLight;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPersonalPage(iconColor, theme),
                  _buildLocationPage(iconColor, theme),
                  _buildFilesPage(iconColor, theme),
                  _buildSecurityPage(iconColor),
                ],
              ),
            ),
            if (_currentPage < _totalPages - 1) _buildBottomNav(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Container(
      padding: EdgeInsets.all(isLandscape ? 10 : 20),
      decoration: BoxDecoration(color: theme.cardColor, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Column(children: [
        Row(children: [
          IconButton(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, size: isLandscape ? 18 : 24, color: Theme.of(context).iconTheme.color!),
              onPressed: () => _currentPage > 0 ? _prevPage() : Navigator.pop(context)
          ),
          Expanded(child: Center(child: Text(widget.isDistributor ? "Distributor Register" : "Customer Register", maxLines: 1, style: TextStyle(fontSize: isLandscape ? 16 : 20, fontWeight: FontWeight.w900, color: AppColors.isDarkMode(context) ? AppColors.textMainDark : AppColors.textMainLight)))),
          SizedBox(width: isLandscape ? 30 : 40),
        ]),
        SizedBox(height: isLandscape ? 5 : 15),
        Row(children: List.generate(_totalPages, (i) => Expanded(child: Container(height: isLandscape ? 4 : 6, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: i <= _currentPage ? theme.primaryColor : theme.disabledColor.withValues(alpha:0.2)))))),
        const SizedBox(height: 5),
        Text("Step ${_currentPage + 1} of $_totalPages", style: theme.textTheme.bodySmall),
      ]),
    );
  }

  Widget _buildLocationPage(Color iconColor, ThemeData theme) {
    return _buildPage(
      title: "Location Details",
      subtitle: "Where are you located?",
      formKey: _formKeys[1],
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLocating ? null : _handleLocationDetection,
            icon: _isLocating
                ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                : const HugeIcon(icon: HugeIcons.strokeRoundedGps01, color: Colors.blue, size: 20),
            label: Text(_isLocating ? "Locating..." : "Auto-Detect My Location"),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: theme.primaryColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ),
        const SizedBox(height: 20),
        _buildField(address, "Address", HugeIcons.strokeRoundedHome01, iconColor: iconColor, maxLines: 2, v: (v) => v!.trim().isEmpty ? "Address is required" : null),
        const SizedBox(height: 15),
        Row(children: [
          Expanded(child: _buildField(place, "City/Place", HugeIcons.strokeRoundedCity01, iconColor: iconColor, v: (v) => v!.trim().isEmpty ? "Place is required" : null)),
          const SizedBox(width: 10),
          Expanded(child: _buildField(pincode, "Pincode", HugeIcons.strokeRoundedPinLocation03, iconColor: iconColor, type: TextInputType.number, maxLength: 6, v: (v) { if(v == null || v.isEmpty) return "Required"; if(v.length != 6) return "Must be 6 digits"; return null; })),
        ]),
        const SizedBox(height: 15),
        _buildField(post, "Post Office", HugeIcons.strokeRoundedMailbox01, iconColor: iconColor, v: (v) => v!.trim().isEmpty ? "Required" : null),
        if (widget.isDistributor) ...[
          const SizedBox(height: 15),
          Row(children: [
            Expanded(child: _buildField(latitude, "Latitude", HugeIcons.strokeRoundedCompass01, iconColor: iconColor, type: TextInputType.number, v: (v) => v!.isEmpty ? "Required" : null)),
            const SizedBox(width: 10),
            Expanded(child: _buildField(longitude, "Longitude", HugeIcons.strokeRoundedCompass01, iconColor: iconColor, type: TextInputType.number, v: (v) => v!.isEmpty ? "Required" : null)),
          ]),
        ]
      ],
    );
  }

  // 🚀 UPDATED PERSONAL PAGE
  Widget _buildPersonalPage(Color iconColor, ThemeData theme) => _buildPage(title: "Personal", subtitle: "Let's get started", formKey: _formKeys[0], children: [

    // Google Prefill Button with "Reset" option if already linked
    if (!_isGoogleLinked)
      Container(
        decoration: BoxDecoration(
          color: AppColors.WhiteColor,
          borderRadius: BorderRadius.circular(50)
        ),
        width: double.infinity,
        child: SecondaryButton(
          onPressed: _prefillWithGoogle,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Lottie.asset(
              'assets/lotties/Google Icon.json', // Apne file ka sahi path dalein
              height: 30, // ⚠️ Size chhota rakhein (Button ke liye 24-30 best hai)
              width: 30,
              repeat: true, // Animation loop kare ya nahi
            ),
          ),
          text: "Fill details from Google",
         
        ),
      )
    else
      SizedBox(
        width: double.infinity,
        child: SecondaryButton(
          onPressed: _clearGoogleData,
          leading: Icon(Icons.close),
          text: "Clear Google Data",
          color: AppColors.getDangerColor(context).withValues(alpha: 0.5),
        ),
      ),

    const SizedBox(height: 20),

    _buildField(name, "Full Name", HugeIcons.strokeRoundedUser, iconColor: iconColor, v: _validateName),
    const SizedBox(height: 15),

    // 🚀 EMAIL FIELD WITH LOCK LOGIC
    _buildField(
        email,
        "Email",
        HugeIcons.strokeRoundedMail01,
        iconColor: iconColor,
        type: TextInputType.emailAddress,
        v: _validateEmail,
        isReadOnly: _isGoogleLinked, // 🔒 Lock if Google Linked
        theme: theme
    ),

    const SizedBox(height: 15),
    _buildField(phone, "Phone", HugeIcons.strokeRoundedSmartPhone01, iconColor: iconColor, type: TextInputType.phone, maxLength: 10, prefix: "+91 ", v: _validatePhone),
  ]);

  Widget _buildFilesPage(Color iconColor, ThemeData theme) => _buildPage(title: "Proofs", subtitle: "Upload images only", formKey: _formKeys[2], children: [
    _buildField(bio, "Bio", HugeIcons.strokeRoundedNoteEdit, iconColor: iconColor, maxLines: 3, v: (v) => v!.isEmpty ? "Bio is required" : null),
    const SizedBox(height: 25),
    _buildFileCard("Profile Image", _file1, () => _pickFile(false), theme),
    if (widget.isDistributor) ...[const SizedBox(height: 15), _buildFileCard("Proof Image", _file2, () => _pickFile(true), theme)]
  ]);

  Widget _buildSecurityPage(Color iconColor) => _buildPage(title: "Security", subtitle: "Set Password", formKey: _formKeys[3], children: [
    _buildField(password, "Password", HugeIcons.strokeRoundedSecurityPassword, iconColor: iconColor, isPass: true, obscure: _obscurePass, togglePass: () => setState(() => _obscurePass = !_obscurePass), v: _validatePassword),
    const SizedBox(height: 15),
    _buildField(confirmpassword, "Confirm", HugeIcons.strokeRoundedSecurityCheck, iconColor: iconColor, isPass: true, obscure: _obscureConfirm, togglePass: () => setState(() => _obscureConfirm = !_obscureConfirm), v: (v) {
      if(v == null || v.isEmpty) return "Confirm your password";
      if(v != password.text) return "Passwords do not match";
      return null;
    }),
    const SizedBox(height: 40),
    AppButton(text: "REGISTER", isLoading: _isLoading, onPressed: _register),
  ]);

  Widget _buildBottomNav(ThemeData theme) => Container(padding: const EdgeInsets.all(20), color: theme.cardColor, child: AppButton(text: "Next Step", onPressed: _nextPage, isTrailingIcon: true, icon: HugeIcons.strokeRoundedArrowRight01));

  Widget _buildPage({required String title, required String subtitle, required List<Widget> children, required GlobalKey<FormState> formKey}) => SingleChildScrollView(padding: const EdgeInsets.all(24), child: Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.isDarkMode(context) ? AppColors.textMainDark : AppColors.textMainLight)), const SizedBox(height: 5), Text(subtitle, style: TextStyle(color: AppColors.isDarkMode(context) ? AppColors.textSubDark : AppColors.textSubLight)), const SizedBox(height: 30), ...children, const SizedBox(height: 100)])));

  // 🚀 UPDATED: Accepts readOnly and theme for styling
  Widget _buildField(TextEditingController c, String label, dynamic icon, {required Color iconColor, bool isPass = false, bool obscure = false, VoidCallback? togglePass, TextInputType type = TextInputType.text, int maxLines = 1, int? maxLength, String? prefix, String? Function(String?)? v, bool isReadOnly = false, ThemeData? theme}) {
    return TextFormField(
        controller: c,
        obscureText: isPass ? obscure : false,
        keyboardType: type,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: v,
        readOnly: isReadOnly, // 🔒 The Lock Mechanism
        style: TextStyle(
            color: isReadOnly
                ? (AppColors.isDarkMode(context) ? Colors.grey : Colors.grey[700]) // Grey text if locked
                : (AppColors.isDarkMode(context) ? AppColors.textMainDark : AppColors.textMainLight)
        ),
        decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: AppColors.isDarkMode(context) ? AppColors.textSubDark : AppColors.textSubLight),
            filled: isReadOnly, // Fill color if locked
            fillColor: isReadOnly
                ? (AppColors.isDarkMode(context) ? Colors.white.withValues(alpha:0.05) : Colors.grey.withValues(alpha:0.1))
                : null,
            prefixIcon: Padding(padding: const EdgeInsets.all(10.0), child: HugeIcon(icon: icon, color: isReadOnly ? Colors.grey : iconColor, size: 10)),
            prefixText: prefix,
            counterText: "",
            suffixIcon: isPass ? IconButton(icon: HugeIcon(icon: obscure ? HugeIcons.strokeRoundedViewOff : HugeIcons.strokeRoundedView, color: iconColor, size: 20), onPressed: togglePass)
                : (isReadOnly ? const Icon(Icons.lock, size: 18, color: Colors.grey) : null) // Show Lock Icon if readOnly
        )
    );
  }

  Widget _buildFileCard(String label, PlatformFile? file, VoidCallback onTap, ThemeData theme) {
    bool isSet = file != null;
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: theme.cardColor, border: Border.all(color: isSet ? theme.primaryColor : theme.dividerColor), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              HugeIcon(icon: isSet ? HugeIcons.strokeRoundedCheckmarkCircle02 : HugeIcons.strokeRoundedImage01, color: isSet ? theme.primaryColor : theme.disabledColor, size: 24),
              const SizedBox(width: 15),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.isDarkMode(context) ? AppColors.textMainDark : AppColors.textMainLight)),
                Text(file != null ? file.name : "Tap to upload image", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.isDarkMode(context) ? AppColors.textSubDark : AppColors.textSubLight))
              ]))]
            )
        )
    );
  }
}