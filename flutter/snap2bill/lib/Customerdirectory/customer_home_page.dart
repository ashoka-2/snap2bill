// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'package:snap2bill/Customerdirectory/custviews/viewCart.dart';
// import 'package:snap2bill/Customerdirectory/custviews/view_feedback.dart';
// import 'package:snap2bill/Customerdirectory/custviews/view_product.dart';
// import 'package:snap2bill/Customerdirectory/Customersends/send_feedback.dart';
// import 'package:snap2bill/Customerdirectory/custviews/viewOrder.dart';
// import 'package:snap2bill/Customerdirectory/password/changePassword.dart';
//
// import 'package:snap2bill/screens/Login_page.dart';
// import 'package:snap2bill/screens/viewWishlist.dart';
//
// import 'package:snap2bill/data/dataModels.dart';
// import 'package:snap2bill/data/category_service.dart';
// import 'package:snap2bill/data/product_service.dart';
// import 'package:snap2bill/widgets/Navbar.dart';
//
// import 'package:snap2bill/widgets/category_filter_bar.dart';
// import 'package:snap2bill/widgets/product_feed.dart';
// import 'package:snap2bill/widgets/custom_drawer.dart';
//
// import '../theme/colors.dart';
//
// class CustomerHomePage extends StatefulWidget {
//   const CustomerHomePage({Key? key}) : super(key: key);
//
//   @override
//   State<CustomerHomePage> createState() => _CustomerHomePageState();
// }
//
// class _CustomerHomePageState extends State<CustomerHomePage> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   List<ProductData> _allProducts = [];
//   List<CategoryData> _categories = [];
//   String _selectedCategoryId = "All";
//   bool _isLoading = true;
//
//   late Color dangerColor;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   /// =============================================================
//   /// LOAD PRODUCTS + CATEGORIES
//   /// =============================================================
//   Future<void> _loadData() async {
//     if (!mounted) return;
//
//     setState(() => _isLoading = true);
//
//     final products = await ProductService.customerProducts();
//     final categories = await CategoryService.fetchCategories();
//
//     if (!mounted) return;
//
//     setState(() {
//       _allProducts = products;
//       _categories = categories;
//       _isLoading = false;
//     });
//   }
//
//   /// =============================================================
//   /// DRAWER ITEMS
//   /// =============================================================
//   List<DrawerItemModel> _getDrawerItems() {
//     return [
//       DrawerItemModel(
//         icon: Icons.shopping_bag_outlined,
//         title: "View Products",
//         onTap: () => const view_product(),
//       ),
//       DrawerItemModel(
//         icon: Icons.feedback_outlined,
//         title: "Send Feedback",
//         onTap: () => const send_feedback(),
//       ),
//       DrawerItemModel(
//         icon: Icons.feedback_outlined,
//         title: "View Feedback",
//         onTap: () => const view_feedback(),
//       ),
//       DrawerItemModel(
//         icon: Icons.list_alt,
//         title: "Orders",
//         onTap: () => const viewOrder(),
//       ),
//       DrawerItemModel(
//         icon: Icons.lock_outline,
//         title: "Change Password",
//         onTap: () => const ChangePassword(),
//       ),
//       DrawerItemModel(
//         icon: Icons.logout,
//         title: "Logout",
//         color: dangerColor,
//         onTap: () async {
//           final prefs = await SharedPreferences.getInstance();
//           final ip = prefs.getString("ip");
//           await prefs.clear();
//           if (ip != null) {
//             await prefs.setString("ip", ip);
//           }
//           return const LoginPage();
//         },
//       ),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     dangerColor = AppColors.getDangerColor(context);
//
//     final theme = Theme.of(context);
//
//     final List<ProductData> filteredProducts =
//     _selectedCategoryId == "All"
//         ? _allProducts
//         : _allProducts
//         .where((p) => p.categoryId == _selectedCategoryId)
//         .toList();
//
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: theme.scaffoldBackgroundColor,
//
//       /// Swipe from left edge
//       drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.4,
//
//       drawer: CustomDrawer(menuItems: _getDrawerItems()),
//
//       appBar: ThemeNavbar(
//         title:"Snap2Bill",
//         leadingIcon: Icons.menu,
//         onLeadingPressed: () => _scaffoldKey.currentState?.openDrawer(),
//
//         actions: [
//           /// ❤️ Wishlist
//           IconButton(
//             icon: const Icon(Icons.favorite_border),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const ViewWishlist()),
//               ).then((_) {
//                 /// 🔁 Sync liked icons
//                 _loadData();
//               });
//             },
//           ),
//
//           /// 🛒 Cart
//           IconButton(
//             icon: const Icon(Icons.shopping_cart_outlined),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const viewCart()),
//               );
//             },
//           ),
//         ],
//       ),
//
//       body: RefreshIndicator(
//         onRefresh: _loadData,
//         child: Column(
//           children: [
//             /// CATEGORY FILTER
//             CategoryFilterBar(
//               categories: _categories,
//               selectedId: _selectedCategoryId,
//               onSelect: (id) =>
//                   setState(() => _selectedCategoryId = id),
//             ),
//
//             /// PRODUCT FEED
//             Expanded(
//               child: ProductFeedWidget(
//                 filteredProducts: filteredProducts,
//                 showAddToCart: true, // ✅ Customer = Add to Cart
//                 isLoading: _isLoading,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert'; // 🚀 Added for json decoding
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // 🚀 Added for counts API

import 'package:snap2bill/Customerdirectory/custviews/viewCart.dart';
import 'package:snap2bill/Customerdirectory/custviews/view_feedback.dart';
import 'package:snap2bill/Customerdirectory/custviews/view_product.dart';
import 'package:snap2bill/Customerdirectory/Customersends/send_feedback.dart';
import 'package:snap2bill/Customerdirectory/custviews/viewOrder.dart';
import 'package:snap2bill/Customerdirectory/password/changePassword.dart';

import 'package:snap2bill/screens/Login_page.dart';
import 'package:snap2bill/screens/viewWishlist.dart';

import 'package:snap2bill/data/dataModels.dart';
import 'package:snap2bill/data/category_service.dart';
import 'package:snap2bill/data/product_service.dart';
import 'package:snap2bill/widgets/Navbar.dart';

import 'package:snap2bill/widgets/category_filter_bar.dart';
import 'package:snap2bill/widgets/product_feed.dart';
import 'package:snap2bill/widgets/custom_drawer.dart';

import '../theme/colors.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({Key? key}) : super(key: key);

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<ProductData> _allProducts = [];
  List<CategoryData> _categories = [];
  String _selectedCategoryId = "All";
  bool _isLoading = true;

  // 🚀 EXTRA DETAILS: Count Variables
  int _cartCount = 0;
  int _wishlistCount = 0;

  late Color dangerColor;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// =============================================================
  /// LOAD PRODUCTS + CATEGORIES + COUNTS
  /// =============================================================
  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    // 1. Fetch products and categories
    final products = await ProductService.customerProducts();
    final categories = await CategoryService.fetchCategories();

    // 2. 🚀 EXTRA DETAILS: Fetch Counts from Backend
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "";
      String cid = prefs.getString("cid") ?? "";

      final response = await http.post(
        Uri.parse("$ip/get_counts"),
        body: {'cid': cid},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _cartCount = data['cart_count'] ?? 0;
            _wishlistCount = data['wishlist_count'] ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching counts: $e");
    }

    if (!mounted) return;

    setState(() {
      _allProducts = products;
      _categories = categories;
      _isLoading = false;
    });
  }
  // 🚀 Sirf counts refresh karne ke liye, products ko touch nahi karega
  Future<void> _refreshCountsOnly() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "";
      String uid = prefs.getString("uid") ?? ""; // Distributor
      String cid = prefs.getString("cid") ?? ""; // Customer

      final response = await http.post(
        Uri.parse("$ip/get_counts"),
        body: uid.isNotEmpty ? {'uid': uid} : {'cid': cid},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (mounted) {
          setState(() {
            // 🚀 Sirf in do variables ko update karein
            _cartCount = data['cart_count'] ?? 0;
            _wishlistCount = data['wishlist_count'] ?? 0;
          });
          // Products reload nahi honge, toh UI blink nahi karega!
        }
      }
    } catch (e) {
      debugPrint("Count refresh error: $e");
    }
  }
  /// =============================================================
  /// DRAWER ITEMS
  /// =============================================================
  List<DrawerItemModel> _getDrawerItems() {
    return [
      DrawerItemModel(
        icon: Icons.shopping_bag_outlined,
        title: "View Products",
        onTap: () => const view_product(),
      ),
      DrawerItemModel(
        icon: Icons.feedback_outlined,
        title: "Send Feedback",
        onTap: () => const send_feedback(),
      ),
      DrawerItemModel(
        icon: Icons.feedback_outlined,
        title: "View Feedback",
        onTap: () => const view_feedback(),
      ),
      DrawerItemModel(
        icon: Icons.list_alt,
        title: "Orders",
        onTap: () => const viewOrder(),
      ),
      DrawerItemModel(
        icon: Icons.lock_outline,
        title: "Change Password",
        onTap: () => const ChangePassword(),
      ),
      DrawerItemModel(
        icon: Icons.logout,
        title: "Logout",
        color: dangerColor,
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          final ip = prefs.getString("ip");
          await prefs.clear();
          if (ip != null) {
            await prefs.setString("ip", ip);
          }
          return const LoginPage();
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    dangerColor = AppColors.getDangerColor(context);
    final primaryColor = AppColors.getPrimaryColor(context); // 🚀 Added for badge color
    final theme = Theme.of(context);

    final List<ProductData> filteredProducts =
    _selectedCategoryId == "All"
        ? _allProducts
        : _allProducts
        .where((p) => p.categoryId == _selectedCategoryId)
        .toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,

      drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.4,
      drawer: CustomDrawer(menuItems: _getDrawerItems()),

      appBar: ThemeNavbar(
        title:"Snap2Bill",
        leadingIcon: Icons.menu,
        onLeadingPressed: () => _scaffoldKey.currentState?.openDrawer(),

        actions: [
          /// ❤️ Wishlist with Badge
          Badge(
            label: Text(_wishlistCount.toString()),
            isLabelVisible: _wishlistCount > 0, // 🚀 Only show if count > 0
            offset: const Offset(-4, 4),
            backgroundColor: primaryColor,
            child: IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewWishlist()),
                ).then((_) {
                  _loadData(); // 🚀 Refresh count when coming back
                });
              },
            ),
          ),

          const SizedBox(width: 0), // Spacing between icons

          /// 🛒 Cart with Badge
          Badge(
            label: Text(_cartCount.toString()),
            isLabelVisible: _cartCount > 0, // 🚀 Only show if count > 0
            offset: const Offset(-4, 4),
            backgroundColor: dangerColor,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const viewCart()),
                ).then((_) {
                  _loadData(); // 🚀 Refresh count when coming back
                });
              },
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            CategoryFilterBar(
              categories: _categories,
              selectedId: _selectedCategoryId,
              onSelect: (id) =>
                  setState(() => _selectedCategoryId = id),
            ),

            Expanded(
              child: ProductFeedWidget(
                filteredProducts: filteredProducts,
                showAddToCart: true,
                isLoading: _isLoading,
                onWishlistToggle: () {
                  // 🚀 Ab poora data load nahi hoga, sirf badge badlega
                  _refreshCountsOnly();
                },

              ),
            ),
          ],
        ),
      ),
    );
  }
}