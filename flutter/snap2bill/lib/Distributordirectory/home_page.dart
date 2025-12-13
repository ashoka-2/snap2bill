import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// --- ESSENTIAL IMPORTS FOR THEME CHANGING ---
import '../../main.dart';         // Update path to point to your main.dart
import '../../theme/theme.dart';  // Update path to point to your theme.dart

// --- Navigation Imports ---
import 'package:snap2bill/Distributordirectory/view/viewOrder.dart';
import 'package:snap2bill/Distributordirectory/view/view_category.dart';
import 'package:snap2bill/Distributordirectory/view/view_distributors.dart';
import 'package:snap2bill/Distributordirectory/view/myProducts.dart';
import 'package:snap2bill/Distributordirectory/view/view_feedback.dart';
import 'package:snap2bill/Distributordirectory/view/view_product.dart';
import 'package:snap2bill/Distributordirectory/password/changePassword.dart';
import 'package:snap2bill/screens/login_page.dart';

class Home_page extends StatefulWidget {
  const Home_page({Key? key}) : super(key: key);

  @override
  State<Home_page> createState() => _Home_pageState();
}

class _Home_pageState extends State<Home_page> {
  // --- VARIABLES ---
  List<Product> _products = [];
  bool _isLoading = true;
  String _distributorName = "Distributor";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- API LOGIC ---
  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _distributorName = prefs.getString("name") ?? "Distributor";
      });
    }

    String? ip = prefs.getString("ip");
    String? uid = prefs.getString("uid");

    if (ip == null || uid == null) return;

    try {
      var response = await http.post(
        Uri.parse("$ip/view_other_products"),
        body: {'uid': uid},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List<Product> temp = [];

        for (var item in jsonData['data']) {
          String rawImg = item['image'].toString();
          String finalUrl = _joinUrl(ip, rawImg);

          temp.add(Product(
            id: item['id'].toString(),
            name: item['name'].toString(),
            price: item['price'].toString(),
            description: item['description'].toString(),
            image: finalUrl,
            distributorName: item['distributor_name'].toString(),
            distributorId: item['distributor_id'].toString(),
          ));
        }

        if (mounted) {
          setState(() {
            _products = temp;
            _isLoading = false;
          });
        }
      } else {
        debugPrint("Server Error: ${response.statusCode}");
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading products: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _joinUrl(String base, String path) {
    if (path == "null" || path.isEmpty) return "";
    if (!base.startsWith("http")) base = "http://$base";
    if (base.endsWith("/")) base = base.substring(0, base.length - 1);
    if (!path.startsWith("/")) path = "/$path";
    return base + path;
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white38 : Colors.grey[500];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Snap2bill",
          style: GoogleFonts.lobster(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: textColor),
          )
        ],
      ),

      drawer: _buildDrawer(context, isDark, textColor),

      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _products.isEmpty
            ? Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 60, color: hintColor),
                const SizedBox(height: 10),
                Text("No products found from others.", style: TextStyle(color: hintColor)),
              ],
            ),
          ),
        )
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            itemCount: _products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(_products[index], isDark);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product item, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Selected: ${item.name} - ₹${item.price}")),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: item.image.isNotEmpty
                    ? Image.network(
                  item.image,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                )
                    : Container(height: 120, color: Colors.grey[200]),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${item.price}",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.grey.shade300,
                          child: const Icon(Icons.store, size: 10, color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.distributorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DRAWER WITH THEME TOGGLE ---
  Widget _buildDrawer(BuildContext context, bool isDark, Color textColor) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      // backgroundColor: Colors.transparent,
      child: ListView(
        // padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            // padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
              // color: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.storefront, color:isDark?Colors.white:Colors.black.withValues(alpha: 0.7), size: 40),
                      const SizedBox(width: 10),
                       Text("Menu", style: TextStyle(color:isDark?Colors.white:Colors.black.withValues(alpha: 0.7), fontSize: 24)),
                    ],),

                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.grey.withValues(alpha: 0.5),
                            border: Border.all(width: 1,color: Colors.grey)

                          ),
                          child: IconButton(
                            icon:  Icon(
                              ThemeService.instance.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                              color: Colors.white,

                            ),

                            onPressed: () {
                              // Navigator.pop(context);
                              MyApp.changeTheme(context);
                            },
                          ),
                        ),
                      ],
                    ),

                  ],
                ),

              ],
            ),
          ),
        // SizedBox(height: 100,),
        SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(bottom: 100),
            padding: EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Column(children: [
                _drawerItem(context,isDark, Icons.people_alt_outlined, "Distributors", () => view_distributors(), textColor),
                SizedBox(height: 3,),
                _drawerItem(context,isDark ,  Icons.inventory_2_outlined, "My Products", () => myProducts(), textColor),
                SizedBox(height: 3,),
                _drawerItem(context, isDark , Icons.shopping_bag_outlined, "All Products", () => view_product(), textColor),
                SizedBox(height: 3,),
                _drawerItem(context, isDark , Icons.list_alt, "Orders", () => viewOrder(), textColor),
                SizedBox(height: 3,),
                _drawerItem(context,isDark ,  Icons.category_outlined, "Category", () => view_category(), textColor),
                SizedBox(height: 3,),
                _drawerItem(context,isDark ,  Icons.feedback_outlined, "Feedback", () => view_feedback(), textColor),
                SizedBox(height: 3,),
                _drawerItem(context,isDark,  Icons.lock_outline, "Change Password", () => changePassword(), textColor),
                SizedBox(height: 3,),
                _drawerItem(context,isDark ,  Icons.logout, "Logout", () async {
                  Navigator.pop(context);

                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? savedIp = prefs.getString("ip");

                  if (savedIp != null) {
                    try {
                      await http.get(Uri.parse("$savedIp/logout_view"));
                    } catch (e) {
                      debugPrint("Server logout failed (ignoring): $e");
                    }
                  }

                  await prefs.clear();

                  if (savedIp != null) {
                    await prefs.setString("ip", savedIp);
                  }

                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const login_page()),
                        (route) => false,
                  );
                }, Colors.red),

              ],),
            ),
          ),
        )
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, isDark ,IconData icon, String title, Function() onTap, Color color) {
    return InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => onTap()));
        },
      child: Container(
        padding: EdgeInsets.only(top: 20,bottom: 20,left: 20,right: 20),
        // padding: EdgeInsets.all(20),
        decoration: BoxDecoration(

        color: isDark ? Colors.grey.shade800:Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5)
        ),

          child: Row(
              children: [
                Icon(icon,color:color),
                SizedBox(width: 10,),
                Text(title,style: TextStyle(color: color),)

              ],
          ),
        ),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String price;
  final String description;
  final String image;
  final String distributorName;
  final String distributorId;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.distributorName,
    required this.distributorId,
  });
}