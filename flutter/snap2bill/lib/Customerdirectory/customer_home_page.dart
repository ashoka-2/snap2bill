import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

// Import all required navigation classes
import '../widgets/product_feed.dart';
import 'Customersends/addOrder.dart';
import 'custviews/viewOrder.dart';
import 'custviews/view_product.dart';
import 'custviews/view_feedback.dart';
import 'Customersends/send_feedback.dart';
import 'password/changePassword.dart';
import 'package:snap2bill/screens/Login_page.dart';

import '../data/category_service.dart';
import '../data/product_service.dart';
import '../main.dart';
import '../theme/theme.dart';
import '../data/dataModels.dart';
import 'package:snap2bill/widgets/category_filter_bar.dart';
import 'package:snap2bill/widgets/product_card.dart';

// NEW IMPORT
import 'package:snap2bill/widgets/custom_drawer.dart'; // Import CustomDrawer (which includes DrawerItemModel)


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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// ---------------- GET DRAWER ITEMS (Customer Specific) ----------------
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


  /// ---------------- LOAD PRODUCTS + CATEGORIES ----------------
  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final products = await ProductService.customerProducts();
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
        title: Text("Home", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const addOrder()));
            },
          ),
        ],
      ),

      /// ---------------- DRAWER (USING REUSABLE COMPONENT) ----------------
      drawer: CustomDrawer(
        menuItems: _getDrawerItems(), // Pass customer's specific links
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
                  // Customer sees 'Add to Cart'
                  showAddToCart: true,
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