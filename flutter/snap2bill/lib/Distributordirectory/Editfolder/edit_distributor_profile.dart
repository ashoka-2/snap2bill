// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:snap2bill/Distributordirectory/profile_page.dart';
//
//
//
//
// class edit_distributor_profile_sub extends StatefulWidget {
//     final id;
//   final name;
//   final email;
//   final phone;
//   final bio;
//   final address;
//   final pincode;
//   final place;
//   final post;
//   final latitude;
//   final longitude;
//   const edit_distributor_profile_sub({required this.id,required this.name,required this.email,required this.phone,required this.bio,required this.address,required this.place,required this.pincode, required this.post,required this.latitude,required this.longitude,}) : super();
//
//
//   @override
//   State<edit_distributor_profile_sub> createState() => _edit_distributor_profile_subState();
// }
//
// class _edit_distributor_profile_subState extends State<edit_distributor_profile_sub> {
//   final name=new TextEditingController();
//   final email=new TextEditingController();
//   final phone=new TextEditingController();
//   final address=new TextEditingController();
//   final pincode=new TextEditingController();
//   final place=new TextEditingController();
//   final post=new TextEditingController();
//   final bio=new TextEditingController();
//   final latitude=new TextEditingController();
//   final longitude=new TextEditingController();
//
//
//
//
//   @override
//   void initState(){
//     name.text=widget.name;
//     email.text=widget.email;
//     phone.text=widget.phone;
//     address.text=widget.address;
//     pincode.text=widget.pincode;
//     place.text=widget.place;
//     post.text=widget.post;
//     bio.text=widget.bio;
//     latitude.text=widget.latitude;
//     longitude.text=widget.longitude;
//
//
//
//   }
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Hello world") ,),
//       // backgroundColor: Colors.cyan,
//       body: SingleChildScrollView(child: Center(child: SizedBox(
//
//
//
//         child: Padding(
//           padding: EdgeInsets.all(10),
//           child: Container(
//             width:400 ,
//             // height: 1000,
//             decoration: BoxDecoration(
//                 color: Colors.green.shade100,
//                 borderRadius: BorderRadius.circular(21)
//             ),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 10, top: 20,right: 10,bottom: 15),
//               child: Column(children: [
//
//                 TextField(controller: name,
//                   decoration: InputDecoration(
//                     hintText:'Enter your name ',
//                     labelText: 'Name',
//                     prefixIcon: Icon(Icons.abc_rounded),
//                     filled: true,
//                     fillColor: Colors.white70,
//                     border: OutlineInputBorder(
//
//                     ),
//
//                   ),
//                 ),SizedBox(height: 10,),
//
//                 TextField(controller: email,enabled: false,
//                   decoration: InputDecoration(
//                       hintText: 'Enter your Email',
//                       labelText: 'Email',
//                       prefixIcon: Icon(Icons.email_outlined),
//                       border: OutlineInputBorder()
//                   ),),SizedBox(height: 10,),
//
//                 TextField(controller: phone,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     hintText: 'Enter your number',
//                     labelText: 'Phone Number',
//                     prefixIcon: Icon(Icons.phone_android),
//                     border: OutlineInputBorder(),
//
//                   ),),SizedBox(height: 10,),
//
//
//                 TextField(controller: address,
//                   decoration: InputDecoration(
//                       hintText: 'Enter your Address',
//                       labelText: 'Address',
//                       prefixIcon: Icon(Icons.location_city),
//                       border: OutlineInputBorder()
//                   ),
//                 ),SizedBox(height: 10,),
//                 TextField(controller: pincode,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                       hintText: 'Enter your pincode',
//                       labelText: 'Pincode',
//                       prefixIcon: Icon(Icons.location_on_sharp),
//                       border: OutlineInputBorder()
//                   ),),SizedBox(height: 10,),
//                 TextField(controller: place,
//                   decoration: InputDecoration(
//                       hintText: 'Enter your Place',
//                       labelText: 'Place',
//                       prefixIcon: Icon(Icons.place),
//                       border: OutlineInputBorder()
//                   ),),SizedBox(height: 10,),
//                 TextField(controller: post,
//                   decoration: InputDecoration(
//                       hintText: 'Enter your post',
//                       labelText: 'Post',
//                       prefixIcon: Icon(Icons.place_sharp),
//                       border: OutlineInputBorder()
//                   ),),SizedBox(height: 10,),
//                 TextField(controller: bio,
//                   decoration: InputDecoration(
//                       hintText: 'Enter description',
//                       labelText: 'Bio',
//                       prefixIcon: Icon(Icons.abc_sharp),
//                       border: OutlineInputBorder()
//                   ),),SizedBox(height: 10,),
//                 TextField(controller: latitude,
//                   decoration: InputDecoration(
//                       hintText: 'Enter your Latitude',
//                       labelText: 'Latitude',
//                       prefixIcon: Icon(Icons.abc_sharp),
//                       border: OutlineInputBorder()
//                   ),),SizedBox(height: 10,),
//                 TextField(controller: longitude,
//                   decoration: InputDecoration(
//                       hintText: 'Enter your Longitude',
//                       labelText: 'Longitude',
//                       prefixIcon: Icon(Icons.abc_sharp),
//                       border: OutlineInputBorder()
//                   ),),SizedBox(height: 10,),
//                 ElevatedButton(onPressed: () async {
//                   print(name.text);
//                   print(email.text);
//                   print(phone.text);
//
//                   print(address.text);
//                   print(pincode.text);
//                   print(place.text);
//                   print(post.text);
//                   print(bio.text);
//                   print(latitude.text);
//                   print(longitude.text);
//
//                   SharedPreferences sh=await SharedPreferences.getInstance();
//                   // var data = await http.post(Uri.parse('http://192.168.29.3:1234/distributor_register'),
//                   var data = await http.post(Uri.parse('${sh.getString("ip")}/edit_distributor_profile'),
//                       body: {
//                         'name':name.text,
//                         'phone':phone.text,
//                         'address':address.text,
//                         'pincode':pincode.text,
//                         'place':place.text,
//                         'post':post.text,
//                         'bio':bio.text,
//                         'latitude':latitude.text,
//                         'longitude':longitude.text,
//                         'uid':sh.getString("uid").toString()
//                       }
//                   );
//
//
//                   var decodeddata = json.decode(data.body);
//                   if(decodeddata['status'] == 'ok'){
//                     showDialog(context: context, builder: (context)=>AlertDialog(
//                       title: Text("UPDATE PROFILE"),content: Text("Updated"),
//                       actions: [TextButton(onPressed: (){
//                         Navigator.push(context, MaterialPageRoute(builder: (context)=>profile_page()));
//
//                       }, child: Text("OK"))],
//                     ));
//                   }
//
//
//
//                 }, child: Text("Update profile")),
//
//
//
//
//               ],),
//             ),
//           ),
//         ),),),),);
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snap2bill/Distributordirectory/home_page.dart';
import 'package:snap2bill/Distributordirectory/profile_page.dart';

class edit_distributor_profile_sub extends StatefulWidget {
  final id;
  final name;
  final email;
  final phone;
  final bio;
  final address;
  final pincode;
  final place;
  final post;
  final latitude;
  final longitude;

  const edit_distributor_profile_sub({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    required this.address,
    required this.place,
    required this.pincode,
    required this.post,
    required this.latitude,
    required this.longitude,
  }) : super();

  @override
  State<edit_distributor_profile_sub> createState() =>
      _edit_distributor_profile_subState();
}

class _edit_distributor_profile_subState
    extends State<edit_distributor_profile_sub> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final pincode = TextEditingController();
  final place = TextEditingController();
  final post = TextEditingController();
  final bio = TextEditingController();
  final latitude = TextEditingController();
  final longitude = TextEditingController();

  @override
  void initState() {
    super.initState();
    name.text = widget.name;
    email.text = widget.email;
    phone.text = widget.phone;
    address.text = widget.address;
    pincode.text = widget.pincode;
    place.text = widget.place;
    post.text = widget.post;
    bio.text = widget.bio;
    latitude.text = widget.latitude;
    longitude.text = widget.longitude;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 400,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  buildTextField("Name", name, Icons.person),
                  const SizedBox(height: 12),
                  buildTextField("Email", email, Icons.email_outlined,
                      enabled: false),
                  const SizedBox(height: 12),
                  buildTextField("Phone Number", phone, Icons.phone_android,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  buildTextField("Address", address, Icons.home),
                  const SizedBox(height: 12),
                  buildTextField("Pincode", pincode, Icons.pin_drop,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  buildTextField("Place", place, Icons.place),
                  const SizedBox(height: 12),
                  buildTextField("Post", post, Icons.location_on),
                  const SizedBox(height: 12),
                  buildTextField("Bio", bio, Icons.info_outline),
                  const SizedBox(height: 12),
                  buildTextField("Latitude", latitude, Icons.explore),
                  const SizedBox(height: 12),
                  buildTextField("Longitude", longitude, Icons.explore_outlined),
                  const SizedBox(height: 25),

                  // ✅ Update button (no loading)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        SharedPreferences sh =
                        await SharedPreferences.getInstance();
                        var data = await http.post(
                          Uri.parse(
                              '${sh.getString("ip")}/edit_distributor_profile'),
                          body: {
                            'name': name.text,
                            'phone': phone.text,
                            'address': address.text,
                            'pincode': pincode.text,
                            'place': place.text,
                            'post': post.text,
                            'bio': bio.text,
                            'latitude': latitude.text,
                            'longitude': longitude.text,
                            'uid': sh.getString("uid").toString()
                          },
                        );

                        var decodeddata = json.decode(data.body);
                        if (decodeddata['status'] == 'ok') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              title: const Text("Profile Updated",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold)),
                              content: const Text(
                                  "Your profile has been successfully updated."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const home_page()),
                                    );
                                  },
                                  child: const Text(
                                    "OK",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Update Profile",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label,
      TextEditingController controller,
      IconData icon, {
        bool enabled = true,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 1.8),
        ),
      ),
    );
  }
}
