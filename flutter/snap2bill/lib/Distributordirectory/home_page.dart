// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'package:snap2bill/Distributordirectory/view/myProducts.dart';
// import 'package:snap2bill/Distributordirectory/view/viewAllOrders.dart';
// import 'package:snap2bill/Distributordirectory/view/view_category.dart';
// import 'package:snap2bill/Distributordirectory/view/view_distributors.dart';
// import 'package:snap2bill/Distributordirectory/view/view_feedback.dart';
// import 'package:snap2bill/Distributordirectory/view/view_product.dart';
// import 'package:snap2bill/Distributordirectory/password/changePassword.dart';
//
// import 'package:snap2bill/screens/Login_page.dart';
// import 'package:snap2bill/screens/viewWishlist.dart';
//
// import 'package:snap2bill/data/dataModels.dart';
// import 'package:snap2bill/data/category_service.dart';
// import 'package:snap2bill/data/product_service.dart';
// import 'package:snap2bill/theme/colors.dart';
// import 'package:snap2bill/widgets/Navbar.dart';
//
// import 'package:snap2bill/widgets/category_filter_bar.dart';
// import 'package:snap2bill/widgets/product_feed.dart';
// import 'package:snap2bill/widgets/custom_drawer.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
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
//     final products = await ProductService.distributorProducts();
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
//         icon: Icons.people_alt_outlined,
//         title: "Distributors",
//         onTap: () => const ViewDistributors(),
//       ),
//       DrawerItemModel(
//         icon: Icons.inventory_2_outlined,
//         title: "My Products",
//         onTap: () => const MyProducts(),
//       ),
//       DrawerItemModel(
//         icon: Icons.shopping_bag_outlined,
//         title: "All Products",
//         onTap: () => const ViewProduct(),
//       ),
//       DrawerItemModel(
//         icon: Icons.list_alt,
//         title: "Orders",
//         onTap: () => const ViewAllOrders(),
//       ),
//       DrawerItemModel(
//         icon: Icons.category_outlined,
//         title: "Category",
//         onTap: () => const ViewCategory(),
//       ),
//       DrawerItemModel(
//         icon: Icons.feedback_outlined,
//         title: "Feedback",
//         onTap: () => const ViewFeedback(),
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
//     final List<ProductData> filteredProducts =
//     _selectedCategoryId == "All"
//         ? _allProducts
//         : _allProducts
//         .where((p) => p.categoryId == _selectedCategoryId)
//         .toList();
//
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//
//       child: Scaffold(
//         key: _scaffoldKey,
//         backgroundColor: AppColors.getScaffoldBg(context),
//
//         /// Swipe from left edge
//         drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.4,
//
//         drawer: CustomDrawer(menuItems: _getDrawerItems()),
//
//         appBar: ThemeNavbar(
//           title:
//             "Snap2Bill",
//           leadingIcon: Icons.menu,
//           onLeadingPressed: ()=>
//           {
//             _scaffoldKey.currentState?.openDrawer(),
//           },
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.favorite_border),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const ViewWishlist()),
//                 ).then((_) {
//                   /// 🔁 Sync wishlist state on return
//                   _loadData();
//                 });
//               },
//             ),
//
//           ],
//         ),
//
//         body: RefreshIndicator(
//           onRefresh: _loadData,
//           child: Column(
//             children: [
//               /// CATEGORY FILTER
//               CategoryFilterBar(
//                 categories: _categories,
//                 selectedId: _selectedCategoryId,
//                 onSelect: (id) =>
//                     setState(() => _selectedCategoryId = id),
//               ),
//
//               /// PRODUCT FEED
//               Expanded(
//                 child: ProductFeedWidget(
//                   filteredProducts: filteredProducts,
//                   showAddToCart: false, // ❌ Distributor = No Cart
//                   isLoading: _isLoading,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snap2bill/Distributordirectory/view/myProducts.dart';
import 'package:snap2bill/Distributordirectory/view/viewAllOrders.dart';
import 'package:snap2bill/Distributordirectory/view/view_category.dart';
import 'package:snap2bill/Distributordirectory/view/view_distributors.dart';
import 'package:snap2bill/Distributordirectory/view/view_feedback.dart';
import 'package:snap2bill/Distributordirectory/view/view_product.dart';
import 'package:snap2bill/Distributordirectory/password/changePassword.dart';

import 'package:snap2bill/screens/Login_page.dart';
import 'package:snap2bill/screens/viewWishlist.dart';

import 'package:snap2bill/data/dataModels.dart';
import 'package:snap2bill/data/category_service.dart';
import 'package:snap2bill/data/product_service.dart';
import 'package:snap2bill/theme/colors.dart';
import 'package:snap2bill/widgets/Navbar.dart';

import 'package:snap2bill/widgets/category_filter_bar.dart';
import 'package:snap2bill/widgets/product_feed.dart';
import 'package:snap2bill/widgets/custom_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<ProductData> _allProducts = [];
  List<CategoryData> _categories = [];
  String _selectedCategoryId = "All";
  bool _isLoading = true;


  // 🚀 EXTRA DETAILS: Wishlist Count state
  int _wishlistCount = 0;
  String _refreshTrigger = "";

  late Color dangerColor;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final products = await ProductService.distributorProducts();
    final categories = await CategoryService.fetchCategories();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "";
      String uid = prefs.getString("uid") ?? "";

      final response = await http.post(
        Uri.parse("$ip/get_counts"),
        body: {'uid': uid}, // 🚀 Distributor ID
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _wishlistCount = data['wishlist_count'] ?? 0;
            debugPrint("Wishlist Count received: $_wishlistCount");
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching wishlist count: $e");
    }

    if (!mounted) return;
    setState(() {
      _allProducts = products;
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _refreshCountsOnly() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "";
      String uid = prefs.getString("uid") ?? ""; // Distributor ID 🚀

      final response = await http.post(
        Uri.parse("$ip/get_counts"),
        body: {'uid': uid},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (mounted) {
          setState(() {
            // 🚀 FIX: Yahan se _cartCount hata diya hai kyunki
            // distributor file mein ye variable nahi hai.
            _wishlistCount = data['wishlist_count'] ?? 0;
          });
          debugPrint("Distributor Wishlist updated: $_wishlistCount");
        }
      }
    } catch (e) {
      debugPrint("Count refresh error: $e");
    }
  }

  Future<void> _syncDistributorData() async {
    final updatedProducts = await ProductService.distributorProducts();
    if (mounted) {
      setState(() {
        // 🚀 FIX 3: List.from() use karein taaki memory reference change ho
        // Isse ProductCard ko pata chalega ki data badla hai
        _allProducts = List.from(updatedProducts);
        _refreshTrigger = DateTime.now().millisecondsSinceEpoch.toString();
      });
      _refreshCountsOnly();
    }
  }

  List<DrawerItemModel> _getDrawerItems() {
    return [
      // 1. Distributors
      DrawerItemModel(
          icon: HugeIcons.strokeRoundedUserGroup, // or strokeRoundedDistribution
          title: "Distributors",
          onTap: () => const ViewDistributors()
      ),

// 2. My Products (Inventory)
      DrawerItemModel(
          icon: HugeIcons.strokeRoundedPackage, // or strokeRoundedBoxIso
          title: "My Products",
          onTap: () => const MyProducts()
      ),

// 3. All Products (Shopping Bag)
      DrawerItemModel(
          icon: HugeIcons.strokeRoundedShoppingBag02,
          title: "All Products",
          onTap: () => const ViewProduct()
      ),

// 4. Orders (List/Invoice)
      DrawerItemModel(
          icon: HugeIcons.strokeRoundedInvoice01, // Fits "Orders" better than list_alt
          title: "Orders",
          onTap: () => const ViewAllOrders()
      ),

// 5. Category (Grid/Layers)
      DrawerItemModel(
          icon: HugeIcons.strokeRoundedGrid, // Standard category icon style
          title: "Category",
          onTap: () => const ViewCategory()
      ),

// 6. Feedback (Chat/Review)
      DrawerItemModel(
          icon: HugeIcons.strokeRoundedMessage02, // or strokeRoundedComment01
          title: "Feedback",
          onTap: () => const ViewFeedback()
      ),

// 7. Change Password (Lock)
      DrawerItemModel(
          icon: HugeIcons.strokeRoundedSecurityPassword, // Specifically for passwords
          title: "Change Password",
          onTap: () => const ChangePassword()
      ),

// 8. Logout
      DrawerItemModel(
        icon: HugeIcons.strokeRoundedLogout04,
        title: "Logout",
        color: dangerColor,
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          final ip = prefs.getString("ip");
          await prefs.clear();
          if (ip != null) await prefs.setString("ip", ip);
          return const LoginPage();
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    dangerColor = AppColors.getDangerColor(context);
    final primaryColor = AppColors.getPrimaryColor(context);

    final List<ProductData> filteredProducts = _selectedCategoryId == "All"
        ? _allProducts
        : _allProducts.where((p) => p.categoryId == _selectedCategoryId).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.getScaffoldBg(context),
      // drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.4,
      drawer: CustomDrawer(menuItems: _getDrawerItems()),
      drawerEnableOpenDragGesture: false,


      appBar: ThemeNavbar(
        title: "Snap2Bill",
        leadingIcon: Icons.menu,
        onLeadingPressed: () => _scaffoldKey.currentState?.openDrawer(),
        actions: [
          // 🚀 Using Badge.count directly on IconButton
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewWishlist()),
              ).then((result) {
                // 🚀 FIX 4: Ab chahe "refresh" aaye ya koi bhi back event, sync chala do
                if (result == "refresh") {
                  _syncDistributorData();
                }
              });
            },
            icon: Badge.count(
              count: _wishlistCount,
              textColor: AppColors.WhiteColor,
              isLabelVisible: _wishlistCount > 0,
              backgroundColor: dangerColor,
              // Isse count bubble icon ke andar perfect set ho jayega
              textStyle:  TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              child: const Icon(Icons.favorite_border,
                size: 25,
              ),
            ),
          ),
          // const SizedBox(width: 8),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            CategoryFilterBar(
              categories: _categories,
              selectedId: _selectedCategoryId,
              onSelect: (id) => setState(() => _selectedCategoryId = id),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  if (details.delta.dx > 5) {
                    _scaffoldKey.currentState?.openDrawer();
                  }
                },
                child: ProductFeedWidget(
                  filteredProducts: filteredProducts,
                  showAddToCart: false,
                  isLoading: _isLoading,
                  onWishlistToggle: () {
                    // 🚀 Ye function Home Page par count update kar dega
                    _refreshCountsOnly();
                  },
                  refreshId: _refreshTrigger,

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}