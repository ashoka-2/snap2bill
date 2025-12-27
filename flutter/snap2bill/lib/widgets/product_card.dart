// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:readmore/readmore.dart';
// // import 'package:snap2bill/theme/colors.dart';
// //
// // import '../data/dataModels.dart';
// // import '../Customerdirectory/Customersends/addOrder.dart';
// // import '../Distributordirectory/view/ViewDistributorProfile.dart';
// //
// // class ProductCard extends StatefulWidget {
// //   final ProductData product;
// //   final bool showAddToCart;
// //
// //   const ProductCard({
// //     Key? key,
// //     required this.product,
// //     required this.showAddToCart,
// //   }) : super(key: key);
// //
// //   @override
// //   State<ProductCard> createState() => _ProductCardState();
// // }
// //
// // class _ProductCardState extends State<ProductCard> {
// //   bool isLiked = false;
// //   bool showCenterHeart = false;
// //
// //   // ---------- Snackbar ----------
// //   void _showSnackBar(String message, Color color) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: color,
// //         duration: const Duration(milliseconds: 800),
// //       ),
// //     );
// //   }
// //
// //   // ---------- Wishlist Toggle (Single Source of Truth) ----------
// //   void _toggleWishlist({bool fromDoubleTap = false}) {
// //     if (!isLiked) {
// //       setState(() {
// //         isLiked = true;
// //         if (fromDoubleTap) showCenterHeart = true;
// //       });
// //
// //       if (fromDoubleTap) {
// //         Future.delayed(const Duration(milliseconds: 700), () {
// //           if (mounted) setState(() => showCenterHeart = false);
// //         });
// //       }
// //
// //       _showSnackBar(
// //         "Added ${widget.product.productName} to Wishlist",
// //         AppColors.dangerColor,
// //       );
// //     } else {
// //       setState(() => isLiked = false);
// //       _showSnackBar(
// //         "Removed ${widget.product.productName} from Wishlist",
// //         Colors.grey,
// //       );
// //     }
// //   }
// //
// //   // ---------- Distributor Profile ----------
// //   void _viewDistributorProfile() {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (_) => ViewDistributorProfile(
// //           distributorId: widget.product.distributorId,
// //           distributorName: widget.product.distributorName,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ---------- Popup Menu ----------
// //   void _showOptionsMenu(
// //       BuildContext context, Color textColor, Color cardColor) {
// //     final RenderBox button = context.findRenderObject() as RenderBox;
// //     final Offset pos = button.localToGlobal(Offset.zero);
// //
// //     showMenu<String>(
// //       context: context,
// //       position: RelativeRect.fromRect(
// //         pos & button.size,
// //         Offset.zero & MediaQuery.of(context).size,
// //       ),
// //       color: cardColor,
// //       items: [
// //         PopupMenuItem(
// //           value: 'profile',
// //           child: Row(
// //             children: [
// //               Icon(Icons.person_outline, color: textColor),
// //               const SizedBox(width: 8),
// //               Text('View Profile', style: TextStyle(color: textColor)),
// //             ],
// //           ),
// //         ),
// //         if (widget.showAddToCart)
// //           PopupMenuItem(
// //             value: 'cart',
// //             child: Row(
// //               children: [
// //                 Icon(Icons.shopping_cart, color: textColor),
// //                 const SizedBox(width: 8),
// //                 Text('Add to Cart', style: TextStyle(color: textColor)),
// //               ],
// //             ),
// //           ),
// //         PopupMenuItem(
// //           value: 'wishlist',
// //           child: Row(
// //             children: [
// //               Icon(
// //                 isLiked ? Icons.favorite : Icons.favorite_border,
// //                 color: isLiked ? Colors.red : textColor,
// //               ),
// //               const SizedBox(width: 8),
// //               Text(
// //                 isLiked ? 'Remove from Wishlist' : 'Add to Wishlist',
// //                 style: TextStyle(color: textColor),
// //               ),
// //             ],
// //           ),
// //         ),
// //         PopupMenuItem(
// //           value: 'share',
// //           child: Row(
// //             children: [
// //               Icon(Icons.share, color: textColor),
// //               const SizedBox(width: 8),
// //               Text('Share', style: TextStyle(color: textColor)),
// //             ],
// //           ),
// //         ),
// //       ],
// //     ).then((value) async {
// //       if (value == 'profile') {
// //         _viewDistributorProfile();
// //       } else if (value == 'cart') {
// //         final prefs = await SharedPreferences.getInstance();
// //         prefs.setString("pid", widget.product.id);
// //         prefs.setString("uid", widget.product.distributorId);
// //         if (!mounted) return;
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(builder: (_) => const addOrder()),
// //         );
// //       } else if (value == 'wishlist') {
// //         _toggleWishlist();
// //       }
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     final isDark = theme.brightness == Brightness.dark;
// //     final textColor = isDark ? Colors.white : Colors.black;
// //     final subText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
// //     final cardColor = theme.cardColor;
// //     final primaryColor = theme.primaryColor;
// //     final btnColor = isDark?AppColors.primaryDark:AppColors.primaryLight;
// //
// //     return Card(
// //       margin: const EdgeInsets.fromLTRB(10, 0, 10, 16),
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // ---------- HEADER ----------
// //           ListTile(
// //             onTap: _viewDistributorProfile,
// //             leading: CircleAvatar(
// //               backgroundImage: widget.product.distributorImage.isNotEmpty
// //                   ? NetworkImage(widget.product.distributorImage)
// //                   : null,
// //               child: widget.product.distributorImage.isEmpty
// //                   ? const Icon(Icons.store)
// //                   : null,
// //             ),
// //             title: Text(widget.product.distributorName,
// //                 style:
// //                 TextStyle(color: textColor, fontWeight: FontWeight.bold)),
// //             subtitle: widget.product.distributorPhone.isNotEmpty
// //                 ? Text(widget.product.distributorPhone,
// //                 style: TextStyle(color: subText, fontSize: 12))
// //                 : null,
// //             trailing: Builder(
// //               builder: (ctx) => IconButton(
// //                 icon: Icon(Icons.more_vert, color: textColor),
// //                 onPressed: () =>
// //                     _showOptionsMenu(ctx, textColor, cardColor),
// //               ),
// //             ),
// //           ),
// //
// //           // ---------- IMAGE + DOUBLE TAP ----------
// //           Stack(
// //             alignment: Alignment.center,
// //             children: [
// //               // 1. Base Image Layer
// //               GestureDetector(
// //                 onDoubleTap: () {
// //                   if (!isLiked) _toggleWishlist(fromDoubleTap: true);
// //                 },
// //                 child: AspectRatio(
// //                   aspectRatio: 1,
// //                   child: Image.network(
// //                     widget.product.image,
// //                     fit: BoxFit.cover,
// //                     errorBuilder: (_, __, ___) => Container(
// //                       color: Colors.grey.shade300,
// //                       child: const Icon(Icons.broken_image, size: 40),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //
// //               // 2. ❤️ Center Heart Animation (Only visible on double tap)
// //               AnimatedOpacity(
// //                 duration: const Duration(milliseconds: 300),
// //                 opacity: showCenterHeart ? 1 : 0,
// //                 child: AnimatedScale(
// //                   duration: const Duration(milliseconds: 300),
// //                   scale: showCenterHeart ? 1.2 : 0.6,
// //                   child: const Icon(
// //                     Icons.favorite,
// //                     color: Colors.red,
// //                     size: 120,
// //                   ),
// //                 ),
// //               ),
// //
// //               // 3. 💰 Price Pill Layer (Positioned at bottom right)
// //               if (widget.product.price.isNotEmpty)
// //                 Positioned(
// //                   bottom: 10,
// //                   right: 10,
// //                   child: Container(
// //                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// //                     decoration: BoxDecoration(
// //                       // theme se primaryColor use karne ke liye 'theme.primaryColor' use karein
// //                       color: theme.primaryColor.withOpacity(0.9),
// //                       borderRadius: BorderRadius.circular(20),
// //                     ),
// //                     child: Text(
// //                       "₹${widget.product.price}",
// //                       style: const TextStyle(
// //                         fontWeight: FontWeight.w900,
// //                         fontSize: 14,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //           // ---------- ACTION BAR ----------
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 10),
// //             child: Row(
// //               children: [
// //                 AnimatedSwitcher(
// //                   duration: const Duration(milliseconds: 200),
// //                   child: IconButton(
// //                     key: ValueKey(isLiked),
// //                     icon: Icon(
// //                       isLiked
// //                           ? Icons.favorite
// //                           : Icons.favorite_outline_rounded,
// //                       color: isLiked ? Colors.red : textColor,
// //                       size: 30,
// //                     ),
// //                     onPressed: _toggleWishlist,
// //                   ),
// //                 ),
// //                 IconButton(
// //                   icon: Icon(Icons.share_outlined, color: textColor),
// //                   onPressed: () =>
// //                       _showSnackBar("Sharing...", primaryColor),
// //                 ),
// //                 const Spacer(),
// //                 if (widget.showAddToCart)
// //                   FilledButton.icon(
// //                     style: FilledButton.styleFrom(backgroundColor: btnColor),
// //                     icon: Icon(Icons.shopping_cart_outlined,color: textColor,),
// //                     label: Text("Add to Cart",style: TextStyle(color:textColor ),),
// //                     onPressed: () async {
// //                       final prefs =
// //                       await SharedPreferences.getInstance();
// //                       prefs.setString("pid", widget.product.id);
// //                       prefs.setString("uid", widget.product.distributorId);
// //                       if (!mounted) return;
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                             builder: (_) => const addOrder()),
// //                       );
// //                     },
// //                   ),
// //               ],
// //             ),
// //           ),
// //
// //           // ---------- DETAILS ----------
// //           Padding(
// //             padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(widget.product.categoryName.toUpperCase(),
// //                     style: TextStyle(
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.bold,
// //                         color: primaryColor)),
// //                 const SizedBox(height: 4),
// //                 Text(widget.product.productName,
// //                     style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: textColor)),
// //                 const SizedBox(height: 6),
// //                 if (widget.product.description.isNotEmpty)
// //                   ReadMoreText(
// //                     widget.product.description,
// //                     trimLines: 2,
// //                     colorClickableText: primaryColor,
// //                     trimCollapsedText: 'read more',
// //                     trimExpandedText: 'show less',
// //                     style: TextStyle(color: textColor),
// //                   ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:readmore/readmore.dart';
// import 'package:snap2bill/theme/colors.dart';
//
// import '../data/dataModels.dart';
// import '../Customerdirectory/Customersends/addOrder.dart';
// import '../Distributordirectory/view/ViewDistributorProfile.dart';
//
// class ProductCard extends StatefulWidget {
//   final ProductData product;
//   final bool showAddToCart;
//
//   const ProductCard({
//     Key? key,
//     required this.product,
//     required this.showAddToCart,
//   }) : super(key: key);
//
//   @override
//   State<ProductCard> createState() => _ProductCardState();
// }
//
// class _ProductCardState extends State<ProductCard> {
//   late bool isLiked;
//   bool showCenterHeart = false;
//   bool _isProcessing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     // Backend se aaye huye initial status ko set karta hai
//     isLiked = widget.product.isLiked;
//   }
//
//   // ✅ SYNC LOGIC: Jab parent page (Home) refresh hoga,
//   // ye method local heart icon ko update kar dega.
//   @override
//   void didUpdateWidget(covariant ProductCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.product.isLiked != widget.product.isLiked) {
//       setState(() {
//         isLiked = widget.product.isLiked;
//       });
//     }
//   }
//
//   // ---------- Snackbar ----------
//   void _showSnackBar(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//         duration: const Duration(milliseconds: 800),
//       ),
//     );
//   }
//
//   // ---------- BACKEND TOGGLE FUNCTION ----------
//   Future<void> _toggleWishlistInBackend({bool fromDoubleTap = false}) async {
//     if (_isProcessing) return;
//
//     if (fromDoubleTap) {
//       setState(() => showCenterHeart = true);
//       Future.delayed(const Duration(milliseconds: 700), () {
//         if (mounted) setState(() => showCenterHeart = false);
//       });
//     }
//
//     setState(() => _isProcessing = true);
//
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String? ip = sh.getString("ip");
//       String? cid = sh.getString("cid");
//       String? uid = sh.getString("uid");
//
//       var response = await http.post(
//         Uri.parse("$ip/toggle_wishlist"),
//         body: {
//           'pid': widget.product.id, // Stock ID
//           'cid': cid ?? "",
//           'uid': uid ?? "",
//         },
//       );
//
//       if (response.statusCode == 200) {
//         var jsonData = json.decode(response.body);
//         setState(() {
//           isLiked = jsonData['action'] == 'added';
//         });
//
//         _showSnackBar(
//           isLiked ? "Added to Wishlist" : "Removed from Wishlist",
//           isLiked ? AppColors.dangerColor : Colors.grey,
//         );
//       }
//     } catch (e) {
//       _showSnackBar("Connection error!", Colors.red);
//     } finally {
//       setState(() => _isProcessing = false);
//     }
//   }
//
//   void _viewDistributorProfile() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ViewDistributorProfile(
//           distributorId: widget.product.distributorId,
//           distributorName: widget.product.distributorName,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : Colors.black;
//     final primaryColor = theme.primaryColor;
//     final btnColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
//
//     return Card(
//       margin: const EdgeInsets.fromLTRB(10, 0, 10, 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ---------- HEADER ----------
//           ListTile(
//             onTap: _viewDistributorProfile,
//             leading: CircleAvatar(
//               backgroundImage: widget.product.distributorImage.isNotEmpty
//                   ? NetworkImage(widget.product.distributorImage)
//                   : null,
//               child: widget.product.distributorImage.isEmpty
//                   ? const Icon(Icons.store)
//                   : null,
//             ),
//             title: Text(widget.product.distributorName,
//                 style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
//             subtitle: Text(widget.product.distributorPhone,
//                 style: const TextStyle(fontSize: 12)),
//           ),
//
//           // ---------- IMAGE SECTION WITH PRICE PILL ----------
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               GestureDetector(
//                 onDoubleTap: () {
//                   if (!isLiked) _toggleWishlistInBackend(fromDoubleTap: true);
//                 },
//                 child: AspectRatio(
//                   aspectRatio: 1,
//                   child: Image.network(
//                     widget.product.image,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => Container(
//                       color: Colors.grey.shade300,
//                       child: const Icon(Icons.broken_image, size: 40),
//                     ),
//                   ),
//                 ),
//               ),
//
//               // ❤️ Double Tap Heart Animation
//               AnimatedOpacity(
//                 duration: const Duration(milliseconds: 300),
//                 opacity: showCenterHeart ? 1 : 0,
//                 child: AnimatedScale(
//                   duration: const Duration(milliseconds: 300),
//                   scale: showCenterHeart ? 1.2 : 0.6,
//                   child: const Icon(Icons.favorite, color: Colors.red, size: 120),
//                 ),
//               ),
//
//               // 💰 PRICE PILL INSIDE IMAGE
//               if (widget.product.price.isNotEmpty)
//                 Positioned(
//                   bottom: 10,
//                   right: 10,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                     decoration: BoxDecoration(
//                       color: primaryColor.withOpacity(0.9),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       "₹${widget.product.price}",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w900,
//                         fontSize: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//
//           // ---------- ACTION BAR ----------
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: Icon(
//                     isLiked ? Icons.favorite : Icons.favorite_border,
//                     color: isLiked ? Colors.red : textColor,
//                     size: 30,
//                   ),
//                   onPressed: () => _toggleWishlistInBackend(),
//                 ),
//                 const Spacer(),
//                 if (widget.showAddToCart)
//                   FilledButton.icon(
//                     style: FilledButton.styleFrom(backgroundColor: btnColor),
//                     icon: Icon(Icons.shopping_cart_outlined, color: textColor),
//                     label: Text("Add to Cart", style: TextStyle(color: textColor)),
//                     onPressed: () async {
//                       final prefs =
//                       await SharedPreferences.getInstance();
//                       prefs.setString("pid", widget.product.id);
//                       prefs.setString("uid", widget.product.distributorId);
//                       if (!mounted) return;
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => const addOrder()),
//                       );
//                     },
//                   ),
//               ],
//             ),
//           ),
//
//           // ---------- DETAILS ----------
//           Padding(
//             padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(widget.product.categoryName.toUpperCase(),
//                     style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: primaryColor)),
//                 const SizedBox(height: 4),
//                 Text(widget.product.productName,
//                     style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: textColor)),
//                 const SizedBox(height: 6),
//                 if (widget.product.description.isNotEmpty)
//                   ReadMoreText(
//                     widget.product.description,
//                     trimLines: 2,
//                     colorClickableText: primaryColor,
//                     trimCollapsedText: 'read more',
//                     trimExpandedText: 'show less',
//                     style: TextStyle(color: textColor),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:readmore/readmore.dart';
import 'package:snap2bill/theme/colors.dart';

import '../data/dataModels.dart';
import '../Customerdirectory/Customersends/addOrder.dart';
import '../Distributordirectory/view/ViewDistributorProfile.dart';

class ProductCard extends StatefulWidget {
  final ProductData product;
  final bool showAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.showAddToCart,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isLiked;
  bool showCenterHeart = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Initialize state from the data model provided by parent
    isLiked = widget.product.isLiked;
  }

  // ✅ THIS FIXES THE COLOR RESET PROBLEM
  // When the list reloads or scrolls, this syncs the heart color with the backend data
  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.isLiked != widget.product.isLiked) {
      setState(() {
        isLiked = widget.product.isLiked;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  // ---------- BACKEND TOGGLE ----------
  Future<void> _toggleWishlistInBackend({bool fromDoubleTap = false}) async {
    if (_isProcessing) return;

    if (fromDoubleTap && !isLiked) {
      setState(() => showCenterHeart = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => showCenterHeart = false);
      });
    }

    setState(() => _isProcessing = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? "";
      String cid = sh.getString("cid") ?? "";
      String uid = sh.getString("uid") ?? "";

      var response = await http.post(
        Uri.parse("$ip/toggle_wishlist"),
        body: {
          'pid': widget.product.id,
          'cid': cid,
          'uid': uid,
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        setState(() {
          isLiked = jsonData['action'] == 'added';
        });
      }
    } catch (e) {
      _showSnackBar("Connection error!", Colors.red);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // ✅ THIS FIXES THE POPUP POSITION PROBLEM
  void _showOptionsMenu(BuildContext context, Offset tapPosition, Color textColor, Color cardColor) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        tapPosition & const Size(40, 40), // Exact tap area
        Offset.zero & overlay.size,
      ),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.person_outline, color: textColor),
            title: Text('View Profile', style: TextStyle(color: textColor)),
          ),
        ),
        PopupMenuItem(
          value: 'wishlist',
          child: ListTile(
            leading: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : textColor,
            ),
            title: Text(
              isLiked ? 'Remove Wishlist' : 'Add to Wishlist',
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'profile') {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ViewDistributorProfile(
          distributorId: widget.product.distributorId,
          distributorName: widget.product.distributorName,
        )));
      } else if (value == 'wishlist') {
        _toggleWishlistInBackend();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Card(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.product.distributorImage),
              onBackgroundImageError: (_, __) => const Icon(Icons.store),
            ),
            title: Text(widget.product.distributorName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.product.distributorPhone, style: const TextStyle(fontSize: 12)),
            trailing: GestureDetector(
              // Captures the exact position of the tap to show the menu locally
              onTapDown: (TapDownDetails details) {
                _showOptionsMenu(context, details.globalPosition, textColor, theme.cardColor);
              },
              child: const Icon(Icons.more_vert),
            ),
          ),

          // IMAGE SECTION
          Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onDoubleTap: () => _toggleWishlistInBackend(fromDoubleTap: true),
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      widget.product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
                    ),
                  ),
                ),
              ),
              if (showCenterHeart)
                const Icon(Icons.favorite, color: Colors.white70, size: 100),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(20)),
                  child: Text("₹${widget.product.price}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),

          // ACTION BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : textColor,
                    size: 30,
                  ),
                  onPressed: () => _toggleWishlistInBackend(),
                ),
                const Spacer(),
                if (widget.showAddToCart)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                      foregroundColor: textColor,
                    ),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString("pid", widget.product.id);
                      prefs.setString("uid", widget.product.distributorId);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const addOrder()));
                    },
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text("Add to Cart"),
                  )
              ],
            ),
          ),

          // DETAILS
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.categoryName.toUpperCase(),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                const SizedBox(height: 4),
                Text(widget.product.productName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ReadMoreText(
                  widget.product.description,
                  trimLines: 2,
                  colorClickableText: theme.primaryColor,
                  style: TextStyle(color: textColor.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}