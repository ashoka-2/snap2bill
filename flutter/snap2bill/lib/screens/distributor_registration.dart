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
import 'dart:typed_data';
import 'dart:io'; // Standard import for File handling on mobile
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Import shared resources
import '../theme/colors.dart';
import '../widgets/app_button.dart';
import 'package:snap2bill/screens/Login_page.dart'; // Ensure this path matches yours

class distributor_registration extends StatefulWidget {
  const distributor_registration({Key? key}) : super(key: key);

  @override
  State<distributor_registration> createState() => _distributor_registrationState();
}

class _distributor_registrationState extends State<distributor_registration> {
  // Global Key for Form Validation
  final _formKey = GlobalKey<FormState>();

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
  // Distributor Specifics
  final latitude = TextEditingController();
  final longitude = TextEditingController();

  // --- STATE ---
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // --- FILES ---
  PlatformFile? _selectedFile; // Profile Image
  Uint8List? _webFileBytes;

  PlatformFile? _selectedFile1; // Document/Proof
  Uint8List? _webFileBytes1;

  @override
  void dispose() {
    name.dispose(); email.dispose(); phone.dispose();
    password.dispose(); confirmpassword.dispose();
    address.dispose(); pincode.dispose(); place.dispose();
    post.dispose(); bio.dispose(); latitude.dispose(); longitude.dispose();
    super.dispose();
  }

  // --- FILE PICKERS ---
  Future<void> _pickProfileImage() async {
    try {
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
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );
      if (result != null) {
        setState(() {
          _selectedFile1 = result.files.first;
          if (kIsWeb) _webFileBytes1 = result.files.first.bytes;
        });
      }
    } catch (e) {
      debugPrint("Error picking doc: $e");
    }
  }

  // --- REGISTRATION LOGIC ---
  Future<void> _register() async {
    // 1. TRIGGER FORM VALIDATION
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
      return;
    }

    // 2. EXTRA CHECKS
    if (password.text != confirmpassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    // Require at least the profile image (File 1)
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a profile image')));
      return;
    }

    // Require Document (File 2)
    if (_selectedFile1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload a proof document')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? "http://10.0.2.2:8000";

      var uri = Uri.parse('$ip/distributor_registration');
      var request = http.MultipartRequest('POST', uri);

      // Fields (Added .trim() to everything)
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
      request.fields['latitude'] = latitude.text.trim();
      request.fields['longitude'] = longitude.text.trim();
      request.fields['uid'] = sh.getString('uid')?.toString() ?? '';

      // File 1 (Profile)
      if (kIsWeb && _webFileBytes != null) {
        request.files.add(http.MultipartFile.fromBytes('file', _webFileBytes!, filename: _selectedFile!.name));
      } else if (_selectedFile?.path != null) {
        request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path!));
      }

      // File 2 (Document)
      if (kIsWeb && _webFileBytes1 != null) {
        request.files.add(http.MultipartFile.fromBytes('file1', _webFileBytes1!, filename: _selectedFile1!.name));
      } else if (_selectedFile1?.path != null) {
        request.files.add(await http.MultipartFile.fromPath('file1', _selectedFile1!.path!));
      }

      var streamedResponse = await request.send();
      var responseString = await streamedResponse.stream.bytesToString();

      if (!mounted) return;

      if (streamedResponse.statusCode == 200) {
        var decoded = json.decode(responseString);
        if (decoded['status'] == 'ok') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Distributor Registered Successfully!')));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => login_page()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration Failed')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server Error: ${streamedResponse.statusCode}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
      // 1. Extend Body so AppBar floats over blobs
      extendBodyBehindAppBar: true,

      // 2. AppBar with Back Button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15, top: 8, bottom: 8),
          child: InkWell(
            onTap: () {
              // Move back to login page
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => login_page()));
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          // 3. ABSTRACT BLOBS
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

          // 4. MAIN FORM
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                "Distributor Registration",
                                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // --- PROFILE IMAGE PICKER ---
                            Center(
                              child: GestureDetector(
                                onTap: _pickProfileImage,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                      color: theme.inputDecorationTheme.fillColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
                                      image: (_selectedFile != null || _webFileBytes != null)
                                          ? DecorationImage(
                                          image: kIsWeb
                                              ? MemoryImage(_webFileBytes!) as ImageProvider
                                              : FileImage(File(_selectedFile!.path!)),
                                          fit: BoxFit.cover
                                      )
                                          : null
                                  ),
                                  child: (_selectedFile == null && _webFileBytes == null)
                                      ? Icon(Icons.person_add, size: 40, color: theme.disabledColor)
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(child: Text("Tap to add profile picture", style: theme.textTheme.bodySmall)),
                            const SizedBox(height: 30),

                            // --- SECTION 1: PERSONAL INFO ---
                            Text("Personal Details", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),

                            _buildTextField(name, "Name", Icons.abc, theme,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return "Name is required";
                                  if (val.trim().length < 3) return "Min 3 chars required";
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            _buildTextField(email, "Email", Icons.email_outlined, theme,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return "Email is required";
                                  if (!val.contains('@') || !val.contains('.')) return "Enter valid email";
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            _buildTextField(phone, "Phone Number", Icons.phone_android, theme,
                                isNumber: true,
                                maxLength: 10,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return "Phone is required";
                                  if (val.length != 10) return "Must be exactly 10 digits";
                                  if (!RegExp(r'^[0-9]+$').hasMatch(val)) return "Only numbers allowed";
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            _buildPasswordField(password, "Password", theme, false,
                                validator: (val) {
                                  if (val == null || val.isEmpty) return "Required";
                                  if (!val.contains(RegExp(r'[A-Z]'))) return "Need Uppercase letter";
                                  if (!val.contains(RegExp(r'[a-z]'))) return "Need Lowercase letter";
                                  if (!val.contains(RegExp(r'[0-9]'))) return "Need Number";
                                  return null;
                                }
                            ),
                            const SizedBox(height: 15),

                            _buildPasswordField(confirmpassword, "Confirm Password", theme, true,
                                validator: (val) {
                                  if (val == null || val.isEmpty) return "Confirm your password";
                                  if (val != password.text) return "Passwords do not match";
                                  return null;
                                }
                            ),

                            const SizedBox(height: 25),
                            const Divider(),
                            const SizedBox(height: 15),

                            // --- SECTION 2: ADDRESS INFO ---
                            Text("Address Details", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),

                            _buildTextField(address, "Address", Icons.location_city, theme,
                                validator: (val) => (val == null || val.trim().isEmpty) ? "Address required" : null
                            ),
                            const SizedBox(height: 15),

                            Row(
                              children: [
                                Expanded(child: _buildTextField(pincode, "Pincode", Icons.pin_drop, theme,
                                    isNumber: true,
                                    maxLength: 6,
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) return "Required";
                                      if (val.length != 6) return "Must be 6 digits";
                                      if (!RegExp(r'^[0-9]+$').hasMatch(val)) return "Numbers only";
                                      return null;
                                    }
                                )),
                                const SizedBox(width: 10),
                                Expanded(child: _buildTextField(post, "Post", Icons.local_post_office, theme,
                                    validator: (val) => (val == null || val.trim().isEmpty) ? "Required" : null
                                )),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(place, "Place", Icons.place, theme,
                                validator: (val) => (val == null || val.trim().isEmpty) ? "Required" : null
                            ),

                            const SizedBox(height: 25),

                            // --- SECTION 3: LOCATION ---
                            Text("Location Coordinates", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(child: _buildTextField(latitude, "Latitude", Icons.gps_fixed, theme,
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) return "Required";
                                      if (double.tryParse(val) == null) return "Invalid";
                                      return null;
                                    }
                                )),
                                const SizedBox(width: 10),
                                Expanded(child: _buildTextField(longitude, "Longitude", Icons.gps_fixed, theme,
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) return "Required";
                                      if (double.tryParse(val) == null) return "Invalid";
                                      return null;
                                    }
                                )),
                              ],
                            ),

                            const SizedBox(height: 25),
                            const Divider(),
                            const SizedBox(height: 15),

                            // --- SECTION 4: DOCUMENTS ---
                            _buildTextField(bio, "Bio / Description", Icons.description, theme, maxLines: 3,
                                validator: (val) => (val == null || val.trim().isEmpty) ? "Bio required" : null
                            ),
                            const SizedBox(height: 20),

                            // Document Picker Box
                            GestureDetector(
                              onTap: _pickDocument,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                    color: theme.inputDecorationTheme.fillColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: _selectedFile1 != null ? theme.primaryColor : Colors.transparent
                                    )
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                        _selectedFile1 != null ? Icons.check_circle_outline : Icons.upload_file,
                                        color: _selectedFile1 != null ? theme.primaryColor : theme.disabledColor,
                                        size: 30
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _selectedFile1 != null ? _selectedFile1!.name : "Upload Proof / Document",
                                      style: TextStyle(
                                          color: _selectedFile1 != null ? theme.primaryColor : theme.disabledColor
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            AppButton(
                              text: "Register Distributor",
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

  // --- HELPERS ---

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
      keyboardType: keyboardType ?? (isNumber ? TextInputType.number : TextInputType.text),
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        counterText: "",
        prefixIcon: Icon(icon, color: AppColors.iconColor, size: 22),
      ),
    );
  }

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
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.iconColor, size: 22),
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