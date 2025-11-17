import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Customerdirectory/custviews/view_product.dart';


class editStock extends StatelessWidget {
  const editStock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: editStockSub(),);
  }
}

class editStockSub extends StatefulWidget {
  const editStockSub({Key? key}) : super(key: key);

  @override
  State<editStockSub> createState() => _editStockSubState();
}

class _editStockSubState extends State<editStockSub> {
  TextEditingController stock = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:

      Column(
        children: [
          Center(
            child: TextField(controller: stock,
              decoration: InputDecoration(
                  hintText: 'Enter stock quantity',
                  labelText: 'Quantity',
                  prefixIcon: Icon(Icons.clean_hands),
                  border: OutlineInputBorder()
              ),),
          ),

          SizedBox(height: 10,),
          ElevatedButton(onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var data = await http.post(Uri.parse(prefs.getString("ip").toString()+"/edit_stock"),
                body: {
                  'pid':prefs.getString("pid").toString(),'uid':prefs.getString("uid").toString(),'quantity':stock.text
                }
            );
            Navigator.push(context, MaterialPageRoute(builder: (context)=>view_product()));

          }, child: Text("Update"))
        ],
      ),

    );
  }
}




