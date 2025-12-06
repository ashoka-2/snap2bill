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
// File: lib/screens/customer_registration.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:snap2bill/screens/Login_page.dart';

// Import shared resources
import '../theme/colors.dart';
import '../widgets/app_button.dart';

class customer_registration extends StatefulWidget {
  const customer_registration({Key? key}) : super(key: key);

  @override
  State<customer_registration> createState() => _customer_registrationState();
}

class _customer_registrationState extends State<customer_registration> {
  // Global Key for Form Validation
  final _formKey = GlobalKey<FormState>();

  // Controllers
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

  // State
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // File Picker State
  PlatformFile? _selectedFile;
  Uint8List? _webFileBytes;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    confirmpassword.dispose();
    address.dispose();
    pincode.dispose();
    place.dispose();
    post.dispose();
    bio.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          if (kIsWeb) {
            _webFileBytes = result.files.first.bytes;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _register() async {
    // 1. TRIGGER FORM VALIDATION
    if (!_formKey.currentState!.validate()) {
      // If validation fails, fields will turn red and show errors automatically.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
      return;
    }

    // 2. EXTRA CHECKS
    if (password.text != confirmpassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? "http://10.0.2.2:8000";

      var uri = Uri.parse('$ip/customer_registration');
      var request = http.MultipartRequest('POST', uri);

      // Add Fields
      request.fields['name'] = name.text.trim();
      request.fields['email'] = email.text.trim();
      request.fields['phone'] = phone.text.trim();
      request.fields['password'] = password.text.trim();
      request.fields['confirmpassword'] = confirmpassword.text.trim();
      request.fields['address'] = address.text.trim();
      request.fields['pincode'] = pincode.text.trim();
      request.fields['place'] = place.text.trim();
      request.fields['post'] = post.text.trim();
      request.fields['bio'] = bio.text.trim();
      request.fields['cid'] = sh.getString('cid')?.toString() ?? '';

      // Add File
      if (kIsWeb && _webFileBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          _webFileBytes!,
          filename: _selectedFile!.name,
        ));
      } else if (_selectedFile?.path != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _selectedFile!.path!,
        ));
      }

      var streamedResponse = await request.send();
      var responseString = await streamedResponse.stream.bytesToString();

      if (!mounted) return;

      if (streamedResponse.statusCode == 200) {
        var decoded = json.decode(responseString);
        if (decoded['status'] == 'ok') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>login_page()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Failed')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error: ${streamedResponse.statusCode}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(



      backgroundColor: theme.scaffoldBackgroundColor,
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

          // 2. TOP BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. MAIN CONTENT
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
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
                      padding: const EdgeInsets.all(24),
                      child: Form( // WRAPPED IN FORM
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                "Customer Registration",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // File Picker
                            Center(
                              child: GestureDetector(
                                onTap: _pickFile,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: theme.inputDecorationTheme.fillColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
                                  ),
                                  child: _selectedFile == null
                                      ? Icon(Icons.upload_file, size: 40, color: theme.disabledColor)
                                      : Icon(Icons.check_circle, size: 40, color: theme.primaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                _selectedFile != null ? _selectedFile!.name : "Tap to upload file",
                                style: theme.textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // --- FORM FIELDS WITH VALIDATION ---

                            // Name: At least 3 chars
                            _buildTextField(
                                name, "Name", Icons.abc, theme,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) return "Name is required";
                                  if (value.trim().length < 3) return "Name must be at least 3 characters";
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            // Email
                            _buildTextField(
                                email, "Email", Icons.email_outlined, theme,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) return "Email is required";
                                  if (!value.contains('@') || !value.contains('.')) return "Enter a valid email";
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            // Phone: EXACTLY 10 digits
                            _buildTextField(
                                phone, "Phone Number", Icons.phone_android, theme,
                                isNumber: true,
                                maxLength: 10,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) return "Phone number is required";
                                  if (value.length != 10) return "Phone number must be exactly 10 digits";
                                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) return "Only numbers allowed";
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            // Password: Upper, Lower, Number
                            _buildPasswordField(
                                password, "Password", theme, false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return "Password is required";
                                  if (!value.contains(RegExp(r'[A-Z]'))) return "Must contain uppercase letter";
                                  if (!value.contains(RegExp(r'[a-z]'))) return "Must contain lowercase letter";
                                  if (!value.contains(RegExp(r'[0-9]'))) return "Must contain a number";
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            // Confirm Password
                            _buildPasswordField(
                                confirmpassword, "Confirm Password", theme, true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return "Confirm your password";
                                  if (value != password.text) return "Passwords do not match";
                                  return null;
                                }
                            ),

                            const SizedBox(height: 25),
                            const Divider(),
                            const SizedBox(height: 15),

                            _buildTextField(
                                address, "Address", Icons.location_city, theme,
                                validator: (val) => (val == null || val.trim().isEmpty) ? "Address is required" : null
                            ),
                            const SizedBox(height: 15),

                            // Pincode: Number only, usually 6 digits for India
                            _buildTextField(
                                pincode, "Pincode", Icons.pin_drop, theme,
                                isNumber: true,
                                maxLength: 6,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return "Pincode is required";
                                  if (!RegExp(r'^[0-9]+$').hasMatch(val)) return "Only numbers allowed";
                                  if (val.length != 6) return "Pincode must be 6 digits";
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            _buildTextField(
                                place, "Place", Icons.place, theme,
                                validator: (val) => (val == null || val.trim().isEmpty) ? "Place is required" : null
                            ),
                            const SizedBox(height: 15),

                            _buildTextField(
                                post, "Post", Icons.local_post_office, theme,
                                validator: (val) => (val == null || val.trim().isEmpty) ? "Post office is required" : null
                            ),
                            const SizedBox(height: 15),

                            _buildTextField(
                                bio, "Bio", Icons.description, theme,
                                maxLines: 3,
                                validator: (val) => (val == null || val.trim().isEmpty) ? "Bio is required" : null
                            ),

                            const SizedBox(height: 40),

                            AppButton(
                              text: "Register",
                              isLoading: _isLoading,
                              onPressed: _register,
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
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

  // UPDATED: Now returns TextFormField for validation
  Widget _buildTextField(
      TextEditingController ctrl,
      String label,
      IconData icon,
      ThemeData theme,
      {
        bool isNumber = false,
        int maxLines = 1,
        int? maxLength,
        TextInputType? keyboardType,
        String? Function(String?)? validator
      }) {
    return TextFormField(
      controller: ctrl,
      // Priority: Specific keyboardType passed -> isNumber check -> Default Text
      keyboardType: keyboardType ?? (isNumber ? TextInputType.number : TextInputType.text),
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      // Auto-validate only when user interacts? or on submit. Kept default (on submit)
      decoration: InputDecoration(
        labelText: label,
        counterText: "", // Hides the tiny 0/10 character counter
        prefixIcon: Icon(icon, color: AppColors.IconColor, size: 22),
        // Style is inherited from Theme.of(context).inputDecorationTheme
      ),
    );
  }

  // UPDATED: Now returns TextFormField for validation
  Widget _buildPasswordField(
      TextEditingController ctrl,
      String label,
      ThemeData theme,
      bool isConfirm,
      {String? Function(String?)? validator}
      ) {
    return TextFormField(
      controller: ctrl,
      obscureText: isConfirm ? _obscureConfirm : _obscurePass,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.IconColor, size: 22),
        suffixIcon: IconButton(
          icon: Icon(
            (isConfirm ? _obscureConfirm : _obscurePass) ? Icons.visibility_off : Icons.visibility,
            color: theme.hintColor,
          ),
          onPressed: () {
            setState(() {
              if (isConfirm) _obscureConfirm = !_obscureConfirm;
              else _obscurePass = !_obscurePass;
            });
          },
        ),
      ),
    );
  }
}