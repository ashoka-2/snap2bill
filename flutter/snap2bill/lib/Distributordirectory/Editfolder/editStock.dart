import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Customerdirectory/custviews/view_product.dart';
import 'package:snap2bill/Distributordirectory/view/myProducts.dart';



class editStock extends StatefulWidget {
  final id;
  final price;
  final quantity;

  const editStock({
    required this.id,
    required this.price,
    required this.quantity,
}) : super();

  @override
  State<editStock> createState() => _editStockState();
}

class _editStockState extends State<editStock> {
  final quantity = TextEditingController();
  final price = TextEditingController();
  @override
  void initState() {
    super.initState();
    price.text = widget.price;
    quantity.text = widget.quantity;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:

      Column(
        children: [
          TextField(controller: quantity,
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
                prefixIcon: Icon(Icons.currency_rupee),
                border: OutlineInputBorder()
            ),),

          SizedBox(height: 10,),
          ElevatedButton(onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var data = await http.post(Uri.parse(prefs.getString("ip").toString()+"/edit_stock"),
                body: {
                  'pid':prefs.getString("pid").toString(),'uid':prefs.getString("uid").toString(),
                  'quantity':quantity.text,
                  'price':price.text,
                }
            );
            Navigator.push(context, MaterialPageRoute(builder: (context)=>myProducts()));

          }, child: Text("Update"))
        ],
      ),
    );
  }
}




