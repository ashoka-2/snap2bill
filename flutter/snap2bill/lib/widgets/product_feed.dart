import 'package:flutter/material.dart';
import 'package:snap2bill/data/dataModels.dart'; // Ensure correct path to ProductData
import 'package:snap2bill/widgets/product_card.dart'; // Ensure correct path to ProductCard

class ProductFeedWidget extends StatelessWidget {
  final List<ProductData> filteredProducts;
  final bool showAddToCart;
  final bool isLoading; // Added to handle loading state visually

  const ProductFeedWidget({
    super.key,
    required this.filteredProducts,
    required this.showAddToCart,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.primaryColor));
    }

    if (filteredProducts.isEmpty) {
      // Shared "No products found" UI block
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  // Use theme for dynamic background color
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(50)),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 60,
                  // Use theme's secondary color or text color for icon contrast
                  color: Colors.grey,
                )),
            const SizedBox(height: 10),
            const Text(
              "No products found",
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      );
    }

    // Shared ListView.builder
    return ListView.builder(
      // The bottom padding to ensure the last card is visible above the system navigation bar
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: filteredProducts[index],
          // Dynamically pass the required cart visibility
          showAddToCart: showAddToCart,
        );
      },
    );
  }
}