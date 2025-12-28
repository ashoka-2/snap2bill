// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// // Import your edit page
// import 'package:snap2bill/Customerdirectory/Edits/edit_customer_profile.dart';
// // import 'package:snap2bill/Customerdirectory/customer_home_page.dart'; // Unused in this file
//
// class profile_page extends StatelessWidget {
//   const profile_page({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Removed MaterialApp to prevent navigation issues
//     return const profile_page_sub();
//   }
// }
//
// class profile_page_sub extends StatefulWidget {
//   const profile_page_sub({Key? key}) : super(key: key);
//
//   @override
//   State<profile_page_sub> createState() => _profile_page_subState();
// }
//
// class _profile_page_subState extends State<profile_page_sub> {
//
//   // Renamed class 'Joke' to 'CustomerProfileModel' for clarity, logic remains same
//   Future<List<CustomerProfileModel>> _getData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? ip = prefs.getString("ip");
//     String? cid = prefs.getString("cid");
//
//     var data = await http.post(
//       Uri.parse("$ip/customer_view_profile"),
//       body: {"cid": cid ?? ""},
//     );
//
//     var jsonData = json.decode(data.body);
//     List<CustomerProfileModel> profiles = [];
//
//     // Check if data exists
//     if (jsonData["data"] != null) {
//       for (var item in jsonData["data"]) {
//         CustomerProfileModel newProfile = CustomerProfileModel(
//           item["id"].toString(),
//           item["name"].toString(),
//           item["email"].toString(),
//           item["phone"].toString(),
//           "$ip${item["profile_image"]}",
//           item["bio"].toString(),
//           item["address"].toString(),
//           item["place"].toString(),
//           item["pincode"].toString(),
//           item["post"].toString(),
//         );
//         profiles.add(newProfile);
//       }
//     }
//     return profiles;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final bool isDark = theme.brightness == Brightness.dark;
//     final Color textColor = isDark ? Colors.white : Colors.black;
//
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: theme.scaffoldBackgroundColor,
//         elevation: 0,
//         title: Row(
//           children: [
//             Icon(Icons.lock_outline, size: 18, color: textColor),
//             const SizedBox(width: 5),
//             Text(
//               "Profile", // You can replace this with username if available
//               style: TextStyle(
//                   color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
//             ),
//           ],
//         ),
//       ),
//       body: FutureBuilder<List<CustomerProfileModel>>(
//         future: _getData(),
//         builder: (BuildContext context, AsyncSnapshot<List<CustomerProfileModel>> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           } else if (snapshot.data == null || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No profile found"));
//           } else {
//             // Usually only one profile, but keeping ListView as per logic
//             return ListView.builder(
//               itemCount: snapshot.data!.length,
//               itemBuilder: (BuildContext context, int index) {
//                 var profile = snapshot.data![index];
//                 return _buildInstagramProfile(context, profile, theme, textColor);
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildInstagramProfile(BuildContext context, CustomerProfileModel i, ThemeData theme, Color textColor) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // 1. HEADER (Pic + Stats/Info)
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Row(
//             children: [
//               // Profile Image
//               Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.grey.shade300, width: 1),
//                 ),
//                 padding: const EdgeInsets.all(3),
//                 child: CircleAvatar(
//                   radius: 40,
//                   backgroundImage: NetworkImage(i.profile_image),
//                   backgroundColor: Colors.grey.shade200,
//                   onBackgroundImageError: (_, __) => const Icon(Icons.person),
//                 ),
//               ),
//               const SizedBox(width: 20),
//
//               // Name and Title Area (Replaces Stats)
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       i.name,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: textColor,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       "Customer Account",
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         // 2. BIO SECTION
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Bio Text
//               if (i.bio.isNotEmpty && i.bio != "null")
//                 Text(
//                   i.bio,
//                   style: TextStyle(color: textColor, fontSize: 14),
//                 )
//               else
//                 Text(
//                   "No bio available.",
//                   style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
//                 ),
//
//               const SizedBox(height: 5),
//               // Address as link-style
//               Row(
//                 children: [
//                   Icon(Icons.location_on, size: 14, color: Colors.blue.shade700),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       i.address,
//                       style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//
//         // 3. EDIT BUTTON
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: SizedBox(
//             width: double.infinity,
//             height: 35,
//             child: OutlinedButton(
//               style: OutlinedButton.styleFrom(
//                 backgroundColor: theme.cardColor,
//                 side: BorderSide(color: Colors.grey.shade300),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => edit_customer_profile_sub(
//                       id: i.id,
//                       name: i.name,
//                       email: i.email,
//                       phone: i.phone,
//                       bio: i.bio,
//                       address: i.address,
//                       pincode: i.pincode,
//                       place: i.place,
//                       post: i.post,
//                     ),
//                   ),
//                 );
//               },
//               child: Text(
//                 "Edit Profile",
//                 style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
//               ),
//             ),
//           ),
//         ),
//
//         const SizedBox(height: 15),
//
//         // 4. HIGHLIGHTS (Place, Post, Pincode)
//         // Mimics Instagram "Story Highlights"
//         SizedBox(
//           height: 85,
//           child: ListView(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.only(left: 16),
//             children: [
//               _buildHighlight(i.place, Icons.place, textColor),
//               _buildHighlight(i.pincode, Icons.pin_drop, textColor),
//               _buildHighlight(i.post, Icons.local_post_office, textColor),
//             ],
//           ),
//         ),
//
//         const Divider(height: 1),
//
//         // 5. CONTACT DETAILS LIST
//         _buildDetailItem(Icons.email_outlined, "Email", i.email, textColor),
//         _buildDetailItem(Icons.phone_android_outlined, "Phone", i.phone, textColor),
//         _buildDetailItem(Icons.map_outlined, "Full Address", "${i.address}, ${i.place}", textColor),
//
//         const SizedBox(height: 20),
//       ],
//     );
//   }
//
//   // Helper for "Story Highlights" circles
//   Widget _buildHighlight(String label, IconData icon, Color textColor) {
//     if (label == "null" || label.isEmpty) return const SizedBox();
//
//     return Padding(
//       padding: const EdgeInsets.only(right: 20.0),
//       child: Column(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.grey.shade300),
//               color: Colors.grey.shade50,
//             ),
//             child: Icon(icon, color: Colors.black87),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             label,
//             style: TextStyle(fontSize: 12, color: textColor),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper for List Items
//   Widget _buildDetailItem(IconData icon, String title, String value, Color textColor) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.grey.shade700),
//       title: Text(
//         title,
//         style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//       ),
//       subtitle: Text(
//         value,
//         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
//       ),
//     );
//   }
// }
//
// // Renamed for clarity (Logic identical to your 'Joke' class)
// class CustomerProfileModel {
//   final String id;
//   final String name;
//   final String email;
//   final String phone;
//   final String profile_image;
//   final String bio;
//   final String address;
//   final String place;
//   final String pincode;
//   final String post;
//
//   CustomerProfileModel(
//       this.id,
//       this.name,
//       this.email,
//       this.phone,
//       this.profile_image,
//       this.bio,
//       this.address,
//       this.place,
//       this.pincode,
//       this.post);
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snap2bill/Customerdirectory/Edits/edit_customer_profile.dart';

// Main Class for Navigation
class profile_page extends StatelessWidget {
  const profile_page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ProfilePageSub();
  }
}

class ProfilePageSub extends StatefulWidget {
  const ProfilePageSub({Key? key}) : super(key: key);

  @override
  State<ProfilePageSub> createState() => _ProfilePageSubState();
}

class _ProfilePageSubState extends State<ProfilePageSub> {

  // API Logic
  Future<List<CustomerProfileModel>> _getData() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip") ?? "";
    String cid = sh.getString("cid") ?? "";

    var data = await http.post(
      Uri.parse("$ip/customer_view_profile"),
      body: {"cid": cid},
    );

    var jsonData = json.decode(data.body);
    List<CustomerProfileModel> profiles = [];

    if (jsonData["data"] != null) {
      for (var item in jsonData["data"]) {
        profiles.add(CustomerProfileModel(
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
        ));
      }
    }
    return profiles;
  }

  // ✅ Proper Structured Sharing
  void _shareProfile(CustomerProfileModel profile) {
    final String shareMessage = """
👤 *Snap2Bill Customer Profile*
---------------------------
✨ *Name:* ${profile.name}
📍 *Location:* ${profile.place}, ${profile.post}
📱 *Contact:* ${profile.phone}

Check out my profile on Snap2Bill!
---------------------------
🚀 Download the app for better billing management.
""";

    Share.share(shareMessage, subject: "${profile.name}'s Profile");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 22
          ),
        ),
      ),
      body: FutureBuilder<List<CustomerProfileModel>>(
        future: _getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No profile found"));
          }

          final profile = snapshot.data![0];
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(profile, textColor, isDark, theme),
                  _buildBio(profile, textColor),
                  _buildActionButtons(profile, theme, textColor, isDark),
                  _buildHighlights(profile, textColor, isDark),
                  const Divider(thickness: 1, height: 40),
                  _buildContactSection(profile, textColor, isDark),

                  // ✅ Extra space so Nav Bar doesn't cover content
                  const SizedBox(height: 120),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(CustomerProfileModel i, Color textColor, bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        children: [
          // ✅ Theme switching border
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: isDark ? Colors.blueAccent.withOpacity(0.6) : Colors.grey.shade300,
                  width: 2.5
              ),
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: theme.scaffoldBackgroundColor,
              backgroundImage: NetworkImage(i.profile_image),
              onBackgroundImageError: (_, __) => const Icon(Icons.person, size: 40),
            ),
          ),
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(label: "Orders", value: "24"),
                _StatItem(label: "Distributors", value: "8"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBio(CustomerProfileModel i, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(i.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor)),
          Text("Snap2Bill Verified Account", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            (i.bio == "null" || i.bio.isEmpty) ? "Welcome to my Snap2Bill profile!" : i.bio,
            style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CustomerProfileModel i, ThemeData theme, Color textColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                foregroundColor: textColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => edit_customer_profile(
                      id: i.id, name: i.name, email: i.email,
                      phone: i.phone, bio: i.bio, address: i.address,
                      pincode: i.pincode, place: i.place, post: i.post,
                    ),
                  ),
                ).then((_) => setState(() {}));
              },
              child: const Text("Edit Profile"),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                foregroundColor: textColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _shareProfile(i),
              child: const Text("Share Profile"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights(CustomerProfileModel i, Color textColor, bool isDark) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _HighlightCircle(label: i.place, icon: Icons.location_city, isDark: isDark),
          _HighlightCircle(label: i.post, icon: Icons.local_post_office, isDark: isDark),
          _HighlightCircle(label: i.pincode, icon: Icons.pin_drop, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildContactSection(CustomerProfileModel i, Color textColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Account Information",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor)),
          const SizedBox(height: 15),
          _ContactTile(icon: Icons.email_outlined, title: "Email", value: i.email, isDark: isDark),
          _ContactTile(icon: Icons.phone_iphone, title: "Phone", value: i.phone, isDark: isDark),
          _ContactTile(icon: Icons.house_outlined, title: "Address", value: i.address, isDark: isDark),
        ],
      ),
    );
  }
}

// Data Model
class CustomerProfileModel {
  final String id, name, email, phone, profile_image, bio, address, place, pincode, post;
  CustomerProfileModel(this.id, this.name, this.email, this.phone, this.profile_image, this.bio, this.address, this.place, this.pincode, this.post);
}

// UI Components
class _StatItem extends StatelessWidget {
  final String label, value;
  const _StatItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}

class _HighlightCircle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  const _HighlightCircle({required this.label, required this.icon, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18.0),
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300, width: 1.5),
              color: isDark ? Colors.white10 : Colors.grey.shade50,
            ),
            child: Icon(icon, color: isDark ? Colors.white70 : Colors.black87, size: 28),
          ),
          const SizedBox(height: 6),
          SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title, value;
  final bool isDark;
  const _ContactTile({required this.icon, required this.title, required this.value, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.blueAccent.withOpacity(0.7) : Colors.grey.shade700),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}