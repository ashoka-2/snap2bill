import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Login_page.dart';
// import 'package:snap2bill/Customerdirectory/customer_home_page.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'dart:typed_data';





class customer_registration extends StatelessWidget {
  const customer_registration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const customer_registration_sub();
  }
}

class customer_registration_sub extends StatefulWidget {
  const customer_registration_sub({Key? key}) : super(key: key);

  @override
  State<customer_registration_sub> createState() => _customer_registration_subState();
}

class _customer_registration_subState extends State<customer_registration_sub> {
  final name=new TextEditingController();
  final email=new TextEditingController();
  final phone=new TextEditingController();
  final password=new TextEditingController();
  final confirmpassword=new TextEditingController();
  final address=new TextEditingController();
  final pincode=new TextEditingController();
  final place=new TextEditingController();
  final post=new TextEditingController();
  final bio=new TextEditingController();


  PlatformFile? _selectedFile;
  Uint8List? _webFileBytes;
  String? _result;
  bool _isLoading = false;


  // =====================================================
  // 📸 PICK FILE FUNCTION
  // =====================================================
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any, // Any file type allowed
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














  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          "Customer registration",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),


      body: SingleChildScrollView(child: Center(
        child: SizedBox(height: 1000 ,width: 400,
          child: Column(children: [
            ElevatedButton.icon(
              icon: Icon(Icons.upload_file),
              label: Text("Select File"),
              onPressed: _pickFile,
            ),
            if (_selectedFile != null) ...[
              SizedBox(height: 10),
              Text("Selected: ${_selectedFile!.name}"),
            ],
            SizedBox(
              height: 10,
            ),

      TextField(controller: name,
        decoration: InputDecoration(
          hintText:'Enter your name ',
          labelText: 'Name',
          prefixIcon: Icon(Icons.abc_rounded),
          border: OutlineInputBorder()
      ),),SizedBox(height: 10,),

      TextField(controller: email,
        decoration: InputDecoration(
          hintText: 'Enter your Email',
          labelText: 'Email',
          prefixIcon: Icon(Icons.email_outlined),
          border: OutlineInputBorder()
      ),),SizedBox(height: 10,),
      TextField(controller: phone,
        decoration: InputDecoration(
          hintText: 'Enter your number',
          labelText: 'Phone Number',
          prefixIcon: Icon(Icons.phone_android),
          border: OutlineInputBorder()
      ),),SizedBox(height: 10,),
      TextField(controller: password,
        decoration: InputDecoration(
        hintText: "Enter password",
        labelText: 'Password',
        prefixIcon: Icon(Icons.password),
        border: OutlineInputBorder(),
      ),),SizedBox(height: 10,),
      TextField(controller: confirmpassword,
        decoration: InputDecoration(
        hintText: "Enter password",
        labelText: 'Confirm Password',
        prefixIcon: Icon(Icons.password),
        border: OutlineInputBorder(),
      ),),SizedBox(height: 10,),



      TextField(controller: address,
        decoration: InputDecoration(
          hintText: 'Enter your Address',
          labelText: 'Address',
          prefixIcon: Icon(Icons.location_city),
          border: OutlineInputBorder()
      ),),SizedBox(height: 10,),
      TextField(controller: pincode,
        decoration: InputDecoration(
          hintText: 'Enter your pincode',
          labelText: 'Pincode',
          prefixIcon: Icon(Icons.location_on_sharp),
          border: OutlineInputBorder()
      ),),SizedBox(height: 10,),
      TextField(controller: place,
        decoration: InputDecoration(
          hintText: 'Enter your Place',
          labelText: 'Place',
          prefixIcon: Icon(Icons.place),
          border: OutlineInputBorder()
      ),),SizedBox(height: 10,),
      TextField(controller: post,
        decoration: InputDecoration(
          hintText: 'Enter your post',
          labelText: 'Post',
          prefixIcon: Icon(Icons.place_sharp),
          border: OutlineInputBorder()
      ),),SizedBox(height: 10,),
      TextField(controller: bio,
        decoration: InputDecoration(
          hintText: 'Enter description',
          labelText: 'Bio',
          prefixIcon: Icon(Icons.abc_sharp),
          border: OutlineInputBorder()
      ),),SizedBox(height: 10,),
            ElevatedButton(
                onPressed: () async {

                  if (_selectedFile == null ) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select at least one file first')),
                    );
                    return;
                  }

                  SharedPreferences sh = await SharedPreferences.getInstance();
                  String? ip = sh.getString('ip');



                  var uri = Uri.parse('$ip/customer_registration');
                  var request = http.MultipartRequest('POST', uri);

                  // 🔹 Normal Form Data
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

                  request.fields['cid'] = sh.getString('cid')?.toString() ?? '';


                  if (_selectedFile != null) {
                    if (kIsWeb) {
                      if (_webFileBytes == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('First file bytes are empty (web).')));
                        setState(() {
                          _isLoading = false;
                        });
                        return;
                      }
                      request.files.add(http.MultipartFile.fromBytes(
                        'file',
                        _webFileBytes!,
                        filename: _selectedFile!.name,
                      ));
                    } else {
                      if (_selectedFile?.path == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('First selected file path is empty.')));
                        setState(() {
                          _isLoading = false;
                        });
                        return;
                      }
                      request.files.add(await http.MultipartFile.fromPath(
                        'file',
                        _selectedFile!.path!,
                      ));
                    }
                  }


                  var streamedResponse = await request.send();
                  var responseString = await streamedResponse.stream.bytesToString();

                  var decoded = json.decode(responseString);



                  if (decoded['status'] == 'ok') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Registration successful!')),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => login_page()),
                    );
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => login_page()));
                  };
                },
                child: Text("Register")),








          ],),),),),);
  }
}




//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:snap2bill/Login_page.dart';
//
// class customer_registration extends StatelessWidget {
//   const customer_registration({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: customer_registration_sub(),
//       theme: ThemeData(primarySwatch: Colors.blue),
//     );
//   }
// }
//
// class customer_registration_sub extends StatefulWidget {
//   const customer_registration_sub({Key? key}) : super(key: key);
//
//   @override
//   State<customer_registration_sub> createState() =>
//       _customer_registration_subState();
// }
//
// class _customer_registration_subState
//     extends State<customer_registration_sub> {
//   // Controllers
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
//
//   bool _obscurePass = true;
//   bool _obscureConfirm = true;
//   int _currentStep = 0; // step 0 = basic info, 1 = other details
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF74ABE2), Color(0xFFA7E2F8)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Container(
//               width: 400,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.95),
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26.withOpacity(0.15),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     "Customer Registration",
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue.shade700,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//
//                   // STEP 1
//                   if (_currentStep == 0) ...[
//                     _buildTextField(name, 'Name', Icons.person_outline),
//                     const SizedBox(height: 15),
//                     _buildTextField(email, 'Email', Icons.email_outlined),
//                     const SizedBox(height: 15),
//                     _buildTextField(phone, 'Phone Number', Icons.phone_android,
//                         inputType: TextInputType.number),
//                     const SizedBox(height: 15),
//                     _buildPasswordField(password, 'Password', _obscurePass, () {
//                       setState(() {
//                         _obscurePass = !_obscurePass;
//                       });
//                     }),
//                     const SizedBox(height: 15),
//                     _buildPasswordField(
//                         confirmpassword, 'Confirm Password', _obscureConfirm,
//                             () {
//                           setState(() {
//                             _obscureConfirm = !_obscureConfirm;
//                           });
//                         }),
//                     const SizedBox(height: 25),
//                     _nextButton("Next", () {
//                       setState(() => _currentStep = 1);
//                     }),
//                   ],
//
//                   // STEP 2
//                   if (_currentStep == 1) ...[
//                     _buildTextField(address, 'Address', Icons.location_city),
//                     const SizedBox(height: 15),
//                     _buildTextField(pincode, 'Pincode', Icons.pin_drop,
//                         inputType: TextInputType.number),
//                     const SizedBox(height: 15),
//                     _buildTextField(place, 'Place', Icons.place_outlined),
//                     const SizedBox(height: 15),
//                     _buildTextField(post, 'Post', Icons.local_post_office),
//                     const SizedBox(height: 15),
//                     _buildTextField(bio, 'Bio / Description', Icons.info),
//                     const SizedBox(height: 25),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         _backButton("Back", () {
//                           setState(() => _currentStep = 0);
//                         }),
//                         _submitButton("Register", _registerUser),
//                       ],
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // 🌈 Reusable TextField builder
//   Widget _buildTextField(TextEditingController controller, String label,
//       IconData icon,
//       {TextInputType inputType = TextInputType.text}) {
//     return TextField(
//       controller: controller,
//       keyboardType: inputType,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: Colors.blueAccent),
//         filled: true,
//         fillColor: Colors.blue.shade50,
//         labelStyle: const TextStyle(color: Colors.black54),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
//
//   // 🔐 Password field with eye icon
//   Widget _buildPasswordField(TextEditingController controller, String label,
//       bool obscure, VoidCallback toggle) {
//     return TextField(
//       controller: controller,
//       obscureText: obscure,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueAccent),
//         suffixIcon: IconButton(
//           icon: Icon(
//             obscure ? Icons.visibility_off : Icons.visibility,
//             color: Colors.grey,
//           ),
//           onPressed: toggle,
//         ),
//         filled: true,
//         fillColor: Colors.blue.shade50,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
//
//   // 🔘 Buttons
//   Widget _nextButton(String text, VoidCallback onPressed) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.blue.shade600,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 4,
//         ),
//         onPressed: onPressed,
//         child: Text(text,
//             style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600)),
//       ),
//     );
//   }
//
//   Widget _backButton(String text, VoidCallback onPressed) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.grey.shade400,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       onPressed: onPressed,
//       child: Text(text,
//           style: const TextStyle(color: Colors.white, fontSize: 16)),
//     );
//   }
//
//   Widget _submitButton(String text, VoidCallback onPressed) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.blue.shade600,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         elevation: 4,
//       ),
//       onPressed: onPressed,
//       child: Text(text,
//           style: const TextStyle(color: Colors.white, fontSize: 16)),
//     );
//   }
//
//   // 🚀 Registration function
//   Future<void> _registerUser() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     try {
//       var data = await http.post(
//         Uri.parse('${sh.getString("ip")}/customer_registration'),
//         body: {
//           'name': name.text,
//           'email': email.text,
//           'phone': phone.text,
//           'password': password.text,
//           'confirmpassword': confirmpassword.text,
//           'address': address.text,
//           'pincode': pincode.text,
//           'place': place.text,
//           'post': post.text,
//           'bio': bio.text,
//         },
//       );
//
//       var decodeddata = json.decode(data.body);
//       print(decodeddata);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Registration Successful!')),
//       );
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => login_page()),
//       );
//     } catch (e) {
//       print("Registration failed: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Something went wrong!')),
//       );
//     }
//   }
// }
//
//
//
//
//


