import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Customerdirectory/custviews/viewOrder.dart';

class editOrder extends StatefulWidget {
  final String id;

  const editOrder({
    required this.id,}) : super();

  @override
  State<editOrder> createState() => _editOrderState();
}

class _editOrderState extends State<editOrder> {
  final quantity = TextEditingController();
  @override
  void initState(){
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          "Add product to cart",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: double.infinity,
          height: 500,
          child: Column(
            children: [
              SizedBox(height: 10),
              TextField(
                controller: quantity,
                decoration: InputDecoration(
                  hintText: 'Enter quantiy',
                  labelText: 'Quantity',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  SharedPreferences sh = await SharedPreferences.getInstance();
                  var data = await http.post(
                    Uri.parse(sh.getString("ip").toString() + "/edit_order"),
                    body: {
                      "id":widget.id,
                      "quantity": quantity.text,

                    },
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => viewOrder(),
                    ),
                  );
                },
                child: Text("Update Order"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}