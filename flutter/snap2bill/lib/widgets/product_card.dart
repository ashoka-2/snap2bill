import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// NOTE: ReadMoreText must be available in your project dependencies.
import 'package:readmore/readmore.dart';

import '../data/dataModels.dart';
import '../Customerdirectory/Customersends/addOrder.dart';
import '../Distributordirectory/view/ViewDistributorProfile.dart';

class ProductCard extends StatelessWidget {
  final ProductData product;

  /// true  -> Customer (show Add to Cart button/menu item)
  /// false -> Distributor (hide Add to Cart button/menu item)
  final bool showAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.showAddToCart,
  }) : super(key: key);

  // Helper function for UI feedback on action bar taps
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Function to show the three-dot options menu
  void _showOptionsMenu(BuildContext context, Color textColor, Color cardColor, Color primaryColor) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        buttonPosition & button.size,
        Offset.zero & MediaQuery.of(context).size,
      ).shift(const Offset(-10, 0)),

      items: [
        PopupMenuItem<String>(
          value: 'view_profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, color: textColor),
              const SizedBox(width: 8),
              Text('View Profile', style: TextStyle(color: textColor)),
            ],
          ),
        ),
        // Add to Cart for Customer
        if (showAddToCart)
          PopupMenuItem<String>(
            value: 'cart',
            child: Row(
              children: [
                Icon(Icons.shopping_cart, size: 18, color: textColor),
                const SizedBox(width: 8),
                Text('Add to Cart', style: TextStyle(color: textColor)),
              ],
            ),
          ),

        // Wishlist for both
        PopupMenuItem<String>(
          value: 'wishlist',
          child: Row(
            children: [
              Icon(Icons.favorite_border, size: 18, color: textColor),
              const SizedBox(width: 8),
              Text('Add to Wishlist', style: TextStyle(color: textColor)),
            ],
          ),
        ),

        // Share for both
        PopupMenuItem<String>(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share, size: 18, color: textColor),
              const SizedBox(width: 8),
              Text('Share Product', style: TextStyle(color: textColor)),
            ],
          ),
        ),
      ],
      elevation: 8.0,
      color: cardColor,
    ).then((value) async {
      if (value == 'view_profile') {
        _viewDistributorProfile(context);
      } else if (value == 'cart') {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("pid", product.id);
        prefs.setString("uid", product.distributorId);

        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const addOrder()),
        );
      } else if (value == 'wishlist') {
        if (!context.mounted) return;
        _showSnackBar(context, "Added ${product.productName} to Wishlist", primaryColor);
      } else if (value == 'share') {
        if (!context.mounted) return;
        _showSnackBar(context, "Sharing ${product.productName}...", primaryColor);
      }
    });
  }

  void _viewDistributorProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewDistributorProfile(
          distributorId: product.distributorId,
          distributorName: product.distributorName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor =
    isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final cardColor = theme.cardColor;
    final primaryColor = theme.primaryColor;

    return Card(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------- 1. HEADER (Distributor Info + 3-dot Menu) ----------
          ListTile(
            onTap: () => _viewDistributorProfile(context),

            leading: CircleAvatar(
              backgroundColor:
              isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              backgroundImage: product.distributorImage.isNotEmpty
                  ? NetworkImage(product.distributorImage)
                  : null,
              child: product.distributorImage.isEmpty
                  ? const Icon(Icons.store)
                  : null,
            ),
            title: Text(
              product.distributorName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            subtitle: product.distributorPhone.isNotEmpty
                ? Text(
              product.distributorPhone,
              style: TextStyle(color: subTextColor, fontSize: 12),
            )
                : null,

            // Trailing button for the 3-dot menu
            trailing: Builder(
              builder: (menuContext) {
                return IconButton(
                  icon: Icon(Icons.more_vert, color: textColor),
                  onPressed: () => _showOptionsMenu(menuContext, textColor, cardColor, primaryColor),
                );
              },
            ),
          ),

          /// ---------- 2. IMAGE + PRICE OVERLAY ----------
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: product.image.isNotEmpty
                    ? Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(Icons.broken_image,
                        color: subTextColor, size: 40),
                  ),
                )
                    : Container(
                  color: isDark
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                ),
              ),

              // PRICE PILL (Right Bottom Corner)
              if (product.price.isNotEmpty)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.9), // Pill background
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "₹${product.price}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          /// ---------- 3. ACTION BAR (Wishlist + Share + Add to Cart Button) ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Wishlist Icon
                IconButton(
                  icon: Icon(Icons.favorite_border, color: textColor),
                  onPressed: () {
                    _showSnackBar(context, "Added ${product.productName} to Wishlist", primaryColor);
                  },
                  tooltip: 'Wishlist',
                ),

                // Share Icon
                IconButton(
                  icon: Icon(Icons.share_outlined, color: textColor),
                  onPressed: () {
                    _showSnackBar(context, "Sharing ${product.productName}...", primaryColor);
                  },
                  tooltip: 'Share',
                ),

                const Spacer(),

                /// ---------- Add to Cart Button (CUSTOMER ONLY) ----------
                if (showAddToCart)
                  FilledButton.icon(
                    icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                    label: const Text("Add to Cart"),
                    onPressed: () async {
                      final prefs =
                      await SharedPreferences.getInstance();

                      prefs.setString("pid", product.id);
                      prefs.setString("uid", product.distributorId);

                      if (!context.mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const addOrder(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),

          /// ---------- 4. DETAILS (Category, Name, Description) ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// CATEGORY
                Text(
                  product.categoryName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),

                /// PRODUCT NAME
                Text(
                  product.productName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 6),

                /// DESCRIPTION (ReadMoreText)
                if (product.description.isNotEmpty)
                  ReadMoreText(
                    product.description,
                    trimLines: 2,
                    colorClickableText: primaryColor,
                    trimCollapsedText: 'read more',
                    trimExpandedText: 'show less',
                    style: TextStyle(color: textColor),
                    moreStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}