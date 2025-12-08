import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
// --- IMPORTS ---
import 'package:snap2bill/Customerdirectory/Customersends/send_feedback.dart';
import 'package:snap2bill/Customerdirectory/custviews/viewOrder.dart';
import 'package:snap2bill/Customerdirectory/custviews/view_feedback.dart';
import 'package:snap2bill/Customerdirectory/custviews/view_product.dart';
import 'package:snap2bill/Customerdirectory/password/changePassword.dart';

import 'Customersends/addOrder.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({Key? key}) : super(key: key);

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  // --- STATE VARIABLES ---
  List<ProductData> allProducts = [];
  List<CategoryData> allCategories = [];
  bool isLoading = true;
  String selectedCategoryId = "All";

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // --- API LOGIC ---
  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    // 3 Second Delay to visualize Shimmer Effect
    await Future.delayed(const Duration(seconds: 1));

    await Future.wait([_fetchCategories(), _fetchProducts()]);
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _fetchCategories() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "";
      List<CategoryData> tempCats = [CategoryData(id: "All", name: "All")];

      if (ip.isNotEmpty) {
        var url = Uri.parse("$ip/view_category");
        var response = await http.post(url, body: {});

        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);
          if (jsonData["data"] != null) {
            for (var item in jsonData["data"]) {
              tempCats.add(
                CategoryData(
                  id: item["id"].toString(),
                  name: item["category_name"].toString(),
                ),
              );
            }
          }
        }
      }
      if (mounted) setState(() => allCategories = tempCats);
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
  }

  Future<void> _fetchProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String lid = prefs.getString("lid") ?? "";
      String ip = prefs.getString("ip") ?? "";

      if (ip.isNotEmpty) {
        var url = Uri.parse("$ip/customer_view_products");
        var response = await http.post(url, body: {"id": lid});

        List<ProductData> tempProducts = [];
        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);
          if (jsonData["data"] != null) {
            for (var item in jsonData["data"]) {
              tempProducts.add(
                ProductData(
                  id: item["id"].toString(),
                  productName: item["product_name"] ?? "Unknown Product",
                  price: item["price"].toString(),
                  image: _joinUrl(ip, item["image"].toString()),
                  description: item["description"].toString(),
                  categoryName: (item["CATEGORY_NAME"] ?? "General").toString(),
                  categoryId: (item["CATEGORY"] ?? "").toString(),
                  distributorName: (item["distributor_name"] ?? "Seller")
                      .toString(),
                  distributorImage: _joinUrl(
                    ip,
                    (item["distributor_image"] ?? "").toString(),
                  ),
                  distributorPhone: (item["distributor_phone"] ?? "")
                      .toString(),
                ),
              );
            }
          }
        }
        if (mounted) setState(() => allProducts = tempProducts);
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }
  }

  String _joinUrl(String base, String path) {
    if (path.isEmpty || path == "null") return "";
    if (base.endsWith("/") && path.startsWith("/"))
      return base + path.substring(1);
    if (!base.endsWith("/") && !path.startsWith("/")) return "$base/$path";
    return base + path;
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    // 1. ACCESS GLOBAL THEME (Provided by main.dart)
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 2. DEFINE LOCAL TEXT COLORS
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    // Filter Logic
    List<ProductData> displayedProducts = selectedCategoryId == "All"
        ? allProducts
        : allProducts
              .where((p) => p.categoryName == selectedCategoryId)
              .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // --- APP BAR ---
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => addOrder()),
              );
            },
          ),
        ],
      ),

      // --- DRAWER ---
      drawer: Drawer(
        backgroundColor: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: theme.primaryColor),
              accountName: const Text("Customer Menu"),
              accountEmail: const Text("Welcome Back"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: theme.cardColor,
                child: Icon(Icons.person, size: 40, color: theme.primaryColor),
              ),
            ),
            _buildDrawerItem(
              Icons.rate_review,
              "View Products",
              const view_product(),
              textColor,
            ),
            _buildDrawerItem(
              Icons.feedback,
              "Send Feedback",
              const send_feedback(),
              textColor,
            ),
            _buildDrawerItem(
              Icons.forum,
              "View Feedback",
              const view_feedback(),
              textColor,
            ),
            const Divider(),
            _buildDrawerItem(
              Icons.lock,
              "Change Password",
              const changePassword(),
              textColor,
            ),
            _buildDrawerItem(
              Icons.shopping_bag,
              "View Orders",
              const viewOrder(),
              textColor,
            ),
          ],
        ),
      ),

      // --- BODY ---
      body: Column(
        children: [
          // A. CATEGORIES
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: isLoading
                ? _buildCategoryShimmer(theme)
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: allCategories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final cat = allCategories[index];
                      final isSelected = selectedCategoryId == cat.name;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat.name),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedCategoryId = cat.name;
                            });
                          },
                          selectedColor: theme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : textColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          backgroundColor: isDark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide.none,
                        ),
                      );
                    },
                  ),
          ),

          // B. PRODUCTS LIST
          Expanded(
            child: isLoading
                ? _buildProductShimmer(theme) // SHIMMER
                : displayedProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: subTextColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "No products found",
                          style: TextStyle(color: subTextColor),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: displayedProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(
                        displayedProducts[index],
                        theme,
                        textColor,
                        subTextColor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- DRAWER HELPER ---
  Widget _buildDrawerItem(
    IconData icon,
    String title,
    Widget page,
    Color color,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  // --- PRODUCT CARD WIDGET ---
  Widget _buildProductCard(
    ProductData item,
    ThemeData theme,
    Color textColor,
    Color subTextColor,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: item.distributorImage.isNotEmpty
                      ? NetworkImage(item.distributorImage)
                      : null,
                  backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                  child: item.distributorImage.isEmpty
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.distributorName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (item.distributorPhone.isNotEmpty)
                        Text(
                          item.distributorPhone,
                          style: TextStyle(color: subTextColor, fontSize: 12),
                        ),
                    ],
                  ),
                ),

                // --- 3-DOTS MENU ---
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: textColor),
                  color: theme.cardColor,
                  onSelected: (value) {
                    if (value == 'cart') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => addOrder()),
                      );
                    } else if (value == 'share') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Sharing ${item.productName}..."),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString("id", item.id.toString());
                        var data = await http.post(
                          Uri.parse(
                            prefs.getString("ip").toString() + "/addorder",
                          ),
                        );
                      },
                      value: 'cart',
                      child: Row(
                        children: [
                          Icon(Icons.shopping_cart, size: 18, color: textColor),
                          SizedBox(width: 8),
                          Text(
                            'Add to Cart',
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'wishlist',
                      child: Row(
                        children: [
                          Icon(Icons.favorite, size: 18, color: textColor),
                          SizedBox(width: 8),
                          Text(
                            'Add to Wishlist',
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, size: 18, color: textColor),
                          SizedBox(width: 8),
                          Text(
                            'Share Product',
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. IMAGE
          Container(
            height: 300,
            width: double.infinity,
            color: isDark ? Colors.black26 : Colors.grey[200],
            child: Image.network(
              item.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.broken_image, size: 50, color: subTextColor),
            ),
          ),

          // 3. ACTION BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.favorite_border, color: textColor),
                const SizedBox(width: 16),
                Icon(Icons.share_outlined, color: textColor),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString("id", item.id.toString());

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => addOrder()),
                    );
                  },

                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),

                  label: const Text("Add to Cart"),

                  style: FilledButton.styleFrom(
                    backgroundColor: theme.primaryColor,

                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),

          // 4. DETAILS
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  item.categoryName.toUpperCase(),

                  style: TextStyle(
                    color: theme.primaryColor,

                    fontWeight: FontWeight.bold,

                    fontSize: 12,

                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Expanded(
                      child: Text(
                        item.productName,

                        style: TextStyle(
                          fontWeight: FontWeight.bold,

                          fontSize: 16,

                          color: textColor,
                        ),
                      ),
                    ),

                    Text(
                      "₹${item.price}",
                      style: TextStyle(
                        color: theme.primaryColor,

                        fontWeight: FontWeight.w900,

                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                ReadMoreText(
                  item.description,

                  trimLines: 2,

                  colorClickableText: theme.primaryColor,

                  trimCollapsedText: 'read more',

                  trimExpandedText: 'show less',

                  style: TextStyle(color: textColor),

                  moreStyle: TextStyle(
                    fontSize: 14,

                    fontWeight: FontWeight.bold,

                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SHIMMER LOADING WIDGETS ---

  Widget _buildCategoryShimmer(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (_, __) => Container(
          width: 80,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildProductShimmer(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return ListView.builder(
      itemCount: 3,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 16),
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 10,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 5),
                          Container(width: 60, height: 8, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(height: 250, color: Colors.white),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(width: 150, height: 12, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- DATA MODELS ---
class ProductData {
  final String id;
  final String productName;
  final String price;
  final String image;
  final String description;
  final String categoryName;
  final String categoryId;
  final String distributorName;
  final String distributorImage;
  final String distributorPhone;

  ProductData({
    required this.id,
    required this.productName,
    required this.price,
    required this.image,
    required this.description,
    required this.categoryName,
    required this.categoryId,
    required this.distributorName,
    required this.distributorImage,
    required this.distributorPhone,
  });
}

class CategoryData {
  final String id;
  final String name;

  CategoryData({required this.id, required this.name});
}
