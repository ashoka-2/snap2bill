import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Customerdirectory/custviews/view_product.dart';
import 'package:snap2bill/widgets/CustomerNavigationBar.dart';

class addOrder extends StatefulWidget {
  const addOrder({Key? key}) : super(key: key);

  @override
  State<addOrder> createState() => _addOrderState();
}

class _addOrderState extends State<addOrder> {
  final quantity = TextEditingController(text: "1");

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
                    Uri.parse(sh.getString("ip").toString() + "/addorder"),
                    body: {
                      "quantity": quantity.text,
                      'uid': sh.getString("uid"),
                      'cid': sh.getString("cid"),
                      'id': sh.getString("id"),
                    },
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerNavigationBar(),
                    ),
                  );
                },
                child: Text("Add to cart"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
