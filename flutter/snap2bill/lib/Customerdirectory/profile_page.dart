import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Import your edit page
import 'package:snap2bill/Customerdirectory/Edits/edit_customer_profile.dart';
// import 'package:snap2bill/Customerdirectory/customer_home_page.dart'; // Unused in this file

class profile_page extends StatelessWidget {
  const profile_page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Removed MaterialApp to prevent navigation issues
    return const profile_page_sub();
  }
}

class profile_page_sub extends StatefulWidget {
  const profile_page_sub({Key? key}) : super(key: key);

  @override
  State<profile_page_sub> createState() => _profile_page_subState();
}

class _profile_page_subState extends State<profile_page_sub> {

  // Renamed class 'Joke' to 'CustomerProfileModel' for clarity, logic remains same
  Future<List<CustomerProfileModel>> _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString("ip");
    String? cid = prefs.getString("cid");

    var data = await http.post(
      Uri.parse("$ip/customer_view_profile"),
      body: {"cid": cid ?? ""},
    );

    var jsonData = json.decode(data.body);
    List<CustomerProfileModel> profiles = [];

    // Check if data exists
    if (jsonData["data"] != null) {
      for (var item in jsonData["data"]) {
        CustomerProfileModel newProfile = CustomerProfileModel(
          item["id"].toString(),
          item["name"].toString(),
          item["email"].toString(),
          item["phone"].toString(),
          "$ip${item["profile_image"]}",
          item["bio"].toString(),
          item["address"].toString(),
          item["place"].toString(),
          item["pincode"].toString(),
          item["post"].toString(),
        );
        profiles.add(newProfile);
      }
    }
    return profiles;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.lock_outline, size: 18, color: textColor),
            const SizedBox(width: 5),
            Text(
              "Profile", // You can replace this with username if available
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<CustomerProfileModel>>(
        future: _getData(),
        builder: (BuildContext context, AsyncSnapshot<List<CustomerProfileModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No profile found"));
          } else {
            // Usually only one profile, but keeping ListView as per logic
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                var profile = snapshot.data![index];
                return _buildInstagramProfile(context, profile, theme, textColor);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildInstagramProfile(BuildContext context, CustomerProfileModel i, ThemeData theme, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. HEADER (Pic + Stats/Info)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Profile Image
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(i.profile_image),
                  backgroundColor: Colors.grey.shade200,
                  onBackgroundImageError: (_, __) => const Icon(Icons.person),
                ),
              ),
              const SizedBox(width: 20),

              // Name and Title Area (Replaces Stats)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Customer Account",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. BIO SECTION
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bio Text
              if (i.bio.isNotEmpty && i.bio != "null")
                Text(
                  i.bio,
                  style: TextStyle(color: textColor, fontSize: 14),
                )
              else
                Text(
                  "No bio available.",
                  style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                ),

              const SizedBox(height: 5),
              // Address as link-style
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.blue.shade700),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      i.address,
                      style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 3. EDIT BUTTON
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            height: 35,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: theme.cardColor,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => edit_customer_profile_sub(
                      id: i.id,
                      name: i.name,
                      email: i.email,
                      phone: i.phone,
                      bio: i.bio,
                      address: i.address,
                      pincode: i.pincode,
                      place: i.place,
                      post: i.post,
                    ),
                  ),
                );
              },
              child: Text(
                "Edit Profile",
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),

        // 4. HIGHLIGHTS (Place, Post, Pincode)
        // Mimics Instagram "Story Highlights"
        SizedBox(
          height: 85,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            children: [
              _buildHighlight(i.place, Icons.place, textColor),
              _buildHighlight(i.pincode, Icons.pin_drop, textColor),
              _buildHighlight(i.post, Icons.local_post_office, textColor),
            ],
          ),
        ),

        const Divider(height: 1),

        // 5. CONTACT DETAILS LIST
        _buildDetailItem(Icons.email_outlined, "Email", i.email, textColor),
        _buildDetailItem(Icons.phone_android_outlined, "Phone", i.phone, textColor),
        _buildDetailItem(Icons.map_outlined, "Full Address", "${i.address}, ${i.place}", textColor),

        const SizedBox(height: 20),
      ],
    );
  }

  // Helper for "Story Highlights" circles
  Widget _buildHighlight(String label, IconData icon, Color textColor) {
    if (label == "null" || label.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade50,
            ),
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Helper for List Items
  Widget _buildDetailItem(IconData icon, String title, String value, Color textColor) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(
        title,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      subtitle: Text(
        value,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
      ),
    );
  }
}

// Renamed for clarity (Logic identical to your 'Joke' class)
class CustomerProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profile_image;
  final String bio;
  final String address;
  final String place;
  final String pincode;
  final String post;

  CustomerProfileModel(
      this.id,
      this.name,
      this.email,
      this.phone,
      this.profile_image,
      this.bio,
      this.address,
      this.place,
      this.pincode,
      this.post);
}