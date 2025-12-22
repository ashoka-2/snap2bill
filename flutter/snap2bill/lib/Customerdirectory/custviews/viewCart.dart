import 'package:input_quantity/input_quantity.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/widgets/CustomerNavigationBar.dart';
import 'package:snap2bill/widgets/app_button.dart';

class viewCart extends StatefulWidget {
  const viewCart({Key? key}) : super(key: key);

  @override
  State<viewCart> createState() => _viewCartState();
}

class _viewCartState extends State<viewCart> {
  String total = "";
  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data =
    await http.post(Uri.parse(prefs.getString("ip").toString() + "/viewCart"),
        body: {
          'cid': prefs.getString('cid').toString()
        }
    );

    var jsonData = json.decode(data.body);
    setState(() {
      total = jsonData['total'].toString();
    });
    print(jsonData);
    List<Joke> jokes = [];
    for (var joke in jsonData["data"]) {
      print(joke);
      Joke newJoke = Joke(
        joke["id"].toString(),
        joke["distributor_name"].toString(),
        joke["image"].toString(),
        joke["product_name"].toString(),
        joke["price"].toString(),
        num.tryParse(joke["quantity"].toString()) ?? 0,
      );
      jokes.add(newJoke);
    }
    return jokes;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
          title: Text('Cart'),
          centerTitle: true,
        ),

        body:
        Container(
          // color: Colors.red,
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
                            _buildRow("Distributor Name:", i.distributor_name.toString()),
                            _buildRow("Image:", i.image.toString()),
                            _buildRow("Name:", i.product_name.toString()),
                            _buildRow("Price:", i.price.toString()),
                            // _buildRow("Quantity:", i.quantity.toString()),

                            Row(
                                children: [
                            InputQty(
                            decoration: QtyDecorationProps(
                            qtyStyle: QtyStyle.classic
                            ),
                            maxVal: 100,
                            initVal: i.quantity,
                            minVal: 1,
                            steps: 1,
                            onQtyChanged: (val) async {
                              print(val);

                              SharedPreferences sh =
                                  await SharedPreferences.getInstance();
                              var data = await http.post(
                                Uri.parse(sh.getString("ip").toString() + "/update_quantity",),
                                body: {
                                  "id": i.id.toString(),
                                  "qty":val.toString()
                                },
                              );
                              setState(() {
                                i.quantity = val;
                              });

                            },

                          ),

                          SizedBox(width: 10,),
                          ElevatedButton(onPressed: () async {
                            SharedPreferences sh =
                            await SharedPreferences.getInstance();

                            var data = await http.post(
                              Uri.parse(
                                sh.getString("ip").toString() + "/deleteFromCart",),
                              body: {
                                "id": i.id.toString(),
                              },
                            );
                            Navigator.pushReplacement(context, MaterialPageRoute(
                                builder: (context) => viewCart()));
                          }, child: Text("Delete")),

                      ],
                    ),


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

        bottomNavigationBar: BottomAppBar(
            color: Colors.transparent,
            child: AppButton(text: "Place Order ${total}", onPressed: () async {
              SharedPreferences sh =
                  await SharedPreferences.getInstance();

              var data = await http.post(
                Uri.parse(
                  sh.getString("ip").toString() + "/addFinalOrder",),
                body: {
                  // "id": i.id.toString(),
                  'cid': sh.getString("cid"),
                  'total':total
                },
              );
              Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => CustomerNavigationBar(initialIndex: 0,)));
            })
        )
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
  final distributor_name;
  final String image;
  final String product_name;
  final String price;
  final num quantity;


  Joke(this.id,
      this.distributor_name,
      this.image,
      this.product_name,
      this.price,
      this.quantity,);
}