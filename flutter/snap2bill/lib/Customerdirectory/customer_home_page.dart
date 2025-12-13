
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

// --- NAVIGATION IMPORTS ---
import 'package:snap2bill/Distributordirectory/view/ViewDistributorProfile.dart';
import 'package:snap2bill/Customerdirectory/Customersends/send_feedback.dart';
import 'package:snap2bill/Customerdirectory/custviews/viewOrder.dart';
import 'package:snap2bill/Customerdirectory/custviews/view_feedback.dart';
import 'package:snap2bill/Customerdirectory/custviews/view_product.dart';
import 'package:snap2bill/Customerdirectory/password/changePassword.dart';
import 'package:snap2bill/screens/Login_page.dart';
import 'package:snap2bill/Customerdirectory/Customersends/addOrder.dart';

import '../main.dart';
import '../theme/theme.dart';



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
  String _customerName = "Customer";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _loadCustomerDetails();
  }

  // Helper to load customer name for the drawer header
  Future<void> _loadCustomerDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _customerName = prefs.getString("name") ?? "Customer";
      });
    }
  }

  // --- API LOGIC (Combined Fetch) ---
  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    await Future.wait([_fetchCategories(), _fetchProducts()]);

    if (mounted) {
      _filterProducts(selectedCategoryId);
      setState(() => isLoading = false);
    }
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

                  distributorId: (item["distributor_id"] ?? "").toString(),

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

  // --- Filtering Logic ---
  void _filterProducts(String catId) {
    if (!mounted) return;
    setState(() {
      selectedCategoryId = catId;
    });
  }

  // --- SWIPE LOGIC ---
  void _handleSwipe(DragEndDetails details) {
    const double sensitivity = 500;

    if (details.primaryVelocity! > sensitivity) {
      _scaffoldKey.currentState?.openDrawer();
    } else if (details.primaryVelocity! < -sensitivity) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Left Swipe Detected! Action to be specified.")),
      // );
    }
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    List<ProductData> displayedProducts = selectedCategoryId == "All"
        ? allProducts
        : allProducts
        .where((p) => p.categoryId == selectedCategoryId)
        .toList();

    return Scaffold(
      key: _scaffoldKey,
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
                MaterialPageRoute(builder: (context) => const addOrder()),
              );
            },
          ),
        ],
      ),

      // --- DRAWER (CUSTOM STYLED) ---
      drawer: _buildDrawer(context, isDark, textColor),

      // --- BODY (WRAPPED IN GESTURE DETECTOR) ---
      body: GestureDetector(
        onHorizontalDragEnd: _handleSwipe,
        child: Column(
          children: [
            // A. CATEGORIES FILTER BAR
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
                  final isSelected = selectedCategoryId == cat.id;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat.name),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            selectedCategoryId = cat.id;
                          });
                        }
                      },
                      selectedColor: theme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : textColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide.none,
                    ),
                  );
                },
              ),
            ),

            // B. PRODUCTS LIST FEED
            Expanded(
              child: isLoading
                  ? _buildProductShimmer(theme)
                  : displayedProducts.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: subTextColor),
                    const SizedBox(height: 8),
                    Text("No products found", style: TextStyle(color: subTextColor)),
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
      ),
    );
  }

  // --- DRAWER WITH THEME TOGGLE (EXACTLY AS PROVIDED BY USER) ---
  Widget _buildDrawer(BuildContext context, bool isDark, Color textColor) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      // backgroundColor: Colors.transparent,
      child: ListView(
        // padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
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
                  _drawerItem(context,isDark, Icons.shopping_bag_outlined, "View Products", () => view_product(), textColor),
                  SizedBox(height: 3,),
                  _drawerItem(context,isDark ,  Icons.feedback_outlined, "Send Feedback", () => send_feedback(), textColor),
                  SizedBox(height: 3,),
                  _drawerItem(context, isDark , Icons.feedback_outlined, "View Feedback", () => view_feedback(), textColor),
                  SizedBox(height: 3,),
                  _drawerItem(context, isDark , Icons.list_alt, "Orders", () => viewOrder(), textColor),
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

  Widget _drawerItem(BuildContext context, isDark ,IconData icon, String title,Function() onTap, Color color) {
    return InkWell(
      onTap: ()  {
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

  // --- PRODUCT CARD WIDGET ---
  Widget _buildProductCard(
      ProductData item,
      ThemeData theme,
      Color textColor,
      Color subTextColor,
      ) {
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    // Function to handle navigation to Distributor Profile
    void viewDistributorProfile() {
      Navigator.push(context, MaterialPageRoute(builder: (context) =>
          ViewDistributorProfile(
            distributorId: item.distributorId,
            distributorName: item.distributorName,
          )
      ));
    }

    // Function to handle Popup Menu options
    void showOptionsMenu(BuildContext context) {
      final RenderBox button = context.findRenderObject() as RenderBox;
      final Offset position = button.localToGlobal(Offset.zero);

      showMenu<String>(
        context: context,
        position: RelativeRect.fromRect(
          position & button.size,
          Offset.zero & MediaQuery.of(context).size,
        ),
        items: [
          PopupMenuItem<String>(
            value: 'view_profile',
            child: Row(
              children: [
                Icon(Icons.person_outline, color: textColor),
                const SizedBox(width: 8),
                Text('View Profile', style: TextStyle(color: textColor)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'cart',
            child: Row(
              children: [
                Icon(Icons.shopping_cart, size: 18, color: textColor),
                const SizedBox(width: 8),
                Text('Add to Cart', style: TextStyle(color: textColor)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share, size: 18, color: textColor),
                const SizedBox(width: 8),
                Text('Share Product', style: TextStyle(color: textColor)),
              ],
            ),
          ),
        ],
        elevation: 8.0,
        color: theme.cardColor,
      ).then((value) async {
        if (value == 'view_profile') {
          viewDistributorProfile();
        } else if (value == 'cart') {
          // Store IDs and navigate to addOrder screen
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("pid", item.id.toString());
          prefs.setString("uid", item.distributorId.toString());

          Navigator.push(context, MaterialPageRoute(builder: (context) => const addOrder()));
        }
      });
    }

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER (Clickable Avatar/Name for Profile, Three Dots for Menu)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Avatar and Name (Clickable part)
                Expanded(
                  child: GestureDetector(
                    onTap: viewDistributorProfile, // <<< VIEW PROFILE ON TAP >>>
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
                        Column(
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
                      ],
                    ),
                  ),
                ),

                // --- 3-DOTS MENU ---
                Builder(
                  builder: (menuContext) => IconButton(
                    icon: Icon(Icons.more_vert, color: textColor),
                    onPressed: () => showOptionsMenu(menuContext),
                  ),
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
                    SharedPreferences prefs = await SharedPreferences.getInstance();

                    // Store the necessary IDs for the addOrder screen to retrieve:
                    // Check for Null before saving, though model ensures non-null string, this is a safe guard.
                    final String distributorId = item.distributorId;

                    if (distributorId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Error: Distributor ID is missing. Cannot add to cart."))
                      );
                      return;
                    }

                    prefs.setString("pid", item.id.toString());
                    prefs.setString("uid", distributorId);

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const addOrder()),
                    );
                  },

                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: const Text("Add to Cart"),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
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
                    color: primaryColor,

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
                        color: primaryColor,

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

                  colorClickableText: primaryColor,

                  trimCollapsedText: 'read more',

                  trimExpandedText: 'show less',

                  style: TextStyle(color: textColor),

                  moreStyle: TextStyle(
                    fontSize: 14,

                    fontWeight: FontWeight.bold,

                    color: primaryColor,
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
  final String distributorId;
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
    required this.distributorId,
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