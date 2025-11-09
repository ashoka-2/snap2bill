// // import 'dart:convert';
// //
// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:snap2bill/Login_page.dart';
// //
// // import 'Distributordirectory/home_page.dart';
// //
// // void main()
// // {
// //   runApp(distributor_registration());
// // }
// //
// // class distributor_registration extends StatelessWidget {
// //   const distributor_registration({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(home: distributor_registration_sub());
// //   }
// // }
// //
// // class distributor_registration_sub extends StatefulWidget {
// //   const distributor_registration_sub({Key? key}) : super(key: key);
// //
// //   @override
// //   State<distributor_registration_sub> createState() => _distributor_registration_subState();
// // }
// //
// // class _distributor_registration_subState extends State<distributor_registration_sub> {
// //   final name=new TextEditingController();
// //   final email=new TextEditingController();
// //   final phone=new TextEditingController();
// //   final password=new TextEditingController();
// //   final confirmpassword=new TextEditingController();
// //   final address=new TextEditingController();
// //   final pincode=new TextEditingController();
// //   final place=new TextEditingController();
// //   final post=new TextEditingController();
// //   final bio=new TextEditingController();
// //   final latitude=new TextEditingController();
// //   final longitude=new TextEditingController();
// //
// //
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Hello world") ,),
// //       // backgroundColor: Colors.cyan,
// //       body: SingleChildScrollView(child: Center(child: SizedBox(
// //
// //
// //
// //       child: Padding(
// //         padding: EdgeInsets.all(10),
// //         child: Container(
// //           width:400 ,
// //           // height: 1000,
// //           decoration: BoxDecoration(
// //           color: Colors.green.shade100,
// //             borderRadius: BorderRadius.circular(21)
// //           ),
// //           child: Padding(
// //             padding: const EdgeInsets.only(left: 10, top: 20,right: 10,bottom: 15),
// //             child: Column(children: [
// //
// //             TextField(controller: name,
// //               decoration: InputDecoration(
// //                 hintText:'Enter your name ',
// //                 labelText: 'Name',
// //                 prefixIcon: Icon(Icons.abc_rounded),
// //                 filled: true,
// //                 fillColor: Colors.white70,
// //                 border: OutlineInputBorder(
// //
// //                    ),
// //
// //             ),
// //             ),SizedBox(height: 10,),
// //
// //             TextField(controller: email,
// //               decoration: InputDecoration(
// //               hintText: 'Enter your Email',
// //               labelText: 'Email',
// //               prefixIcon: Icon(Icons.email_outlined),
// //               border: OutlineInputBorder()
// //             ),),SizedBox(height: 10,),
// //
// //             TextField(controller: phone,
// //               keyboardType: TextInputType.number,
// //               decoration: InputDecoration(
// //                 hintText: 'Enter your number',
// //                 labelText: 'Phone Number',
// //                 prefixIcon: Icon(Icons.phone_android),
// //                 border: OutlineInputBorder(),
// //
// //             ),),SizedBox(height: 10,),
// //
// //             TextField(controller: password,
// //               decoration: InputDecoration(
// //               hintText: "Enter password",
// //               labelText: 'Password',
// //               prefixIcon: Icon(Icons.password),
// //               border: OutlineInputBorder(),
// //             ),),SizedBox(height: 10,),
// //             TextField(controller: confirmpassword,
// //               decoration: InputDecoration(
// //               hintText: "Enter password",
// //               labelText: 'Confirm Password',
// //               prefixIcon: Icon(Icons.password),
// //               border: OutlineInputBorder(),
// //             ),),SizedBox(height: 10,),
// //
// //
// //
// //             TextField(controller: address,
// //               decoration: InputDecoration(
// //                 hintText: 'Enter your Address',
// //                 labelText: 'Address',
// //                 prefixIcon: Icon(Icons.location_city),
// //                 border: OutlineInputBorder()
// //             ),
// //             ),SizedBox(height: 10,),
// //             TextField(controller: pincode,
// //               keyboardType: TextInputType.number,
// //               decoration: InputDecoration(
// //                 hintText: 'Enter your pincode',
// //                 labelText: 'Pincode',
// //                 prefixIcon: Icon(Icons.location_on_sharp),
// //                 border: OutlineInputBorder()
// //             ),),SizedBox(height: 10,),
// //             TextField(controller: place,
// //               decoration: InputDecoration(
// //                 hintText: 'Enter your Place',
// //                 labelText: 'Place',
// //                 prefixIcon: Icon(Icons.place),
// //                 border: OutlineInputBorder()
// //             ),),SizedBox(height: 10,),
// //             TextField(controller: post,
// //               decoration: InputDecoration(
// //                 hintText: 'Enter your post',
// //                 labelText: 'Post',
// //                 prefixIcon: Icon(Icons.place_sharp),
// //                 border: OutlineInputBorder()
// //             ),),SizedBox(height: 10,),
// //             TextField(controller: bio,
// //               decoration: InputDecoration(
// //                 hintText: 'Enter description',
// //                 labelText: 'Bio',
// //                 prefixIcon: Icon(Icons.abc_sharp),
// //                 border: OutlineInputBorder()
// //             ),),SizedBox(height: 10,),
// //             TextField(controller: latitude,
// //               decoration: InputDecoration(
// //                 hintText: 'Enter your Latitude',
// //                 labelText: 'Latitude',
// //                 prefixIcon: Icon(Icons.abc_sharp),
// //                 border: OutlineInputBorder()
// //             ),),SizedBox(height: 10,),
// //             TextField(controller: longitude,
// //               decoration: InputDecoration(
// //                 hintText: 'Enter your Longitude',
// //                 labelText: 'Longitude',
// //                 prefixIcon: Icon(Icons.abc_sharp),
// //                 border: OutlineInputBorder()
// //             ),),SizedBox(height: 10,),
// //             ElevatedButton(onPressed: () async {
// //               print(name.text);
// //               print(email.text);
// //               print(phone.text);
// //               print(password.text);
// //               print(confirmpassword.text);
// //               print(address.text);
// //               print(pincode.text);
// //               print(place.text);
// //               print(post.text);
// //               print(bio.text);
// //               print(latitude.text);
// //               print(longitude.text);
// //
// //               SharedPreferences sh=await SharedPreferences.getInstance();
// //               // var data = await http.post(Uri.parse('http://192.168.29.3:1234/distributor_register'),
// //                   var data = await http.post(Uri.parse('${sh.getString("ip")}/distributor_registration'),
// //               body: {
// //                 'name':name.text,
// //                 'email':email.text,
// //                 'phone':phone.text,
// //                 'password':password.text,
// //                 'confirmpassword':confirmpassword.text,
// //                 'address':address.text,
// //                 'pincode':pincode.text,
// //                 'place':place.text,
// //                 'post':post.text,
// //                 'bio':bio.text,
// //                 'latitude':latitude.text,
// //                 'longitude':longitude.text,
// //               }
// //               );
// //               Navigator.push(context, MaterialPageRoute(builder: (context)=>login_page()));
// //
// //               var decodeddata = json.decode(data.body);
// //
// //
// //
// //             }, child: Text("Register")),
// //
// //
// //
// //
// //                 ],),
// //           ),
// //         ),
// //       ),),),),);
// //   }
// // }
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
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:snap2bill/Login_page.dart';
//
// class distributor_registration extends StatelessWidget {
//   const distributor_registration({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: distributor_registration_sub(),
//       theme: ThemeData(primarySwatch: Colors.blue),
//     );
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
//   final latitude = TextEditingController();
//   final longitude = TextEditingController();
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
//                     "Distributor Registration",
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
//                     _buildPasswordField(confirmpassword, 'Confirm Password',
//                         _obscureConfirm, () {
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
//                     const SizedBox(height: 15),
//                     _buildTextField(latitude, 'Latitude', Icons.map_outlined),
//                     const SizedBox(height: 15),
//                     _buildTextField(
//                         longitude, 'Longitude', Icons.map_rounded),
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
//         Uri.parse('${sh.getString("ip")}/distributor_registration'),
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
//           'latitude': latitude.text,
//           'longitude': longitude.text,
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



import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snap2bill/Login_page.dart';

class distributor_registration extends StatelessWidget {
  const distributor_registration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: distributor_registration_sub(),
    );
  }
}

class distributor_registration_sub extends StatefulWidget {
  const distributor_registration_sub({Key? key}) : super(key: key);

  @override
  State<distributor_registration_sub> createState() =>
      _distributor_registration_subState();
}

class _distributor_registration_subState
    extends State<distributor_registration_sub> {
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
  final latitude = TextEditingController();
  final longitude = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  int _currentStep = 0;

  File? _profileImage;
  File? _proofImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isProfile, ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 75);
    if (image != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(image.path);
        } else {
          _proofImage = File(image.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0EA5E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Distributor Registration",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_currentStep == 0) ...[
                    _buildImageSection("Profile Photo", true),
                    const SizedBox(height: 20),
                    _buildTextField(name, 'Full Name', Icons.person_outline),
                    const SizedBox(height: 15),
                    _buildTextField(email, 'Email', Icons.email_outlined),
                    const SizedBox(height: 15),
                    _buildTextField(phone, 'Phone', Icons.phone_android,
                        inputType: TextInputType.phone),
                    const SizedBox(height: 15),
                    _buildPasswordField(password, 'Password', _obscurePass, () {
                      setState(() => _obscurePass = !_obscurePass);
                    }),
                    const SizedBox(height: 15),
                    _buildPasswordField(confirmpassword, 'Confirm Password',
                        _obscureConfirm, () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        }),
                    const SizedBox(height: 25),
                    _nextButton("Next", () => setState(() => _currentStep = 1)),
                  ],

                  if (_currentStep == 1) ...[
                    _buildImageSection("Business Proof / License", false),
                    const SizedBox(height: 20),
                    _buildTextField(address, 'Address', Icons.location_city),
                    const SizedBox(height: 15),
                    _buildTextField(pincode, 'Pincode', Icons.pin_drop,
                        inputType: TextInputType.number),
                    const SizedBox(height: 15),
                    _buildTextField(place, 'Place', Icons.place_outlined),
                    const SizedBox(height: 15),
                    _buildTextField(post, 'Post', Icons.local_post_office),
                    const SizedBox(height: 15),
                    _buildTextField(bio, 'Business Bio', Icons.info_outline),
                    const SizedBox(height: 15),
                    _buildTextField(latitude, 'Latitude', Icons.map_outlined),
                    const SizedBox(height: 15),
                    _buildTextField(longitude, 'Longitude', Icons.map_rounded),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _backButton("Back", () => setState(() => _currentStep = 0)),
                        _submitButton("Register", _registerUser),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🧱 Reusable Widgets

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon,
      {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
        filled: true,
        fillColor: Colors.blue.shade50,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      bool obscure, VoidCallback toggle) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
        const Icon(Icons.lock_outline, color: Color(0xFF1565C0)),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildImageSection(String title, bool isProfile) {
    File? image = isProfile ? _profileImage : _proofImage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF0A0A0A)),
        ),
        const SizedBox(height: 10),
        Center(
          child: GestureDetector(
            onTap: () => _showImagePickerDialog(isProfile),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200, width: 2),
                color: Colors.blue.shade50,
              ),
              child: image != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(image, fit: BoxFit.cover),
              )
                  : const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFF1565C0), size: 50),
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePickerDialog(bool isProfile) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF1565C0)),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(isProfile, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF1565C0)),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(isProfile, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🔘 Buttons
  Widget _nextButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        onPressed: onPressed,
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _backButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  Widget _submitButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1565C0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      onPressed: onPressed,
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  // 🚀 Registration logic (with file upload)
  Future<void> _registerUser() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    try {
      var uri =
      Uri.parse('${sh.getString("ip")}/distributor_registration');
      var request = http.MultipartRequest('POST', uri);

      request.fields.addAll({
        'name': name.text,
        'email': email.text,
        'phone': phone.text,
        'password': password.text,
        'confirmpassword': confirmpassword.text,
        'address': address.text,
        'pincode': pincode.text,
        'place': place.text,
        'post': post.text,
        'bio': bio.text,
        'latitude': latitude.text,
        'longitude': longitude.text,
      });

      if (_profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'profile_photo', _profileImage!.path));
      }

      if (_proofImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'proof_photo', _proofImage!.path));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var decoded = json.decode(responseBody);

      if (decoded['status'] == 'ok') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const login_page()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed!')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong!')),
      );
    }
  }
}
