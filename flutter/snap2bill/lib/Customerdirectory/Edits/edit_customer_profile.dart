import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snap2bill/Customerdirectory/profile_page.dart';




class edit_customer_profile_sub extends StatefulWidget {
  final id;
  final name;
  final email;
  final phone;
  final bio;
  final address;
  final pincode;
  final place;
  final post;

  const edit_customer_profile_sub({required this.id,required this.name,required this.email,required this.phone,required this.bio,required this.address,required this.place,required this.pincode, required this.post,}) : super();


  @override
  State<edit_customer_profile_sub> createState() => _edit_customer_profile_subState();
}

class _edit_customer_profile_subState extends State<edit_customer_profile_sub> {
  final name=new TextEditingController();
  final email=new TextEditingController();
  final phone=new TextEditingController();
  final address=new TextEditingController();
  final pincode=new TextEditingController();
  final place=new TextEditingController();
  final post=new TextEditingController();
  final bio=new TextEditingController();





  @override
  void initState(){
    name.text=widget.name;
    email.text=widget.email;
    phone.text=widget.phone;
    address.text=widget.address;
    pincode.text=widget.pincode;
    place.text=widget.place;
    post.text=widget.post;
    bio.text=widget.bio;



  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hello world") ,),
      // backgroundColor: Colors.cyan,
      body: SingleChildScrollView(child: Center(child: SizedBox(



        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            width:400 ,
            // height: 1000,
            decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(21)
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 20,right: 10,bottom: 15),
              child: Column(children: [

                TextField(controller: name,
                  decoration: InputDecoration(
                    hintText:'Enter your name ',
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.abc_rounded),
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(

                    ),

                  ),
                ),SizedBox(height: 10,),

                TextField(controller: email,enabled: false,
                  decoration: InputDecoration(
                      hintText: 'Enter your Email',
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder()
                  ),),SizedBox(height: 10,),

                TextField(controller: phone,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter your number',
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_android),
                    border: OutlineInputBorder(),

                  ),),SizedBox(height: 10,),


                TextField(controller: address,
                  decoration: InputDecoration(
                      hintText: 'Enter your Address',
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder()
                  ),
                ),SizedBox(height: 10,),
                TextField(controller: pincode,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: 'Enter your pincode',
                      labelText: 'Pincode',
                      prefixIcon: Icon(Icons.location_on_sharp),
                      border: OutlineInputBorder()
                  ),),SizedBox(height: 10,),
                TextField(controller: place,
                  decoration: InputDecoration(
                      hintText: 'Enter your Place',
                      labelText: 'Place',
                      prefixIcon: Icon(Icons.place),
                      border: OutlineInputBorder()
                  ),),SizedBox(height: 10,),
                TextField(controller: post,
                  decoration: InputDecoration(
                      hintText: 'Enter your post',
                      labelText: 'Post',
                      prefixIcon: Icon(Icons.place_sharp),
                      border: OutlineInputBorder()
                  ),),SizedBox(height: 10,),
                TextField(controller: bio,
                  decoration: InputDecoration(
                      hintText: 'Enter description',
                      labelText: 'Bio',
                      prefixIcon: Icon(Icons.abc_sharp),
                      border: OutlineInputBorder()
                  ),),SizedBox(height: 10,),


                ElevatedButton(onPressed: () async {
                  print(name.text);
                  print(email.text);
                  print(phone.text);

                  print(address.text);
                  print(pincode.text);
                  print(place.text);
                  print(post.text);
                  print(bio.text);


                  SharedPreferences sh=await SharedPreferences.getInstance();

                  var data = await http.post(Uri.parse('${sh.getString("ip")}/edit_customer_profile'),
                      body: {
                        'name':name.text,
                        'phone':phone.text,
                        'address':address.text,
                        'pincode':pincode.text,
                        'place':place.text,
                        'post':post.text,
                        'bio':bio.text,
                        'cid':sh.getString("cid").toString()
                      }
                  );


                  var decodeddata = json.decode(data.body);
                  if(decodeddata['status'] == 'ok'){
                    showDialog(context: context, builder: (context)=>AlertDialog(
                      title: Text("UPDATE PROFILE"),content: Text("Updated"),
                      actions: [TextButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>profile_page()));

                      }, child: Text("OK"))],
                    ));
                  }



                }, child: Text("Update Profile")),




              ],),
            ),
          ),
        ),),),),);
  }
}
