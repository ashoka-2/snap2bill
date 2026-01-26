
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/widgets/Navbar.dart';

// Import your navigation bar to go to "My Profile"
import 'package:snap2bill/widgets/distributorNavigationbar.dart';

import '../../screens/viewDistributorProfile.dart';
import '../../theme/colors.dart';
// Import the Read-Only profile page

class ViewDistributors extends StatefulWidget {
  const ViewDistributors({Key? key}) : super(key: key);

  @override
  State<ViewDistributors> createState() => _ViewDistributorsState();
}

class _ViewDistributorsState extends State<ViewDistributors> {
  String? _currentUserId; // To store the logged-in user's ID

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("uid");
    });
  }

  // --- API Logic ---
  Future<List<Joke>> _getDistributors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString("ip");
    // 1. Capture the current user's ID here for sorting
    String? currentUid = prefs.getString("uid");

    if (ip == null) return [];

    try {
      var data = await http.post(
          Uri.parse("$ip/distributor_view_distributor"),
          body: {
            "uid": currentUid ?? ""
          }
      );

      if (data.statusCode != 200) return [];

      var jsonData = json.decode(data.body);
      if (jsonData["data"] == null) return [];

      List<Joke> distributors = [];
      for (var item in jsonData["data"]) {
        String baseUrl = ip;
        String profileUrl = _joinUrl(baseUrl, (item["profile_image"] ?? "").toString());
        String proofUrl = _joinUrl(baseUrl, (item["proof"] ?? "").toString());

        Joke newDistributor = Joke(
            (item["id"] ?? "").toString(),
            (item["name"] ?? "").toString(),
            (item["email"] ?? "").toString(),
            (item["phone"] ?? "").toString(),
            profileUrl,
            (item["bio"] ?? "").toString(),
            (item["address"] ?? "").toString(),
            (item["place"] ?? "").toString(),
            (item["pincode"] ?? "").toString(),
            (item["post"] ?? "").toString(),
            (item["latitude"] ?? "").toString(),
            (item["longitude"] ?? "").toString(),
            proofUrl
        );
        distributors.add(newDistributor);
      }

      // --- ADDED: SORTING LOGIC ---
      // This moves the user with 'currentUid' to the front (index 0)
      if (currentUid != null) {
        distributors.sort((a, b) {
          if (a.id == currentUid) return -1; // 'a' moves up
          if (b.id == currentUid) return 1;  // 'b' moves up
          return 0; // Keep others in original order
        });
      }
      // ----------------------------

      return distributors;
    } catch (e) {
      debugPrint("Error: $e");
      return [];
    }
  }
  String _joinUrl(String base, String path) {
    if (path.isEmpty || path == "null") return "";
    if (base.endsWith("/") && path.startsWith("/")) return base + path.substring(1);
    if (!base.endsWith("/") && !path.startsWith("/")) return "$base/$path";
    return base + path;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = theme.cardColor;
    final hintColor = isDark ? Colors.white38 : Colors.grey[500];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: ThemeNavbar(title: "All Distributors",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: ()=>{
        if (Navigator.canPop(context)) Navigator.pop(context)
        },
        centerTitle: true,

      ),
      body: FutureBuilder<List<Joke>>(
        future: _getDistributors(),
        builder: (BuildContext context, AsyncSnapshot<List<Joke>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading distributors", style: TextStyle(color: textColor)));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_outlined, size: 80, color: hintColor),
                  const SizedBox(height: 16),
                  Text(
                    "No distributors found",
                    style: TextStyle(color: hintColor, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              var i = items[index];
              return _buildDistributorCard(i, cardColor, textColor, hintColor!, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildDistributorCard(Joke i, Color cardColor, Color textColor, Color hintColor, bool isDark) {
    bool hasImage = i.profile_image.isNotEmpty && i.profile_image != "null";

    // Check if this card belongs to the logged-in user
    bool isMe = _currentUserId == i.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isMe ? Border.all(color: AppColors.getPrimaryColor(context).withValues(alpha:0.5), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: isDark? Colors.black.withValues(alpha:0.3): Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (isMe) {
              // Navigate to MY Profile Tab (Index 4)
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) =>  DistributorNavigationBar(initialIndex: 4))
              );
            } else {
              // Navigate to THEIR Read-Only Profile Page
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewDistributorProfile(
                    distributorId: i.id,
                    distributorName: i.name,
                  ))
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Profile Image
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.withValues(alpha:0.2), width: 1),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: hasImage ? NetworkImage(i.profile_image) : null,
                    onBackgroundImageError: hasImage
                        ? (_, __) { debugPrint("Image load error"); }
                        : null,
                    child: !hasImage
                        ? Icon(Icons.person, color: Colors.grey.shade400, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // 2. Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              i.name + (isMe ? " (You)" : ""),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isMe ? AppColors.getPrimaryColor(context) : textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isMe)
                             Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.verified, size: 16, color: AppColors.getPrimaryColor(context)),
                            )
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (i.place.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                i.place,
                                style: TextStyle(fontSize: 12, color: hintColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 12),

                      Text(
                        isMe ? "Tap to view your profile" : "Tap to view details",
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.grey.shade500,
                            fontStyle: FontStyle.italic
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: hintColor)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Data Model for the list
class Joke {
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
  final String latitude;
  final String longitude;
  final String proof;

  Joke(
      this.id,
      this.name,
      this.email,
      this.phone,
      this.profile_image,
      this.bio,
      this.address,
      this.place,
      this.pincode,
      this.post,
      this.latitude,
      this.longitude,
      this.proof
      );
}