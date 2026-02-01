import 'package:flutter/material.dart';
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

  late Color dangerColor;

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
        onTap: () => const ViewDistributors(),
      ),
      DrawerItemModel(
        icon: Icons.inventory_2_outlined,
        title: "My Products",
        onTap: () => const MyProducts(),
      ),
      DrawerItemModel(
        icon: Icons.shopping_bag_outlined,
        title: "All Products",
        onTap: () => const ViewProduct(),
      ),
      DrawerItemModel(
        icon: Icons.list_alt,
        title: "Orders",
        onTap: () => const ViewAllOrders(),
      ),
      DrawerItemModel(
        icon: Icons.category_outlined,
        title: "Category",
        onTap: () => const ViewCategory(),
      ),
      DrawerItemModel(
        icon: Icons.feedback_outlined,
        title: "Feedback",
        onTap: () => const ViewFeedback(),
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
    
    final List<ProductData> filteredProducts =
    _selectedCategoryId == "All"
        ? _allProducts
        : _allProducts
        .where((p) => p.categoryId == _selectedCategoryId)
        .toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.getScaffoldBg(context),

        /// Swipe from left edge
        drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.4,

        drawer: CustomDrawer(menuItems: _getDrawerItems()),

        appBar: ThemeNavbar(
          title:
            "Snap2Bill",
          leadingIcon: Icons.menu,
          onLeadingPressed: ()=>
          {
            _scaffoldKey.currentState?.openDrawer(),
          },
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
      ),
    );
  }
}
