

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:readmore/readmore.dart';

import '../data/dataModels.dart';
import '../Customerdirectory/Customersends/addOrder.dart';
import '../Distributordirectory/view/ViewDistributorProfile.dart';
import '../theme/colors.dart';

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
    isLiked = widget.product.isLiked;
  }

  /// ---------------- WISHLIST ----------------
  Future<void> _toggleWishlist({bool fromDoubleTap = false}) async {
    if (_isProcessing) return;

    if (fromDoubleTap && !isLiked) {
      setState(() => showCenterHeart = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => showCenterHeart = false);
      });
    }

    setState(() => _isProcessing = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      final ip = prefs.getString("ip") ?? "";
      final cid = prefs.getString("cid") ?? "";
      final uid = prefs.getString("uid") ?? "";

      final res = await http.post(
        Uri.parse("$ip/toggle_wishlist"),
        body: {
          'pid': widget.product.id,
          'cid': cid,
          'uid': uid,
        },
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          isLiked = data['action'] == 'added';
        });
      }
    } catch (e) {
      debugPrint("Wishlist error: $e");
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// ---------------- 3 DOT MENU ----------------
  void _showOptionsMenu(
      BuildContext ctx, Offset pos, Color textColor, Color bg) {
    final overlay = Overlay.of(ctx).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: ctx,
      position: RelativeRect.fromRect(
        pos & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      color: bg,
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
    ).then((v) {
      if (v == 'profile') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewDistributorProfile(
              distributorId: widget.product.distributorId,
              distributorName: widget.product.distributorName,
            ),
          ),
        );
      } else if (v == 'wishlist') {
        _toggleWishlist();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Center(
      child: SizedBox(
        width: 340,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              ListTile(
                leading: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewDistributorProfile(
                          distributorId: widget.product.distributorId,
                          distributorName: widget.product.distributorName,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage:
                    NetworkImage(widget.product.distributorImage),
                  ),
                ),
                title: Text(widget.product.distributorName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(widget.product.distributorPhone,
                    style: const TextStyle(fontSize: 12)),
                trailing: GestureDetector(
                  onTapDown: (d) => _showOptionsMenu(
                      context, d.globalPosition, textColor, theme.cardColor),
                  child: const Icon(Icons.more_vert),
                ),
              ),

              /// IMAGE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.15,
                      child: ClipPath(
                        clipper: ExactSvgClipper(),
                        child: GestureDetector(
                          onDoubleTap: () =>
                              _toggleWishlist(fromDoubleTap: true),
                          child: Image.network(
                            widget.product.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    /// PRICE
                    Positioned(
                      bottom: 18,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text("₹${widget.product.price}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),

                    /// WISHLIST BUTTON
                    Positioned(
                      bottom: 16,
                      left: 12,
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border:
                            Border.all(color: Colors.white, width: 3),
                          ),
                          child: IconButton(
                            icon: Icon(
                              isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.pinkAccent,
                              size: 22,
                            ),
                            onPressed: () => _toggleWishlist(),
                          ),
                        ),
                      ),
                    ),

                    if (showCenterHeart)
                      const Center(
                        child: Icon(Icons.favorite,
                            size: 90, color: Colors.white70),
                      ),
                  ],
                ),
              ),

              /// DETAILS
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.categoryName.toUpperCase(),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor)),
                    const SizedBox(height: 6),
                    Text(widget.product.productName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),

                    if (widget.product.description.trim().isNotEmpty)
                      ReadMoreText(
                        widget.product.description,
                        trimLines: 2,
                        style:
                        TextStyle(color: textColor.withOpacity(0.7)),
                      ),

                    if (widget.showAddToCart) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight,
                          ),
                          onPressed: () async {
                            final prefs =
                            await SharedPreferences.getInstance();
                            prefs.setString("pid", widget.product.id);
                            prefs.setString(
                                "uid", widget.product.distributorId);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const addOrder()),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart, size: 18,color: Colors.black,),
                          label: const Text("Add to Cart",style: TextStyle(color: Colors.black),),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// SVG CLIPPER (UNCHANGED)
class ExactSvgClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double svgW = 304.2;
    const double svgH = 259.8;

    final Path p = Path()
      ..moveTo(303.913, 252.788)
      ..quadraticBezierTo(308.656, 293.698, 263.596, 291.92)
      ..lineTo(71.459, 291.92)
      ..cubicTo(51.62, 291.98, 55.653, 286.979, 64.068, 276.494)
      ..arcToPoint(const Offset(10.919, 247.395),
          radius: const Radius.circular(1), clockwise: false)
      ..cubicTo(8.01, 255.269, 6.782, 257.343, 3.556, 254.843)
      ..cubicTo(0.09, 251.026, 0.173, 233.19, 0.379, 220.713)
      ..lineTo(0.379, 36.095)
      ..quadraticBezierTo(-4.834, -1.788, 33.807, 0.485)
      ..lineTo(263.385, 0.485)
      ..quadraticBezierTo(302.923, -0.202, 302.062, 33.834)
      ..close();

    final m = Matrix4.identity()
      ..scale(size.width / svgW, (size.height / svgH) * 0.85);

    return p.transform(m.storage);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}