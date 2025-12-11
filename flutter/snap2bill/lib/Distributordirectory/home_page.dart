// lib/Distributordirectory/home_screen.dart
import 'package:flutter/material.dart';

// Imports for your navigation
import 'package:snap2bill/Distributordirectory/view/view_category.dart';
import 'package:snap2bill/Distributordirectory/view/view_distributors.dart';
import 'package:snap2bill/Distributordirectory/view/myProducts.dart';
import 'package:snap2bill/Distributordirectory/view/view_feedback.dart';
import 'package:snap2bill/Distributordirectory/view/view_product.dart';
import 'package:snap2bill/Distributordirectory/password/changePassword.dart';
import 'package:snap2bill/Distributordirectory/view/viewOrder.dart';

class Home_page extends StatelessWidget {
  const Home_page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        // The hamburger menu icon appears automatically because we added a 'drawer' below
      ),

      // ERROR FIX: Removed bottomNavigationBar: distributorNavigationBar()
      // The parent widget already handles the navigation bar.

      // ERROR FIX: Moved Drawer from 'body' to 'drawer'
      drawer: Drawer(
        backgroundColor: Colors.brown.shade300,
        child: ListView(
          padding: EdgeInsets.zero, // Good practice to remove top padding in drawers
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.brown),
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text("View Category"),
              onTap: () {
                Navigator.pop(context); // Close drawer before navigating
                Navigator.push(context, MaterialPageRoute(builder: (context) => view_category()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("View Distributors"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => view_distributors()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text("My Product"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => myProducts()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text("View all Product"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => view_product()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text("Feedback"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => view_feedback()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.password),
              title: const Text("Change password"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => changePassword()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text("View orders"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => viewOrder()));
              },
            ),
          ],
        ),
      ),

      // Since the Drawer is hidden now, we need a body for the main screen content
      body: const Center(
        child: Text("Welcome to Distributor Dashboard"),
      ),
    );
  }
}