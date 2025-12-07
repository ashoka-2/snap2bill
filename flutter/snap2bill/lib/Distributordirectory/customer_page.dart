// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Distributordirectory/view/myProducts.dart';
//
// class customer_page extends StatelessWidget {
//   const customer_page({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: customer_page_sub());
//   }
// }
//
// class customer_page_sub extends StatefulWidget {
//   const customer_page_sub({Key? key}) : super(key: key);
//
//   @override
//   State<customer_page_sub> createState() => _customer_page_subState();
// }
//
// class _customer_page_subState extends State<customer_page_sub> {
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String b = prefs.getString("lid").toString();
//     String foodimage = "";
//     var data = await http.post(
//       Uri.parse(
//         prefs.getString("ip").toString() + "/distributor_view_customer",
//       ),
//       body: {"cid": prefs.getString("cid").toString()},
//     );
//
//     var jsonData = json.decode(data.body);
//     //    print(jsonData);
//     List<Joke> jokes = [];
//     for (var joke in jsonData["data"]) {
//       print(joke);
//       Joke newJoke = Joke(
//         joke["id"].toString(),
//         joke["name"].toString(),
//         joke["email"].toString(),
//         joke["phone"].toString(),
//         prefs.getString("ip").toString() + joke["profile_image"].toString(),
//         joke["bio"].toString(),
//         joke["address"].toString(),
//         joke["place"].toString(),
//         joke["pincode"].toString(),
//         joke["post"].toString(),
//       );
//       jokes.add(newJoke);
//     }
//     return jokes;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         child: FutureBuilder(
//           future: _getJokes(),
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             //              print("snapshot"+snapshot.toString());
//             if (snapshot.data == null) {
//               return Container(child: Center(child: Text("Loading...")));
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
//                             SizedBox(height: 10),
//                             Image.network(
//                               i.profile_image.toString(),
//                               height: 50,
//                               width: 50,
//                             ),
//                             _buildRow("Name:", i.name.toString()),
//                             _buildRow("Email:", i.email.toString()),
//                             _buildRow("Phone:", i.phone.toString()),
//                             SizedBox(height: 10),
//                             Row(
//                               children: [
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => myProducts(),
//                                       ),
//                                     );
//                                   },
//                                   child: Text("Add bill"),
//                                 ),
//                                 SizedBox(width: 10),
//                                 ElevatedButton(
//                                   onPressed: () {},
//                                   child: Text("view bills"),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//           SizedBox(width: 5),
//           Flexible(
//             child: Text(value, style: TextStyle(color: Colors.grey.shade800)),
//           ),
//         ],
//       ),
//     );
//   }
// }
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
//
//   Joke(
//     this.id,
//     this.name,
//     this.email,
//     this.phone,
//     this.profile_image,
//     this.bio,
//     this.address,
//     this.place,
//     this.pincode,
//     this.post,
//   );
//   //  print("hiiiii");
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart'; // Ensure shimmer is in pubspec.yaml
// Import your page
import 'package:snap2bill/Distributordirectory/view/myProducts.dart';

class customer_page extends StatelessWidget {
  const customer_page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const customer_page_sub();
  }
}

class customer_page_sub extends StatefulWidget {
  const customer_page_sub({Key? key}) : super(key: key);

  @override
  State<customer_page_sub> createState() => _customer_page_subState();
}

class _customer_page_subState extends State<customer_page_sub> {
  // State for search functionality
  String _searchQuery = "";

  // Cache the future
  late Future<List<Joke>> _customerFuture;

  @override
  void initState() {
    super.initState();
    _customerFuture = _getJokes();
  }

  Future<void> _refreshData() async {
    setState(() {
      _customerFuture = _getJokes();
    });
  }

  Future<List<Joke>> _getJokes() async {
    // --- ARTIFICIAL DELAY TO SHOW SHIMMER (2 Seconds) ---
    await Future.delayed(const Duration(seconds: 2));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("ip").toString();

    try {
      var data = await http.post(
        Uri.parse("$ip/distributor_view_customer"),
        body: {"cid": prefs.getString("cid").toString()},
      );

      if (data.statusCode == 200) {
        var jsonData = json.decode(data.body);
        List<Joke> jokes = [];

        if (jsonData["data"] != null) {
          for (var joke in jsonData["data"]) {
            String imgUrl = joke["profile_image"].toString();
            if (!imgUrl.startsWith("http")) {
              imgUrl = "$ip$imgUrl";
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
            );
            jokes.add(newJoke);
          }
        }
        return jokes;
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching customers: $e");
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
            // 1. FLOATING SEARCH BAR
            SliverAppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              floating: true,
              snap: true,
              pinned: false,
              automaticallyImplyLeading: false,
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
                    hintText: "Search customer...",
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
              future: _customerFuture,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Joke>> snapshot) {
                    // STATE: LOADING -> SHOW SHIMMER
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildShimmerList(theme, isDark);
                    }
                    // STATE: ERROR
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
                    // STATE: EMPTY
                    else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            "No customers found",
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      );
                    }
                    // STATE: SUCCESS
                    else {
                      final filteredList = snapshot.data!.where((customer) {
                        return customer.name.toLowerCase().contains(
                              _searchQuery,
                            ) ||
                            customer.phone.contains(_searchQuery) ||
                            customer.email.toLowerCase().contains(_searchQuery);
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
                          return _buildInstagramCard(item, theme, isDark);
                        }, childCount: filteredList.length),
                      );
                    }
                  },
            ),

            // 3. BOTTOM PADDING
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  // 1. Shimmer Loading List
  Widget _buildShimmerList(ThemeData theme, bool isDark) {
    // Determine colors based on theme
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              // Use a generic container color for skeleton
              color: isDark ? Colors.black : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Avatar Skeleton
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(width: 15),
                    // Text Skeleton
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150,
                            height: 16,
                            color: Colors.white,
                          ), // Name
                          const SizedBox(height: 8),
                          Container(
                            width: 200,
                            height: 12,
                            color: Colors.white,
                          ), // Email
                          const SizedBox(height: 6),
                          Container(
                            width: 100,
                            height: 12,
                            color: Colors.white,
                          ), // Phone
                        ],
                      ),
                    ),
                    // Menu Icon Skeleton
                    const SizedBox(width: 10),
                    Container(width: 10, height: 20, color: Colors.white),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: 8, // Show 8 skeleton items
      ),
    );
  }

  // 2. Real Data Card
  Widget _buildInstagramCard(Joke item, ThemeData theme, bool isDark) {
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
          print("Clicked on ${item.name}");
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

              // Customer Info
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

              // Menu
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                color: theme.cardColor,
                onSelected: (String value) {
                  if (value == 'add_bill') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => myProducts()),
                    );
                  } else if (value == 'view_bills') {
                    // View Bills Logic
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'add_bill',
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Add Bill',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'view_bills',
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'View Bills',
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
  );
}
