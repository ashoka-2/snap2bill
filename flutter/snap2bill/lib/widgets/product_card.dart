
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