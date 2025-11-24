import 'package:flutter/material.dart';

void main(){
  runApp(dsetting());
}



class dsetting extends StatelessWidget {
  const dsetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const dsetting_sub();
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
          "Settings",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),


      body: Center(child: Text("Distributor Setting"),),
      
      
    );
  }
}
