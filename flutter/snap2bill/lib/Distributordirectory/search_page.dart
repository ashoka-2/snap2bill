import 'package:flutter/material.dart';

import '../widgets/Navbar.dart';



class search_page extends StatefulWidget {
  const search_page({Key? key}) : super(key: key);

  @override
  State<search_page> createState() => _search_pageState();
}

class _search_pageState extends State<search_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThemeNavbar(
        title:
        "Snap2Bill",
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.favorite_border),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => const ViewWishlist()),
          //     ).then((_) {
          //       /// 🔁 Sync wishlist state on return
          //       _loadData();
          //     });
          //   },
          // ),
        ],
      ),
      body: Container(

        child: Center(child: Text("search page")),
      ),

    );
  }
}
