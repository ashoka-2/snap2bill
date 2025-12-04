import 'package:flutter/material.dart';
import 'package:snap2bill/Distributordirectory/addfolder/addOrder.dart';
import 'package:snap2bill/Distributordirectory/distributorsends/send_feedback.dart';
import 'package:snap2bill/Distributordirectory/view/myProducts.dart';
import 'package:snap2bill/Distributordirectory/view/viewOrder.dart';
import 'package:snap2bill/Distributordirectory/view/view_category.dart';
import 'package:snap2bill/Distributordirectory/view/view_distributors.dart';
import 'package:snap2bill/Distributordirectory/view/view_product.dart';
import 'package:snap2bill/Distributordirectory/view/view_bills.dart';
import 'package:snap2bill/Distributordirectory/password/changePassword.dart';


import '../Distributordirectory/search_page.dart';
import '../Distributordirectory/upload_page.dart';
import '../Distributordirectory/customer_page.dart';
import '../Distributordirectory/profile_page.dart';


import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'dart:ui'; // Required for ImageFilter
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';


void main(){
  runApp(home_page());
}



class home_page extends StatelessWidget {
  const home_page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: home_page_sub(),);
  }
}


class home_page_sub extends StatefulWidget {

  const home_page_sub({Key? key}) : super(key: key);

  @override
  State<home_page_sub> createState() => _home_page_subState();
}

class _home_page_subState extends State<home_page_sub> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      // Home page content inline
      home_content(),
      // Other pages imported
      search_page(),
      upload_page(),
      customer_page(),
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
      // debugShowCheckedModeBanner: false,
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
                        GButton(icon: LineIcons.plus, text: 'Add'),
                        GButton(icon: LineIcons.users, text: 'Customers'),
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

   Widget home_content() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body:  Drawer(backgroundColor: Colors.brown.shade300,
        child: ListView(
          children: [

            ListTile(leading: Icon(Icons.category),title:Text("View Category"),onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>view_category()));
              // Navigator.pop(context);
            },),

            ListTile(leading: Icon(Icons.people),title:Text("View Distributors"),onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>view_distributors()));
              // Navigator.pop(context);
            },),
            ListTile(leading: Icon(Icons.image),title:Text("My Product"),onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>myProducts()));
              // Navigator.pop(context);
            },),
            ListTile(leading: Icon(Icons.image),title:Text("View all Product"),onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>view_product()));
              // Navigator.pop(context);
            },),
            ListTile(leading: Icon(Icons.image),title:Text("feedback"),onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>send_feedback()));
              // Navigator.pop(context);
            },),
            ListTile(leading: Icon(Icons.password),title:Text("Change password"),onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>changePassword()));
              // Navigator.pop(context);
            },),
            ListTile(leading: Icon(Icons.list),title:Text("View orders"),onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>viewOrder()));
              // Navigator.pop(context);
            },)

          ],
        ),
      ),
    );
  }
}








