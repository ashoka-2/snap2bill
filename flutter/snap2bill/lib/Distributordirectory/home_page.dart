import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snap2bill/Distributordirectory/view/myProducts.dart';
import 'package:snap2bill/Distributordirectory/view/viewOrder.dart';
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

import 'package:snap2bill/widgets/category_filter_bar.dart';
import 'package:snap2bill/widgets/product_feed.dart';
import 'package:snap2bill/widgets/custom_drawer.dart';

class Home_page extends StatefulWidget {
  const Home_page({Key? key}) : super(key: key);

  @override
  State<Home_page> createState() => _Home_pageState();
}

class _Home_pageState extends State<Home_page> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<ProductData> _allProducts = [];
  List<CategoryData> _categories = [];
  String _selectedCategoryId = "All";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// =============================================================
  /// LOAD PRODUCTS + CATEGORIES
  /// =============================================================
  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final products = await ProductService.distributorProducts();
    final categories = await CategoryService.fetchCategories();

    if (!mounted) return;

    setState(() {
      _allProducts = products;
      _categories = categories;
      _isLoading = false;
    });
  }

  /// =============================================================
  /// DRAWER ITEMS
  /// =============================================================
  List<DrawerItemModel> _getDrawerItems() {
    return [
      DrawerItemModel(
        icon: Icons.people_alt_outlined,
        title: "Distributors",
        onTap: () => const view_distributors(),
      ),
      DrawerItemModel(
        icon: Icons.inventory_2_outlined,
        title: "My Products",
        onTap: () => const myProducts(),
      ),
      DrawerItemModel(
        icon: Icons.shopping_bag_outlined,
        title: "All Products",
        onTap: () => const view_product(),
      ),
      DrawerItemModel(
        icon: Icons.list_alt,
        title: "Orders",
        onTap: () => const viewOrder(),
      ),
      DrawerItemModel(
        icon: Icons.category_outlined,
        title: "Category",
        onTap: () => const view_category(),
      ),
      DrawerItemModel(
        icon: Icons.feedback_outlined,
        title: "Feedback",
        onTap: () => const view_feedback(),
      ),
      DrawerItemModel(
        icon: Icons.lock_outline,
        title: "Change Password",
        onTap: () => const changePassword(),
      ),
      DrawerItemModel(
        icon: Icons.logout,
        title: "Logout",
        color: Colors.red,
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          final ip = prefs.getString("ip");
          await prefs.clear();
          if (ip != null) {
            await prefs.setString("ip", ip);
          }
          return const login_page();
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
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

      /// Swipe from left edge
      drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.2,

      drawer: CustomDrawer(menuItems: _getDrawerItems()),

      appBar: AppBar(
        title: const Text(
          "Snap2Bill",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewWishlist()),
              ).then((_) {
                /// 🔁 Sync wishlist state on return
                _loadData();
              });
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            /// CATEGORY FILTER
            CategoryFilterBar(
              categories: _categories,
              selectedId: _selectedCategoryId,
              onSelect: (id) =>
                  setState(() => _selectedCategoryId = id),
            ),

            /// PRODUCT FEED
            Expanded(
              child: ProductFeedWidget(
                filteredProducts: filteredProducts,
                showAddToCart: false, // ❌ Distributor = No Cart
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
