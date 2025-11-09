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








