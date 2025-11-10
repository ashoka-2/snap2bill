// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Distributordirectory/home_page.dart';
// import 'package:snap2bill/distributor_registration.dart';
// import 'package:http/http.dart' as http;
// import 'package:snap2bill/customer_registration.dart';
//
// import 'Customerdirectory/customer_home_page.dart';
//
//
// void main(){
//   runApp(login_page());
// }
//
// class login_page extends StatelessWidget {
//   const login_page({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: login_page_sub(),);
//   }
// }
//
// class login_page_sub extends StatefulWidget {
//   const login_page_sub({Key? key}) : super(key: key);
//
//   @override
//   State<login_page_sub> createState() => _login_page_subState();
// }
//
// class _login_page_subState extends State<login_page_sub> {
//   TextEditingController username = TextEditingController();
//   TextEditingController password = TextEditingController();
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: PreferredSize(
//           preferredSize: Size.fromHeight(80),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.blue,
//               borderRadius: BorderRadius.vertical(
//                 bottom: Radius.circular(30),
//               ),
//             ),
//             child: AppBar(
//               centerTitle: true,
//               title: Text('LOGIN' , style: TextStyle(fontSize: 40),),
//               backgroundColor: Colors.transparent, // make AppBar background transparent
//               elevation: 0,
//             ),
//           ),
//         ),
//         backgroundColor: Colors.cyan.shade100, body:
//
//     Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//
//         Center(child:
//         Container(
//
//           width:400,
//           height:400,
//           decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.black38,),
//           // decoration: BoxDecoration(borderRadius: BorderRadius.only(
//           //   topLeft: Radius.circular(30),
//           //   topRight: Radius.circular(10),
//           //   bottomLeft: Radius.circular(50),
//           //   bottomRight: Radius.circular(0),
//           // ),color: Colors.black38,),
//           margin: EdgeInsets.all(10),
//           child:Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),child:
//           Column(children: [
//             // Text("Log In",style: TextStyle(fontSize: 30),),
//
//             SizedBox(height: 8,),
//             TextFormField(decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),), labelText: 'username', fillColor: Colors.white38, filled: true,),controller: username,),
//
//             SizedBox(height: 8,),
//             TextFormField(decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),), labelText: 'password', fillColor: Colors.white38, filled: true,),controller: password,),
//             SizedBox(height: 8,),
//
//             ElevatedButton(onPressed: () async {
//               print("Username:${username.text}");
//               print("Password: ${password.text}");
//               SharedPreferences sh = await SharedPreferences.getInstance();
//               String ip = sh.getString("ip").toString();
//               // print("Password:", sh.getString("ip").toString());
//               try {
//                 var response = await http.post(
//                   Uri.parse('${ip}/login_page'),
//                   body: {'username': username.text, 'password': password.text},
//                 );
//
//                 var decodeddata=await json.decode(response.body);
//                 if (decodeddata['status'] == 'custok') {
//                   print(response);
//                   var contentType = response.headers['content-type'];
//                   print("Content-Type: $contentType");
//                   if (contentType != null && contentType.contains('application/json')) {
//                     // Proceed with decoding the JSON response
//                     var decode = json.decode(response.body);
//                     sh.setString("cid", decodeddata['cid']);
//                     print(decode);  // Check response
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Login successful'),
//                       ),
//                     );
//                     Navigator.push(context, MaterialPageRoute(builder: (context)=>customer_home_page()));
//                   }
//                   else {
//                     print("Invalid Content-Type. Expected application/json.");
//                   }
//
//                 }
//
//                 else if(decodeddata['status'] == 'distok'){
//                   sh.setString("uid", decodeddata['uid']);
//                   print(response);
//                   var contentType = response.headers['content-type'];
//                   print("Content-Type: $contentType");
//                   Navigator.push(context, MaterialPageRoute(builder: (context)=>home_page()));
//                 }
//                 else {
//                   print('Failed to fetch data. Status code: ${response.statusCode}');
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Invalid details'),
//                     ),
//                   );
//                 }
//               } catch (e) {
//                 print("Request failed: $e");
//               }
//
//
//
//             }, child: Text('submit')),
//
//             TextButton(onPressed: () async{
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>distributor_registration()));
//
//               },child: Text("Register now")),
//             TextButton(onPressed: () async{
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>customer_registration()));
//
//
//             },child: Text("Customer Register")),
//
//
//
//
//
//
//
//           ],)
//           ),
//
//         )),
//       ],
//     ));
//   }
// }
//



import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/home_page.dart';
import 'package:snap2bill/distributor_registration.dart';
import 'package:http/http.dart' as http;
import 'package:snap2bill/customer_registration.dart';
import 'Customerdirectory/customer_home_page.dart';

class login_page extends StatelessWidget {
  const login_page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: login_page_sub(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class login_page_sub extends StatefulWidget {
  const login_page_sub({Key? key}) : super(key: key);

  @override
  State<login_page_sub> createState() => _login_page_subState();
}

class _login_page_subState extends State<login_page_sub>
    with SingleTickerProviderStateMixin {
  TextEditingController username = TextEditingController(text: "ashoka@gmail.com");
  TextEditingController password = TextEditingController(text: "password");
  bool _obscureText = true;

  bool _usernameError = false;
  bool _passwordError = false;
  String? _invalidError;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _usernameError = username.text.isEmpty;
      _passwordError = password.text.isEmpty;
      _invalidError = null;
    });

    if (_usernameError || _passwordError) {
      _shakeController.forward(from: 0);
      return;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip").toString();

    try {
      var response = await http.post(
        Uri.parse('$ip/login_page'),
        body: {
          'username': username.text,
          'password': password.text,
        },
      );

      var decoded = json.decode(response.body);

      if (decoded['status'] == 'custok') {
        sh.setString("cid", decoded['cid']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => customer_home_page()),
        );
      } else if (decoded['status'] == 'distok') {
        sh.setString("uid", decoded['uid']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => home_page()),
        );
      } else {
        setState(() {
          _invalidError = "Invalid username or password!";
        });
        _shakeController.forward(from: 0);
      }
    } catch (e) {
      setState(() {
        _invalidError = "Connection error. Please check your IP.";
      });
      _shakeController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _shakeAnim,
        builder: (context, child) {
          final offsetX = (_usernameError || _passwordError || _invalidError != null)
              ? math.sin(_shakeAnim.value) * 10
              : 0.0;

          return Transform.translate(
            offset: Offset(offsetX, 0),
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF74ABE2), Color(0xFFA7E2F8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),
                Text(
                  "LOGIN",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.95),
                    letterSpacing: 1.2,
                    shadows: [
                      const Shadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4))
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Center(
                  child: Container(
                    width: 400,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
                        TextFormField(
                          controller: username,
                          onChanged: (_) {
                            if (_usernameError || _invalidError != null) {
                              setState(() {
                                _usernameError = false;
                                _invalidError = null;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person_outline,
                                color: Colors.blueAccent),
                            filled: true,
                            fillColor: _usernameError
                                ? Colors.red.shade50
                                : Colors.blue.shade50,
                            labelStyle: const TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: password,
                          obscureText: _obscureText,
                          onChanged: (_) {
                            if (_passwordError || _invalidError != null) {
                              setState(() {
                                _passwordError = false;
                                _invalidError = null;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.blueAccent),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: _passwordError
                                ? Colors.red.shade50
                                : Colors.blue.shade50,
                            labelStyle: const TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        if (_invalidError != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _invalidError!,
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.w500),
                          ),
                        ],
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              shadowColor: Colors.blueAccent,
                            ),
                            onPressed: _login,
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 18,
                                letterSpacing: 0.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          distributor_registration()),
                                );
                              },
                              child: const Text(
                                "Distributor Register",
                                style: TextStyle(
                                    color: Colors.blueAccent, fontSize: 15),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 20,
                              color: Colors.grey.shade400,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          customer_registration()),
                                );
                              },
                              child: const Text(
                                "Customer Register",
                                style: TextStyle(
                                    color: Colors.blueAccent, fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

