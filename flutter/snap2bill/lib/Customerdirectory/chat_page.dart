import 'package:flutter/material.dart';



class chat_page extends StatefulWidget {
  const chat_page({Key? key}) : super(key: key);

  @override
  State<chat_page> createState() => _chat_pageState();
}

class _chat_pageState extends State<chat_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(

        child: Center(child: Text("chat page")),
      ),

    );
  }
}
