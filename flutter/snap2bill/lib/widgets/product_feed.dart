import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snap2bill/widgets/product_card.dart';

import '../data/dataModels.dart';

class ProductFeedWidget extends StatelessWidget {
  final List<ProductData> filteredProducts;
  final bool showAddToCart;
  final bool isLoading;

  const ProductFeedWidget({
    Key? key,
    required this.filteredProducts,
    required this.showAddToCart,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    /// ---------------- LOADING STATE ----------------
    if (isLoading) {
      return ListView.builder(
        itemCount: 3,
        padding: const EdgeInsets.only(bottom: 100),
        itemBuilder: (context, index) => _buildShimmer(isDark),
      );
    }

    /// ---------------- EMPTY STATE ----------------
    if (filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          "No products found",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    /// ---------------- PRODUCT LIST ----------------
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: filteredProducts.length,
      addAutomaticKeepAlives: true,
      cacheExtent: 1000, // ⚡ smooth scrolling
      itemBuilder: (context, index) {
        final product = filteredProducts[index];

        return ProductCard(
          /// 🔑 Key forces rebuild when wishlist state changes
          key: ValueKey("${product.id}_${product.isLiked}"),
          product: product,
          showAddToCart: showAddToCart,
        );
      },
    );
  }

  /// ---------------- SHIMMER PLACEHOLDER ----------------
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
