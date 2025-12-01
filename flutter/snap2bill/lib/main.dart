// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Login_page.dart';
//
// void main(){
//   runApp(MyApp());
// }
//
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: MyApp_sub(),);
//   }
// }
//
//
// class MyApp_sub extends StatefulWidget {
//   const MyApp_sub({Key? key}) : super(key: key);
//
//   @override
//   State<MyApp_sub> createState() => _MyApp_subState();
// }
//
// class _MyApp_subState extends State<MyApp_sub> {
//   // TextEditingController ip = TextEditingController(text: "192.168.29.3");
//   TextEditingController ip = TextEditingController(text: "10.218.83.28");
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Center(child: Container(
//       width:400,
//       height:400,
//       color: Colors.blue.shade300,
//       margin: EdgeInsets.all(10),
//       child:Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),child:
//       Column(children: [
//         SizedBox(height: 8,),
//         TextFormField(decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),), labelText: 'ip', fillColor: Colors.white38, filled: true,),controller: ip,),
//
//         SizedBox(height: 8,),
//         ElevatedButton(onPressed: () async {
//           SharedPreferences sh = await SharedPreferences.getInstance();
//
//           sh.setString("ip","http://${ip.text}:8000");
//           Navigator.push(context, MaterialPageRoute(builder: (context)=>login_page()));
//
//         }, child: Text('submit')),
//
//
//
//
//       ],)
//       ),
//
//     )));
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp_sub(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        
      ),
    );
  }
}

class MyApp_sub extends StatefulWidget {
  const MyApp_sub({Key? key}) : super(key: key);

  @override
  State<MyApp_sub> createState() => _MyApp_subState();
}

class _MyApp_subState extends State<MyApp_sub>
    with SingleTickerProviderStateMixin {
  TextEditingController ip = TextEditingController(text: "192.168.29.5");

  // TextEditingController ip = TextEditingController(text: "10.223.211.28");

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    sh.setString("ip", "http://${ip.text}:8000");
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => login_page(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Enter IP Address",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'IP Address',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      filled: true,
                      fillColor: Colors.blue.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.wifi,
                        color: Colors.blueAccent,
                      ),
                    ),
                    controller: ip,
                  ),
                  const SizedBox(height: 24),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
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
                      onPressed: _onSubmit,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
