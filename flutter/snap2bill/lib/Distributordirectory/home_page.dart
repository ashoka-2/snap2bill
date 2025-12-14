
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Import all required navigation classes
import 'package:snap2bill/Distributordirectory/view/myProducts.dart';
import 'package:snap2bill/Distributordirectory/view/viewOrder.dart';
import 'package:snap2bill/Distributordirectory/view/view_category.dart';
import 'package:snap2bill/Distributordirectory/view/view_distributors.dart';
import 'package:snap2bill/Distributordirectory/view/view_feedback.dart';
import 'package:snap2bill/Distributordirectory/view/view_product.dart';
import 'package:snap2bill/Distributordirectory/password/changePassword.dart';
import 'package:snap2bill/screens/Login_page.dart';

import '../../main.dart';
import '../../theme/theme.dart';
import 'package:snap2bill/data/dataModels.dart';
import 'package:snap2bill/widgets/category_filter_bar.dart';
import 'package:snap2bill/widgets/product_card.dart';

import '../data/category_service.dart';
import '../data/product_service.dart';
// NEW IMPORT
import 'package:snap2bill/widgets/custom_drawer.dart';

import '../widgets/product_feed.dart'; // Import CustomDrawer (which includes DrawerItemModel)

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

  /// ---------------- GET DRAWER ITEMS (Distributor Specific) ----------------
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
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          final savedIp = prefs.getString("ip");
          await prefs.clear();
          if (savedIp != null) { await prefs.setString("ip", savedIp); }
          return const login_page();
        },
        color: Colors.red,
      ),
    ];
  }


  /// ---------------- LOAD DATA ----------------
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

  /// ---------------- SWIPE TO OPEN DRAWER ----------------
  void _handleSwipe(DragEndDetails details) {
    const double sensitivity = 500;
    if (details.primaryVelocity != null &&
        details.primaryVelocity! > sensitivity) {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    final List<ProductData> filteredProducts = _selectedCategoryId == "All"
        ? _allProducts
        : _allProducts
        .where((p) => p.categoryId == _selectedCategoryId)
        .toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,

      /// ---------------- APP BAR ----------------
      appBar: AppBar(
        title: Text("Snap2Bill", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: textColor),
          )
        ],
      ),

      /// ---------------- DRAWER (USING REUSABLE COMPONENT) ----------------
      drawer: CustomDrawer(
        menuItems: _getDrawerItems(), // Pass distributor's specific links
      ),

      /// ---------------- BODY ----------------
      body: GestureDetector(
        onHorizontalDragEnd: _handleSwipe,
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              /// CATEGORY FILTER BAR
              CategoryFilterBar(
                categories: _categories,
                selectedId: _selectedCategoryId,
                onSelect: (id) {
                  setState(() => _selectedCategoryId = id);
                },
              ),

              /// PRODUCT FEED
              Expanded(
                child: ProductFeedWidget(
                  // Pass the calculated list
                  filteredProducts: filteredProducts,
                  // Distributor does NOT see 'Add to Cart'
                  showAddToCart: false,
                  // Pass loading state
                  isLoading: _isLoading,
                ),
              ),            ],
          ),
        ),
      ),
    );
  }
}