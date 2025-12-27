import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Customerdirectory/custviews/viewCart.dart';
import 'package:snap2bill/Customerdirectory/custviews/view_feedback.dart';
import 'package:snap2bill/Customerdirectory/custviews/view_product.dart';
import 'package:snap2bill/Customerdirectory/Customersends/send_feedback.dart';
import 'package:snap2bill/Customerdirectory/custviews/viewOrder.dart';
import 'package:snap2bill/Customerdirectory/password/changePassword.dart';
import 'package:snap2bill/screens/Login_page.dart';
import 'package:snap2bill/data/dataModels.dart';
import 'package:snap2bill/data/category_service.dart';
import 'package:snap2bill/data/product_service.dart';
import 'package:snap2bill/widgets/category_filter_bar.dart';
import 'package:snap2bill/widgets/product_feed.dart';
import 'package:snap2bill/widgets/custom_drawer.dart';
import 'package:snap2bill/screens/viewWishlist.dart';

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

  List<DrawerItemModel> _getDrawerItems() {
    return [
      DrawerItemModel(icon: Icons.shopping_bag_outlined, title: "View Products", onTap: () => const view_product()),
      DrawerItemModel(icon: Icons.feedback_outlined, title: "Send Feedback", onTap: () => const send_feedback()),
      DrawerItemModel(icon: Icons.feedback_outlined, title: "View Feedback", onTap: () => const view_feedback()),
      DrawerItemModel(icon: Icons.list_alt, title: "Orders", onTap: () => const viewOrder()),
      DrawerItemModel(icon: Icons.lock_outline, title: "Change Password", onTap: () => const changePassword()),
      DrawerItemModel(icon: Icons.logout, title: "Logout", color: Colors.red, onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final ip = prefs.getString("ip");
        await prefs.clear();
        if (ip != null) await prefs.setString("ip", ip);
        return const login_page();
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredProducts = _selectedCategoryId == "All"
        ? _allProducts
        : _allProducts.where((p) => p.categoryId == _selectedCategoryId).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      // Enables Swipe to open from left edge
      drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.2,
      drawer: CustomDrawer(menuItems: _getDrawerItems()),
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewWishlist()))
                  .then((_) => _loadData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const viewCart())),
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
              onSelect: (id) => setState(() => _selectedCategoryId = id),
            ),
            Expanded(
              child: ProductFeedWidget(
                filteredProducts: filteredProducts,
                showAddToCart: true,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}