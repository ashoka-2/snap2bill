// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Login_page.dart';
// // import 'package:snap2bill/Customerdirectory/customer_home_page.dart';
//
//
// void main()
// {
//   runApp(customer_registration());
// }
//
// class customer_registration extends StatelessWidget {
//   const customer_registration({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: customer_registration_sub());
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
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: SingleChildScrollView(child: Center(child: SizedBox(height: 1000 ,width: 400,child: Column(children: [
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
//
//
//
//       ElevatedButton(onPressed: () async {
//
//
//
//
//
//
//
//         print(name.text);
//         print(email.text);
//         print(phone.text);
//         print(password.text);
//         print(confirmpassword.text);
//         print(address.text);
//         print(pincode.text);
//         print(place.text);
//         print(post.text);
//         print(bio.text);
//
//         SharedPreferences sh=await SharedPreferences.getInstance();
//         // var data = await http.post(Uri.parse('http://192.168.29.3:1234/customer_registration'),
//         var data = await http.post(Uri.parse('${sh.getString("ip")}/customer_registration'),
//
//             body: {
//               'name':name.text,
//               'email':email.text,
//               'phone':phone.text,
//               'password':password.text,
//               'confirmpassword':confirmpassword.text,
//               'address':address.text,
//               'pincode':pincode.text,
//               'place':place.text,
//               'post':post.text,
//               'bio':bio.text,
//
//             }
//         );
//
//
//
//         var decodeddata = json.decode(data.body); //
//
//
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => login_page()),
//         );
//       }, child: Text("Register")),
//
//
//
//
//
//     ],),),),),);
//   }
// }
// //
// // import 'dart:convert';
// // import 'dart:ui';
// //
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:snap2bill/Login_page.dart';
// // // import 'package:snap2bill/Customerdirectory/customer_home_page.dart';
// //
// //
// // void main()
// // {
// //   runApp(customer_registration());
// // }
// //
// // class customer_registration extends StatelessWidget {
// //   const customer_registration({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(home: customer_registration_sub());
// //   }
// // }
// //
// // class customer_registration_sub extends StatefulWidget {
// //   const customer_registration_sub({Key? key}) : super(key: key);
// //
// //   @override
// //   State<customer_registration_sub> createState() => _customer_registration_subState();
// // }
// //
// // class _customer_registration_subState extends State<customer_registration_sub> {
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
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         decoration: BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //             colors: [
// //               Color(0xFF001F3F), // Navy blue
// //               Color(0xFF000814), // Dark navy
// //               Color(0xFF000000), // Black
// //             ],
// //           ),
// //         ),
// //         child: SafeArea(
// //           child: Center(
// //             child: SingleChildScrollView(
// //               child: Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
// //                 child: Container(
// //                   constraints: BoxConstraints(maxWidth: 450),
// //                   decoration: BoxDecoration(
// //                     borderRadius: BorderRadius.circular(30),
// //                     gradient: LinearGradient(
// //                       begin: Alignment.topLeft,
// //                       end: Alignment.bottomRight,
// //                       colors: [
// //                         Colors.white.withOpacity(0.1),
// //                         Colors.white.withOpacity(0.05),
// //                       ],
// //                     ),
// //                     border: Border.all(
// //                       color: Colors.white.withOpacity(0.2),
// //                       width: 1.5,
// //                     ),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.black.withOpacity(0.3),
// //                         blurRadius: 30,
// //                         spreadRadius: 5,
// //                         offset: Offset(0, 10),
// //                       ),
// //                       BoxShadow(
// //                         color: Colors.white.withOpacity(0.1),
// //                         blurRadius: 10,
// //                         spreadRadius: -5,
// //                         offset: Offset(0, -5),
// //                       ),
// //                     ],
// //                   ),
// //                   child: ClipRRect(
// //                     borderRadius: BorderRadius.circular(30),
// //                     child: BackdropFilter(
// //                       filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
// //                       child: Padding(
// //                         padding: const EdgeInsets.all(32.0),
// //                         child: Column(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             // Header
// //                             Text(
// //                               'Create Account',
// //                               style: TextStyle(
// //                                 fontSize: 32,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.white,
// //                                 letterSpacing: 1.2,
// //                                 shadows: [
// //                                   Shadow(
// //                                     color: Color(0xFF001F3F),
// //                                     blurRadius: 10,
// //                                     offset: Offset(0, 3),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                             SizedBox(height: 8),
// //                             Text(
// //                               'Fill in your details to register',
// //                               style: TextStyle(
// //                                 fontSize: 14,
// //                                 color: Colors.white.withOpacity(0.7),
// //                                 letterSpacing: 0.5,
// //                               ),
// //                             ),
// //                             SizedBox(height: 32),
// //
// //                             _buildGlassTextField(
// //                               controller: name,
// //                               hintText: 'Enter your name',
// //                               labelText: 'Name',
// //                               icon: Icons.person_outline,
// //                             ),
// //                             SizedBox(height: 16),
// //
// //                             _buildGlassTextField(
// //                               controller: email,
// //                               hintText: 'Enter your Email',
// //                               labelText: 'Email',
// //                               icon: Icons.email_outlined,
// //                             ),
// //                             SizedBox(height: 16),
// //
// //                             _buildGlassTextField(
// //                               controller: phone,
// //                               hintText: 'Enter your number',
// //                               labelText: 'Phone Number',
// //                               icon: Icons.phone_android,
// //                             ),
// //                             SizedBox(height: 16),
// //
// //                             _buildGlassTextField(
// //                               controller: password,
// //                               hintText: 'Enter password',
// //                               labelText: 'Password',
// //                               icon: Icons.lock_outline,
// //                               isPassword: true,
// //                             ),
// //                             SizedBox(height: 16),
// //
// //                             _buildGlassTextField(
// //                               controller: confirmpassword,
// //                               hintText: 'Enter password',
// //                               labelText: 'Confirm Password',
// //                               icon: Icons.lock_outline,
// //                               isPassword: true,
// //                             ),
// //                             SizedBox(height: 16),
// //
// //                             _buildGlassTextField(
// //                               controller: address,
// //                               hintText: 'Enter your Address',
// //                               labelText: 'Address',
// //                               icon: Icons.location_city,
// //                             ),
// //                             SizedBox(height: 16),
// //
// //                             _buildGlassTextField(
// //                               controller: pincode,
// //                               hintText: 'Enter your pincode',
// //                               labelText: 'Pincode',
// //                               icon: Icons.location_on_outlined,
// //                             ),
// //                             SizedBox(height: 16),
// //
// //                             _buildGlassTextField(
// //                               controller: place,
// //                               hintText: 'Enter your Place',
// //                               labelText: 'Place',
// //                               icon: Icons.place_outlined,
// //                             ),
// //                             SizedBox(height: 16),
// //
// //                             _buildGlassTextField(
// //                               controller: post,
// //                               hintText: 'Enter your post',
// //                               labelText: 'Post',
// //                               icon: Icons.place_outlined,
// //                             ),
// //                             SizedBox(height: 16),
// //
// //                             _buildGlassTextField(
// //                               controller: bio,
// //                               hintText: 'Enter description',
// //                               labelText: 'Bio',
// //                               icon: Icons.description_outlined,
// //                               maxLines: 3,
// //                             ),
// //                             SizedBox(height: 32),
// //
// //                             // Register Button
// //                             Container(
// //                               width: double.infinity,
// //                               height: 56,
// //                               decoration: BoxDecoration(
// //                                 borderRadius: BorderRadius.circular(16),
// //                                 gradient: LinearGradient(
// //                                   colors: [
// //                                     Color(0xFF001F3F),
// //                                     Color(0xFF003366),
// //                                   ],
// //                                 ),
// //                                 border: Border.all(
// //                                   color: Colors.white.withOpacity(0.3),
// //                                   width: 1,
// //                                 ),
// //                                 boxShadow: [
// //                                   BoxShadow(
// //                                     color: Colors.white.withOpacity(0.2),
// //                                     blurRadius: 15,
// //                                     spreadRadius: 0,
// //                                   ),
// //                                   BoxShadow(
// //                                     color: Color(0xFF001F3F).withOpacity(0.5),
// //                                     blurRadius: 20,
// //                                     offset: Offset(0, 10),
// //                                   ),
// //                                 ],
// //                               ),
// //                               child: ElevatedButton(
// //                                 onPressed: () async {
// //                                   print(name.text);
// //                                   print(email.text);
// //                                   print(phone.text);
// //                                   print(password.text);
// //                                   print(confirmpassword.text);
// //                                   print(address.text);
// //                                   print(pincode.text);
// //                                   print(place.text);
// //                                   print(post.text);
// //                                   print(bio.text);
// //
// //                                   SharedPreferences sh=await SharedPreferences.getInstance();
// //                                   // var data = await http.post(Uri.parse('http://192.168.29.3:1234/customer_registration'),
// //                                   var data = await http.post(Uri.parse('${sh.getString("ip")}/customer_registration'),
// //
// //                                       body: {
// //                                         'name':name.text,
// //                                         'email':email.text,
// //                                         'phone':phone.text,
// //                                         'password':password.text,
// //                                         'confirmpassword':confirmpassword.text,
// //                                         'address':address.text,
// //                                         'pincode':pincode.text,
// //                                         'place':place.text,
// //                                         'post':post.text,
// //                                         'bio':bio.text,
// //
// //                                       }
// //                                   );
// //
// //                                   var decodeddata = json.decode(data.body); //
// //
// //                                   Navigator.pushReplacement(
// //                                     context,
// //                                     MaterialPageRoute(builder: (context) => login_page()),
// //                                   );
// //                                 },
// //                                 style: ElevatedButton.styleFrom(
// //                                   backgroundColor: Colors.transparent,
// //                                   shadowColor: Colors.transparent,
// //                                   shape: RoundedRectangleBorder(
// //                                     borderRadius: BorderRadius.circular(16),
// //                                   ),
// //                                 ),
// //                                 child: Text(
// //                                   'Register',
// //                                   style: TextStyle(
// //                                     fontSize: 18,
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Colors.white,
// //                                     letterSpacing: 1.5,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildGlassTextField({
// //     required TextEditingController controller,
// //     required String hintText,
// //     required String labelText,
// //     required IconData icon,
// //     bool isPassword = false,
// //     int maxLines = 1,
// //   }) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(16),
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: [
// //             Colors.white.withOpacity(0.15),
// //             Colors.white.withOpacity(0.05),
// //           ],
// //         ),
// //         border: Border.all(
// //           color: Colors.white.withOpacity(0.2),
// //           width: 1,
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.1),
// //             blurRadius: 10,
// //             offset: Offset(0, 5),
// //           ),
// //         ],
// //       ),
// //       child: TextField(
// //         controller: controller,
// //         obscureText: isPassword,
// //         maxLines: maxLines,
// //         style: TextStyle(
// //           color: Colors.white,
// //           fontSize: 15,
// //           fontWeight: FontWeight.w400,
// //         ),
// //         decoration: InputDecoration(
// //           hintText: hintText,
// //           labelText: labelText,
// //           hintStyle: TextStyle(
// //             color: Colors.white.withOpacity(0.5),
// //             fontSize: 14,
// //           ),
// //           labelStyle: TextStyle(
// //             color: Colors.white.withOpacity(0.8),
// //             fontSize: 14,
// //             fontWeight: FontWeight.w500,
// //           ),
// //           prefixIcon: Icon(
// //             icon,
// //             color: Colors.white.withOpacity(0.7),
// //             size: 22,
// //           ),
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(16),
// //             borderSide: BorderSide.none,
// //           ),
// //           enabledBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(16),
// //             borderSide: BorderSide.none,
// //           ),
// //           focusedBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(16),
// //             borderSide: BorderSide(
// //               color: Colors.white.withOpacity(0.4),
// //               width: 1.5,
// //             ),
// //           ),
// //           filled: true,
// //           fillColor: Colors.white.withOpacity(0.08),
// //           contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //




import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snap2bill/Login_page.dart';

class customer_registration extends StatelessWidget {
  const customer_registration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: customer_registration_sub(),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

class customer_registration_sub extends StatefulWidget {
  const customer_registration_sub({Key? key}) : super(key: key);

  @override
  State<customer_registration_sub> createState() =>
      _customer_registration_subState();
}

class _customer_registration_subState
    extends State<customer_registration_sub> {
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

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  int _currentStep = 0; // step 0 = basic info, 1 = other details

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF74ABE2), Color(0xFFA7E2F8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
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
                    "Customer Registration",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // STEP 1
                  if (_currentStep == 0) ...[
                    _buildTextField(name, 'Name', Icons.person_outline),
                    const SizedBox(height: 15),
                    _buildTextField(email, 'Email', Icons.email_outlined),
                    const SizedBox(height: 15),
                    _buildTextField(phone, 'Phone Number', Icons.phone_android,
                        inputType: TextInputType.number),
                    const SizedBox(height: 15),
                    _buildPasswordField(password, 'Password', _obscurePass, () {
                      setState(() {
                        _obscurePass = !_obscurePass;
                      });
                    }),
                    const SizedBox(height: 15),
                    _buildPasswordField(
                        confirmpassword, 'Confirm Password', _obscureConfirm,
                            () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        }),
                    const SizedBox(height: 25),
                    _nextButton("Next", () {
                      setState(() => _currentStep = 1);
                    }),
                  ],

                  // STEP 2
                  if (_currentStep == 1) ...[
                    _buildTextField(address, 'Address', Icons.location_city),
                    const SizedBox(height: 15),
                    _buildTextField(pincode, 'Pincode', Icons.pin_drop,
                        inputType: TextInputType.number),
                    const SizedBox(height: 15),
                    _buildTextField(place, 'Place', Icons.place_outlined),
                    const SizedBox(height: 15),
                    _buildTextField(post, 'Post', Icons.local_post_office),
                    const SizedBox(height: 15),
                    _buildTextField(bio, 'Bio / Description', Icons.info),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _backButton("Back", () {
                          setState(() => _currentStep = 0);
                        }),
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

  // 🌈 Reusable TextField builder
  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon,
      {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
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

  // 🔐 Password field with eye icon
  Widget _buildPasswordField(TextEditingController controller, String label,
      bool obscure, VoidCallback toggle) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueAccent),
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

  // 🔘 Buttons
  Widget _nextButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        onPressed: onPressed,
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
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
        backgroundColor: Colors.blue.shade600,
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

  // 🚀 Registration function
  Future<void> _registerUser() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    try {
      var data = await http.post(
        Uri.parse('${sh.getString("ip")}/customer_registration'),
        body: {
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
        },
      );

      var decodeddata = json.decode(data.body);
      print(decodeddata);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful!')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => login_page()),
      );
    } catch (e) {
      print("Registration failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong!')),
      );
    }
  }
}







