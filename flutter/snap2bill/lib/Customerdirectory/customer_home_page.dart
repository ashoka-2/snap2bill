
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:snap2bill/Customerdirectory/Customersends/send_feedback.dart';
import 'package:snap2bill/Customerdirectory/Customersends/send_review.dart';
import 'package:snap2bill/Customerdirectory/custviews/view_review.dart';
import 'package:snap2bill/Customerdirectory/distributor_page.dart';
import 'package:snap2bill/Customerdirectory/password/changePassword.dart';
import 'package:snap2bill/Customerdirectory/search_page.dart';
import 'package:snap2bill/Customerdirectory/profile_page.dart';
import '../Customerdirectory/chat_page.dart';
import 'custviews/view_feedback.dart';



void main() {
  runApp(customer_home_page());
}

class customer_home_page extends StatefulWidget {
  const customer_home_page({Key? key}) : super(key: key);

  @override
  State<customer_home_page> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<customer_home_page> {
  int _pageIndex = 0;

  // Pages for IndexedStack
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      // Home page content inline
      customer_home_content(),
      // Other pages imported
      search_page(),
      chat_page(),
      distributor_page(),
      profile_page(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: IndexedStack(
          index: _pageIndex,
          children: _pages,
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: _pageIndex,
          items: const [
            Icon(Icons.home_filled, size: 30),
            Icon(Icons.search, size: 30),
            Icon(Icons.chat, size: 30),
            Icon(Icons.people, size: 30),
            Icon(Icons.perm_identity, size: 30),
          ],
          color: Colors.white,
          buttonBackgroundColor: Colors.white,
          backgroundColor: Colors.black,
          animationCurve: Curves.easeInOut,
          onTap: (index) {
            setState(() {
              _pageIndex = index;
              print([
                "Home Page clicked",
                "Search Page clicked",
                "Chat Page clicked",
                "Distributor Page clicked",
                "Profile Page clicked"
              ][index]);
            });
          },
        ),
      ),
    );
  }

  // ===== Home page content (inline) =====
  Widget customer_home_content() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              "Home Page ",
              style: TextStyle(fontSize: 24),
            ),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>send_review()));
            }, child: Text("Send Review")),
            SizedBox(height: 10,),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>send_feedback()));
            }, child: Text("Send feedback")),
            SizedBox(height: 10,),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>view_review()));
            }, child: Text("view review")),
            SizedBox(height: 10,),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>view_feedback()));
            }, child: Text("view feedback")),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>changePassword()));
            }, child: Text("Change password"))
          ],
        ),
      ),
    );
  }
}
