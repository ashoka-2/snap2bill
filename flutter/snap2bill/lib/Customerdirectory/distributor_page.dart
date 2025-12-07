// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Customerdirectory/Customersends/send_review.dart';
//
// import 'custviews/view_review.dart';
//
//
//
// class distributor_page extends StatelessWidget {
//   const distributor_page({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: distributor_page_sub(),);
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
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String b = prefs.getString("lid").toString();
//     String foodimage="";
//     var data =
//     await http.post(Uri.parse(prefs.getString("ip").toString()+"/customer_view_distributor"),
//         body: {"uid":prefs.getString("uid").toString()}
//     );
//
//     var jsonData = json.decode(data.body);
// //    print(jsonData);
//     List<Joke> jokes = [];
//     for (var joke in jsonData["data"]) {
//       print(joke);
//       Joke newJoke = Joke(
//           joke["id"].toString(),
//           joke["name"].toString(),
//           joke["email"].toString(),
//           joke["phone"].toString(),
//         prefs.getString("ip").toString()+joke["profile_image"].toString(),
//         joke["bio"].toString(),
//
//         joke["address"].toString(),
//
//           joke["place"].toString(),
//           joke["pincode"].toString(),
//           joke["post"].toString(),
//           joke["latitude"].toString(),
//         joke["longitude"].toString(),
//            prefs.getString("ip").toString()+joke["proof"].toString(),
//
//
//       );
//       jokes.add(newJoke);
//     }
//     return jokes;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       body:       Container(
//
//         child:
//         FutureBuilder(
//           future: _getJokes(),
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
// //              print("snapshot"+snapshot.toString());
//             if (snapshot.data == null) {
//               return Container(
//                 child: Center(
//                   child: Text("Loading..."),
//                 ),
//               );
//             } else {
//               return ListView.builder(
//                 itemCount: snapshot.data.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   var i = snapshot.data![index];
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Card(
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         side: BorderSide(color: Colors.grey.shade300),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//
//                             SizedBox(height: 10),
//                             Image.network(i.profile_image.toString(),height: 50,width: 50,),
//                             _buildRow("Name:", i.name.toString()),
//                             _buildRow("Email:", i.email.toString()),
//                             _buildRow("Phone:", i.phone.toString()),
//
//                            SizedBox(height: 10,),
//
//
//                             Row(children: [
//                               ElevatedButton(onPressed: ()async{
//                                 SharedPreferences sh =await SharedPreferences.getInstance();
//                                 sh.setString("uid",i.id.toString());
//                                 Navigator.push(context, MaterialPageRoute(builder: (context)=> send_review()));
//                               }, child: Text("Send Review")),
//                               SizedBox(width: 10,),
//
//                               ElevatedButton(onPressed: () async {
//                                 SharedPreferences sh =await SharedPreferences.getInstance();
//                                 sh.setString("uid",i.id.toString());
//                                 Navigator.push(context, MaterialPageRoute(builder: (context)=>view_review()));
//                               }, child: Text("view review")),
//                             ],)
//
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//
//
//             }
//           },
//
//
//         ),
//
//
//
//
//
//       ),
//
//
//
//     );
//   }
//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           SizedBox(width: 5),
//           Flexible(
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: Colors.grey.shade800,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
// }
//
//
//
//
//
// class Joke {
//   final String id;
//   final String name;
//
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
//
//
//
//
//
//
//   Joke(this.id,this.name, this.email,this.phone,this.profile_image,this.bio,this.address,this.place,this.pincode,this.post,this.latitude,this.longitude,this.proof);
// //  print("hiiiii");
// }
//
//
//
//
//
//
//

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart'; // Ensure shimmer is in pubspec.yaml
// Import your views
import 'package:snap2bill/Customerdirectory/Customersends/send_review.dart';

import 'custviews/view_review.dart';

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
  // State for search
  String _searchQuery = "";

  // Cache the future
  late Future<List<Joke>> _distributorFuture;

  @override
  void initState() {
    super.initState();
    _distributorFuture = _getJokes();
  }

  Future<void> _refreshData() async {
    setState(() {
      _distributorFuture = _getJokes();
    });
  }

  Future<List<Joke>> _getJokes() async {
    // --- ARTIFICIAL DELAY FOR SHIMMER (2 Seconds) ---
    await Future.delayed(const Duration(seconds: 2));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("ip").toString();

    try {
      var data = await http.post(
        Uri.parse("$ip/customer_view_distributor"),
        // Note: passing "uid" might be wrong if you want ALL distributors,
        // but I kept your original logic here.
        body: {"uid": prefs.getString("uid").toString()},
      );

      if (data.statusCode == 200) {
        var jsonData = json.decode(data.body);
        List<Joke> jokes = [];

        if (jsonData["data"] != null) {
          for (var joke in jsonData["data"]) {
            // Fix Image URL
            String imgUrl = joke["profile_image"].toString();
            if (!imgUrl.startsWith("http")) {
              imgUrl = "$ip$imgUrl";
            }

            String proofUrl = joke["proof"].toString();
            if (!proofUrl.startsWith("http")) {
              proofUrl = "$ip$proofUrl";
            }

            Joke newJoke = Joke(
              joke["id"].toString(),
              joke["name"].toString(),
              joke["email"].toString(),
              joke["phone"].toString(),
              imgUrl,
              joke["bio"].toString(),
              joke["address"].toString(),
              joke["place"].toString(),
              joke["pincode"].toString(),
              joke["post"].toString(),
              joke["latitude"].toString(),
              joke["longitude"].toString(),
              proofUrl,
            );
            jokes.add(newJoke);
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // CustomScrollView for floating search bar
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. FLOATING SEARCH BAR (No Back Button)
            SliverAppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              floating: true,
              snap: true,
              pinned: false,
              automaticallyImplyLeading: false, // Removes Back Button
              title: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: theme.inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Search distributor...",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                ),
              ),
            ),

            // 2. LIST CONTENT (WITH SHIMMER)
            FutureBuilder<List<Joke>>(
              future: _distributorFuture,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Joke>> snapshot) {
                    // LOADING -> SHIMMER
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildShimmerList(theme, isDark);
                    }
                    // ERROR
                    else if (snapshot.hasError) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            "Error loading data",
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      );
                    }
                    // EMPTY
                    else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            "No distributors found",
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      );
                    }
                    // SUCCESS
                    else {
                      final filteredList = snapshot.data!.where((item) {
                        return item.name.toLowerCase().contains(_searchQuery) ||
                            item.phone.contains(_searchQuery) ||
                            item.email.toLowerCase().contains(_searchQuery);
                      }).toList();

                      if (filteredList.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Text(
                              "No matches found",
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate((
                          BuildContext context,
                          int index,
                        ) {
                          var item = filteredList[index];
                          return _buildDistributorCard(item, theme, isDark);
                        }, childCount: filteredList.length),
                      );
                    }
                  },
            ),

            // 3. BOTTOM PADDING (Prevents hiding behind navbar)
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  // 1. Shimmer Loading List
  Widget _buildShimmerList(ThemeData theme, bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: isDark ? Colors.black : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const CircleAvatar(radius: 30, backgroundColor: Colors.white),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 150, height: 16, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(width: 200, height: 12, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(width: 100, height: 12, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(width: 10, height: 20, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      }, childCount: 8),
    );
  }

  // 2. Real Distributor Card
  Widget _buildDistributorCard(Joke item, ThemeData theme, bool isDark) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Card tap logic if needed
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      (item.profile_image.isNotEmpty &&
                          item.profile_image != "null")
                      ? NetworkImage(item.profile_image)
                      : null,
                  child:
                      (item.profile_image.isEmpty ||
                          item.profile_image == "null")
                      ? Icon(
                          Icons.person,
                          color: Colors.grey.shade600,
                          size: 30,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 15),

              // Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.phone,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // 3-Dot Menu
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                color: theme.cardColor,
                onSelected: (String value) async {
                  SharedPreferences sh = await SharedPreferences.getInstance();
                  sh.setString("uid", item.id.toString());

                  if (value == 'send_review') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => send_review()),
                    );
                  } else if (value == 'view_review') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => view_review()),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'send_review',
                    child: Row(
                      children: [
                        Icon(
                          Icons.rate_review,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Send Review',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'view_review',
                    child: Row(
                      children: [
                        Icon(
                          Icons.reviews,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'View Reviews',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Keeping your original model class name
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
    this.proof,
  );
}
