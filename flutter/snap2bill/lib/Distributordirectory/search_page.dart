import 'package:flutter/material.dart';



class search_page extends StatefulWidget {
  const search_page({Key? key}) : super(key: key);

  @override
  State<search_page> createState() => _search_pageState();
}

class _search_pageState extends State<search_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(

        child: Center(child: Text("search page")),
      ),

    );
  }
}
