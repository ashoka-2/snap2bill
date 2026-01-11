//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:snap2bill/Customerdirectory/Customersends/send_review.dart';
// import 'package:snap2bill/Customerdirectory/custviews/view_review.dart';
//
// import '../screens/viewDistributorProfile.dart';
// import 'custviews/viewOrder.dart';
//
// class distributor_page extends StatelessWidget {
//   const distributor_page({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const distributor_page_sub();
//   }
// }
//
// class distributor_page_sub extends StatefulWidget {
//   const distributor_page_sub({Key? key}) : super(key: key);
//
//   @override
//   State<distributor_page_sub> createState() => _distributor_page_subState();
// }
//
// class _distributor_page_subState extends State<distributor_page_sub> {
//   String _searchQuery = "";
//   late Future<List<Joke>> _distributorFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _distributorFuture = _getJokes();
//   }
//
//   Future<void> _refreshData() async {
//     setState(() {
//       _distributorFuture = _getJokes();
//     });
//   }
//
//   Future<List<Joke>> _getJokes() async {
//     await Future.delayed(const Duration(seconds: 1));
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String ip = prefs.getString("ip").toString();
//     String cid = prefs.getString("cid").toString();
//
//     try {
//       var data = await http.post(
//         Uri.parse("$ip/customer_view_distributor"),
//         body: {"cid": cid},
//       );
//
//       if (data.statusCode == 200) {
//         var jsonData = json.decode(data.body);
//         List<Joke> jokes = [];
//
//         if (jsonData["status"] == "ok" && jsonData["data"] != null) {
//           for (var item in jsonData["data"]) {
//             String imgUrl = item["profile_image"].toString();
//             if (!imgUrl.startsWith("http")) {
//               imgUrl = "$ip$imgUrl";
//             }
//
//             jokes.add(Joke(
//               item["id"].toString(),
//               item["name"].toString(),
//               item["email"].toString(),
//               item["phone"].toString(),
//               imgUrl,
//               item["bio"].toString(),
//               item["address"].toString(),
//               item["place"].toString(),
//               item["pincode"].toString(),
//               item["post"].toString(),
//               item["latitude"]?.toString() ?? "",
//               item["longitude"]?.toString() ?? "",
//               "",
//             ));
//           }
//         }
//         return jokes;
//       } else {
//         return [];
//       }
//     } catch (e) {
//       debugPrint("Error fetching distributors: $e");
//       return [];
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: RefreshIndicator(
//         onRefresh: _refreshData,
//         child: CustomScrollView(
//           physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
//           slivers: [
//             SliverAppBar(
//               backgroundColor: theme.scaffoldBackgroundColor,
//               elevation: 0,
//               floating: true,
//               snap: true,
//               automaticallyImplyLeading: false,
//               title: Container(
//                 height: 45,
//                 decoration: BoxDecoration(
//                   color: isDark ? Colors.white10 : Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: TextField(
//                   onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
//                   style: TextStyle(color: isDark ? Colors.white : Colors.black),
//                   decoration: InputDecoration(
//                     hintText: "Search my distributors...",
//                     hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
//                     prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(vertical: 10),
//                   ),
//                 ),
//               ),
//             ),
//
//             FutureBuilder<List<Joke>>(
//               future: _distributorFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return _buildShimmerList(isDark);
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const SliverFillRemaining(
//                     child: Center(child: Text("No linked distributors found")),
//                   );
//                 }
//
//                 final filteredList = snapshot.data!.where((item) {
//                   return item.name.toLowerCase().contains(_searchQuery) ||
//                       item.phone.contains(_searchQuery);
//                 }).toList();
//
//                 return SliverList(
//                   delegate: SliverChildBuilderDelegate((context, index) {
//                     return _buildDistributorCard(filteredList[index], theme, isDark);
//                   }, childCount: filteredList.length),
//                 );
//               },
//             ),
//             const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDistributorCard(Joke item, ThemeData theme, bool isDark) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//         side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
//       ),
//       child: InkWell(
//         onTap: () async {
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           await prefs.setString("selected_distributor_id", item.id);
//           Navigator.push(context, MaterialPageRoute(builder: (context) => const viewOrder()));
//         },
//         borderRadius: BorderRadius.circular(15),
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Row(
//             children: [
//               // ✅ Hero Animation Avatar (Navigate to Profile on Click)
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ViewDistributorProfile(
//                         distributorId: item.id,
//                         distributorName: item.name,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Hero(
//                   tag: 'avatar_${item.id}',
//                   child: CircleAvatar(
//                     radius: 30,
//                     backgroundColor: Colors.blue.shade50,
//                     backgroundImage: item.profile_image.startsWith("http")
//                         ? NetworkImage(item.profile_image)
//                         : null,
//                     child: !item.profile_image.startsWith("http")
//                         ? const Icon(Icons.business, color: Colors.blue)
//                         : null,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 15),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                     const SizedBox(height: 4),
//                     Text(item.phone, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
//                     Text(item.place, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
//                   ],
//                 ),
//               ),
//               PopupMenuButton<String>(
//                 icon: const Icon(Icons.more_vert),
//                 onSelected: (String value) async {
//                   SharedPreferences prefs = await SharedPreferences.getInstance();
//                   prefs.setString("uid", item.id.toString());
//                   prefs.setString("selected_distributor_id", item.id.toString());
//
//                   if (value == 'send_review') {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => send_review()));
//                   } else if (value == 'view_review') {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => view_review()));
//                   } else if (value == 'view_bills') {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => const viewOrder()));
//                   } else if (value == 'view_profile') { // ✅ Navigate to Profile from Popup
//                     Navigator.push(context, MaterialPageRoute(builder: (context) =>
//                         ViewDistributorProfile(distributorId: item.id, distributorName: item.name)));
//                   }
//                 },
//                 itemBuilder: (context) => [
//                   const PopupMenuItem(value: 'view_profile', child: ListTile(leading: Icon(Icons.person_outline, color: Colors.blue), title: Text("View Profile"))),
//                   const PopupMenuItem(value: 'view_bills', child: ListTile(leading: Icon(Icons.history, color: Colors.blue), title: Text("My Bills"))),
//                   const PopupMenuItem(value: 'send_review', child: ListTile(leading: Icon(Icons.rate_review, color: Colors.blue), title: Text("Rate"))),
//                   const PopupMenuItem(value: 'view_review', child: ListTile(leading: Icon(Icons.reviews, color: Colors.blue), title: Text("Reviews"))),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildShimmerList(bool isDark) {
//     return SliverList(
//       delegate: SliverChildBuilderDelegate((context, index) {
//         return Shimmer.fromColors(
//           baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
//           highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//             height: 90,
//             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
//           ),
//         );
//       }, childCount: 6),
//     );
//   }
// }
//
// class Joke {
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
//   final String latitude;
//   final String longitude;
//   final String proof;
//
//   Joke(this.id, this.name, this.email, this.phone, this.profile_image, this.bio, this.address, this.place, this.pincode, this.post, this.latitude, this.longitude, this.proof);
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snap2bill/Customerdirectory/Customersends/send_review.dart';
import 'package:snap2bill/Customerdirectory/custviews/view_review.dart';

// Navigation targets
import '../screens/viewDistributorProfile.dart';
import 'custviews/viewOrder.dart';
import '../widgets/SearchBar.dart'; // Ensure this points to your SearchAppBar file

class distributor_page extends StatelessWidget {
  const distributor_page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const distributor_page_sub();
  }
}

class distributor_page_sub extends StatefulWidget {
  const distributor_page_sub({Key? key}) : super(key: key);

  @override
  State<distributor_page_sub> createState() => _distributor_page_subState();
}

class _distributor_page_subState extends State<distributor_page_sub> {
  String _searchQuery = "";
  late Future<List<Joke>> _distributorFuture;

  @override
  void initState() {
    super.initState();
    _distributorFuture = _getDistributors();
  }

  Future<void> _refreshData() async {
    setState(() {
      _distributorFuture = _getDistributors();
    });
    await _distributorFuture;
  }

  Future<List<Joke>> _getDistributors() async {
    await Future.delayed(const Duration(milliseconds: 800));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("ip") ?? "";
    String cid = prefs.getString("cid") ?? "";

    try {
      var response = await http.post(
        Uri.parse("$ip/customer_view_distributor"),
        body: {"cid": cid},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List<Joke> jokes = [];

        if (jsonData["status"] == "ok" && jsonData["data"] != null) {
          for (var item in jsonData["data"]) {
            String imgUrl = item["profile_image"]?.toString() ?? "";
            if (imgUrl.isNotEmpty && !imgUrl.startsWith("http")) {
              imgUrl = "$ip$imgUrl";
            }

            jokes.add(Joke(
              item["id"].toString(),
              item["name"]?.toString() ?? "Unknown",
              item["email"]?.toString() ?? "",
              item["phone"]?.toString() ?? "",
              imgUrl,
              item["bio"]?.toString() ?? "",
              item["address"]?.toString() ?? "",
              item["place"]?.toString() ?? "",
              item["pincode"]?.toString() ?? "",
              item["post"]?.toString() ?? "",
              item["latitude"]?.toString() ?? "",
              item["longitude"]?.toString() ?? "",
              "",
            ));
          }
        }
        return jokes;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching distributors: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      // 🚀 Fix: Unfocus keyboard when tapping anywhere outside
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        // 🚀 Unified Search Bar in AppBar
        appBar: SearchAppBar(
          hintText: "Search distributors, place or phone...",
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          displacement: 20,
          color: Colors.blueAccent,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              FutureBuilder<List<Joke>>(
                future: _distributorFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerList(isDark);
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business_center_outlined, size: 60, color: Colors.grey),
                            SizedBox(height: 10),
                            Text("No linked distributors found", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  }

                  // 🚀 Advanced filtering: Name, Phone, and Place
                  final filteredList = snapshot.data!.where((item) {
                    return item.name.toLowerCase().contains(_searchQuery) ||
                        item.phone.contains(_searchQuery) ||
                        item.place.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredList.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text("No matching distributors found")),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildDistributorCard(filteredList[index], theme, isDark),
                      childCount: filteredList.length,
                    ),
                  );
                },
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistributorCard(Joke item, ThemeData theme, bool isDark) {
    final subTextColor = isDark ? Colors.white70 : Colors.grey.shade600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString("selected_distributor_id", item.id);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const viewOrder()));
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewDistributorProfile(
                          distributorId: item.id,
                          distributorName: item.name,
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'avatar_${item.id}',
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade50,
                      backgroundImage: item.profile_image.startsWith("http")
                          ? NetworkImage(item.profile_image)
                          : null,
                      child: !item.profile_image.startsWith("http")
                          ? const Icon(Icons.business, color: Colors.blue)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(item.phone, style: TextStyle(fontSize: 12, color: subTextColor)),
                      Text(item.place, style: TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  icon: const Icon(Icons.more_vert),
                  onSelected: (String value) async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString("uid", item.id.toString());
                    prefs.setString("selected_distributor_id", item.id.toString());

                    if (value == 'send_review') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => send_review()));
                    } else if (value == 'view_review') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => view_review()));
                    } else if (value == 'view_bills') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const viewOrder()));
                    } else if (value == 'view_profile') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          ViewDistributorProfile(distributorId: item.id, distributorName: item.name)));
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view_profile', child: ListTile(leading: Icon(Icons.person_outline, color: Colors.blue), title: Text("Profile"))),
                    const PopupMenuItem(value: 'view_bills', child: ListTile(leading: Icon(Icons.history, color: Colors.blue), title: Text("My Bills"))),
                    const PopupMenuItem(value: 'send_review', child: ListTile(leading: Icon(Icons.rate_review, color: Colors.blue), title: Text("Rate"))),
                    const PopupMenuItem(value: 'view_review', child: ListTile(leading: Icon(Icons.reviews, color: Colors.blue), title: Text("Reviews"))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList(bool isDark) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            height: 90,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          ),
        );
      }, childCount: 6),
    );
  }
}

class Joke {
  final String id, name, email, phone, profile_image, bio, address, place, pincode, post, latitude, longitude, proof;
  Joke(this.id, this.name, this.email, this.phone, this.profile_image, this.bio, this.address, this.place, this.pincode, this.post, this.latitude, this.longitude, this.proof);
}