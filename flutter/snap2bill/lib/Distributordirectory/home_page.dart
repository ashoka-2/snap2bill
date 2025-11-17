import 'package:flutter/material.dart';
import 'package:snap2bill/Distributordirectory/addfolder/add_product.dart';
import 'package:snap2bill/Distributordirectory/distributorsends/send_feedback.dart';
import 'package:snap2bill/Distributordirectory/view/myProducts.dart';
import 'package:snap2bill/Distributordirectory/view/view_category.dart';
import 'package:snap2bill/Distributordirectory/view/view_distributors.dart';
import 'package:snap2bill/Distributordirectory/view/view_product.dart';
import 'package:snap2bill/Distributordirectory/view/view_bills.dart';
import 'package:snap2bill/password/changePassword.dart';


import '../Distributordirectory/search_page.dart';
import '../Distributordirectory/upload_page.dart';
import '../Distributordirectory/customer_page.dart';
import '../Distributordirectory/profile_page.dart';


import 'package:curved_navigation_bar/curved_navigation_bar.dart';



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
  int _pageIndex = 0;
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



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
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
            Icon(Icons.add, size: 30),
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
                "Upload Page clicked",
                "Customers Page clicked",
                "Profile Page clicked"
              ][index]);
            });
          },
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
            },)

          ],
        ),
      ),
    );
  }
}







