// // import 'dart:convert';
// //
// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:snap2bill/Login_page.dart';
// //
// // import 'package:file_picker/file_picker.dart';
// // import 'package:flutter/foundation.dart'; // kIsWeb
// // import 'dart:typed_data';
// //
// //
// //
// //
// //
// // class distributor_registration extends StatelessWidget {
// //   const distributor_registration({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return const distributor_registration_sub();
// //   }
// // }
// //
// // class distributor_registration_sub extends StatefulWidget {
// //   const distributor_registration_sub({Key? key}) : super(key: key);
// //
// //   @override
// //   State<distributor_registration_sub> createState() =>
// //       _distributor_registration_subState();
// // }
// //
// // class _distributor_registration_subState
// //     extends State<distributor_registration_sub> {
// //   final name = new TextEditingController();
// //   final email = new TextEditingController();
// //   final phone = new TextEditingController();
// //   final password = new TextEditingController();
// //   final confirmpassword = new TextEditingController();
// //   final address = new TextEditingController();
// //   final pincode = new TextEditingController();
// //   final place = new TextEditingController();
// //   final post = new TextEditingController();
// //   final bio = new TextEditingController();
// //   final latitude = new TextEditingController();
// //   final longitude = new TextEditingController();
// //
// //   PlatformFile? _selectedFile;
// //   Uint8List? _webFileBytes;
// //   String? _result;
// //   bool _isLoading = false;
// //
// //   PlatformFile? _selectedFile1;
// //   Uint8List? _webFileBytes1;
// //   String? _result1;
// //   bool _isLoading1 = false;
// //
// //   // =====================================================
// //   // 📸 PICK FILE FUNCTION
// //   // =====================================================
// //   Future<void> _pickFile() async {
// //     FilePickerResult? result = await FilePicker.platform.pickFiles(
// //       allowMultiple: false,
// //       type: FileType.any, // Any file type allowed
// //     );
// //
// //     if (result != null) {
// //       setState(() {
// //         _selectedFile = result.files.first;
// //         _result = null;
// //       });
// //
// //       if (kIsWeb) {
// //         _webFileBytes = result.files.first.bytes;
// //       }
// //     }
// //   }
// //
// //   Future<void> _pickFile1() async {
// //     FilePickerResult? result = await FilePicker.platform.pickFiles(
// //       allowMultiple: false,
// //       type: FileType.any, // Any file type allowed
// //     );
// //
// //     if (result != null) {
// //       setState(() {
// //         _selectedFile1 = result.files.first;
// //         _result1 = null;
// //       });
// //
// //       if (kIsWeb) {
// //         _webFileBytes1 = result.files.first.bytes;
// //       }
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         centerTitle: true,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
// //           onPressed: () {
// //             if (Navigator.canPop(context)) Navigator.pop(context);
// //           },
// //         ),
// //         title: const Text(
// //           "Distribution registration",
// //           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
// //         ),
// //       ),
// //
// //       // backgroundColor: Colors.cyan,
// //       body: SingleChildScrollView(
// //         child: Center(
// //           child: SizedBox(
// //             child: Padding(
// //               padding: EdgeInsets.all(10),
// //               child: Container(
// //                 width: 400,
// //                 // height: 1000,
// //                 decoration: BoxDecoration(
// //                     color: Colors.green.shade100,
// //                     borderRadius: BorderRadius.circular(21)),
// //                 child: Padding(
// //                   padding:
// //                   const EdgeInsets.only(left: 10, top: 20, right: 10, bottom: 15),
// //                   child: Column(
// //                     children: [
// //                       ElevatedButton.icon(
// //                         icon: Icon(Icons.upload_file),
// //                         label: Text("Select File"),
// //                         onPressed: _pickFile,
// //                       ),
// //                       if (_selectedFile != null) ...[
// //                         SizedBox(height: 10),
// //                         Text("Selected: ${_selectedFile!.name}"),
// //                       ],
// //                       SizedBox(
// //                         height: 10,
// //                       ),
// //                       TextField(
// //                         controller: name,
// //                         decoration: InputDecoration(
// //                           hintText: 'Enter your name ',
// //                           labelText: 'Name',
// //                           prefixIcon: Icon(Icons.abc_rounded),
// //                           filled: true,
// //                           fillColor: Colors.white70,
// //                           border: OutlineInputBorder(),
// //                         ),
// //                       ),
// //                       SizedBox(
// //                         height: 10,
// //                       ),
// //                       TextField(
// //                         controller: email,
// //                         decoration: InputDecoration(
// //                             hintText: 'Enter your Email',
// //                             labelText: 'Email',
// //                             prefixIcon: Icon(Icons.email_outlined),
// //                             border: OutlineInputBorder()),
// //                       ),
// //                       SizedBox(
// //                         height: 10,
// //                       ),
// //                       TextField(
// //                         controller: phone,
// //                         keyboardType: TextInputType.number,
// //                         decoration: InputDecoration(
// //                           hintText: 'Enter your number',
// //                           labelText: 'Phone Number',
// //                           prefixIcon: Icon(Icons.phone_android),
// //                           border: OutlineInputBorder(),
// //                         ),
// //                       ),
// //                       SizedBox(
// //                         height: 10,
// //                       ),
// //                       TextField(
// //                         controller: password,
// //                         decoration: InputDecoration(
// //                           hintText: "Enter password",
// //                           labelText: 'Password',
// //                           prefixIcon: Icon(Icons.password),
// //                           border: OutlineInputBorder(),
// //                         ),
// //                       ),
// //                       SizedBox(
// //                         height: 10,
// //                       ),
// //                       TextField(
// //                         controller: confirmpassword,
// //                         decoration: InputDecoration(
// //                           hintText: "Enter password",
// //                           labelText: 'Confirm Password',
// //                           prefixIcon: Icon(Icons.password),
// //                           border: OutlineInputBorder(),
// //                         ),
// //                       ),
// //                       SizedBox(
// //                         height: 10,
// //                       ),
// //                       TextField(
// //                         controller: address,
// //                         decoration: InputDecoration(
// //                             hintText: 'Enter your Address',
// //                             labelText: 'Address',
// //                             prefixIcon: Icon(Icons.location_city),
// //                             border: OutlineInputBorder()),
// //                       ),
// //                       SizedBox(
// //                         height: 10,
// //                       ),
// //                       TextField(
// //                         controller: pincode,
// //                         keyboardType: TextInputType.number,
// //                         decoration: InputDecoration(
// //                             hintText: 'Enter your pincode',
// //                             labelText: 'Pincode',
// //                             prefixIcon: Icon(Icons.location_on_sharp),
// //                             border: OutlineInputBorder()),
// //                       ),
// //                       SizedBox(
// //                         height: 10,
// //                       ),
// //                       TextField(
// //                         controller: place,
// //                         decoration: InputDecoration(
// //                             hintText: 'Enter your Place',
// //                             labelText: 'Place',
// //                             prefixIcon: Icon(Icons.place),
// //                             border: OutlineInputBorder()),
// //                       ),
// //                       SizedBox(
// //                         height: 10,
// //                       ),
// //                       TextField(
// //                         controller: post,
// //                         decoration: InputDecoration(
// //                             hintText: 'Enter your post',
// //                             labelText: 'Post',
// //                             prefixIcon: Icon(Icons.place_sharp),
// //                             border: OutlineInputBorder()),
// //                       ),
// //                       SizedBox(
// //                         height: 10,
// //                       ),
// //                       TextField(
// //                         controller: bio,
// //                         decoration: InputDecoration(
// //                             hintText: 'Enter description',
// //                             labelText: 'Bio',
// //                             prefixIcon: Icon(Icons.abc_sharp),
// //                             border: OutlineInputBorder()),
// //                       ),
// //                       SizedBox(
// //                         height: 10,
// //                       ),
// //                       TextField(
// //                         controller: latitude,
// //                         decoration: InputDecoration(
// //                             hintText: 'Enter your Latitude',
// //                             labelText: 'Latitude',
// //                             prefixIcon: Icon(Icons.abc_sharp),
// //                             border: OutlineInputBorder()),
// //                       ),
// //                       SizedBox(
// //                         height: 10,
// //                       ),
// //                       TextField(
// //                         controller: longitude,
// //                         decoration: InputDecoration(
// //                             hintText: 'Enter your Longitude',
// //                             labelText: 'Longitude',
// //                             prefixIcon: Icon(Icons.abc_sharp),
// //                             border: OutlineInputBorder()),
// //                       ),
// //                       SizedBox(height: 10),
// //                       ElevatedButton.icon(
// //                         icon: Icon(Icons.upload_file),
// //                         label: Text("Select File"),
// //                         onPressed: _pickFile1,
// //                       ),
// //                       if (_selectedFile1 != null) ...[
// //                         SizedBox(height: 10),
// //                         Text("Selected: ${_selectedFile1!.name}"),
// //                       ],
// //                       SizedBox(
// //                         height: 10,
// //                       ),
// //                       ElevatedButton(
// //                           onPressed: () async {
// //
// //                             if (_selectedFile == null && _selectedFile1 == null) {
// //                               ScaffoldMessenger.of(context).showSnackBar(
// //                                 SnackBar(content: Text('Please select at least one file first')),
// //                               );
// //                               return;
// //                             }
// //
// //                             SharedPreferences sh = await SharedPreferences.getInstance();
// //                             String? ip = sh.getString('ip');
// //
// //
// //
// //                             var uri = Uri.parse('$ip/distributor_registration');
// //                             var request = http.MultipartRequest('POST', uri);
// //
// //                             // 🔹 Normal Form Data
// //                             request.fields['name'] = name.text;
// //                             request.fields['email'] = email.text;
// //                             request.fields['phone'] = phone.text;
// //                             request.fields['password'] = password.text;
// //                             request.fields['confirmpassword'] = confirmpassword.text;
// //                             request.fields['address'] = address.text;
// //                             request.fields['pincode'] = pincode.text;
// //                             request.fields['place'] = place.text;
// //                             request.fields['post'] = post.text;
// //                             request.fields['bio'] = bio.text;
// //                             request.fields['latitude'] = latitude.text;
// //                             request.fields['longitude'] = longitude.text;
// //
// //                             request.fields['uid'] = sh.getString('uid')?.toString() ?? '';
// //
// //
// //                             if (_selectedFile != null) {
// //                               if (kIsWeb) {
// //                                 if (_webFileBytes == null) {
// //                                   ScaffoldMessenger.of(context).showSnackBar(
// //                                       SnackBar(content: Text('First file bytes are empty (web).')));
// //                                   setState(() {
// //                                     _isLoading = false;
// //                                     _isLoading1 = false;
// //                                   });
// //                                   return;
// //                                 }
// //                                 request.files.add(http.MultipartFile.fromBytes(
// //                                   'file',
// //                                   _webFileBytes!,
// //                                   filename: _selectedFile!.name,
// //                                 ));
// //                               } else {
// //                                 if (_selectedFile?.path == null) {
// //                                   ScaffoldMessenger.of(context).showSnackBar(
// //                                       SnackBar(content: Text('First selected file path is empty.')));
// //                                   setState(() {
// //                                     _isLoading = false;
// //                                     _isLoading1 = false;
// //                                   });
// //                                   return;
// //                                 }
// //                                 request.files.add(await http.MultipartFile.fromPath(
// //                                   'file',
// //                                   _selectedFile!.path!,
// //                                 ));
// //                               }
// //                             }
// //
// //                             // file1 (second)
// //                             if (_selectedFile1 != null) {
// //                               if (kIsWeb) {
// //                                 if (_webFileBytes1 == null) {
// //                                   ScaffoldMessenger.of(context).showSnackBar(
// //                                       SnackBar(content: Text('Second file bytes are empty (web).')));
// //                                   setState(() {
// //                                     _isLoading = false;
// //                                     _isLoading1 = false;
// //                                   });
// //                                   return;
// //                                 }
// //                                 request.files.add(http.MultipartFile.fromBytes(
// //                                   'file1',
// //                                   _webFileBytes1!,
// //                                   filename: _selectedFile1!.name,
// //                                 ));
// //                               } else {
// //                                 if (_selectedFile1?.path == null) {
// //                                   ScaffoldMessenger.of(context).showSnackBar(
// //                                       SnackBar(content: Text('Second selected file path is empty.')));
// //                                   setState(() {
// //                                     _isLoading = false;
// //                                     _isLoading1 = false;
// //                                   });
// //                                   return;
// //                                 }
// //                                 request.files.add(await http.MultipartFile.fromPath(
// //                                   'file1',
// //                                   _selectedFile1!.path!,
// //                                 ));
// //                               }
// //                             }
// //
// //                             var streamedResponse = await request.send();
// //                             var responseString = await streamedResponse.stream.bytesToString();
// //
// //                             var decoded = json.decode(responseString);
// //
// //
// //
// //                             if (decoded['status'] == 'ok') {
// //                               ScaffoldMessenger.of(context).showSnackBar(
// //                                 SnackBar(content: Text('Registration successful!')),
// //                               );
// //                               Navigator.pushReplacement(
// //                                 context,
// //                                 MaterialPageRoute(builder: (context) => login_page()),
// //                               );
// //                             } else {
// //                               Navigator.pushReplacement(
// //                                   context,
// //                                   MaterialPageRoute(builder: (context) => login_page()));
// //                             };
// //                           },
// //                           child: Text("Register")),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:flutter/foundation.dart'; // for kIsWeb
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:snap2bill/screens/Login_page.dart';
//
// // Import your custom files
// import '../theme/colors.dart';
// import '../widgets/app_button.dart'; // Ensure AppButton is imported
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
//
//   // --- FORM KEYS ---
//   final GlobalKey<FormState> _formKeyPage1 = GlobalKey<FormState>();
//   final GlobalKey<FormState> _formKeyPage2 = GlobalKey<FormState>();
//   final GlobalKey<FormState> _formKeyPage3 = GlobalKey<FormState>();
//   final GlobalKey<FormState> _formKeyPage4 = GlobalKey<FormState>();
//
//   // --- CONTROLLERS ---
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
//   // --- STATE VARIABLES ---
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   bool _isLoading = false;
//   final int _totalPages = 4;
//
//   // Password Visibility Toggles
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//
//   // --- FILES ---
//   PlatformFile? _selectedFile;
//   Uint8List? _webFileBytes;
//   PlatformFile? _selectedFile1;
//   Uint8List? _webFileBytes1;
//
//   // --- FILE PICKERS ---
//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.any);
//     if (result != null) {
//       setState(() {
//         _selectedFile = result.files.first;
//         if (kIsWeb) _webFileBytes = result.files.first.bytes;
//       });
//     }
//   }
//
//   Future<void> _pickFile1() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.any);
//     if (result != null) {
//       setState(() {
//         _selectedFile1 = result.files.first;
//         if (kIsWeb) _webFileBytes1 = result.files.first.bytes;
//       });
//     }
//   }
//
//   // --- NAVIGATION ---
//   void _nextPage() {
//     bool isValid = false;
//     switch (_currentPage) {
//       case 0: isValid = _formKeyPage1.currentState!.validate(); break;
//       case 1: isValid = _formKeyPage2.currentState!.validate(); break;
//       case 2:
//         bool bioValid = _formKeyPage3.currentState!.validate();
//         if (bioValid) {
//           if (_selectedFile == null) { _showError("Upload Profile Image"); return; }
//           if (_selectedFile1 == null) { _showError("Upload Proof Document"); return; }
//           isValid = true;
//         }
//         break;
//       case 3: return;
//     }
//
//     if (isValid) {
//       _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
//       setState(() => _currentPage++);
//     } else {
//       _showError("Please fill the details !");
//     }
//   }
//
//   void _prevPage() {
//     _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
//     setState(() => _currentPage--);
//   }
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
//     );
//   }
//
//   // --- REGISTRATION ---
//   Future<void> _register() async {
//     if (!_formKeyPage4.currentState!.validate()) return;
//     if (password.text != confirmpassword.text) { _showError("Passwords do not match."); return; }
//
//     setState(() => _isLoading = true);
//
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String? ip = sh.getString('ip');
//       String? uid = sh.getString('uid');
//
//       if(ip == null) { _showError("IP configuration missing"); setState(() => _isLoading = false); return; }
//
//       var uri = Uri.parse('$ip/distributor_registration');
//       var request = http.MultipartRequest('POST', uri);
//
//       request.fields['name'] = name.text;
//       request.fields['email'] = email.text;
//       request.fields['phone'] = "+91${phone.text}";
//       request.fields['password'] = password.text;
//       request.fields['confirmpassword'] = confirmpassword.text;
//       request.fields['address'] = address.text;
//       request.fields['pincode'] = pincode.text;
//       request.fields['place'] = place.text;
//       request.fields['post'] = post.text;
//       request.fields['bio'] = bio.text;
//       request.fields['latitude'] = latitude.text;
//       request.fields['longitude'] = longitude.text;
//       request.fields['uid'] = uid ?? '';
//
//       if (_selectedFile != null) {
//         if (kIsWeb && _webFileBytes != null) {
//           request.files.add(http.MultipartFile.fromBytes('file', _webFileBytes!, filename: _selectedFile!.name));
//         } else if (_selectedFile?.path != null) {
//           request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path!));
//         }
//       }
//       if (_selectedFile1 != null) {
//         if (kIsWeb && _webFileBytes1 != null) {
//           request.files.add(http.MultipartFile.fromBytes('file1', _webFileBytes1!, filename: _selectedFile1!.name));
//         } else if (_selectedFile1?.path != null) {
//           request.files.add(await http.MultipartFile.fromPath('file1', _selectedFile1!.path!));
//         }
//       }
//
//       var streamedResponse = await request.send();
//       var responseString = await streamedResponse.stream.bytesToString();
//
//       if(streamedResponse.statusCode == 200) {
//         var decoded = json.decode(responseString);
//         if (decoded['status'] == 'ok') {
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registered Successfully!'), backgroundColor: Colors.green));
//           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => login_page()));
//         } else {
//           _showError("Failed: ${decoded['status']}");
//         }
//       } else {
//         _showError("Server Error: ${streamedResponse.statusCode}");
//       }
//     } catch (e) {
//       _showError("Connection Error: $e");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final progressColor = theme.primaryColor;
//
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // --- HEADER ---
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//               decoration: BoxDecoration(
//                 color: theme.cardColor,
//                 boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.05), blurRadius: 10)],
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.arrow_back_ios_new, size: 20, color: theme.iconTheme.color),
//                         onPressed: () => _currentPage > 0 ? _prevPage() : Navigator.pop(context),
//                       ),
//                       Expanded(
//                         child: Center(
//                           child: Text(
//                             "Create Account",
//                             style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 40),
//                     ],
//                   ),
//                   const SizedBox(height: 15),
//                   Row(
//                     children: List.generate(_totalPages, (index) {
//                       return Expanded(
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 300),
//                           height: 6,
//                           margin: const EdgeInsets.symmetric(horizontal: 4),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(3),
//                             color: index <= _currentPage ? progressColor : theme.disabledColor.withOpacity(0.2),
//                           ),
//                         ),
//                       );
//                     }),
//                   ),
//                   const SizedBox(height: 5),
//                   Text("Step ${_currentPage + 1} of $_totalPages", style: theme.textTheme.bodySmall),
//                 ],
//               ),
//             ),
//
//             // --- PAGE VIEW ---
//             Expanded(
//               child: PageView(
//                 controller: _pageController,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: [
//                   // STEP 1: Personal
//                   _buildPageWrapper(
//                     title: "Who are you?",
//                     subtitle: "Basic details for your ID.",
//                     formKey: _formKeyPage1,
//                     children: [
//                       _buildTextField(name, "Full Name", Icons.person_outline, validator: (v) => (v!.isEmpty) ? "Name required" : null),
//                       const SizedBox(height: 15),
//                       _buildTextField(email, "Email", Icons.email_outlined, type: TextInputType.emailAddress,
//                           validator: (v) => (v!.contains('@') && v.contains('.')) ? null : "Invalid Email"
//                       ),
//                       const SizedBox(height: 15),
//                       _buildTextField(
//                           phone, "Phone Number", Icons.phone_android,
//                           type: TextInputType.phone, maxLength: 10,
//                           prefixText: "+91 ",
//                           validator: (v) => (v!.length == 10) ? null : "Enter 10 digit number"
//                       ),
//                     ],
//                   ),
//
//                   // STEP 2: Location
//                   _buildPageWrapper(
//                     title: "Location Details",
//                     subtitle: "Where can we find you?",
//                     formKey: _formKeyPage2,
//                     children: [
//                       _buildTextField(address, "Address", Icons.location_on_outlined, maxLines: 2, validator: (v) => v!.isEmpty ? "Required" : null),
//                       const SizedBox(height: 15),
//                       Row(children: [
//                         Expanded(child: _buildTextField(place, "Place", Icons.location_city, validator: (v) => v!.isEmpty ? "Required" : null)),
//                         const SizedBox(width: 10),
//                         Expanded(child: _buildTextField(pincode, "Pincode", Icons.pin, type: TextInputType.number, maxLength: 6,
//                             validator: (v) => (v!.length == 6) ? null : "Invalid Pincode")),
//                       ]),
//                       const SizedBox(height: 15),
//                       _buildTextField(post, "Post Office", Icons.local_post_office_outlined, validator: (v) => v!.isEmpty ? "Required" : null),
//                       const SizedBox(height: 15),
//                       Row(children: [
//                         Expanded(child: _buildTextField(latitude, "Latitude", Icons.gps_fixed, type: TextInputType.number)),
//                         const SizedBox(width: 10),
//                         Expanded(child: _buildTextField(longitude, "Longitude", Icons.gps_fixed, type: TextInputType.number)),
//                       ]),
//                     ],
//                   ),
//
//                   // STEP 3: Files
//                   _buildPageWrapper(
//                     title: "Distributor Info",
//                     subtitle: "Upload your proofs.",
//                     formKey: _formKeyPage3,
//                     children: [
//                       _buildTextField(bio, "Bio", Icons.description_outlined, maxLines: 3, validator: (v) => v!.isEmpty ? "Required" : null),
//                       const SizedBox(height: 25),
//                       Text("Documents", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 10),
//                       _buildFileCard("Profile Image", _selectedFile, _pickFile, theme),
//                       const SizedBox(height: 15),
//                       _buildFileCard("Proof Document", _selectedFile1, _pickFile1, theme),
//                     ],
//                   ),
//
//                   // STEP 4: Password
//                   _buildPageWrapper(
//                     title: "Security",
//                     subtitle: "Set your password.",
//                     formKey: _formKeyPage4,
//                     children: [
//                       _buildTextField(
//                           password,
//                           "Password",
//                           Icons.lock_outline,
//                           obscureText: _obscurePassword,
//                           validator: (val) {
//                             if (val == null || val.isEmpty) return "Password is required";
//                             if (val.length < 8) return "Min 8 characters required";
//                             if (!RegExp(r'(?=.*[A-Z])').hasMatch(val)) return "One Uppercase required";
//                             if (!RegExp(r'(?=.*[0-9])').hasMatch(val)) return "One Number required";
//                             return null; // Valid
//                           },
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                               color: AppColors.iconColor,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 _obscurePassword = !_obscurePassword;
//                               });
//                             },
//                           )
//                       ),
//
//                       const SizedBox(height: 20),
//
//                       _buildTextField(
//                           confirmpassword,
//                           "Confirm Password",
//                           Icons.lock,
//                           obscureText: _obscureConfirmPassword,
//                           validator: (v) => v != password.text ? "Passwords do not match" : null,
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
//                               color: AppColors.iconColor,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 _obscureConfirmPassword = !_obscureConfirmPassword;
//                               });
//                             },
//                           )
//                       ),
//
//                       const SizedBox(height: 40),
//                       AppButton(
//                         text: "COMPLETE REGISTRATION",
//                         isLoading: _isLoading,
//                         onPressed: _register,
//                         color: AppColors.buttonColor,
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             // --- BOTTOM NAVIGATION ---
//             if (_currentPage < _totalPages - 1)
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 color: theme.cardColor,
//                 child: AppButton(
//                   text: "Next Step",
//                   onPressed: _nextPage,
//                   color: AppColors.buttonColor,
//                   isTrailingIcon: true,
//                   icon: Icons.arrow_forward,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // --- WIDGETS ---
//
//   Widget _buildPageWrapper({required String title, required String subtitle, required List<Widget> children, required GlobalKey<FormState> formKey}) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Form(
//         key: formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 5),
//             Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSubLight)),
//             const SizedBox(height: 30),
//             ...children,
//             const SizedBox(height: 100),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {
//     bool obscureText = false,
//     TextInputType type = TextInputType.text,
//     int maxLines = 1,
//     int? maxLength,
//     String? prefixText,
//     Widget? suffixIcon,
//     String? Function(String?)? validator
//   }) {
//     return TextFormField(
//       controller: ctrl,
//       obscureText: obscureText,
//       keyboardType: type,
//       maxLines: maxLines,
//       maxLength: maxLength,
//       validator: validator,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: AppColors.iconColor, size: 20),
//         prefixText: prefixText,
//         suffixIcon: suffixIcon,
//         counterText: "",
//       ),
//     );
//   }
//
//   Widget _buildFileCard(String title, PlatformFile? file, VoidCallback onTap, ThemeData theme) {
//     bool hasFile = file != null;
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//             color: theme.cardColor,
//             border: Border.all(color: hasFile ? AppColors.primaryLight : theme.dividerColor),
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               if(hasFile) BoxShadow(color: AppColors.primaryLight.withOpacity(0.1), blurRadius: 8)
//             ]
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: hasFile ? AppColors.primaryLight.withOpacity(0.1) : theme.scaffoldBackgroundColor,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 hasFile ? Icons.check_circle : Icons.upload_file,
//                 color: hasFile ? AppColors.primaryLight : theme.disabledColor,
//               ),
//             ),
//             const SizedBox(width: 15),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 4),
//                   Text(
//                     hasFile ? file.name : "Tap to upload",
//                     style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }