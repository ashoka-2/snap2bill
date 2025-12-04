
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'dart:ui'; // Required for ImageFilter
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';


import 'package:snap2bill/Customerdirectory/Customersends/send_feedback.dart';
import 'package:snap2bill/Customerdirectory/Customersends/send_review.dart';
import 'package:snap2bill/Customerdirectory/custviews/viewOrder.dart';
import 'package:snap2bill/Customerdirectory/custviews/view_product.dart';
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
  int _selectedIndex = 0;

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
  final Set<Color> tabColors = {
    Colors.purple,
    Colors.yellow,
    Colors.blue,
    Colors.green,
    Colors.red,
  };


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBody: true,

        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                    child: GNav(
                      rippleColor:Colors.white.withOpacity(0.1),
                      hoverColor: Colors.white.withOpacity(0.1),
                      gap: 5,
                      activeColor: tabColors.elementAt(_selectedIndex),
                      iconSize: 24,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      duration: Duration(milliseconds: 400),
                      tabBackgroundColor:
                      tabColors.elementAt(_selectedIndex).withOpacity(0.1),
                      color: Colors.black,
                      tabs: [
                        GButton(icon: LineIcons.home, text: 'Home'),
                        GButton(icon: LineIcons.search, text: 'Search'),
                        GButton(icon: LineIcons.facebookMessenger, text: 'Chat'),
                        GButton(icon: LineIcons.users, text: 'Distributors'),
                        GButton(icon: LineIcons.user, text: 'Profile'),
                      ],
                      selectedIndex: _selectedIndex,
                      onTabChange: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=>view_feedback()));
            }, child: Text("view feedback")),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>changePassword()));
            }, child: Text("Change password")),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>view_product()));
            }, child: Text("View Product")),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>viewOrder()));
            }, child: Text("View Order"))

          ],
        ),
      ),
    );
  }
}
