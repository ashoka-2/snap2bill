import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snap2bill/screens/Login_page.dart';

// Import shared resources
import '../theme/colors.dart';
import '../widgets/app_button.dart';

class RegistrationPage extends StatefulWidget {
  final bool isDistributor; // The Magic Switch

  const RegistrationPage({Key? key, required this.isDistributor}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // --- FORM KEYS ---
  final _formKeys = [
    GlobalKey<FormState>(), // Step 1
    GlobalKey<FormState>(), // Step 2
    GlobalKey<FormState>(), // Step 3
    GlobalKey<FormState>(), // Step 4
  ];

  // --- CONTROLLERS ---
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
  final latitude = TextEditingController(); // Only for Distributor
  final longitude = TextEditingController(); // Only for Distributor

  // --- STATE ---
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  final int _totalPages = 4;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // --- FILES ---
  PlatformFile? _file1; // Profile/Main
  Uint8List? _file1Bytes;
  PlatformFile? _file2; // Proof (Distributor only)
  Uint8List? _file2Bytes;

  @override
  void dispose() {
    name.dispose(); email.dispose(); phone.dispose();
    password.dispose(); confirmpassword.dispose();
    address.dispose(); pincode.dispose(); place.dispose();
    post.dispose(); bio.dispose(); latitude.dispose(); longitude.dispose();
    super.dispose();
  }

  // --- FILE PICKER ---
  Future<void> _pickFile(bool isSecondFile) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
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
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  // --- NAVIGATION ---
  void _nextPage() {
    // Validate current step
    if (!_formKeys[_currentPage].currentState!.validate()) return;

    // Special File Validation for Step 3
    if (_currentPage == 2) {
      if (_file1 == null) {
        _showError("Please upload the required file.");
        return;
      }
      // If Distributor, check 2nd file
      if (widget.isDistributor && _file2 == null) {
        _showError("Please upload the proof document.");
        return;
      }
    }

    // Move Next
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage++);
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage--);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // --- REGISTER API ---
  Future<void> _register() async {
    if (!_formKeys[3].currentState!.validate()) return;
    if (password.text != confirmpassword.text) {
      _showError("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? "http://10.0.2.2:8000";

      // Dynamic URL and ID key based on type
      String endpoint = widget.isDistributor ? '/distributor_registration' : '/customer_registration';
      String idKey = widget.isDistributor ? 'uid' : 'cid';

      var uri = Uri.parse('$ip$endpoint');
      var request = http.MultipartRequest('POST', uri);

      // Common Fields
      request.fields['name'] = name.text.trim();
      request.fields['email'] = email.text.trim();
      request.fields['phone'] = "+91${phone.text.trim()}";
      request.fields['password'] = password.text.trim();
      request.fields['confirmpassword'] = confirmpassword.text.trim();
      request.fields['address'] = address.text.trim();
      request.fields['pincode'] = pincode.text.trim();
      request.fields['place'] = place.text.trim();
      request.fields['post'] = post.text.trim();
      request.fields['bio'] = bio.text.trim();
      request.fields[idKey] = sh.getString(idKey) ?? '';

      // Distributor Only Fields
      if (widget.isDistributor) {
        request.fields['latitude'] = latitude.text.trim();
        request.fields['longitude'] = longitude.text.trim();
      }

      // Add File 1
      if (kIsWeb && _file1Bytes != null) {
        request.files.add(http.MultipartFile.fromBytes('file', _file1Bytes!, filename: _file1!.name));
      } else if (_file1?.path != null) {
        request.files.add(await http.MultipartFile.fromPath('file', _file1!.path!));
      }

      // Add File 2 (Distributor Only)
      if (widget.isDistributor) {
        if (kIsWeb && _file2Bytes != null) {
          request.files.add(http.MultipartFile.fromBytes('file1', _file2Bytes!, filename: _file2!.name));
        } else if (_file2?.path != null) {
          request.files.add(await http.MultipartFile.fromPath('file1', _file2!.path!));
        }
      }

      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var decoded = json.decode(responseString);
        if (decoded['status'] == 'ok') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration Successful!"), backgroundColor: Colors.green));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => login_page()));
        } else {
          _showError("Failed: ${decoded['status']}");
        }
      } else {
        _showError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Dynamic Title
    final String pageTitle = widget.isDistributor ? "Distributor Register" : "Customer Register";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, size: 20, color: theme.iconTheme.color),
                        onPressed: () => _currentPage > 0 ? _prevPage() : Navigator.pop(context),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            pageTitle,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Progress Dots
                  Row(
                    children: List.generate(_totalPages, (index) {
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: index <= _currentPage ? theme.primaryColor : theme.disabledColor.withOpacity(0.2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 5),
                  Text("Step ${_currentPage + 1} of $_totalPages", style: theme.textTheme.bodySmall),
                ],
              ),
            ),

            // --- PAGE VIEW ---
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // STEP 1: Personal
                  _buildPage(
                    title: "Personal Details",
                    subtitle: "Let's get to know you.",
                    formKey: _formKeys[0],
                    children: [
                      _buildField(name, "Full Name", Icons.person, v: (v) => v!.length < 3 ? "Name too short" : null),
                      const SizedBox(height: 15),
                      _buildField(email, "Email", Icons.email, type: TextInputType.emailAddress, v: (v) => !v!.contains("@") ? "Invalid email" : null),
                      const SizedBox(height: 15),
                      _buildField(phone, "Phone", Icons.phone, type: TextInputType.phone, maxLength: 10, prefix: "+91 ", v: (v) => v!.length != 10 ? "10 digits required" : null),
                    ],
                  ),

                  // STEP 2: Address
                  _buildPage(
                    title: "Location Details",
                    subtitle: "Where are you located?",
                    formKey: _formKeys[1],
                    children: [
                      _buildField(address, "Address", Icons.home, maxLines: 2, v: (v) => v!.isEmpty ? "Required" : null),
                      const SizedBox(height: 15),
                      Row(children: [
                        Expanded(child: _buildField(place, "City/Place", Icons.location_city, v: (v) => v!.isEmpty ? "Required" : null)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildField(pincode, "Pincode", Icons.pin_drop, type: TextInputType.number, maxLength: 6, v: (v) => v!.length != 6 ? "Invalid" : null)),
                      ]),
                      const SizedBox(height: 15),
                      _buildField(post, "Post Office", Icons.local_post_office, v: (v) => v!.isEmpty ? "Required" : null),

                      // CONDITIONAL: Show Lat/Long ONLY if Distributor
                      if (widget.isDistributor) ...[
                        const SizedBox(height: 15),
                        Row(children: [
                          Expanded(child: _buildField(latitude, "Latitude", Icons.gps_fixed, type: TextInputType.number)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildField(longitude, "Longitude", Icons.gps_fixed, type: TextInputType.number)),
                        ]),
                      ]
                    ],
                  ),

                  // STEP 3: Files
                  _buildPage(
                    title: "Profile & Documents",
                    subtitle: "Upload necessary proofs.",
                    formKey: _formKeys[2],
                    children: [
                      _buildField(bio, "Bio / Description", Icons.description, maxLines: 3, v: (v) => v!.isEmpty ? "Required" : null),
                      const SizedBox(height: 25),

                      Text("Uploads", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      _buildFileCard("Profile Image / File", _file1, () => _pickFile(false), theme),

                      // CONDITIONAL: Show 2nd File ONLY if Distributor
                      if (widget.isDistributor) ...[
                        const SizedBox(height: 15),
                        _buildFileCard("Proof Document", _file2, () => _pickFile(true), theme),
                      ]
                    ],
                  ),

                  // STEP 4: Security
                  _buildPage(
                    title: "Security",
                    subtitle: "Protect your account.",
                    formKey: _formKeys[3],
                    children: [
                      _buildField(password, "Password", Icons.lock, isPass: true, obscure: _obscurePass,
                          togglePass: () => setState(() => _obscurePass = !_obscurePass),
                          v: (v) {
                            if (v!.length < 8) return "Min 8 chars";
                            if (!v.contains(RegExp(r'[A-Z]'))) return "Need Uppercase";
                            if (!v.contains(RegExp(r'[0-9]'))) return "Need Number";
                            return null;
                          }),
                      const SizedBox(height: 20),
                      _buildField(confirmpassword, "Confirm Password", Icons.lock_outline, isPass: true, obscure: _obscureConfirm,
                          togglePass: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          v: (v) => v != password.text ? "Mismatch" : null),
                      const SizedBox(height: 40),

                      AppButton(
                        text: "REGISTER",
                        isLoading: _isLoading,
                        onPressed: _register,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- BOTTOM NAV ---
            if (_currentPage < _totalPages - 1)
              Container(
                padding: const EdgeInsets.all(20),
                color: theme.cardColor,
                child: AppButton(
                  text: "Next Step",
                  onPressed: _nextPage,
                  isTrailingIcon: true,
                  icon: Icons.arrow_forward,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE WIDGETS (Internal) ---

  Widget _buildPage({required String title, required String subtitle, required List<Widget> children, required GlobalKey<FormState> formKey}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSubLight)),
          const SizedBox(height: 30),
          ...children,
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String label, IconData icon, {
    bool isPass = false, bool obscure = false, VoidCallback? togglePass,
    TextInputType type = TextInputType.text, int maxLines = 1, int? maxLength,
    String? prefix, String? Function(String?)? v
  }) {
    return TextFormField(
      controller: c,
      obscureText: isPass ? obscure : false,
      keyboardType: type,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: v,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.iconColorLight, size: 20),
        prefixText: prefix,
        counterText: "",
        suffixIcon: isPass ? IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.iconColorLight),
          onPressed: togglePass,
        ) : null,
      ),
    );
  }

  Widget _buildFileCard(String label, PlatformFile? file, VoidCallback onTap, ThemeData theme) {
    bool isSet = file != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border.all(color: isSet ? AppColors.primaryLight : theme.dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(isSet ? Icons.check_circle : Icons.upload_file, color: isSet ? AppColors.primaryLight : theme.disabledColor),
            const SizedBox(width: 15),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(isSet ? file.name : "Tap to upload", maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
              ]),
            )
          ],
        ),
      ),
    );
  }
}