import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Customerdirectory/custviews/view_product.dart';


class addStock extends StatelessWidget {
  const addStock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: addStockSub(),);
  }
}

class addStockSub extends StatefulWidget {
  const addStockSub({Key? key}) : super(key: key);

  @override
  State<addStockSub> createState() => _addStockSubState();
}

class _addStockSubState extends State<addStockSub> {
  TextEditingController stock = TextEditingController();
  TextEditingController price = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:

        Column(
          children: [
            TextField(controller: stock,
              decoration: InputDecoration(
                  hintText: 'Enter stock quantity',
                  labelText: 'Quantity',
                  prefixIcon: Icon(Icons.clean_hands),
                  border: OutlineInputBorder()
              ),),
            TextField(controller: price,
              decoration: InputDecoration(
                  hintText: 'Enter price',
                  labelText: 'Price',
                  prefixIcon: Icon(Icons.clean_hands),
                  border: OutlineInputBorder()
              ),),

            SizedBox(height: 10,),
            ElevatedButton(onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              var data = await http.post(Uri.parse(prefs.getString("ip").toString()+"/add_stock"),
                  body: {
                'pid':prefs.getString("pid").toString(),
                    'uid':prefs.getString("uid").toString(),
                    'quantity':stock.text,
                    'price':price.text,
                  }
              );
              Navigator.push(context, MaterialPageRoute(builder: (context)=>view_product()));

            }, child: Text("Add"))
          ],
        ),

    );
  }
}




