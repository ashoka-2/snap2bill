// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Login_page.dart';
// // import 'package:snap2bill/Customerdirectory/customer_home_page.dart';
//
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart'; // kIsWeb
// import 'dart:typed_data';
//
//
//
//
//
// class customer_registration extends StatelessWidget {
//   const customer_registration({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const customer_registration_sub();
//   }
// }
//
// class customer_registration_sub extends StatefulWidget {
//   const customer_registration_sub({Key? key}) : super(key: key);
//
//   @override
//   State<customer_registration_sub> createState() => _customer_registration_subState();
// }
//
// class _customer_registration_subState extends State<customer_registration_sub> {
//   final name=new TextEditingController();
//   final email=new TextEditingController();
//   final phone=new TextEditingController();
//   final password=new TextEditingController();
//   final confirmpassword=new TextEditingController();
//   final address=new TextEditingController();
//   final pincode=new TextEditingController();
//   final place=new TextEditingController();
//   final post=new TextEditingController();
//   final bio=new TextEditingController();
//
//
//   PlatformFile? _selectedFile;
//   Uint8List? _webFileBytes;
//   String? _result;
//   bool _isLoading = false;
//
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
//
//
//
//
//
//
//
//
//
//
//
//
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
//           "Customer registration",
//           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
//         ),
//       ),
//
//
//       body: SingleChildScrollView(child: Center(
//         child: SizedBox(height: 1000 ,width: 400,
//           child: Column(children: [
//             ElevatedButton.icon(
//               icon: Icon(Icons.upload_file),
//               label: Text("Select File"),
//               onPressed: _pickFile,
//             ),
//             if (_selectedFile != null) ...[
//               SizedBox(height: 10),
//               Text("Selected: ${_selectedFile!.name}"),
//             ],
//             SizedBox(
//               height: 10,
//             ),
//
//       TextField(controller: name,
//         decoration: InputDecoration(
//           hintText:'Enter your name ',
//           labelText: 'Name',
//           prefixIcon: Icon(Icons.abc_rounded),
//           border: OutlineInputBorder()
//       ),),SizedBox(height: 10,),
//
//       TextField(controller: email,
//         decoration: InputDecoration(
//           hintText: 'Enter your Email',
//           labelText: 'Email',
//           prefixIcon: Icon(Icons.email_outlined),
//           border: OutlineInputBorder()
//       ),),SizedBox(height: 10,),
//       TextField(controller: phone,
//         decoration: InputDecoration(
//           hintText: 'Enter your number',
//           labelText: 'Phone Number',
//           prefixIcon: Icon(Icons.phone_android),
//           border: OutlineInputBorder()
//       ),),SizedBox(height: 10,),
//       TextField(controller: password,
//         decoration: InputDecoration(
//         hintText: "Enter password",
//         labelText: 'Password',
//         prefixIcon: Icon(Icons.password),
//         border: OutlineInputBorder(),
//       ),),SizedBox(height: 10,),
//       TextField(controller: confirmpassword,
//         decoration: InputDecoration(
//         hintText: "Enter password",
//         labelText: 'Confirm Password',
//         prefixIcon: Icon(Icons.password),
//         border: OutlineInputBorder(),
//       ),),SizedBox(height: 10,),
//
//
//
//       TextField(controller: address,
//         decoration: InputDecoration(
//           hintText: 'Enter your Address',
//           labelText: 'Address',
//           prefixIcon: Icon(Icons.location_city),
//           border: OutlineInputBorder()
//       ),),SizedBox(height: 10,),
//       TextField(controller: pincode,
//         decoration: InputDecoration(
//           hintText: 'Enter your pincode',
//           labelText: 'Pincode',
//           prefixIcon: Icon(Icons.location_on_sharp),
//           border: OutlineInputBorder()
//       ),),SizedBox(height: 10,),
//       TextField(controller: place,
//         decoration: InputDecoration(
//           hintText: 'Enter your Place',
//           labelText: 'Place',
//           prefixIcon: Icon(Icons.place),
//           border: OutlineInputBorder()
//       ),),SizedBox(height: 10,),
//       TextField(controller: post,
//         decoration: InputDecoration(
//           hintText: 'Enter your post',
//           labelText: 'Post',
//           prefixIcon: Icon(Icons.place_sharp),
//           border: OutlineInputBorder()
//       ),),SizedBox(height: 10,),
//       TextField(controller: bio,
//         decoration: InputDecoration(
//           hintText: 'Enter description',
//           labelText: 'Bio',
//           prefixIcon: Icon(Icons.abc_sharp),
//           border: OutlineInputBorder()
//       ),),SizedBox(height: 10,),
//             ElevatedButton(
//                 onPressed: () async {
//
//                   if (_selectedFile == null ) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Please select at least one file first')),
//                     );
//                     return;
//                   }
//
//                   SharedPreferences sh = await SharedPreferences.getInstance();
//                   String? ip = sh.getString('ip');
//
//
//
//                   var uri = Uri.parse('$ip/customer_registration');
//                   var request = http.MultipartRequest('POST', uri);
//
//                   // 🔹 Normal Form Data
//                   request.fields['name'] = name.text;
//                   request.fields['email'] = email.text;
//                   request.fields['phone'] = phone.text;
//                   request.fields['password'] = password.text;
//                   request.fields['confirmpassword'] = confirmpassword.text;
//                   request.fields['address'] = address.text;
//                   request.fields['pincode'] = pincode.text;
//                   request.fields['place'] = place.text;
//                   request.fields['post'] = post.text;
//                   request.fields['bio'] = bio.text;
//
//                   request.fields['cid'] = sh.getString('cid')?.toString() ?? '';
//
//
//                   if (_selectedFile != null) {
//                     if (kIsWeb) {
//                       if (_webFileBytes == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('First file bytes are empty (web).')));
//                         setState(() {
//                           _isLoading = false;
//                         });
//                         return;
//                       }
//                       request.files.add(http.MultipartFile.fromBytes(
//                         'file',
//                         _webFileBytes!,
//                         filename: _selectedFile!.name,
//                       ));
//                     } else {
//                       if (_selectedFile?.path == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('First selected file path is empty.')));
//                         setState(() {
//                           _isLoading = false;
//                         });
//                         return;
//                       }
//                       request.files.add(await http.MultipartFile.fromPath(
//                         'file',
//                         _selectedFile!.path!,
//                       ));
//                     }
//                   }
//
//
//                   var streamedResponse = await request.send();
//                   var responseString = await streamedResponse.stream.bytesToString();
//
//                   var decoded = json.decode(responseString);
//
//
//
//                   if (decoded['status'] == 'ok') {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Registration successful!')),
//                     );
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => login_page()),
//                     );
//                   } else {
//                     Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (context) => login_page()));
//                   };
//                 },
//                 child: Text("Register")),
//
//
//
//
//
//
//
//
//           ],),),),),);
//   }
// }
//
//
//
//
// //
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:snap2bill/Login_page.dart';
// //
// // class customer_registration extends StatelessWidget {
// //   const customer_registration({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       home: customer_registration_sub(),
// //       theme: ThemeData(primarySwatch: Colors.blue),
// //     );
// //   }
// // }
// //
// // class customer_registration_sub extends StatefulWidget {
// //   const customer_registration_sub({Key? key}) : super(key: key);
// //
// //   @override
// //   State<customer_registration_sub> createState() =>
// //       _customer_registration_subState();
// // }
// //
// // class _customer_registration_subState
// //     extends State<customer_registration_sub> {
// //   // Controllers
// //   final name = TextEditingController();
// //   final email = TextEditingController();
// //   final phone = TextEditingController();
// //   final password = TextEditingController();
// //   final confirmpassword = TextEditingController();
// //   final address = TextEditingController();
// //   final pincode = TextEditingController();
// //   final place = TextEditingController();
// //   final post = TextEditingController();
// //   final bio = TextEditingController();
// //
// //   bool _obscurePass = true;
// //   bool _obscureConfirm = true;
// //   int _currentStep = 0; // step 0 = basic info, 1 = other details
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         width: double.infinity,
// //         height: double.infinity,
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             colors: [Color(0xFF74ABE2), Color(0xFFA7E2F8)],
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //           ),
// //         ),
// //         child: Center(
// //           child: SingleChildScrollView(
// //             child: Container(
// //               width: 400,
// //               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
// //               decoration: BoxDecoration(
// //                 color: Colors.white.withOpacity(0.95),
// //                 borderRadius: BorderRadius.circular(20),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black26.withOpacity(0.15),
// //                     blurRadius: 20,
// //                     offset: const Offset(0, 10),
// //                   ),
// //                 ],
// //               ),
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Text(
// //                     "Customer Registration",
// //                     style: TextStyle(
// //                       fontSize: 22,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.blue.shade700,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 20),
// //
// //                   // STEP 1
// //                   if (_currentStep == 0) ...[
// //                     _buildTextField(name, 'Name', Icons.person_outline),
// //                     const SizedBox(height: 15),
// //                     _buildTextField(email, 'Email', Icons.email_outlined),
// //                     const SizedBox(height: 15),
// //                     _buildTextField(phone, 'Phone Number', Icons.phone_android,
// //                         inputType: TextInputType.number),
// //                     const SizedBox(height: 15),
// //                     _buildPasswordField(password, 'Password', _obscurePass, () {
// //                       setState(() {
// //                         _obscurePass = !_obscurePass;
// //                       });
// //                     }),
// //                     const SizedBox(height: 15),
// //                     _buildPasswordField(
// //                         confirmpassword, 'Confirm Password', _obscureConfirm,
// //                             () {
// //                           setState(() {
// //                             _obscureConfirm = !_obscureConfirm;
// //                           });
// //                         }),
// //                     const SizedBox(height: 25),
// //                     _nextButton("Next", () {
// //                       setState(() => _currentStep = 1);
// //                     }),
// //                   ],
// //
// //                   // STEP 2
// //                   if (_currentStep == 1) ...[
// //                     _buildTextField(address, 'Address', Icons.location_city),
// //                     const SizedBox(height: 15),
// //                     _buildTextField(pincode, 'Pincode', Icons.pin_drop,
// //                         inputType: TextInputType.number),
// //                     const SizedBox(height: 15),
// //                     _buildTextField(place, 'Place', Icons.place_outlined),
// //                     const SizedBox(height: 15),
// //                     _buildTextField(post, 'Post', Icons.local_post_office),
// //                     const SizedBox(height: 15),
// //                     _buildTextField(bio, 'Bio / Description', Icons.info),
// //                     const SizedBox(height: 25),
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         _backButton("Back", () {
// //                           setState(() => _currentStep = 0);
// //                         }),
// //                         _submitButton("Register", _registerUser),
// //                       ],
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // 🌈 Reusable TextField builder
// //   Widget _buildTextField(TextEditingController controller, String label,
// //       IconData icon,
// //       {TextInputType inputType = TextInputType.text}) {
// //     return TextField(
// //       controller: controller,
// //       keyboardType: inputType,
// //       decoration: InputDecoration(
// //         labelText: label,
// //         prefixIcon: Icon(icon, color: Colors.blueAccent),
// //         filled: true,
// //         fillColor: Colors.blue.shade50,
// //         labelStyle: const TextStyle(color: Colors.black54),
// //         border: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(12),
// //           borderSide: BorderSide.none,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // 🔐 Password field with eye icon
// //   Widget _buildPasswordField(TextEditingController controller, String label,
// //       bool obscure, VoidCallback toggle) {
// //     return TextField(
// //       controller: controller,
// //       obscureText: obscure,
// //       decoration: InputDecoration(
// //         labelText: label,
// //         prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueAccent),
// //         suffixIcon: IconButton(
// //           icon: Icon(
// //             obscure ? Icons.visibility_off : Icons.visibility,
// //             color: Colors.grey,
// //           ),
// //           onPressed: toggle,
// //         ),
// //         filled: true,
// //         fillColor: Colors.blue.shade50,
// //         border: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(12),
// //           borderSide: BorderSide.none,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // 🔘 Buttons
// //   Widget _nextButton(String text, VoidCallback onPressed) {
// //     return SizedBox(
// //       width: double.infinity,
// //       height: 50,
// //       child: ElevatedButton(
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: Colors.blue.shade600,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           elevation: 4,
// //         ),
// //         onPressed: onPressed,
// //         child: Text(text,
// //             style: const TextStyle(
// //                 color: Colors.white,
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.w600)),
// //       ),
// //     );
// //   }
// //
// //   Widget _backButton(String text, VoidCallback onPressed) {
// //     return ElevatedButton(
// //       style: ElevatedButton.styleFrom(
// //         backgroundColor: Colors.grey.shade400,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //       ),
// //       onPressed: onPressed,
// //       child: Text(text,
// //           style: const TextStyle(color: Colors.white, fontSize: 16)),
// //     );
// //   }
// //
// //   Widget _submitButton(String text, VoidCallback onPressed) {
// //     return ElevatedButton(
// //       style: ElevatedButton.styleFrom(
// //         backgroundColor: Colors.blue.shade600,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //         elevation: 4,
// //       ),
// //       onPressed: onPressed,
// //       child: Text(text,
// //           style: const TextStyle(color: Colors.white, fontSize: 16)),
// //     );
// //   }
// //
// //   // 🚀 Registration function
// //   Future<void> _registerUser() async {
// //     SharedPreferences sh = await SharedPreferences.getInstance();
// //     try {
// //       var data = await http.post(
// //         Uri.parse('${sh.getString("ip")}/customer_registration'),
// //         body: {
// //           'name': name.text,
// //           'email': email.text,
// //           'phone': phone.text,
// //           'password': password.text,
// //           'confirmpassword': confirmpassword.text,
// //           'address': address.text,
// //           'pincode': pincode.text,
// //           'place': place.text,
// //           'post': post.text,
// //           'bio': bio.text,
// //         },
// //       );
// //
// //       var decodeddata = json.decode(data.body);
// //       print(decodeddata);
// //
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Registration Successful!')),
// //       );
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(builder: (context) => login_page()),
// //       );
// //     } catch (e) {
// //       print("Registration failed: $e");
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Something went wrong!')),
// //       );
// //     }
// //   }
// // }
// //
// //
// //
// //
// //
//
//
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:snap2bill/Login_page.dart';

// --- 1. DESIGN CONSTANTS (Matching Distributor Page) ---
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

class customer_registration extends StatefulWidget {
  const customer_registration({Key? key}) : super(key: key);

  @override
  State<customer_registration> createState() => _customer_registrationState();
}

class _customer_registrationState extends State<customer_registration> {
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
      home: customer_registration_sub(
        onThemeChanged: toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class customer_registration_sub extends StatefulWidget {
  final VoidCallback? onThemeChanged;
  final bool isDarkMode;

  const customer_registration_sub({
    Key? key,
    this.onThemeChanged,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  State<customer_registration_sub> createState() => _customer_registration_subState();
}

class _customer_registration_subState extends State<customer_registration_sub> {
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

  // --- FORM KEYS ---
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  // --- STATE VARIABLES ---
  int _currentStep = 0; // 0 for Basic Info, 1 for Address
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // --- FILE VARS ---
  PlatformFile? _selectedFile;
  Uint8List? _webFileBytes;
  String? _result;

  // --- FILE PICKER LOGIC ---
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any, // Allow any as per original code, usually images for profile
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

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile file/image first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? ip = sh.getString('ip');

      var uri = Uri.parse('$ip/customer_registration');
      var request = http.MultipartRequest('POST', uri);

      // Add Fields
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

      // Usually registration creates an ID, but keeping your logic if needed
      request.fields['cid'] = sh.getString('cid')?.toString() ?? '';

      // Add File
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
        // Uncomment if you want to redirect anyway on failure
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => login_page()));
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
                          // Fallback
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
              "Customer Registration",
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
              "Join us today!",
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
          const SizedBox(height: 10),
          if (_selectedFile != null)
            Center(child: Text("File: ${_selectedFile!.name}", style: TextStyle(color: subTextColor, fontSize: 12))),

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
        ],
      ),
    );
  }

  // --- STEP 2: ADDRESS & SUBMIT ---
  Widget _buildStep2(Color textColor, Color subTextColor, Color inputFill) {
    return Form(
      key: _formKeyStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Address Details",
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
              "Tell us where you are",
              style: TextStyle(color: subTextColor, fontSize: 14),
            ),
          ),
          const SizedBox(height: 30),

          // --- ADDRESS FIELDS ---
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

          const SizedBox(height: 25),
          _buildInputField(bio, "Bio / Description", Icons.description_outlined, false, inputFill, textColor, subTextColor, maxLines: 3),

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
                "Complete Registration",
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

  // --- HELPER WIDGETS ---

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
}