

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:readmore/readmore.dart';

import '../data/dataModels.dart';
import '../Customerdirectory/Customersends/addOrder.dart';
import '../screens/viewDistributorProfile.dart';
import '../theme/colors.dart';
import 'app_button.dart';

class ProductCard extends StatefulWidget {
  final ProductData product;
  final bool showAddToCart;
  final VoidCallback? onWishlistToggle;
  final String? refreshId;

  const ProductCard({
    Key? key,
    required this.product,
    required this.showAddToCart,
    this.onWishlistToggle,
    this.refreshId,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isLiked;
  bool showCenterHeart = false;
  bool _isProcessing = false;

  late Color dangerColor;

  @override
  void initState() {
    super.initState();
    isLiked = widget.product.isLiked;
  }

  @override
  void didUpdateWidget(ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // LOGIC: Agar Parent se naya "Time" aaya hai, toh Local State ko Server Data se overwrite karo
    if (widget.refreshId != oldWidget.refreshId) {
      setState(() {
        isLiked = widget.product.isLiked; // Force Update
      });
    }
    // Backup: Agar normal data change hua ho
    else if (widget.product.isLiked != oldWidget.product.isLiked) {
      setState(() {
        isLiked = widget.product.isLiked;
      });
    }
  }


  /// ---------------- WISHLIST ----------------
  // Future<void> _toggleWishlist({bool fromDoubleTap = false}) async {
  //   if (_isProcessing) return;
  //
  //   // (Existing heart animation logic...)
  //
  //   setState(() => _isProcessing = true);
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final ip = prefs.getString("ip") ?? "";
  //     final cid = prefs.getString("cid") ?? "";
  //     final uid = prefs.getString("uid") ?? "";
  //
  //     final res = await http.post(
  //       Uri.parse("$ip/toggle_wishlist"),
  //       body: {'pid': widget.product.id, 'cid': cid, 'uid': uid},
  //     );
  //
  //     if (res.statusCode == 200) {
  //       final data = json.decode(res.body);
  //       setState(() {
  //         isLiked = data['action'] == 'added';
  //       });
  //
  //       // 🚀 YE SABSE IMPORTANT HAI: Home page ko signal dena
  //       if (widget.onWishlistToggle != null) {
  //         widget.onWishlistToggle!();
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Wishlist error: $e");
  //   } finally {
  //     if (mounted) setState(() => _isProcessing = false);
  //   }
  // }
  Future<void> _toggleWishlist({bool fromDoubleTap = false}) async {
    if (_isProcessing) return;

    // 🚀 OPTIMISTIC UPDATE: Backend call se pehle hi UI badal do
    setState(() {
      isLiked = !isLiked;
      if (fromDoubleTap && isLiked) showCenterHeart = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final ip = prefs.getString("ip") ?? "";
      final cid = prefs.getString("cid") ?? "";
      final uid = prefs.getString("uid") ?? "";

      final res = await http.post(
        Uri.parse("$ip/toggle_wishlist"),
        body: {'pid': widget.product.id, 'cid': cid, 'uid': uid},
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        // Backend se confirm karein final state
        if (mounted) {
          setState(() {
            isLiked = data['action'] == 'added';
          });
          if (widget.onWishlistToggle != null) widget.onWishlistToggle!();
        }
      } else {
        // 🔄 ROLLBACK: Agar backend fail ho jaye toh wapas purana state
        if (mounted) {
          setState(() {
            isLiked = !isLiked;
          });
        }
      }
    } catch (e) {
      // 🔄 ROLLBACK on Error
      if (mounted) {
        setState(() {
          isLiked = !isLiked;
        });
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
              color: isLiked ? dangerColor : textColor,
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
    dangerColor = AppColors.getDangerColor(context);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.WhiteColor: Colors.black87;

    return Center(
      child: SizedBox(
        width: 340,
        child: Card(
          color: AppColors.getCardColor(context),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              Container(
                // margin: EdgeInsets.only(left: 8,right: 8,top: 5,bottom: 2),
                // decoration: BoxDecoration(
                //   color: AppColors.getPillBg(context),
                //   borderRadius: BorderRadius.circular(50),
                // ),
                child: ListTile(
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
                      backgroundColor: Colors.grey[200], // Optional: background color
                      backgroundImage: const AssetImage("assets/images/default-avatar.png"),
                      foregroundImage: widget.product.distributorImage.isNotEmpty
                          ? NetworkImage(widget.product.distributorImage)
                          : null,
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
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.getPillBg(context),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(width: 1,color: AppColors.getBorderColor(context))
                        ),
                        child: Text("₹${widget.product.price}",
                            style:  TextStyle(
                              fontSize: 13,
                                color: AppColors.getTextColor(context),
                                fontWeight: FontWeight.bold)),
                      ),
                    ),

                    /// WISHLIST BUTTON
                    Positioned(
                      bottom: 13,
                      left:9,
                      child: Container(
                        width: 63,
                        height: 63,
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:  AppColors.getCardColor(context),
                          borderRadius: BorderRadius.circular(50)
                        ),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isLiked?AppColors.dangerbgColor:AppColors.getPillBg(context).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border:
                              Border.all(color:isLiked?AppColors.dangerColor.withValues(alpha: 0.5):AppColors.getBorderColor(context) , width: 2,),
                            ),
                            child: IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isLiked?AppColors.dangerColor:AppColors.getIconColor(context),
                                size: 30,
                              ),
                              onPressed: () => _toggleWishlist(),
                            ),
                          ),
                        ),
                      ),
                    ),


                    if (showCenterHeart)
                      Positioned.fill(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 700),
                          onEnd: () {
                            setState(() {
                              showCenterHeart = false;
                            });
                          },
                          builder: (context, value, child) {
                            // 1. POP SCALE (Instagram style)
                            double scale = 0.0;
                            if (value < 0.2) {
                              scale = (value / 0.2) * 1.2;
                            } else if (value < 0.4) {
                              scale = 1.2 - ((value - 0.2) / 0.2) * 0.2;
                            } else {
                              scale = 1.0;
                            }

                            // 2. SLIDE UP (Starts after the pop)
                            double slideProgress = value > 0.4 ? (value - 0.4) / 0.6 : 0.0;
                            double yOffset = -70 * slideProgress;

                            // 3. FADE OUT
                            double opacity = value < 0.7 ? 1.0 : 1.0 - ((value - 0.7) / 0.3);

                            return Transform.translate(
                              offset: Offset(0, yOffset),
                              child: Transform.scale(
                                scale: scale,
                                child: Opacity(
                                  opacity: opacity.clamp(0.0, 1.0),
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: Center(
                            child: ShaderMask(
                              // 3D Gradient Colors
                              shaderCallback: (Rect bounds) {
                                return const RadialGradient(
                                  center: Alignment(-0.2, -0.2), // Light source from top-left
                                  radius: 0.8,
                                  colors: [
                                    Color(0xFFFF0062),
                                    Color(0xFFFF006A),
                                    Color(0xFFFF004D),
                                  ],
                                  stops: [0.2, 0.5, 1.0],
                                ).createShader(bounds);
                              },
                              child: Icon(
                                Icons.favorite_rounded,
                                size: 110,
                                color: Colors.white, // Required for ShaderMask
                                shadows: [
                                  // Bottom-right shadow for depth
                                  Shadow(
                                    offset: const Offset(5, 8),
                                    blurRadius: 15,
                                    color: Colors.black.withValues(alpha: 0.4),
                                  ),
                                  // Subtle white rim light for 3D effect
                                  const Shadow(
                                    offset: Offset(-2, -2),
                                    blurRadius: 4,
                                    color: Colors.white30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                  ],
                ),
              ),

              /// DETAILS
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.product.categoryName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),

                        if (widget.showAddToCart)
                          SizedBox(
                            width: 130, // Slimmer width for the top corner
                            height: 36, // Slightly shorter to match text height better
                            child:
                            // CartButton(
                            //   text: "Add to cart",
                            //   icon: Icons.add_shopping_cart,
                            //   onPressed: () async {
                            //     final prefs = await SharedPreferences.getInstance();
                            //     await prefs.setString("pid", widget.product.id);
                            //     await prefs.setString("uid", widget.product.distributorId);
                            //
                            //     if (context.mounted) {
                            //
                            //       if (widget.onWishlistToggle != null) {
                            //         widget.onWishlistToggle!();
                            //       }
                            //       Navigator.push(
                            //         context,
                            //         MaterialPageRoute(builder: (_) => const addOrder()),
                            //       );
                            //     }
                            //   },
                            // ),
                            // ProductCard.dart ke build method mein CartButton wala part
                            CartButton(
                              text: "Add to cart",
                              icon: Icons.add_shopping_cart,
                              onPressed: () async {
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setString("pid", widget.product.id);
                                await prefs.setString("uid", widget.product.distributorId);

                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const addOrder()),
                                  ).then((result) {
                                    // 🚀 Agar addOrder page se "refresh" signal aaya hai,
                                    // toh Home page ka _refreshCountsOnly() trigger karein
                                    if (result == "refresh" || result == null) {
                                      if (widget.onWishlistToggle != null) {
                                        widget.onWishlistToggle!();
                                      }
                                    }
                                  });
                                }
                              },
                            ),
                          ),

                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(widget.product.productName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),

                    if (widget.product.description.trim().isNotEmpty)
                      Container(
                        height: 60, // 🔒 Height fix kar di (Overflow khatam)
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: ReadMoreText(
                            widget.product.description, // Original text rakha
                            trimLines: 2,
                            trimMode: TrimMode.Line,
                            trimCollapsedText: ' Read more',
                            trimExpandedText: ' Show less',
                            style: TextStyle(color: AppColors.getIconColor(context)),
                          ),
                        ),
                      ),
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