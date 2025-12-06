import 'package:flutter/material.dart';

// Import your specific pages here so the buttons work
import 'package:snap2bill/Customerdirectory/Customersends/send_feedback.dart';
import 'package:snap2bill/Customerdirectory/Customersends/send_review.dart';
import 'package:snap2bill/Customerdirectory/custviews/viewOrder.dart';
import 'package:snap2bill/Customerdirectory/custviews/view_product.dart';
import 'package:snap2bill/Customerdirectory/password/changePassword.dart';
import 'package:snap2bill/Customerdirectory/custviews/view_feedback.dart';
// Note: I adjusted the view_feedback import to match the full package path style 
// to ensure it works, but you can change it back to relative if preferred.

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        automaticallyImplyLeading: false, // Prevents back arrow if this is the main tab
      ),
      body: Center(
        child: SingleChildScrollView( // Added scroll view in case content overflows on small screens
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Home Page",
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),

              // Buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => send_review()));
                },
                child: const Text("Send Review"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => send_feedback()));
                },
                child: const Text("Send feedback"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => view_feedback()));
                },
                child: const Text("View feedback"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => changePassword()));
                },
                child: const Text("Change password"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => view_product()));
                },
                child: const Text("View Product"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => viewOrder()));
                },
                child: const Text("View Order"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}