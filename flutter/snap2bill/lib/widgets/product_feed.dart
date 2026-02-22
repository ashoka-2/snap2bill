
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snap2bill/widgets/product_card.dart';
import '../data/dataModels.dart';

class ProductFeedWidget extends StatelessWidget {
  final List<ProductData> filteredProducts;
  final bool showAddToCart;
  final bool isLoading;
  final VoidCallback? onWishlistToggle;
  final String? refreshId;

  const ProductFeedWidget({
    Key? key,
    required this.filteredProducts,
    required this.showAddToCart,
    required this.isLoading,
    this.onWishlistToggle,
    this.refreshId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // ---------------- LOADING STATE ----------------
    if (isLoading) {
      return ListView.builder(
        itemCount: 3,
        padding: const EdgeInsets.only(bottom: 100),
        itemBuilder: (context, index) => _buildShimmer(isDark),
      );
    }

    // ---------------- EMPTY STATE ----------------
    if (filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          "No products found",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    // ---------------- RESPONSIVE SWITCHER ----------------
    return LayoutBuilder(
      builder: (context, constraints) {

        // 📱 MOBILE PORTRAIT (Width < 600) -> Use LIST VIEW
        // This restores your original look completely (No extra gaps)
        if (constraints.maxWidth < 600) {
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: filteredProducts.length,
            addAutomaticKeepAlives: true,
            cacheExtent: 1000,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return ProductCard(
                key: ValueKey("${product.id}_${product.isLiked}"),
                product: product,
                showAddToCart: showAddToCart,
                onWishlistToggle: onWishlistToggle,
                refreshId: refreshId,
              );
            },
          );
        }

        // 💻 LANDSCAPE / TABLET (Width >= 600) -> Use GRID VIEW
        else {
          return GridView.builder(
            padding: const EdgeInsets.only(bottom: 100, top: 10, left: 10, right: 10),
            itemCount: filteredProducts.length,
            addAutomaticKeepAlives: true,
            cacheExtent: 1000,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400, // Cards will try to be around 400px wide
              childAspectRatio: 0.65, // Adjust this to fit card height
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return Center(
                child: ProductCard(
                  key: ValueKey("${product.id}_${product.isLiked}"),
                  product: product,
                  showAddToCart: showAddToCart,
                  onWishlistToggle: onWishlistToggle,
                  refreshId: refreshId,
                ),
              );
            },
          );
        }
      },
    );
  }

  // ---------------- SHIMMER (Mobile Style) ----------------
  Widget _buildShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}