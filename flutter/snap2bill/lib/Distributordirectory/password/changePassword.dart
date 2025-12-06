import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/home_page.dart';
import 'package:snap2bill/screens/login_page.dart';




class changePassword extends StatelessWidget {
  const changePassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const changePasswordSub();
  }
}

class changePasswordSub extends StatefulWidget {
  const changePasswordSub({Key? key}) : super(key: key);

  @override
  State<changePasswordSub> createState() => _changePasswordSubState();
}

class _changePasswordSubState extends State<changePasswordSub> {
  TextEditingController oldpassword = TextEditingController();
  TextEditingController newpassword = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          "Change Password",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Column(
            children: [
              TextField(
                controller: oldpassword,
                    decoration: InputDecoration(
                    hintText: 'Enter old password',
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.password),
                    border: OutlineInputBorder()
                  ),),
              SizedBox(height: 10,),
              TextField(
                controller: newpassword,
                decoration: InputDecoration(
                    hintText: 'Enter new password',
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.password),
                    border: OutlineInputBorder()
                ),),
              SizedBox(height: 10,),
              TextField(
                controller: confirmpassword,
                decoration: InputDecoration(
                    hintText: 'Confirm new password',
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.password),
                    border: OutlineInputBorder()
                ),),
              SizedBox(height: 10,),
              ElevatedButton(onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                var data = await http.post(Uri.parse(prefs.getString("ip").toString()+"/password_change"),
                    body: {
                    'uid':prefs.getString("uid").toString(),
                      "newpassword":newpassword.text,
                    }
                );
                if(oldpassword.text==prefs.getString("pwd1")){
                  if(newpassword.text==confirmpassword.text){

                    Navigator.push(context, MaterialPageRoute(builder: (context)=>login_page()));

                  }
                  else{
                    showDialog(context: context, builder: (BuildContext context){
                      return AlertDialog(title: Text("Change Password "),
                        content: Text("Password does not match."),
                        actions: [
                          TextButton(onPressed: (){
                            Navigator.of(context).pop();
                          }, child: Text("ok"))
                        ],
                      );
                    });
                  }
                }
                else{
                  showDialog(context: context, builder: (BuildContext context){
                    return AlertDialog(title: Text("Change Password "),
                      content: Text("Password does not match."),
                      actions: [
                        TextButton(onPressed: (){
                          Navigator.of(context).pop();
                        }, child: Text("ok"))
                      ],
                    );
                  });
                }
                print(newpassword);



              }, child: Text("Update Password"))

            ],
          ),

        ),
      ),

    );
  }
}
