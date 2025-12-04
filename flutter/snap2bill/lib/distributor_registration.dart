// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:snap2bill/Login_page.dart';
//
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart'; // kIsWeb
// import 'dart:typed_data';
//
//
//
//
//
// class distributor_registration extends StatelessWidget {
//   const distributor_registration({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const distributor_registration_sub();
//   }
// }
//
// class distributor_registration_sub extends StatefulWidget {
//   const distributor_registration_sub({Key? key}) : super(key: key);
//
//   @override
//   State<distributor_registration_sub> createState() =>
//       _distributor_registration_subState();
// }
//
// class _distributor_registration_subState
//     extends State<distributor_registration_sub> {
//   final name = new TextEditingController();
//   final email = new TextEditingController();
//   final phone = new TextEditingController();
//   final password = new TextEditingController();
//   final confirmpassword = new TextEditingController();
//   final address = new TextEditingController();
//   final pincode = new TextEditingController();
//   final place = new TextEditingController();
//   final post = new TextEditingController();
//   final bio = new TextEditingController();
//   final latitude = new TextEditingController();
//   final longitude = new TextEditingController();
//
//   PlatformFile? _selectedFile;
//   Uint8List? _webFileBytes;
//   String? _result;
//   bool _isLoading = false;
//
//   PlatformFile? _selectedFile1;
//   Uint8List? _webFileBytes1;
//   String? _result1;
//   bool _isLoading1 = false;
//
//   // =====================================================
//   // 📸 PICK FILE FUNCTION
//   // =====================================================
//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: false,
//       type: FileType.any, // Any file type allowed
//     );
//
//     if (result != null) {
//       setState(() {
//         _selectedFile = result.files.first;
//         _result = null;
//       });
//
//       if (kIsWeb) {
//         _webFileBytes = result.files.first.bytes;
//       }
//     }
//   }
//
//   Future<void> _pickFile1() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: false,
//       type: FileType.any, // Any file type allowed
//     );
//
//     if (result != null) {
//       setState(() {
//         _selectedFile1 = result.files.first;
//         _result1 = null;
//       });
//
//       if (kIsWeb) {
//         _webFileBytes1 = result.files.first.bytes;
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
//           onPressed: () {
//             if (Navigator.canPop(context)) Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           "Distribution registration",
//           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
//         ),
//       ),
//
//       // backgroundColor: Colors.cyan,
//       body: SingleChildScrollView(
//         child: Center(
//           child: SizedBox(
//             child: Padding(
//               padding: EdgeInsets.all(10),
//               child: Container(
//                 width: 400,
//                 // height: 1000,
//                 decoration: BoxDecoration(
//                     color: Colors.green.shade100,
//                     borderRadius: BorderRadius.circular(21)),
//                 child: Padding(
//                   padding:
//                   const EdgeInsets.only(left: 10, top: 20, right: 10, bottom: 15),
//                   child: Column(
//                     children: [
//                       ElevatedButton.icon(
//                         icon: Icon(Icons.upload_file),
//                         label: Text("Select File"),
//                         onPressed: _pickFile,
//                       ),
//                       if (_selectedFile != null) ...[
//                         SizedBox(height: 10),
//                         Text("Selected: ${_selectedFile!.name}"),
//                       ],
//                       SizedBox(
//                         height: 10,
//                       ),
//                       TextField(
//                         controller: name,
//                         decoration: InputDecoration(
//                           hintText: 'Enter your name ',
//                           labelText: 'Name',
//                           prefixIcon: Icon(Icons.abc_rounded),
//                           filled: true,
//                           fillColor: Colors.white70,
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       TextField(
//                         controller: email,
//                         decoration: InputDecoration(
//                             hintText: 'Enter your Email',
//                             labelText: 'Email',
//                             prefixIcon: Icon(Icons.email_outlined),
//                             border: OutlineInputBorder()),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       TextField(
//                         controller: phone,
//                         keyboardType: TextInputType.number,
//                         decoration: InputDecoration(
//                           hintText: 'Enter your number',
//                           labelText: 'Phone Number',
//                           prefixIcon: Icon(Icons.phone_android),
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       TextField(
//                         controller: password,
//                         decoration: InputDecoration(
//                           hintText: "Enter password",
//                           labelText: 'Password',
//                           prefixIcon: Icon(Icons.password),
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       TextField(
//                         controller: confirmpassword,
//                         decoration: InputDecoration(
//                           hintText: "Enter password",
//                           labelText: 'Confirm Password',
//                           prefixIcon: Icon(Icons.password),
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       TextField(
//                         controller: address,
//                         decoration: InputDecoration(
//                             hintText: 'Enter your Address',
//                             labelText: 'Address',
//                             prefixIcon: Icon(Icons.location_city),
//                             border: OutlineInputBorder()),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       TextField(
//                         controller: pincode,
//                         keyboardType: TextInputType.number,
//                         decoration: InputDecoration(
//                             hintText: 'Enter your pincode',
//                             labelText: 'Pincode',
//                             prefixIcon: Icon(Icons.location_on_sharp),
//                             border: OutlineInputBorder()),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       TextField(
//                         controller: place,
//                         decoration: InputDecoration(
//                             hintText: 'Enter your Place',
//                             labelText: 'Place',
//                             prefixIcon: Icon(Icons.place),
//                             border: OutlineInputBorder()),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       TextField(
//                         controller: post,
//                         decoration: InputDecoration(
//                             hintText: 'Enter your post',
//                             labelText: 'Post',
//                             prefixIcon: Icon(Icons.place_sharp),
//                             border: OutlineInputBorder()),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       TextField(
//                         controller: bio,
//                         decoration: InputDecoration(
//                             hintText: 'Enter description',
//                             labelText: 'Bio',
//                             prefixIcon: Icon(Icons.abc_sharp),
//                             border: OutlineInputBorder()),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       TextField(
//                         controller: latitude,
//                         decoration: InputDecoration(
//                             hintText: 'Enter your Latitude',
//                             labelText: 'Latitude',
//                             prefixIcon: Icon(Icons.abc_sharp),
//                             border: OutlineInputBorder()),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       TextField(
//                         controller: longitude,
//                         decoration: InputDecoration(
//                             hintText: 'Enter your Longitude',
//                             labelText: 'Longitude',
//                             prefixIcon: Icon(Icons.abc_sharp),
//                             border: OutlineInputBorder()),
//                       ),
//                       SizedBox(height: 10),
//                       ElevatedButton.icon(
//                         icon: Icon(Icons.upload_file),
//                         label: Text("Select File"),
//                         onPressed: _pickFile1,
//                       ),
//                       if (_selectedFile1 != null) ...[
//                         SizedBox(height: 10),
//                         Text("Selected: ${_selectedFile1!.name}"),
//                       ],
//                       SizedBox(
//                         height: 10,
//                       ),
//                       ElevatedButton(
//                           onPressed: () async {
//
//                             if (_selectedFile == null && _selectedFile1 == null) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('Please select at least one file first')),
//                               );
//                               return;
//                             }
//
//                             SharedPreferences sh = await SharedPreferences.getInstance();
//                             String? ip = sh.getString('ip');
//
//
//
//                             var uri = Uri.parse('$ip/distributor_registration');
//                             var request = http.MultipartRequest('POST', uri);
//
//                             // 🔹 Normal Form Data
//                             request.fields['name'] = name.text;
//                             request.fields['email'] = email.text;
//                             request.fields['phone'] = phone.text;
//                             request.fields['password'] = password.text;
//                             request.fields['confirmpassword'] = confirmpassword.text;
//                             request.fields['address'] = address.text;
//                             request.fields['pincode'] = pincode.text;
//                             request.fields['place'] = place.text;
//                             request.fields['post'] = post.text;
//                             request.fields['bio'] = bio.text;
//                             request.fields['latitude'] = latitude.text;
//                             request.fields['longitude'] = longitude.text;
//
//                             request.fields['uid'] = sh.getString('uid')?.toString() ?? '';
//
//
//                             if (_selectedFile != null) {
//                               if (kIsWeb) {
//                                 if (_webFileBytes == null) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(content: Text('First file bytes are empty (web).')));
//                                   setState(() {
//                                     _isLoading = false;
//                                     _isLoading1 = false;
//                                   });
//                                   return;
//                                 }
//                                 request.files.add(http.MultipartFile.fromBytes(
//                                   'file',
//                                   _webFileBytes!,
//                                   filename: _selectedFile!.name,
//                                 ));
//                               } else {
//                                 if (_selectedFile?.path == null) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(content: Text('First selected file path is empty.')));
//                                   setState(() {
//                                     _isLoading = false;
//                                     _isLoading1 = false;
//                                   });
//                                   return;
//                                 }
//                                 request.files.add(await http.MultipartFile.fromPath(
//                                   'file',
//                                   _selectedFile!.path!,
//                                 ));
//                               }
//                             }
//
//                             // file1 (second)
//                             if (_selectedFile1 != null) {
//                               if (kIsWeb) {
//                                 if (_webFileBytes1 == null) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(content: Text('Second file bytes are empty (web).')));
//                                   setState(() {
//                                     _isLoading = false;
//                                     _isLoading1 = false;
//                                   });
//                                   return;
//                                 }
//                                 request.files.add(http.MultipartFile.fromBytes(
//                                   'file1',
//                                   _webFileBytes1!,
//                                   filename: _selectedFile1!.name,
//                                 ));
//                               } else {
//                                 if (_selectedFile1?.path == null) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(content: Text('Second selected file path is empty.')));
//                                   setState(() {
//                                     _isLoading = false;
//                                     _isLoading1 = false;
//                                   });
//                                   return;
//                                 }
//                                 request.files.add(await http.MultipartFile.fromPath(
//                                   'file1',
//                                   _selectedFile1!.path!,
//                                 ));
//                               }
//                             }
//
//                             var streamedResponse = await request.send();
//                             var responseString = await streamedResponse.stream.bytesToString();
//
//                             var decoded = json.decode(responseString);
//
//
//
//                             if (decoded['status'] == 'ok') {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('Registration successful!')),
//                               );
//                               Navigator.pushReplacement(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => login_page()),
//                               );
//                             } else {
//                               Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(builder: (context) => login_page()));
//                             };
//                           },
//                           child: Text("Register")),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:snap2bill/Login_page.dart';

// --- 1. DESIGN CONSTANTS (Matching Login Page) ---
class AppColors {
  // Light Mode Colors
  static const Color primaryLight = Color(0xFF4A69FF);
  static const Color backgroundLight = Color(0xFFF0F4F8);
  static const Color cardLight = Colors.white;
  static const Color textMainLight = Color(0xFF1A1D1E);
  static const Color textSubLight = Color(0xFF6A6C7B);
  static const Color inputFillLight = Color(0xFFF5F6FA);

  // Dark Mode Colors
  static const Color primaryDark = Color(0xFF5C7AE6);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color textMainDark = Color(0xFFFFFFFF);
  static const Color textSubDark = Color(0xFFAAAAAA);
  static const Color inputFillDark = Color(0xFF2C2C2C);

  // Gradients for the background blobs
  static const List<Color> blobGradient1 = [Color(0xFF4A69FF), Color(0xFF2E3F8F)];
  static const List<Color> blobGradient2 = [Color(0xFF6E85FF), Color(0xFF4A69FF)];
}

class distributor_registration extends StatefulWidget {
  const distributor_registration({Key? key}) : super(key: key);

  @override
  State<distributor_registration> createState() => _distributor_registrationState();
}

class _distributor_registrationState extends State<distributor_registration> {
  // Theme State
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // Load theme from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = (prefs.getBool('isDarkMode') ?? false) ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Toggle and save theme
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primaryLight,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primaryDark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
      ),
      home: distributor_registration_sub(
        onThemeChanged: toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class distributor_registration_sub extends StatefulWidget {
  final VoidCallback? onThemeChanged;
  final bool isDarkMode;

  const distributor_registration_sub({
    Key? key,
    this.onThemeChanged,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  State<distributor_registration_sub> createState() =>
      _distributor_registration_subState();
}

class _distributor_registration_subState
    extends State<distributor_registration_sub> {
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
  final latitude = TextEditingController();
  final longitude = TextEditingController();

  // --- FORM KEYS ---
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  // --- STATE VARIABLES ---
  int _currentStep = 0; // 0 for Basic Info, 1 for Address/Docs

  // --- FILE VARS ---
  PlatformFile? _selectedFile; // Profile Image
  Uint8List? _webFileBytes;
  String? _result;
  bool _isLoading = false;

  PlatformFile? _selectedFile1; // Other File
  Uint8List? _webFileBytes1;
  String? _result1;
  bool _isLoading1 = false;

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // --- FILE PICKER LOGIC ---
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image, // Prefer images for profile
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

  Future<void> _pickFile1() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _selectedFile1 = result.files.first;
        _result1 = null;
      });

      if (kIsWeb) {
        _webFileBytes1 = result.files.first.bytes;
      }
    }
  }

  // --- NAVIGATION LOGIC ---
  void _nextStep() {
    if (_formKeyStep1.currentState!.validate()) {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep = 0;
    });
  }

  // --- SUBMIT LOGIC ---
  Future<void> _submitRegistration() async {
    // Validate Step 2 Form
    if (!_formKeyStep2.currentState!.validate()) {
      return;
    }

    if (_selectedFile == null && _selectedFile1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile picture or document')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? ip = sh.getString('ip');

      var uri = Uri.parse('$ip/distributor_registration');
      var request = http.MultipartRequest('POST', uri);

      request.fields['name'] = name.text;
      request.fields['email'] = email.text;
      request.fields['phone'] = phone.text;
      request.fields['password'] = password.text;
      request.fields['confirmpassword'] = confirmpassword.text;
      request.fields['address'] = address.text;
      request.fields['pincode'] = pincode.text;
      request.fields['place'] = place.text;
      request.fields['post'] = post.text;
      request.fields['bio'] = bio.text;
      request.fields['latitude'] = latitude.text;
      request.fields['longitude'] = longitude.text;
      request.fields['uid'] = sh.getString('uid')?.toString() ?? '';

      // Handle File 1 (Profile)
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
          if (_selectedFile?.path != null) {
            request.files.add(await http.MultipartFile.fromPath(
              'file',
              _selectedFile!.path!,
            ));
          }
        }
      }

      // Handle File 2 (Document)
      if (_selectedFile1 != null) {
        if (kIsWeb) {
          if (_webFileBytes1 != null) {
            request.files.add(http.MultipartFile.fromBytes(
              'file1',
              _webFileBytes1!,
              filename: _selectedFile1!.name,
            ));
          }
        } else {
          if (_selectedFile1?.path != null) {
            request.files.add(await http.MultipartFile.fromPath(
              'file1',
              _selectedFile1!.path!,
            ));
          }
        }
      }

      var streamedResponse = await request.send();
      var responseString = await streamedResponse.stream.bytesToString();
      var decoded = json.decode(responseString);

      if (decoded['status'] == 'ok') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => login_page()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    final isDark = widget.isDarkMode;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final subTextColor = isDark ? AppColors.textSubDark : AppColors.textSubLight;
    final inputFill = isDark ? AppColors.inputFillDark : AppColors.inputFillLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. ABSTRACT BACKGROUND BLOBS
          Positioned(
            top: -80,
            right: -50,
            child: _buildBlob(250, AppColors.blobGradient1),
          ),
          Positioned(
            top: 100,
            left: -100,
            child: _buildBlob(200, AppColors.blobGradient2),
          ),

          // 2. TOP BAR (Back Button & Theme Toggle)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      if (_currentStep == 1) {
                        _previousStep();
                      } else {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => login_page()));
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),
                  InkWell(
                    onTap: widget.onThemeChanged,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. MAIN CONTENT SHEET
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: _currentStep == 0
                          ? _buildStep1(textColor, subTextColor, inputFill)
                          : _buildStep2(textColor, subTextColor, inputFill),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- STEP 1: PERSONAL DETAILS ---
  Widget _buildStep1(Color textColor, Color subTextColor, Color inputFill) {
    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Create Account",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              "Enter your personal details",
              style: TextStyle(color: subTextColor, fontSize: 14),
            ),
          ),
          const SizedBox(height: 30),

          // --- PROFILE PHOTO PICKER ---
          Center(
            child: GestureDetector(
              onTap: _pickFile,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: inputFill,
                    backgroundImage: _webFileBytes != null
                        ? MemoryImage(_webFileBytes!)
                        : (_selectedFile?.path != null
                        ? AssetImage("assets/placeholder.png")
                        : null) as ImageProvider?,
                    child: _selectedFile == null && _webFileBytes == null
                        ? Icon(Icons.person_add_rounded, size: 40, color: subTextColor)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // --- FORM FIELDS ---
          _buildInputField(
            name,
            "Full Name",
            Icons.person_outline,
            false, inputFill, textColor, subTextColor,
            validator: (val) => val == null || val.isEmpty ? "Name is required" : null,
          ),
          const SizedBox(height: 15),
          _buildInputField(
            email,
            "Email Address",
            Icons.email_outlined,
            false, inputFill, textColor, subTextColor,
            validator: (val) {
              if (val == null || val.isEmpty) return "Email is required";
              if (!val.contains('@') || !val.contains('.')) return "Invalid email";
              return null;
            },
          ),
          const SizedBox(height: 15),
          _buildInputField(
              phone,
              "Phone Number",
              Icons.phone_android_rounded,
              false, inputFill, textColor, subTextColor,
              keyboardType: TextInputType.phone,
              validator: (val) {
                if (val == null || val.isEmpty) return "Phone is required";
                if (val.length < 10) return "Invalid phone number";
                return null;
              }
          ),

          const SizedBox(height: 15),
          _buildInputField(
            password,
            "Password",
            Icons.lock_outline,
            true, inputFill, textColor, subTextColor,
            isPass: true,
            validator: (val) {
              if (val == null || val.isEmpty) return "Password is required";
              if (val.length <= 8) return "Must be more than 8 characters";
              if (!val.contains(RegExp(r'[A-Z]'))) return "Must have an uppercase letter";
              if (!val.contains(RegExp(r'[a-z]'))) return "Must have a lowercase letter";
              if (!val.contains(RegExp(r'[0-9]'))) return "Must have a number";
              return null;
            },
          ),
          const SizedBox(height: 15),
          _buildInputField(
            confirmpassword,
            "Confirm Password",
            Icons.lock_outline,
            true, inputFill, textColor, subTextColor,
            isPass: true,
            isConfirm: true,
            validator: (val) => val != password.text ? "Passwords do not match" : null,
          ),

          const SizedBox(height: 40),

          // --- NEXT BUTTON ---
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                shadowColor: AppColors.primaryLight.withOpacity(0.4),
              ),
              onPressed: _nextStep,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Next Step",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // --- SOCIAL SIGN UP ---
          Row(
            children: [
              Expanded(child: Divider(color: subTextColor.withOpacity(0.3))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "or sign up with",
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: subTextColor.withOpacity(0.3))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialBtn(Icons.g_mobiledata, Colors.red),
              const SizedBox(width: 20),
              _buildSocialBtn(Icons.facebook, Colors.blue),
              const SizedBox(width: 20),
              _buildSocialBtn(Icons.apple, textColor),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- STEP 2: ADDRESS & DOCUMENTS ---
  Widget _buildStep2(Color textColor, Color subTextColor, Color inputFill) {
    return Form(
      key: _formKeyStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Details & Documents",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              "Complete your profile",
              style: TextStyle(color: subTextColor, fontSize: 14),
            ),
          ),
          const SizedBox(height: 30),

          // --- ADDRESS FIELDS ---
          _buildSectionTitle("Address Details", textColor),
          const SizedBox(height: 15),
          _buildInputField(address, "Address", Icons.home_outlined, false, inputFill, textColor, subTextColor, validator: (v) => v!.isEmpty ? "Required" : null),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildInputField(pincode, "Pincode", Icons.pin_drop_outlined, false, inputFill, textColor, subTextColor, keyboardType: TextInputType.number, validator: (v) => v!.length < 4 ? "Invalid" : null)),
              const SizedBox(width: 15),
              Expanded(child: _buildInputField(post, "Post", Icons.local_post_office_outlined, false, inputFill, textColor, subTextColor, validator: (v) => v!.isEmpty ? "Required" : null)),
            ],
          ),
          const SizedBox(height: 15),
          _buildInputField(place, "Place", Icons.map_outlined, false, inputFill, textColor, subTextColor, validator: (v) => v!.isEmpty ? "Required" : null),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildInputField(latitude, "Latitude", Icons.location_on_outlined, false, inputFill, textColor, subTextColor)),
              const SizedBox(width: 15),
              Expanded(child: _buildInputField(longitude, "Longitude", Icons.location_on_outlined, false, inputFill, textColor, subTextColor)),
            ],
          ),

          const SizedBox(height: 25),
          _buildSectionTitle("Bio & Documents", textColor),
          const SizedBox(height: 15),
          _buildInputField(bio, "Bio / Description", Icons.description_outlined, false, inputFill, textColor, subTextColor, maxLines: 3),

          const SizedBox(height: 20),

          // --- SECOND FILE UPLOAD ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: inputFill,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: subTextColor.withOpacity(0.2), style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(Icons.upload_file, color: subTextColor, size: 30),
                const SizedBox(height: 8),
                Text("Upload Additional Document", style: TextStyle(color: subTextColor, fontSize: 13)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickFile1,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                    foregroundColor: AppColors.primaryLight,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(_selectedFile1 != null ? "Change File" : "Choose File"),
                ),
                if (_selectedFile1 != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(_selectedFile1!.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // --- SUBMIT BUTTON ---
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                shadowColor: AppColors.primaryLight.withOpacity(0.4),
              ),
              onPressed: _isLoading ? null : _submitRegistration,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "Submit Registration",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller,
      String label,
      IconData icon,
      bool isObscure,
      Color fillColor,
      Color textColor,
      Color hintColor, {
        bool isPass = false,
        bool isConfirm = false,
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPass
            ? (isConfirm ? _obscureConfirm : _obscurePass)
            : false,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: hintColor, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.primaryLight, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: isPass
              ? IconButton(
            icon: Icon(
              (isConfirm ? _obscureConfirm : _obscurePass)
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: hintColor,
            ),
            onPressed: () {
              setState(() {
                if (isConfirm) {
                  _obscureConfirm = !_obscureConfirm;
                } else {
                  _obscurePass = !_obscurePass;
                }
              });
            },
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildBlob(double size, List<Color> colors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildSocialBtn(IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}