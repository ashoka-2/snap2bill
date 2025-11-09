import 'package:flutter/material.dart';

void main(){
  runApp(dsetting());
}



class dsetting extends StatelessWidget {
  const dsetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: dsetting_sub(),);
  }
}


class dsetting_sub extends StatefulWidget {
  const dsetting_sub({Key? key}) : super(key: key);

  @override
  State<dsetting_sub> createState() => _dsetting_subState();
}

class _dsetting_subState extends State<dsetting_sub> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(child: Text("Distributor Setting"),),
      
      
    );
  }
}
