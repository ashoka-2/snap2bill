// import 'package:flutter/material.dart';
// import 'package:snap2bill/Customerdirectory/custviews/viewCart.dart';
//
// // --- SERVICE IMPORTS ---
// import '../../data/dataModels.dart';
// import '../../data/product_service.dart';
//
// // --- WIDGET IMPORTS ---
// import 'package:snap2bill/widgets/product_card.dart';
//
// // --- NAVIGATION IMPORTS (Original) ---
// import '../../theme/colors.dart';
// import '../../widgets/Navbar.dart';
//
// class view_product extends StatelessWidget {
//   const view_product({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const _ViewProductSub();
//   }
// }
//
// class _ViewProductSub extends StatefulWidget {
//   const _ViewProductSub({Key? key}) : super(key: key);
//
//   @override
//   State<_ViewProductSub> createState() => _ViewProductSubState();
// }
//
// class _ViewProductSubState extends State<_ViewProductSub> {
//   late Future<List<ProductData>> _productsFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _productsFuture = ProductService.customerProducts();
//   }
//
//   // Helper method for refresh
//   Future<void> _refreshProducts() async {
//     setState(() {
//       _productsFuture = ProductService.customerProducts();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final textColor = AppColors.getTextColor(context);
//     final bgColor = AppColors.getScaffoldBg(context);
//     final primaryColor = AppColors.getPrimaryColor(context);
//
//
//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: ThemeNavbar(title: "Products",
//         leadingIcon: Icons.arrow_back_ios_rounded,
//         onLeadingPressed: ()=>{
//           if (Navigator.canPop(context)) Navigator.pop(context)
//         },
//         centerTitle: true,
//
//
//         actions: [
//           IconButton(
//             icon: Icon(Icons.shopping_bag_outlined, color: textColor),
//             onPressed: () {
//               // Assuming this navigates to the cart/addOrder page
//               Navigator.push(context, MaterialPageRoute(builder: (context) => const viewCart()));
//             },
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refreshProducts,
//         child: FutureBuilder<List<ProductData>>(
//           future: _productsFuture,
//           builder: (BuildContext context, AsyncSnapshot<List<ProductData>> snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(color: primaryColor),
//               );
//             }
//
//             final List<ProductData> products = snapshot.data ?? [];
//
//             if (snapshot.hasError || products.isEmpty) {
//               return Center(
//                 child: SingleChildScrollView(
//                   // Allows pull-to-refresh even when list is empty
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.inventory_2_outlined,
//                         size: 60,
//                         color: AppColors.disabledColor,
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         "No products found",
//                         style: TextStyle(color: AppColors.disabledColor),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             } else {
//               // ⭐️ CORE CHANGE: Use the reusable ProductCard
//               return ListView.builder(
//                 padding: const EdgeInsets.only(bottom: 20),
//                 itemCount: products.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   return ProductCard(
//                     product: products[index],
//                     showAddToCart: true, // Enable Add to Cart features
//                   );
//                 },
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
// // Note: The redundant Joke model and utility functions were removed as they are now handled by ProductService and ProductData.


import 'package:flutter/material.dart';
import 'package:snap2bill/Customerdirectory/custviews/viewCart.dart';

// --- SERVICE IMPORTS ---
import '../../data/dataModels.dart';
import '../../data/product_service.dart';

// --- WIDGET IMPORTS ---
import 'package:snap2bill/widgets/product_card.dart';
import 'package:snap2bill/widgets/SearchBar.dart'; // Aapka Custom SearchAppBar

// --- THEME IMPORTS ---
import '../../theme/colors.dart';

class view_product extends StatelessWidget {
  const view_product({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _ViewProductSub();
  }
}

class _ViewProductSub extends StatefulWidget {
  const _ViewProductSub({Key? key}) : super(key: key);

  @override
  State<_ViewProductSub> createState() => _ViewProductSubState();
}

class _ViewProductSubState extends State<_ViewProductSub> {
  late Future<List<ProductData>> _productsFuture;

  // 🚀 Search Logic ke liye variable
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService.customerProducts();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _searchQuery = ""; // Refresh par search saaf
      _productsFuture = ProductService.customerProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.getScaffoldBg(context);
    final primaryColor = AppColors.getPrimaryColor(context);

    return Scaffold(
      backgroundColor: bgColor,

      appBar: SearchAppBar(
        hintText: "Search products or categories...",
        onLeadingPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),

      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        color: primaryColor,
        child: FutureBuilder<List<ProductData>>(
          future: _productsFuture,
          builder: (BuildContext context, AsyncSnapshot<List<ProductData>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryColor));
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Error loading products", style: TextStyle(color: Colors.red)));
            }

            final List<ProductData> allProducts = snapshot.data ?? [];

            final filteredProducts = allProducts.where((product) {
              final nameMatch = product.productName.toLowerCase().contains(_searchQuery);
              final categoryMatch = product.categoryName.toLowerCase().contains(_searchQuery);
              return nameMatch || categoryMatch;
            }).toList();

            if (filteredProducts.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty ? "No products available" : "No results for '$_searchQuery'",
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 20, bottom: 80,left: 20,right: 20),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: filteredProducts[index],
                  showAddToCart: true,
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const viewCart())
        ),
        child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
      ),
    );
  }
}