import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/Editfolder/edit_distributor_profile.dart';



class profile_page extends StatelessWidget {
  const profile_page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: profile_page_sub(),);
  }
}

class profile_page_sub extends StatefulWidget {
  const profile_page_sub({Key? key}) : super(key: key);

  @override
  State<profile_page_sub> createState() => _profile_page_subState();
}

class _profile_page_subState extends State<profile_page_sub> {
  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String b = prefs.getString("lid").toString();
    String foodimage="";
    var data =
    await http.post(Uri.parse(prefs.getString("ip").toString()+"/distributor_view_profile"),
        body: {"uid":prefs.getString("uid").toString()}
    );

    var jsonData = json.decode(data.body);
//    print(jsonData);
    List<Joke> jokes = [];
    for (var joke in jsonData["data"]) {
      print(joke);
      Joke newJoke = Joke(
          joke["id"].toString(),
          joke["name"].toString(),
          joke["email"].toString(),
          joke["phone"].toString(),
        prefs.getString("ip").toString()+joke["profile_image"].toString(),
        joke["bio"].toString(),

        joke["address"].toString(),

          joke["place"].toString(),
          joke["pincode"].toString(),
          joke["post"].toString(),
          joke["latitude"].toString(),
        joke["longitude"].toString(),
           prefs.getString("ip").toString()+joke["proof"].toString(),


      );
      jokes.add(newJoke);
    }
    return jokes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:       Container(

        child:
        FutureBuilder(
          future: _getJokes(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
//              print("snapshot"+snapshot.toString());
            if (snapshot.data == null) {
              return Container(
                child: Center(
                  child: Text("Loading..."),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  var i = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            SizedBox(height: 10),
                            Image.network(i.profile_image.toString(),height: 100,width: 100,),
                            _buildRow("Name:", i.name.toString()),
                            _buildRow("Email:", i.email.toString()),
                            _buildRow("Phone:", i.phone.toString()),
                            _buildRow("Address:", i.address.toString()),

                            _buildRow("Place:", i.place.toString()),
                            _buildRow("Pincode:", i.pincode.toString()),
                            _buildRow("Post:", i.post.toString()),
                            _buildRow("Latitude:", i.latitude.toString()),
                            _buildRow("Longitude:", i.longitude.toString()),
                            _buildRow("Bio:", i.bio.toString()),
                            Image.network(i.proof.toString(),height: 100,width: 100,),
                            SizedBox(height: 10,),

                            Row(children: [ElevatedButton(onPressed: (){

                              Navigator.push(context, MaterialPageRoute(builder: (context)=>edit_distributor_profile_sub(
                                id:i.id.toString(),
                                name:i.name.toString(),
                                email:i.email.toString(),
                                phone:i.phone.toString(),
                                bio:i.bio.toString(),
                                address:i.address.toString(),
                                pincode: i.pincode.toString(),
                                place:i.place.toString(),
                                post:i.post.toString(),
                                latitude:i.latitude.toString(),
                                longitude:i.longitude.toString(),

                              )));
                            }, child: Text("Edit profile"))],)
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );


            }
          },


        ),





      ),



    );
  }
  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 5),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
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
  final String latitude;
  final String longitude;
  final String proof;







  Joke(this.id,this.name, this.email,this.phone,this.profile_image,this.bio,this.address,this.place,this.pincode,this.post,this.latitude,this.longitude,this.proof);
//  print("hiiiii");
}



























// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Distributordirectory/Editfolder/edit_distributor_profile.dart';
//
// class profile_page extends StatelessWidget {
//   const profile_page({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Wrapped in MaterialApp to ensure theme consistency
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         scaffoldBackgroundColor: Colors.white,
//         appBarTheme: AppBarTheme(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           iconTheme: IconThemeData(color: Colors.black),
//           titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//       ),
//       home: profile_page_sub(),
//     );
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
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String b = prefs.getString("lid").toString();
//     String foodimage = "";
//     var data = await http.post(
//         Uri.parse(prefs.getString("ip").toString() + "/distributor_view_profile"),
//         body: {"uid": prefs.getString("uid").toString()});
//
//     var jsonData = json.decode(data.body);
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
//         joke["latitude"].toString(),
//         joke["longitude"].toString(),
//         prefs.getString("ip").toString() + joke["proof"].toString(),
//       );
//       jokes.add(newJoke);
//     }
//     return jokes;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Icon(Icons.lock_outline, size: 16),
//             SizedBox(width: 5),
//             Text("My Shop Profile"), // Instagram style title
//             Icon(Icons.keyboard_arrow_down),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add_box_outlined),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: Icon(Icons.menu),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Container(
//         child: FutureBuilder(
//           future: _getJokes(),
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             if (snapshot.data == null) {
//               return Container(
//                 child: Center(
//                   child: CircularProgressIndicator(color: Colors.black),
//                 ),
//               );
//             } else {
//               return ListView.builder(
//                 itemCount: snapshot.data.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   var i = snapshot.data![index];
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // --- HEADER SECTION (Avatar + Stats) ---
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             // Profile Image (Shopkeeper Avatar)
//                             Container(
//                               width: 90,
//                               height: 90,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.grey[200],
//                                 border: Border.all(color: Colors.grey.shade300, width: 1),
//                                 image: DecorationImage(
//                                   image: NetworkImage(i.profile_image.toString()),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             // Stats (Simulated to look like Insta)
//                             Expanded(
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   _buildStatColumn("1", "Docs"), // Represents the Proof
//                                   _buildStatColumn("142", "Bills"), // Dummy data for style
//                                   _buildStatColumn("2k", "Customers"), // Dummy data for style
//                                 ],
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//
//                       // --- BIO SECTION ---
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 15),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               i.name.toString(),
//                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                             ),
//                             if (i.bio.toString() != "null" && i.bio.toString().isNotEmpty)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 2),
//                                 child: Text(i.bio.toString()),
//                               ),
//
//                             // Contact & Address Info styled nicely
//                             SizedBox(height: 4),
//                             Text("📍 ${i.address}, ${i.place}", style: TextStyle(color: Colors.grey[800])),
//                             Text("📮 ${i.post} - ${i.pincode}", style: TextStyle(color: Colors.grey[800])),
//                             Text("📞 ${i.phone}  |  ✉️ ${i.email}", style: TextStyle(color: Colors.blue[900], fontSize: 13)),
//
//                             // Coordinate info (Small)
//                             SizedBox(height: 4),
//                             Text(
//                               "Lat: ${i.latitude} / Long: ${i.longitude}",
//                               style: TextStyle(fontSize: 10, color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       // --- ACTION BUTTONS ---
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: () {
//                                   Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => edit_distributor_profile_sub(
//                                             id: i.id.toString(),
//                                             name: i.name.toString(),
//                                             email: i.email.toString(),
//                                             phone: i.phone.toString(),
//                                             bio: i.bio.toString(),
//                                             address: i.address.toString(),
//                                             pincode: i.pincode.toString(),
//                                             place: i.place.toString(),
//                                             post: i.post.toString(),
//                                             latitude: i.latitude.toString(),
//                                             longitude: i.longitude.toString(),
//                                           )));
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.grey[200],
//                                   elevation: 0,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   "Edit Profile",
//                                   style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 6),
//                             Container(
//                               padding: EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[200],
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Icon(Icons.person_add_outlined, color: Colors.black, size: 20),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       // --- HIGHLIGHTS (Optional Visual) ---
//                       SizedBox(
//                         height: 80,
//                         child: ListView(
//                           scrollDirection: Axis.horizontal,
//                           padding: EdgeInsets.only(left: 15),
//                           children: [
//                             _buildHighlight("Verified", Icons.verified, Colors.green),
//                             _buildHighlight("Bills", Icons.receipt_long, Colors.blue),
//                             _buildHighlight("New", Icons.add, Colors.grey),
//                           ],
//                         ),
//                       ),
//
//                       SizedBox(height: 10),
//                       Divider(height: 1, color: Colors.grey[300]),
//
//                       // --- TAB ICONS ---
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           Container(
//                               padding: EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                   border: Border(bottom: BorderSide(color: Colors.black, width: 1.5))
//                               ),
//                               child: Icon(Icons.grid_on, size: 28)),
//                           Icon(Icons.assignment_ind_outlined, color: Colors.grey, size: 28),
//                         ],
//                       ),
//                       Divider(height: 1, color: Colors.grey[300]),
//
//                       // --- GRID VIEW (Displaying the 'Proof' image as a post) ---
//                       GridView.count(
//                         shrinkWrap: true,
//                         physics: NeverScrollableScrollPhysics(),
//                         crossAxisCount: 3,
//                         crossAxisSpacing: 2,
//                         mainAxisSpacing: 2,
//                         children: [
//                           // This is the "Proof" image displayed as a gallery item
//                           Container(
//                             color: Colors.grey[300],
//                             child: Image.network(
//                               i.proof.toString(),
//                               fit: BoxFit.cover,
//                               errorBuilder: (c, o, s) => Icon(Icons.broken_image, color: Colors.grey),
//                             ),
//                           ),
//                           // Placeholders to fill the grid nicely for the demo
//                           Container(color: Colors.grey[100]),
//                           Container(color: Colors.grey[100]),
//                         ],
//                       ),
//                       SizedBox(height: 50),
//                     ],
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
//   // Helper widget for Stats (Posts/Followers/Following)
//   Widget _buildStatColumn(String count, String label) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           count,
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         Container(
//           margin: EdgeInsets.only(top: 4),
//           child: Text(
//             label,
//             style: TextStyle(fontSize: 13, color: Colors.black),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Helper widget for Highlights
//   Widget _buildHighlight(String label, IconData icon, Color color) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 15),
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(2),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: CircleAvatar(
//               radius: 28,
//               backgroundColor: Colors.grey[100],
//               child: Icon(icon, color: color, size: 28),
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(label, style: TextStyle(fontSize: 12)),
//         ],
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
//   Joke(this.id, this.name, this.email, this.phone, this.profile_image, this.bio,
//       this.address, this.place, this.pincode, this.post, this.latitude,
//       this.longitude, this.proof);
// //  print("hiiiii");
// }