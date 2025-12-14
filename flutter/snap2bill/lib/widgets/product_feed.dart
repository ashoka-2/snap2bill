import 'package:flutter/material.dart';

import '../data/dataModels.dart';
import 'product_card.dart';

class ProductFeed extends StatelessWidget {
  final List<ProductData> products;

  /// true  -> Customer (show Add to Cart)
  /// false -> Distributor (hide Add to Cart)
  final bool showAddToCart;

  const ProductFeed({
    Key? key,
    required this.products,
    required this.showAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(
        child: Text("No products found"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          showAddToCart: showAddToCart,
        );
      },
    );
  }
}
