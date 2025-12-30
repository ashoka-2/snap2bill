
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snap2bill/screens/Login_page.dart';

// ✅ LOCATION PACKAGES
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../theme/colors.dart';
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
  int _currentPage = 0;
  bool _isLoading = false;
  bool _isLocating = false;
  final int _totalPages = 4;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

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

  // ✅ AUTO-DETECT LOCATION
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

  // ✅ RESTRICTED TO IMAGES ONLY
  Future<void> _pickFile(bool isSecondFile) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image, // ✅ Prevents Video Selection
        allowMultiple: false,
      );
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
  }

  // ✅ FIXED REGISTER API KEYS
  Future<void> _register() async {
    if (!_formKeys[3].currentState!.validate()) return;
    if (password.text != confirmpassword.text) { _showError("Passwords mismatch"); return; }

    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? "http://10.0.2.2:8000";
      String endpoint = widget.isDistributor ? '/distributor_registration' : '/customer_registration';

      var request = http.MultipartRequest('POST', Uri.parse('$ip$endpoint'));

      request.fields.addAll({
        'name': name.text.trim(),
        'email': email.text.trim(),
        'phone': "+91${phone.text.trim()}",
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

      // ✅ KEY: 'file' for Avatar
      if (_file1 != null) {
        if (kIsWeb) request.files.add(http.MultipartFile.fromBytes('file', _file1Bytes!, filename: _file1!.name));
        else request.files.add(await http.MultipartFile.fromPath('file', _file1!.path!));
      }

      // ✅ KEY: 'file1' for Proof (Matches Django request.FILES['file1'])
      if (widget.isDistributor && _file2 != null) {
        if (kIsWeb) request.files.add(http.MultipartFile.fromBytes('file1', _file2Bytes!, filename: _file2!.name));
        else request.files.add(await http.MultipartFile.fromPath('file1', _file2!.path!));
      }

      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      var decoded = json.decode(responseString);

      if (decoded['status'] == 'ok') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const login_page()));
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
                  _buildPersonalPage(iconColor),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.cardColor, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Column(children: [
        Row(children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => _currentPage > 0 ? _prevPage() : Navigator.pop(context)),
          Expanded(child: Center(child: Text(widget.isDistributor ? "Distributor Register" : "Customer Register", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)))),
          const SizedBox(width: 40),
        ]),
        const SizedBox(height: 15),
        Row(children: List.generate(_totalPages, (i) => Expanded(child: Container(height: 6, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: i <= _currentPage ? theme.primaryColor : theme.disabledColor.withOpacity(0.2)))))),
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
                : const Icon(Icons.my_location),
            label: Text(_isLocating ? "Locating..." : "Auto-Detect My Location"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: theme.primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildField(address, "Address", Icons.home, iconColor: iconColor, maxLines: 2, v: (v) => v!.isEmpty ? "Required" : null),
        const SizedBox(height: 15),
        Row(children: [
          Expanded(child: _buildField(place, "City/Place", Icons.location_city, iconColor: iconColor, v: (v) => v!.isEmpty ? "Required" : null)),
          const SizedBox(width: 10),
          Expanded(child: _buildField(pincode, "Pincode", Icons.pin_drop, iconColor: iconColor, type: TextInputType.number, maxLength: 6, v: (v) => v!.length != 6 ? "Invalid" : null)),
        ]),
        const SizedBox(height: 15),
        _buildField(post, "Post Office", Icons.local_post_office, iconColor: iconColor, v: (v) => v!.isEmpty ? "Required" : null),
        if (widget.isDistributor) ...[
          const SizedBox(height: 15),
          Row(children: [
            Expanded(child: _buildField(latitude, "Latitude", Icons.gps_fixed, iconColor: iconColor, type: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(child: _buildField(longitude, "Longitude", Icons.gps_fixed, iconColor: iconColor, type: TextInputType.number)),
          ]),
        ]
      ],
    );
  }

  Widget _buildPersonalPage(Color iconColor) => _buildPage(title: "Personal", subtitle: "Let's get started", formKey: _formKeys[0], children: [
    _buildField(name, "Full Name", Icons.person, iconColor: iconColor),
    const SizedBox(height: 15),
    _buildField(email, "Email", Icons.email, iconColor: iconColor, type: TextInputType.emailAddress),
    const SizedBox(height: 15),
    _buildField(phone, "Phone", Icons.phone, iconColor: iconColor, type: TextInputType.phone, maxLength: 10, prefix: "+91 "),
  ]);

  Widget _buildFilesPage(Color iconColor, ThemeData theme) => _buildPage(title: "Proofs", subtitle: "Upload images only", formKey: _formKeys[2], children: [
    _buildField(bio, "Bio", Icons.description, iconColor: iconColor, maxLines: 3),
    const SizedBox(height: 25),
    _buildFileCard("Profile Image", _file1, () => _pickFile(false), theme),
    if (widget.isDistributor) ...[const SizedBox(height: 15), _buildFileCard("Proof Image", _file2, () => _pickFile(true), theme)]
  ]);

  Widget _buildSecurityPage(Color iconColor) => _buildPage(title: "Security", subtitle: "Set Password", formKey: _formKeys[3], children: [
    _buildField(password, "Password", Icons.lock, iconColor: iconColor, isPass: true, obscure: _obscurePass, togglePass: () => setState(() => _obscurePass = !_obscurePass)),
    const SizedBox(height: 15),
    _buildField(confirmpassword, "Confirm", Icons.lock_outline, iconColor: iconColor, isPass: true, obscure: _obscureConfirm, togglePass: () => setState(() => _obscureConfirm = !_obscureConfirm)),
    const SizedBox(height: 40),
    AppButton(text: "REGISTER", isLoading: _isLoading, onPressed: _register),
  ]);

  Widget _buildBottomNav(ThemeData theme) => Container(padding: const EdgeInsets.all(20), color: theme.cardColor, child: AppButton(text: "Next Step", onPressed: _nextPage, isTrailingIcon: true, icon: Icons.arrow_forward));

  Widget _buildPage({required String title, required String subtitle, required List<Widget> children, required GlobalKey<FormState> formKey}) => SingleChildScrollView(padding: const EdgeInsets.all(24), child: Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(subtitle), const SizedBox(height: 30), ...children, const SizedBox(height: 100)])));

  Widget _buildField(TextEditingController c, String label, IconData icon, {required Color iconColor, bool isPass = false, bool obscure = false, VoidCallback? togglePass, TextInputType type = TextInputType.text, int maxLines = 1, int? maxLength, String? prefix, String? Function(String?)? v}) {
    return TextFormField(controller: c, obscureText: isPass ? obscure : false, keyboardType: type, maxLines: maxLines, maxLength: maxLength, validator: v, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: iconColor, size: 20), prefixText: prefix, counterText: "", suffixIcon: isPass ? IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: iconColor), onPressed: togglePass) : null));
  }

  Widget _buildFileCard(String label, PlatformFile? file, VoidCallback onTap, ThemeData theme) {
    bool isSet = file != null;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: theme.cardColor, border: Border.all(color: isSet ? theme.primaryColor : theme.dividerColor), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(isSet ? Icons.check_circle : Icons.image, color: isSet ? theme.primaryColor : theme.disabledColor), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), Text(file != null ? file.name : "Tap to upload image", maxLines: 1, overflow: TextOverflow.ellipsis)]))] )));
  }
}