// import 'dart:convert';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/widgets/app_button.dart';
// import '../Customerdirectory/Customersends/addOrder.dart';
// import '../theme/colors.dart';
// import '../widgets/Navbar.dart';
//
// class ViewWishlist extends StatefulWidget {
//   const ViewWishlist({Key? key}) : super(key: key);
//
//   @override
//   State<ViewWishlist> createState() => _ViewWishlistState();
// }
//
// class _ViewWishlistState extends State<ViewWishlist> {
//   List _wishlistItems = [];
//   bool _isLoading = true;
//
//   String _baseUrl = "";
//   String? _cid; // customer id
//   String? _uid;
//
//   late Color successColor; // distributor id
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchWishlist();
//   }
//
//   // ---------------- IMAGE URL JOINER ----------------
//   String _joinUrl(String base, String path) {
//     if (base.isEmpty || path.isEmpty || path == "null") return "";
//     if (path.startsWith("http")) return path;
//
//     if (base.endsWith("/") && path.startsWith("/")) {
//       return base + path.substring(1);
//     }
//     if (!base.endsWith("/") && !path.startsWith("/")) {
//       return "$base/$path";
//     }
//     return base + path;
//   }
//
//   // ---------------- FETCH WISHLIST ----------------
//   Future<void> _fetchWishlist() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       _baseUrl = prefs.getString("ip") ?? "";
//       _cid = prefs.getString("cid");
//       _uid = prefs.getString("uid");
//
//       if (_baseUrl.isEmpty) {
//         setState(() => _isLoading = false);
//         return;
//       }
//
//       Map<String, String> body = {};
//
//       // 🔒 STRICT ROLE CHECK
//       if (_cid != null && _cid!.isNotEmpty && (_uid == null || _uid!.isEmpty)) {
//         body['cid'] = _cid!;
//       } else if (_uid != null && _uid!.isNotEmpty && (_cid == null || _cid!.isEmpty)) {
//         body['uid'] = _uid!;
//       }
//
//       final res = await http.post(
//         Uri.parse("$_baseUrl/view_wishlist"),
//         body: body,
//       );
//
//       if (res.statusCode == 200) {
//         final jsonData = jsonDecode(res.body);
//         setState(() {
//           _wishlistItems = jsonData['data'] ?? [];
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   // ---------------- REMOVE FROM WISHLIST ----------------
//   Future<void> _removeItem(String wid) async {
//     final prefs = await SharedPreferences.getInstance();
//     final ip = prefs.getString("ip") ?? "";
//
//     Map<String, String> body = {'wid': wid};
//
//     if (_cid != null && _cid!.isNotEmpty) {
//       body['cid'] = _cid!;
//     } else if (_uid != null && _uid!.isNotEmpty) {
//       body['uid'] = _uid!;
//     }
//
//     await http.post(
//       Uri.parse("$ip/remove_from_wishlist"),
//       body: body,
//     );
//
//     _fetchWishlist();
//   }
//
//   // ---------------- ERROR IMAGE ----------------
//   Widget _errorImage() {
//     return Container(
//       width: 80,
//       height: 80,
//       color: Colors.grey.shade300,
//       child: const Icon(Icons.broken_image, color: Colors.grey),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     successColor = AppColors.getSuccessColor(context);
//
//     final textColor = AppColors.getTextColor(context);
//     final bgColor = AppColors.getScaffoldBg(context);
//     final cardColor = AppColors.getCardColor(context);
//
//     // ✅ CUSTOMER ONLY
//     final bool isCustomer =
//         _cid != null && _cid!.isNotEmpty && (_uid == null || _uid!.isEmpty);
//
//     return
//       WillPopScope(
//         // 🚀 FIX 1: Physical Back button dabane par bhi "refresh" bhejo
//         onWillPop: () async {
//       Navigator.pop(context, "refresh");
//       return false; // False isliye kyunki humne manually pop kar diya
//     },child:
//       Scaffold(
//       backgroundColor: bgColor,
//       appBar: ThemeNavbar(title: "My Wishlist",
//         leadingIcon: Icons.arrow_back_ios_rounded,
//         onLeadingPressed: ()=>{
//         Navigator.pop(context, "refresh")
//         },
//         centerTitle: true,
//
//       ),
//       body:_isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _wishlistItems.isEmpty
//           ? Center(child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: EdgeInsets.all(15),
//                 decoration: BoxDecoration(
//                   color: AppColors.getPillBg(context),
//                   borderRadius: BorderRadius.circular(100)
//                 ),
//                   child: Icon(Icons.heart_broken,size: 100,)),
//               SizedBox(height: 10,),
//               Text("Your wishlist is empty",style: TextStyle(fontSize: 15,color: theme.disabledColor),),
//             ],
//           ))
//           : ListView.builder(
//         padding: const EdgeInsets.all(10),
//         itemCount: _wishlistItems.length,
//         itemBuilder: (context, index) {
//           final item = _wishlistItems[index];
//           final imageUrl = _joinUrl(_baseUrl, item['image'] ?? "");
//
//           return Card(
//             color: cardColor,
//             key: ValueKey(item['wishlist_id'].toString()),
//             elevation: 3,
//             margin: const EdgeInsets.only(bottom: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(10),
//               child: Row(
//                 children: [
//                   // IMAGE
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: imageUrl.isNotEmpty
//                         ? CachedNetworkImage(
//                         imageUrl: imageUrl,
//                       width: 80,
//                       height: 80,
//                       fit: BoxFit.cover,
//                       errorWidget: (_, __, ___) => _errorImage(),
//                     )
//                         : _errorImage(),
//                   ),
//                   const SizedBox(width: 12),
//
//                   // DETAILS
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           item['product_name'] ?? "No Name",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                             color: textColor,
//                           ),
//                         ),
//                         Text(
//                           item['category_name'] ?? "",
//                           style:  TextStyle(
//                               color: AppColors.getTextSubColor(context), fontSize: 12),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           "₹${item['price']}",
//                           style: TextStyle(
//                             color: AppColors.getPrimaryColor(context),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           "By: ${item['distributor_name']}",
//                           style:  TextStyle(
//                               fontSize: 10,
//                               color: textColor ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // ACTIONS
//                   Column(
//                     children: [
//                       // REMOVE
//                       DeleteButton(
//                         onPressed: () => _removeItem(
//                             item['wishlist_id'].toString()),
//                       ),
//
//                       // 🛒 ADD TO CART (ONLY CUSTOMER)
//                       if (isCustomer)
//                         Container(
//                           margin: EdgeInsets.only(top: 10),
//                           height: 35,
//                           width: 35,
//                           decoration: BoxDecoration(
//                             color: AppColors.successbgColor.withValues(alpha: 0.1),
//                             borderRadius: BorderRadius.circular(50),
//                             border: Border.all(width: 1,color: successColor)
//                           ),
//                           child: IconButton(
//                             icon:  Icon(
//                                 size: 20,
//                                 Icons.add_shopping_cart,
//                                 color: successColor),
//                             onPressed: () async {
//                               final prefs =
//                               await SharedPreferences.getInstance();
//                               prefs.setString(
//                                   "pid", item['id'].toString());
//
//                               if (!mounted) return;
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (_) => const addOrder()),
//                               ).then((_) => _fetchWishlist());
//                             },
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     ));
//   }
// }



import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/widgets/app_button.dart';
import '../Customerdirectory/Customersends/addOrder.dart';
import '../theme/colors.dart';
import '../widgets/Navbar.dart';

class ViewWishlist extends StatefulWidget {
  const ViewWishlist({Key? key}) : super(key: key);

  @override
  State<ViewWishlist> createState() => _ViewWishlistState();
}

class _ViewWishlistState extends State<ViewWishlist> {
  List _wishlistItems = [];
  bool _isLoading = true;

  String _baseUrl = "";
  String? _cid; // customer id
  String? _uid; // distributor id

  late Color successColor;

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  // ---------------- IMAGE URL JOINER ----------------
  String _joinUrl(String base, String path) {
    if (base.isEmpty || path.isEmpty || path == "null") return "";
    if (path.startsWith("http")) return path;

    if (base.endsWith("/") && path.startsWith("/")) {
      return base + path.substring(1);
    }
    if (!base.endsWith("/") && !path.startsWith("/")) {
      return "$base/$path";
    }
    return base + path;
  }

  // ---------------- FETCH WISHLIST ----------------
  Future<void> _fetchWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _baseUrl = prefs.getString("ip") ?? "";
      String rawCid = prefs.getString("cid") ?? "";
      String rawUid = prefs.getString("uid") ?? "";

      // 🔥 FIX 1: Clean the literal "null" strings
      _cid = (rawCid == "null" || rawCid.trim().isEmpty) ? null : rawCid;
      _uid = (rawUid == "null" || rawUid.trim().isEmpty) ? null : rawUid;

      if (_baseUrl.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      Map<String, String> body = {};

      // 🔥 FIX 2: Simple priority check. Custom priority to Customer if both somehow exist
      if (_cid != null) {
        body['cid'] = _cid!;
      } else if (_uid != null) {
        body['uid'] = _uid!;
      }

      final res = await http.post(
        Uri.parse("$_baseUrl/view_wishlist"),
        body: body,
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        setState(() {
          _wishlistItems = jsonData['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ---------------- REMOVE FROM WISHLIST ----------------
  Future<void> _removeItem(String wid) async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString("ip") ?? "";

    Map<String, String> body = {'wid': wid};

    // Use cleaned variables directly
    if (_cid != null) {
      body['cid'] = _cid!;
    } else if (_uid != null) {
      body['uid'] = _uid!;
    }

    await http.post(
      Uri.parse("$ip/remove_from_wishlist"),
      body: body,
    );

    _fetchWishlist();
  }

  // ---------------- ERROR IMAGE ----------------
  Widget _errorImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey.shade300,
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    successColor = AppColors.getSuccessColor(context);
    final textColor = AppColors.getTextColor(context);
    final bgColor = AppColors.getScaffoldBg(context);
    final cardColor = AppColors.getCardColor(context);

    // ✅ CUSTOMER ONLY (Cleaned check)
    final bool isCustomer = _cid != null;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, "refresh");
        return false;
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: ThemeNavbar(
          title: "My Wishlist",
          leadingIcon: Icons.arrow_back_ios_rounded,
          onLeadingPressed: () => Navigator.pop(context, "refresh"),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _wishlistItems.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: AppColors.getPillBg(context),
                    borderRadius: BorderRadius.circular(100)),
                child: const Icon(Icons.heart_broken, size: 100),
              ),
              const SizedBox(height: 10),
              Text(
                "Your wishlist is empty",
                style: TextStyle(
                    fontSize: 15, color: theme.disabledColor),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: _wishlistItems.length,
          itemBuilder: (context, index) {
            final item = _wishlistItems[index];
            final imageUrl = _joinUrl(_baseUrl, item['image'] ?? "");

            return Card(
              color: cardColor,
              key: ValueKey(item['wishlist_id'].toString()),
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    // IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _errorImage(),
                      )
                          : _errorImage(),
                    ),
                    const SizedBox(width: 12),

                    // DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['product_name'] ?? "No Name",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          Text(
                            item['category_name'] ?? "",
                            style: TextStyle(
                                color: AppColors.getTextSubColor(context),
                                fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "₹${item['price']}",
                            style: TextStyle(
                              color: AppColors.getPrimaryColor(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "By: ${item['distributor_name']}",
                            style: TextStyle(
                                fontSize: 10, color: textColor),
                          ),
                        ],
                      ),
                    ),

                    // ACTIONS
                    Column(
                      children: [
                        // REMOVE
                        DeleteButton(
                          onPressed: () =>
                              _removeItem(item['wishlist_id'].toString()),
                        ),

                        // 🛒 ADD TO CART (ONLY CUSTOMER)
                        if (isCustomer)
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                                color: AppColors.successbgColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                    width: 1, color: successColor)),
                            child: IconButton(
                              icon: Icon(
                                  size: 20,
                                  Icons.add_shopping_cart,
                                  color: successColor),
                              onPressed: () async {
                                final prefs =
                                await SharedPreferences.getInstance();
                                prefs.setString(
                                    "pid", item['id'].toString());

                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const addOrder()),
                                ).then((_) => _fetchWishlist());
                              },
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}