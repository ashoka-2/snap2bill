import 'package:flutter/material.dart';


class addToBill extends StatefulWidget {
  const addToBill({Key? key}) : super(key: key);

  @override
  State<addToBill> createState() => _addToBillState();
}

class _addToBillState extends State<addToBill> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          // color: Colors.red,
        ),

        child: Center(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

            Text("product Name"),
              SizedBox(height: 10,),

              TextFormField(

                decoration:InputDecoration(
                    labelText: "Enter Price",
                    border: OutlineInputBorder()
                ) ,),
              SizedBox(height: 10,),
              TextFormField(

                decoration:InputDecoration(
                    labelText: "Enter quantity",
                    border: OutlineInputBorder()
                ) ,),
          ],),
        ),
      ),

    );
  }
}
