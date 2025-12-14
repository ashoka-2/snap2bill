// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// //
// // // --- ESSENTIAL IMPORTS FOR THEME CHANGING ---
// // import '../../main.dart';         // Update path to point to your main.dart
// // import '../../theme/theme.dart';  // Update path to point to your theme.dart
// //
// // // --- Navigation Imports ---
// // import 'package:snap2bill/Distributordirectory/view/viewOrder.dart';
// // import 'package:snap2bill/Distributordirectory/view/view_category.dart';
// // import 'package:snap2bill/Distributordirectory/view/view_distributors.dart';
// // import 'package:snap2bill/Distributordirectory/view/myProducts.dart';
// // import 'package:snap2bill/Distributordirectory/view/view_feedback.dart';
// // import 'package:snap2bill/Distributordirectory/view/view_product.dart';
// // import 'package:snap2bill/Distributordirectory/password/changePassword.dart';
// // import 'package:snap2bill/screens/login_page.dart';
// //
// // class Home_page extends StatefulWidget {
// //   const Home_page({Key? key}) : super(key: key);
// //
// //   @override
// //   State<Home_page> createState() => _Home_pageState();
// // }
// //
// // class _Home_pageState extends State<Home_page> {
// //   // --- VARIABLES ---
// //   List<Product> _products = [];
// //   bool _isLoading = true;
// //   String _distributorName = "Distributor";
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadData();
// //   }
// //
// //   // --- API LOGIC ---
// //   Future<void> _loadData() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     if (mounted) {
// //       setState(() {
// //         _distributorName = prefs.getString("name") ?? "Distributor";
// //       });
// //     }
// //
// //     String? ip = prefs.getString("ip");
// //     String? uid = prefs.getString("uid");
// //
// //     if (ip == null || uid == null) return;
// //
// //     try {
// //       var response = await http.post(
// //         Uri.parse("$ip/view_other_products"),
// //         body: {'uid': uid},
// //       );
// //
// //       if (response.statusCode == 200) {
// //         var jsonData = json.decode(response.body);
// //         List<Product> temp = [];
// //
// //         for (var item in jsonData['data']) {
// //           String rawImg = item['image'].toString();
// //           String finalUrl = _joinUrl(ip, rawImg);
// //
// //           temp.add(Product(
// //             id: item['id'].toString(),
// //             name: item['name'].toString(),
// //             price: item['price'].toString(),
// //             description: item['description'].toString(),
// //             image: finalUrl,
// //             distributorName: item['distributor_name'].toString(),
// //             distributorId: item['distributor_id'].toString(),
// //           ));
// //         }
// //
// //         if (mounted) {
// //           setState(() {
// //             _products = temp;
// //             _isLoading = false;
// //           });
// //         }
// //       } else {
// //         debugPrint("Server Error: ${response.statusCode}");
// //         if (mounted) setState(() => _isLoading = false);
// //       }
// //     } catch (e) {
// //       debugPrint("Error loading products: $e");
// //       if (mounted) setState(() => _isLoading = false);
// //     }
// //   }
// //
// //   String _joinUrl(String base, String path) {
// //     if (path == "null" || path.isEmpty) return "";
// //     if (!base.startsWith("http")) base = "http://$base";
// //     if (base.endsWith("/")) base = base.substring(0, base.length - 1);
// //     if (!path.startsWith("/")) path = "/$path";
// //     return base + path;
// //   }
// //
// //   // --- UI BUILD ---
// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     final isDark = theme.brightness == Brightness.dark;
// //     final bgColor = theme.scaffoldBackgroundColor;
// //     final textColor = isDark ? Colors.white : Colors.black87;
// //     final hintColor = isDark ? Colors.white38 : Colors.grey[500];
// //
// //     return Scaffold(
// //       backgroundColor: bgColor,
// //       appBar: AppBar(
// //         title: Text(
// //           "Snap2bill",
// //           style: GoogleFonts.lobster(color: textColor, fontWeight: FontWeight.bold),
// //         ),
// //         centerTitle: true,
// //         backgroundColor: Colors.transparent,
// //         elevation: 0,
// //         iconTheme: IconThemeData(color: textColor),
// //         actions: [
// //           IconButton(
// //             onPressed: () {},
// //             icon: Icon(Icons.notifications_none, color: textColor),
// //           )
// //         ],
// //       ),
// //
// //       drawer: _buildDrawer(context, isDark, textColor),
// //
// //       body: RefreshIndicator(
// //         onRefresh: _loadData,
// //         child: _isLoading
// //             ? const Center(child: CircularProgressIndicator())
// //             : _products.isEmpty
// //             ? Center(
// //           child: SingleChildScrollView(
// //             physics: const AlwaysScrollableScrollPhysics(),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(Icons.inventory_2_outlined, size: 60, color: hintColor),
// //                 const SizedBox(height: 10),
// //                 Text("No products found from others.", style: TextStyle(color: hintColor)),
// //               ],
// //             ),
// //           ),
// //         )
// //             : Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //           child: MasonryGridView.count(
// //             crossAxisCount: 2,
// //             mainAxisSpacing: 16,
// //             crossAxisSpacing: 16,
// //             itemCount: _products.length,
// //             itemBuilder: (context, index) {
// //               return _buildProductCard(_products[index], isDark);
// //             },
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildProductCard(Product item, bool isDark) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: isDark ? const Color(0xFF1E1E1E) : Colors.white70,
// //         borderRadius: BorderRadius.circular(10),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withValues(alpha:isDark ? 0.4 : 0.05),
// //             blurRadius: 10,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Material(
// //         color: Colors.transparent,
// //         child: InkWell(
// //           borderRadius: BorderRadius.circular(16),
// //           onTap: () {
// //             ScaffoldMessenger.of(context).showSnackBar(
// //               SnackBar(content: Text("Selected: ${item.name} - ₹${item.price}")),
// //             );
// //           },
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               ClipRRect(
// //                 borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
// //                 child: item.image.isNotEmpty
// //                     ? Image.network(
// //                   item.image,
// //                   fit: BoxFit.cover,
// //                   errorBuilder: (c, o, s) => Container(
// //                     height: 120,
// //                     color: Colors.grey[200],
// //                     child: const Icon(Icons.broken_image, color: Colors.grey),
// //                   ),
// //                 )
// //                     : Container(height: 120, color: Colors.grey[200]),
// //               ),
// //               Padding(
// //                 padding: const EdgeInsets.all(12.0),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       item.name,
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.bold,
// //                         fontSize: 14,
// //                         color: isDark ? Colors.white : Colors.black87,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Text(
// //                       "₹${item.price}",
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.w900,
// //                         fontSize: 16,
// //                         color: Colors.blue.shade700,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 8),
// //                     Row(
// //                       children: [
// //                         CircleAvatar(
// //                           radius: 8,
// //                           backgroundColor: Colors.grey.shade300,
// //                           child: const Icon(Icons.store, size: 10, color: Colors.white),
// //                         ),
// //                         const SizedBox(width: 6),
// //                         Expanded(
// //                           child: Text(
// //                             item.distributorName,
// //                             maxLines: 1,
// //                             overflow: TextOverflow.ellipsis,
// //                             style: const TextStyle(fontSize: 11, color: Colors.grey),
// //                           ),
// //                         ),
// //                       ],
// //                     )
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // --- DRAWER WITH THEME TOGGLE ---
// //   Widget _buildDrawer(BuildContext context, bool isDark, Color textColor) {
// //     return Drawer(
// //       backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //       // backgroundColor: Colors.transparent,
// //       child: ListView(
// //         // padding: EdgeInsets.zero,
// //         children: [
// //           DrawerHeader(
// //             decoration: BoxDecoration(
// //                 color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
// //               // color: Colors.transparent,
// //             ),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisAlignment: MainAxisAlignment.end,
// //               children: [
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Row(children: [
// //                       Icon(Icons.storefront, color:isDark?Colors.white:Colors.black.withValues(alpha: 0.7), size: 40),
// //                       const SizedBox(width: 10),
// //                        Text("Menu", style: TextStyle(color:isDark?Colors.white:Colors.black.withValues(alpha: 0.7), fontSize: 24)),
// //                     ],),
// //
// //                     Column(
// //                       children: [
// //                         Container(
// //                           decoration: BoxDecoration(
// //                             borderRadius: BorderRadius.circular(50),
// //                             color: Colors.grey.withValues(alpha: 0.5),
// //                             border: Border.all(width: 1,color: Colors.grey)
// //
// //                           ),
// //                           child: IconButton(
// //                             icon:  Icon(
// //                               ThemeService.instance.isDarkMode ? Icons.light_mode : Icons.dark_mode,
// //                               color: Colors.white,
// //
// //                             ),
// //
// //                             onPressed: () {
// //                               // Navigator.pop(context);
// //                               MyApp.changeTheme(context);
// //                             },
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //
// //                   ],
// //                 ),
// //
// //               ],
// //             ),
// //           ),
// //         // SizedBox(height: 100,),
// //         SingleChildScrollView(
// //           child: Container(
// //             margin: EdgeInsets.only(bottom: 100),
// //             padding: EdgeInsets.all(20),
// //             child: ClipRRect(
// //               borderRadius: BorderRadius.circular(30),
// //               child: Column(children: [
// //                 _drawerItem(context,isDark, Icons.people_alt_outlined, "Distributors", () => view_distributors(), textColor),
// //                 SizedBox(height: 3,),
// //                 _drawerItem(context,isDark ,  Icons.inventory_2_outlined, "My Products", () => myProducts(), textColor),
// //                 SizedBox(height: 3,),
// //                 _drawerItem(context, isDark , Icons.shopping_bag_outlined, "All Products", () => view_product(), textColor),
// //                 SizedBox(height: 3,),
// //                 _drawerItem(context, isDark , Icons.list_alt, "Orders", () => viewOrder(), textColor),
// //                 SizedBox(height: 3,),
// //                 _drawerItem(context,isDark ,  Icons.category_outlined, "Category", () => view_category(), textColor),
// //                 SizedBox(height: 3,),
// //                 _drawerItem(context,isDark ,  Icons.feedback_outlined, "Feedback", () => view_feedback(), textColor),
// //                 SizedBox(height: 3,),
// //                 _drawerItem(context,isDark,  Icons.lock_outline, "Change Password", () => changePassword(), textColor),
// //                 SizedBox(height: 3,),
// //                 _drawerItem(context,isDark ,  Icons.logout, "Logout", () async {
// //                   Navigator.pop(context);
// //
// //                   SharedPreferences prefs = await SharedPreferences.getInstance();
// //                   String? savedIp = prefs.getString("ip");
// //
// //                   if (savedIp != null) {
// //                     try {
// //                       await http.get(Uri.parse("$savedIp/logout_view"));
// //                     } catch (e) {
// //                       debugPrint("Server logout failed (ignoring): $e");
// //                     }
// //                   }
// //
// //                   await prefs.clear();
// //
// //                   if (savedIp != null) {
// //                     await prefs.setString("ip", savedIp);
// //                   }
// //
// //                   if (!context.mounted) return;
// //                   Navigator.pushAndRemoveUntil(
// //                     context,
// //                     MaterialPageRoute(builder: (context) => const login_page()),
// //                         (route) => false,
// //                   );
// //                 }, Colors.red),
// //
// //               ],),
// //             ),
// //           ),
// //         )
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _drawerItem(BuildContext context, isDark ,IconData icon, String title, Function() onTap, Color color) {
// //     return InkWell(
// //         onTap: () {
// //           Navigator.pop(context);
// //           Navigator.push(context, MaterialPageRoute(builder: (context) => onTap()));
// //         },
// //       child: Container(
// //         padding: EdgeInsets.only(top: 20,bottom: 20,left: 20,right: 20),
// //         // padding: EdgeInsets.all(20),
// //         decoration: BoxDecoration(
// //
// //         color: isDark ? Colors.grey.shade800:Colors.grey.shade200,
// //           borderRadius: BorderRadius.circular(5)
// //         ),
// //
// //           child: Row(
// //               children: [
// //                 Icon(icon,color:color),
// //                 SizedBox(width: 10,),
// //                 Text(title,style: TextStyle(color: color),)
// //
// //               ],
// //           ),
// //         ),
// //     );
// //   }
// // }
// //
// // class Product {
// //   final String id;
// //   final String name;
// //   final String price;
// //   final String description;
// //   final String image;
// //   final String distributorName;
// //   final String distributorId;
// //
// //   Product({
// //     required this.id,
// //     required this.name,
// //     required this.price,
// //     required this.description,
// //     required this.image,
// //     required this.distributorName,
// //     required this.distributorId,
// //   });
// // }
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:snap2bill/Distributordirectory/view/ViewDistributorProfile.dart';
//
// // --- ESSENTIAL IMPORTS FOR THEME CHANGING ---
// import '../../main.dart';
// import '../../theme/theme.dart';
//
// // --- Navigation Imports ---
// import 'package:snap2bill/Distributordirectory/view/viewOrder.dart';
// import 'package:snap2bill/Distributordirectory/view/view_category.dart';
// import 'package:snap2bill/Distributordirectory/view/view_distributors.dart';
// import 'package:snap2bill/Distributordirectory/view/myProducts.dart';
// import 'package:snap2bill/Distributordirectory/view/view_feedback.dart';
// import 'package:snap2bill/Distributordirectory/view/view_product.dart';
// import 'package:snap2bill/Distributordirectory/password/changePassword.dart';
// import 'package:snap2bill/screens/login_page.dart';
//
// class Home_page extends StatefulWidget {
//   const Home_page({Key? key}) : super(key: key);
//
//   @override
//   State<Home_page> createState() => _Home_pageState();
// }
//
// class _Home_pageState extends State<Home_page> {
//   // --- VARIABLES ---
//   List<Product> _allProducts = []; // Stores all fetched products
//   List<Product> _filteredProducts = []; // Products displayed in the feed
//   List<CategoryModel> _categories = []; // List of categories for the filter bar
//   String _selectedCategoryId = "All"; // Filter state: Default is "All"
//   bool _isLoading = true;
//   String _distributorName = "Distributor";
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   // --- API LOGIC (Combined Fetch) ---
//   Future<void> _loadData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     if (mounted) {
//       setState(() {
//         _distributorName = prefs.getString("name") ?? "Distributor";
//         _isLoading = true;
//       });
//     }
//
//     await Future.wait([
//       _fetchProducts(prefs),
//       _fetchCategories(prefs),
//     ]);
//
//     if (mounted) {
//       // Apply initial filtering (show all) after both lists are fetched
//       setState(() {
//         _filteredProducts = _allProducts;
//         _isLoading = false;
//       });
//     }
//   }
//
//   // Helper: Fetch Products
//   Future<void> _fetchProducts(SharedPreferences prefs) async {
//     String? ip = prefs.getString("ip");
//     String? uid = prefs.getString("uid");
//
//     if (ip == null || uid == null) return;
//
//     try {
//       var response = await http.post(
//         Uri.parse("$ip/view_other_products"),
//         body: {'uid': uid},
//       );
//
//       if (response.statusCode == 200) {
//         var jsonData = json.decode(response.body);
//         List<Product> temp = [];
//
//         for (var item in jsonData['data']) {
//           String rawImg = item['image'].toString();
//           String finalUrl = _joinUrl(ip, rawImg);
//
//           String distImg = item["distributor_image"] ?? "";
//           if (distImg != "null" && distImg.isNotEmpty) {
//             distImg = _joinUrl(ip, distImg);
//           }
//
//           temp.add(Product(
//             id: item['id'].toString(),
//             name: item['name'].toString(),
//             price: item['price'].toString(),
//             description: item['description'].toString(),
//             image: finalUrl,
//             distributorName: item['distributor_name'].toString(),
//             distributorId: item['distributor_id'].toString(),
//             categoryName: item['CATEGORY_NAME']?.toString() ?? "General", // Corrected key from backend
//             categoryId: item['CATEGORY']?.toString() ?? "0", // New field from backend
//             distributorImage: distImg,
//             phone: item['phone']?.toString() ?? "",
//           ));
//         }
//
//         if (mounted) {
//           setState(() {
//             _allProducts = temp;
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint("Error loading products: $e");
//     }
//   }
//
//   // Helper: Fetch Categories (assuming a separate endpoint for the full list)
//   Future<void> _fetchCategories(SharedPreferences prefs) async {
//     String? ip = prefs.getString("ip");
//     if (ip == null) return;
//
//     // Using a separate endpoint for all categories if available,
//     // otherwise you could parse unique categories from _allProducts.
//     // Assuming API endpoint: $ip/view_category
//     try {
//       var res = await http.post(Uri.parse("$ip/view_category"), body: {});
//       var jsonDecoded = json.decode(res.body);
//
//       List<CategoryModel> temp = [];
//       // 1. ADD 'ALL' CATEGORY FIRST AS REQUESTED
//       temp.add(CategoryModel("All", "All"));
//
//       if (jsonDecoded["data"] != null && jsonDecoded["data"] is List) {
//         for (var item in jsonDecoded["data"]) {
//           temp.add(CategoryModel(
//             item["id"].toString(),
//             item["category_name"].toString(),
//           ));
//         }
//       }
//
//       if (mounted) {
//         setState(() {
//           _categories = temp;
//         });
//       }
//     } catch (e) {
//       // If category endpoint fails, the app will still function by showing 'All'
//       debugPrint("Category fetch error: $e");
//     }
//   }
//
//   String _joinUrl(String base, String path) {
//     if (path == "null" || path.isEmpty) return "";
//     if (!base.startsWith("http")) base = "http://$base";
//     if (base.endsWith("/")) base = base.substring(0, base.length - 1);
//     if (!path.startsWith("/")) path = "/$path";
//     return base + path;
//   }
//
//   // --- Filtering Logic ---
//   void _filterProducts(String catId) {
//     setState(() {
//       _selectedCategoryId = catId;
//       if (catId == "All") {
//         _filteredProducts = _allProducts;
//       } else {
//         _filteredProducts = _allProducts
//             .where((element) => element.categoryId == catId)
//             .toList();
//       }
//     });
//   }
//
//   // --- SWIPE LOGIC ---
//   void _handleSwipe(DragEndDetails details) {
//     const double sensitivity = 500;
//
//     if (details.primaryVelocity! > sensitivity) {
//       // Swipe Right (Positive velocity) -> Open Left Drawer
//       _scaffoldKey.currentState?.openDrawer();
//     } else if (details.primaryVelocity! < -sensitivity) {
//       // Swipe Left (Negative velocity) -> Placeholder action
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Left Swipe Detected! Action to be specified.")),
//       );
//     }
//   }
//
//   // --- UI BUILD ---
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final bgColor = theme.scaffoldBackgroundColor;
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final hintColor = isDark ? Colors.white38 : Colors.grey[500];
//     final primaryColor = Colors.deepPurple;
//
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: bgColor,
//       appBar: AppBar(
//         title: Text(
//           "Snap2bill",
//           style: GoogleFonts.lobster(color: textColor, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: IconThemeData(color: textColor),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: Icon(Icons.notifications_none, color: textColor),
//           )
//         ],
//       ),
//
//       drawer: _buildDrawer(context, isDark, textColor),
//
//       body: GestureDetector(
//         onHorizontalDragEnd: _handleSwipe,
//         child: RefreshIndicator(
//           onRefresh: _loadData,
//           child: _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : Column(
//             children: [
//               // 1. Category Filter Bar
//               _buildCategoryFilter(primaryColor, textColor, isDark),
//
//               // 2. Product Feed
//               Expanded(
//                 child: _filteredProducts.isEmpty
//                     ? Center(
//                   child: SingleChildScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.inventory_2_outlined, size: 60, color: hintColor),
//                         const SizedBox(height: 10),
//                         Text("No products found in this category.", style: TextStyle(color: hintColor)),
//                       ],
//                     ),
//                   ),
//                 )
//                     :
//                 ListView.builder(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   itemCount: _filteredProducts.length,
//                   itemBuilder: (context, index) {
//                     return _buildProductCard(_filteredProducts[index], isDark);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // --- Widget: Category Filter Bar ---
//   Widget _buildCategoryFilter(Color primaryColor, Color textColor, bool isDark) {
//     return Container(
//       height: 50,
//       margin: const EdgeInsets.only(top: 8, bottom: 8),
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         scrollDirection: Axis.horizontal,
//         itemCount: _categories.length,
//         itemBuilder: (context, index) {
//           final cat = _categories[index];
//           final isSelected = _selectedCategoryId == cat.id;
//
//           return GestureDetector(
//             onTap: () => _filterProducts(cat.id),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               margin: const EdgeInsets.only(right: 10),
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               decoration: BoxDecoration(
//                 color: isSelected ? primaryColor : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
//                 borderRadius: BorderRadius.circular(25),
//                 border: Border.all(
//                     color: isSelected ? primaryColor : (isDark ? Colors.grey.shade700 : Colors.grey.shade300)
//                 ),
//                 boxShadow: isSelected
//                     ? [BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 4)]
//                     : [],
//               ),
//               alignment: Alignment.center,
//               child: Text(
//                 cat.name,
//                 style: TextStyle(
//                   color: isSelected ? Colors.white : textColor,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // --- MODIFIED PRODUCT CARD (Instagram Style) ---
//   Widget _buildProductCard(Product item, bool isDark) {
//     final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final primaryColor = Colors.deepPurple;
//     final bool hasDistributorImage = item.distributorImage.isNotEmpty && item.distributorImage != "null";
//
//     // --- Navigation Function (Called by both header and menu) ---
//     void viewDistributorProfile() {
//       Navigator.push(context, MaterialPageRoute(builder: (context) =>
//           ViewDistributorProfile(
//             distributorId: item.distributorId,
//             distributorName: item.distributorName,
//           )
//       ));
//     }
//
//     // --- Show Options Menu ---
//     void showOptionsMenu(BuildContext context) {
//       final RenderBox button = context.findRenderObject() as RenderBox;
//       final Offset position = button.localToGlobal(Offset.zero);
//
//       showMenu<String>(
//         context: context,
//         position: RelativeRect.fromRect(
//           position & button.size,
//           Offset.zero & MediaQuery.of(context).size,
//         ),
//         items: [
//           PopupMenuItem<String>(
//             value: 'view_profile',
//             child: Row(
//               children: [
//                 Icon(Icons.person_outline, color: textColor),
//                 const SizedBox(width: 8),
//                 Text('View Profile', style: TextStyle(color: textColor)),
//               ],
//             ),
//           ),
//         ],
//         elevation: 8.0,
//         color: cardColor,
//       ).then((value) {
//         if (value == 'view_profile') {
//           viewDistributorProfile();
//         }
//       });
//     }
//
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(10),
//           onTap: () {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text("Selected: ${item.name}")),
//             );
//           },
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 1. HEADER: Distributor Info (Circular Avatar + Name + Phone + Menu)
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     // Avatar and Name (Clickable part)
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: viewDistributorProfile,
//                         child: Row(
//                           children: [
//                             // Circular Avatar
//                             CircleAvatar(
//                               radius: 18,
//                               backgroundColor: primaryColor.withOpacity(0.1),
//                               backgroundImage: hasDistributorImage ? NetworkImage(item.distributorImage) : null,
//                               child: !hasDistributorImage
//                                   ? Icon(Icons.store, size: 20, color: primaryColor)
//                                   : null,
//                             ),
//                             const SizedBox(width: 10),
//                             // Distributor Name & Phone (in a Column)
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   item.distributorName,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                     color: textColor,
//                                   ),
//                                 ),
//                                 // Display Phone Number
//                                 if (item.phone.isNotEmpty)
//                                   Text(
//                                     item.phone,
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                       color: textColor.withOpacity(0.6),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     // Three-dot Menu Button
//                     Builder(
//                       builder: (menuContext) => IconButton(
//                         icon: Icon(Icons.more_vert, color: textColor.withOpacity(0.6)),
//                         onPressed: () => showOptionsMenu(menuContext),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // 2. PRODUCT IMAGE with Overlays
//               Stack(
//                 children: [
//                   // Main Image
//                   AspectRatio(
//                     aspectRatio: 1.0,
//                     child: item.image.isNotEmpty
//                         ? Image.network(
//                       item.image,
//                       fit: BoxFit.cover,
//                       errorBuilder: (c, o, s) => Container(
//                         color: isDark ? Colors.grey[800] : Colors.grey[200],
//                         child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
//                       ),
//                     )
//                         : Container(
//                       color: isDark ? Colors.grey[800] : Colors.grey[200],
//                     ),
//                   ),
//
//                   // Gradient Overlay for readability
//                   Positioned.fill(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.3)],
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   // BOTTOM LEFT: Product Name & Category Name
//                   Positioned(
//                     bottom: 12,
//                     left: 12,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           item.name, // Product Name
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             shadows: [Shadow(color: Colors.black, blurRadius: 4)],
//                           ),
//                         ),
//                         Text(
//                           item.categoryName, // Category Name
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.8),
//                             fontSize: 12,
//                             shadows: [Shadow(color: Colors.black, blurRadius: 4)],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // BOTTOM RIGHT: Price inside the image
//                   Positioned(
//                     bottom: 12,
//                     right: 12,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: primaryColor,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
//                       ),
//                       child: Text(
//                         "₹${item.price}",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w900,
//                           fontSize: 14,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               // 3. FOOTER: Description (Caption style)
//               if (item.description.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 15.0),
//                   child: Text(
//                     item.description,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.9)),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
//
//   // --- DRAWER WITH THEME TOGGLE (EXACTLY AS PROVIDED BY USER) ---
//   Widget _buildDrawer(BuildContext context, bool isDark, Color textColor) {
//     return Drawer(
//       backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//       // backgroundColor: Colors.transparent,
//       child: ListView(
//         // padding: EdgeInsets.zero,
//         children: [
//           DrawerHeader(
//             decoration: BoxDecoration(
//               color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
//               // color: Colors.transparent,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(children: [
//                       Icon(Icons.storefront, color:isDark?Colors.white:Colors.black.withValues(alpha: 0.7), size: 40),
//                       const SizedBox(width: 10),
//                       Text("Menu", style: TextStyle(color:isDark?Colors.white:Colors.black.withValues(alpha: 0.7), fontSize: 24)),
//                     ],),
//
//                     Column(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(50),
//                               color: Colors.grey.withValues(alpha: 0.5),
//                               border: Border.all(width: 1,color: Colors.grey)
//
//                           ),
//                           child: IconButton(
//                             icon:  Icon(
//                               ThemeService.instance.isDarkMode ? Icons.light_mode : Icons.dark_mode,
//                               color: Colors.white,
//
//                             ),
//
//                             onPressed: () {
//                               // Navigator.pop(context);
//                               MyApp.changeTheme(context);
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//
//                   ],
//                 ),
//
//               ],
//             ),
//           ),
//           // SizedBox(height: 100,),
//           SingleChildScrollView(
//             child: Container(
//               margin: EdgeInsets.only(bottom: 100),
//               padding: EdgeInsets.all(20),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(30),
//                 child: Column(children: [
//                   _drawerItem(context,isDark, Icons.people_alt_outlined, "Distributors", () => view_distributors(), textColor),
//                   SizedBox(height: 3,),
//                   _drawerItem(context,isDark ,  Icons.inventory_2_outlined, "My Products", () => myProducts(), textColor),
//                   SizedBox(height: 3,),
//                   _drawerItem(context, isDark , Icons.shopping_bag_outlined, "All Products", () => view_product(), textColor),
//                   SizedBox(height: 3,),
//                   _drawerItem(context, isDark , Icons.list_alt, "Orders", () => viewOrder(), textColor),
//                   SizedBox(height: 3,),
//                   _drawerItem(context,isDark ,  Icons.category_outlined, "Category", () => view_category(), textColor),
//                   SizedBox(height: 3,),
//                   _drawerItem(context,isDark ,  Icons.feedback_outlined, "Feedback", () => view_feedback(), textColor),
//                   SizedBox(height: 3,),
//                   _drawerItem(context,isDark,  Icons.lock_outline, "Change Password", () => changePassword(), textColor),
//                   SizedBox(height: 3,),
//                   _drawerItem(context,isDark ,  Icons.logout, "Logout", () async {
//                     Navigator.pop(context);
//
//                     SharedPreferences prefs = await SharedPreferences.getInstance();
//                     String? savedIp = prefs.getString("ip");
//
//                     if (savedIp != null) {
//                       try {
//                         await http.get(Uri.parse("$savedIp/logout_view"));
//                       } catch (e) {
//                         debugPrint("Server logout failed (ignoring): $e");
//                       }
//                     }
//
//                     await prefs.clear();
//
//                     if (savedIp != null) {
//                       await prefs.setString("ip", savedIp);
//                     }
//
//                     if (!context.mounted) return;
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(builder: (context) => const login_page()),
//                           (route) => false,
//                     );
//                   }, Colors.red),
//
//                 ],),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _drawerItem(BuildContext context, isDark ,IconData icon, String title, Function() onTap, Color color) {
//     return InkWell(
//       onTap: () {
//         Navigator.pop(context);
//         Navigator.push(context, MaterialPageRoute(builder: (context) => onTap()));
//       },
//       child: Container(
//         padding: EdgeInsets.only(top: 20,bottom: 20,left: 20,right: 20),
//         // padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//
//             color: isDark ? Colors.grey.shade800:Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(5)
//         ),
//
//         child: Row(
//           children: [
//             Icon(icon,color:color),
//             SizedBox(width: 10,),
//             Text(title,style: TextStyle(color: color),)
//
//           ],
//         ),
//       ),
//     );
//   }
//
//
// }
//
//
//
//
// // --- CATEGORY MODEL ---
// class CategoryModel {
//   final String id;
//   final String name;
//   CategoryModel(this.id, this.name);
// }
//
// // --- PRODUCT MODEL ---
// class Product {
//   final String id;
//   final String name;
//   final String price;
//   final String description;
//   final String image;
//   final String distributorName;
//   final String distributorId;
//   final String categoryId; // New field for filtering
//   final String categoryName;
//   final String distributorImage;
//   final String phone;
//
//   Product({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.description,
//     required this.image,
//     required this.distributorName,
//     required this.distributorId,
//     this.categoryId = "0",
//     this.categoryName = "General",
//     this.distributorImage = "",
//     this.phone = "",
//   });
// }
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
import 'package:snap2bill/widgets/custom_drawer.dart'; // Import CustomDrawer (which includes DrawerItemModel)

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
                child: filteredProducts.isEmpty
                    ? const Center(child: Text("No products found"))
                    : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: filteredProducts[index],
                      showAddToCart: false, // DISTRIBUTOR VIEW
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}