import 'package:flutter/material.dart';

class editOrder extends StatefulWidget {
  const editOrder({Key? key}) : super(key: key);

  @override
  State<editOrder> createState() => _editOrderState();
}

class _editOrderState extends State<editOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Order Details"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Container(height: 100, child: Center(child: Text("Edit Order"))),
      ),
    );
  }
}
