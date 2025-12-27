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
    if (isLoading) {
      return ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => _buildShimmer(Theme.of(context).brightness == Brightness.dark),
      );
    }

    if (filteredProducts.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    //
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: filteredProducts.length,
      addAutomaticKeepAlives: true,
      cacheExtent: 1000, // Pre-loads items for zero lag
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return ProductCard(
          // Key ensures that the card state (color) resets when data reloads
          key: ValueKey("${product.id}_${product.isLiked}"),
          product: product,
          showAddToCart: showAddToCart,
        );
      },
    );
  }

  Widget _buildShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.all(15),
        height: 300,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}