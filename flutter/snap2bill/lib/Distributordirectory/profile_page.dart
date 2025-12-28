// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:shimmer/shimmer.dart'; // Make sure to add shimmer to pubspec.yaml
//
// // Import your edit pages
// import 'package:snap2bill/Distributordirectory/Editfolder/edit_distributor_profile.dart';
// import 'package:snap2bill/Distributordirectory/Editfolder/editStock.dart';
//
// class distributor_profile_page extends StatefulWidget {
//   const distributor_profile_page({Key? key}) : super(key: key);
//
//   @override
//   State<distributor_profile_page> createState() => _distributor_profile_pageState();
// }
//
// class _distributor_profile_pageState extends State<distributor_profile_page> {
//   // Data Holders
//   DistributorProfileModel? _profile;
//   List<ProductModel> _products = [];
//   bool _isLoading = true;
//
//   // Toggle State: False = Grid View, True = Info/Details View
//   bool _showDetails = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchAllData();
//   }
//
//   // --- DATA FETCHING ---
//   Future<void> _fetchAllData() async {
//     if (!mounted) return;
//     setState(() => _isLoading = true);
//
//     // Optional delay to see Shimmer
//     await Future.delayed(const Duration(milliseconds: 1000));
//
//     await Future.wait([
//       _getProfile(),
//       _getProducts(),
//     ]);
//     if (mounted) {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _getProfile() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? ip = prefs.getString("ip");
//       String? uid = prefs.getString("uid");
//
//       if (ip == null || uid == null) return;
//
//       var response = await http.post(
//         Uri.parse("$ip/distributor_view_profile"),
//         body: {"uid": uid},
//       );
//
//       var jsonData = json.decode(response.body);
//       if (jsonData["data"] != null && jsonData["data"].isNotEmpty) {
//         var item = jsonData["data"][0];
//
//         String imgUrl = "";
//         if (item["profile_image"] != null && item["profile_image"] != "null") {
//           imgUrl = "$ip${item["profile_image"]}";
//         }
//
//         String proofUrl = "";
//         if (item["proof"] != null && item["proof"] != "null") {
//           proofUrl = "$ip${item["proof"]}";
//         }
//
//         setState(() {
//           _profile = DistributorProfileModel(
//             item["id"].toString(),
//             item["name"].toString(),
//             item["email"].toString(),
//             item["phone"].toString(),
//             imgUrl,
//             item["bio"].toString(),
//             item["address"].toString(),
//             item["place"].toString(),
//             item["pincode"].toString(),
//             item["post"].toString(),
//             item["latitude"].toString(),
//             item["longitude"].toString(),
//             proofUrl,
//           );
//         });
//       }
//     } catch (e) {
//       debugPrint("Profile Error: $e");
//     }
//   }
//
//   Future<void> _getProducts() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final base = prefs.getString("ip") ?? "";
//       final uid = prefs.getString("uid") ?? "";
//
//       final uri = Uri.parse("$base/distributor_products");
//       final res = await http.post(uri, body: {"uid": uid});
//
//       if (res.statusCode == 200) {
//         final js = json.decode(res.body);
//         if (js is Map && js['status'] == 'ok' && js['data'] != null) {
//           List<ProductModel> temp = [];
//           for (final it in (js['data'] as List)) {
//             temp.add(ProductModel(
//               (it["id"] ?? "").toString(),
//               (it["product_name"] ?? "").toString(),
//               (it["price"] ?? "").toString(),
//               _joinUrl(base, (it["image"] ?? "").toString()),
//               (it["description"] ?? "").toString(),
//               (it["quantity"] ?? "").toString(),
//               (it["CATEGORY"] ?? "").toString(),
//               (it["CATEGORY_NAME"] ?? "").toString(),
//             ));
//           }
//           setState(() {
//             _products = temp;
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint("Product Error: $e");
//     }
//   }
//
//   String _joinUrl(String base, String path) {
//     if (path.trim().isEmpty || path == "null") return "";
//     if (base.endsWith("/") && path.startsWith("/")) return base + path.substring(1);
//     if (!base.endsWith("/") && !path.startsWith("/")) return "$base/$path";
//     return base + path;
//   }
//
//   Future<void> _launchMaps() async {
//     if (_profile == null) return;
//     // Basic Google Maps intent
//     final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=${_profile!.latitude},${_profile!.longitude}");
//
//     try {
//       if (await canLaunchUrl(googleMapsUrl)) {
//         await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open maps")));
//       }
//     } catch (e) {
//       debugPrint("Map Error: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // 1. THEME SETUP
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     // Dynamic Text Colors based on theme brightness
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
//     final iconColor = isDark ? Colors.white70 : Colors.black54;
//
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         leading: Icon(Icons.lock),
//         backgroundColor: theme.scaffoldBackgroundColor,
//         elevation: 0,
//         centerTitle: true,
//         title: _isLoading
//             ? const SizedBox() // Hide title while loading
//             : Text(
//           _profile?.name ?? "Profile",
//           style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
//         ),
//         iconTheme: IconThemeData(color: textColor),
//         actions: [
//           IconButton(
//               icon: Icon(Icons.refresh, color: textColor),
//               onPressed: _fetchAllData
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? _buildPageShimmer(theme) // SHOW SHIMMER WHEN LOADING
//           : RefreshIndicator(
//         onRefresh: _fetchAllData,
//         child: CustomScrollView(
//           physics: const BouncingScrollPhysics(),
//           slivers: [
//             // 1. PROFILE HEADER
//             SliverToBoxAdapter(
//               child: _buildProfileHeader(theme, textColor, subTextColor),
//             ),
//
//             // 2. TOGGLE TABS (Grid vs Info)
//             SliverToBoxAdapter(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 10),
//                   Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
//                   Container(
//                     height: 50,
//                     color: theme.scaffoldBackgroundColor,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         // Grid Button
//                         Expanded(
//                           child: InkWell(
//                             onTap: () => setState(() => _showDetails = false),
//                             child: Icon(
//                                 Icons.grid_on,
//                                 color: !_showDetails ? theme.primaryColor : iconColor
//                             ),
//                           ),
//                         ),
//                         // Vertical Divider
//                         Container(width: 1, height: 20, color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
//                         // Info Button
//                         Expanded(
//                           child: InkWell(
//                             onTap: () => setState(() => _showDetails = true),
//                             child: Icon(
//                                 Icons.info_outline,
//                                 color: _showDetails ? theme.primaryColor : iconColor
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
//                 ],
//               ),
//             ),
//
//             // 3. CONTENT AREA
//             if (_showDetails)
//               SliverToBoxAdapter(
//                 child: _buildContactDetails(theme, textColor, subTextColor),
//               )
//             else
//               _products.isEmpty
//                   ? SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 80.0),
//                   child: Column(
//                     children: [
//                       Icon(Icons.inventory_2_outlined, size: 60, color: subTextColor),
//                       const SizedBox(height: 10),
//                       Text(
//                         "No products found",
//                         style: TextStyle(color: subTextColor, fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//                   : SliverGrid(
//                 delegate: SliverChildBuilderDelegate(
//                       (context, index) {
//                     return _buildProductTile(_products[index], theme);
//                   },
//                   childCount: _products.length,
//                 ),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   mainAxisSpacing: 2,
//                   crossAxisSpacing: 2,
//                   childAspectRatio: 1.0,
//                 ),
//               ),
//
//             const SliverPadding(padding: EdgeInsets.only(bottom: 50)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // --- WIDGETS ---
//
//   Widget _buildProfileHeader(ThemeData theme, Color textColor, Color subTextColor) {
//     if (_profile == null) return const SizedBox();
//
//     bool hasImage = _profile!.profile_image.isNotEmpty;
//     final isDark = theme.brightness == Brightness.dark;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               // Avatar
//               Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                       color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
//                       width: 2
//                   ),
//                 ),
//                 padding: const EdgeInsets.all(3),
//                 child: CircleAvatar(
//                   radius: 40,
//                   backgroundColor: theme.cardColor,
//                   backgroundImage: hasImage ? NetworkImage(_profile!.profile_image) : null,
//                   child: !hasImage ? Icon(Icons.person, size: 40, color: subTextColor) : null,
//                 ),
//               ),
//               const SizedBox(width: 20),
//               Expanded(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildStatColumn(_products.length.toString(), "Products", textColor, subTextColor),
//                     _buildStatColumn("0", "Sold", textColor, subTextColor),
//                     _buildStatColumn("4.5", "Rating", textColor, subTextColor),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//
//           Text(
//             _profile!.name,
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
//           ),
//
//           if (_profile!.bio.isNotEmpty && _profile!.bio != "null")
//             Padding(
//               padding: const EdgeInsets.only(top: 4.0),
//               child: Text(_profile!.bio, style: TextStyle(color: subTextColor)),
//             ),
//
//           Padding(
//             padding: const EdgeInsets.only(top: 4.0),
//             child: Row(
//               children: [
//                 Icon(Icons.location_on, size: 14, color: theme.primaryColor),
//                 const SizedBox(width: 4),
//                 Text(
//                   "${_profile!.place}",
//                   style: TextStyle(color: theme.primaryColor, fontSize: 14, fontWeight: FontWeight.w500),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 20),
//
//           // Action Buttons
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Navigate to Edit Profile
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => edit_distributor_profile_sub(
//                       id: _profile!.id,
//                       name: _profile!.name,
//                       email: _profile!.email,
//                       phone: _profile!.phone,
//                       bio: _profile!.bio,
//                       address: _profile!.address,
//                       place: _profile!.place,
//                       pincode: _profile!.pincode,
//                       post: _profile!.post,
//                       latitude: _profile!.latitude,
//                       longitude: _profile!.longitude,
//                     )));
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: theme.cardColor,
//                     foregroundColor: textColor,
//                     elevation: 0,
//                     side: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: const Text("Edit Profile"),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () => _showProofDialog(_profile!.proof, theme),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: theme.cardColor,
//                     foregroundColor: textColor,
//                     elevation: 0,
//                     side: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: const Text("View Proof"),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildContactDetails(ThemeData theme, Color textColor, Color subTextColor) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Contact Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
//           const SizedBox(height: 20),
//
//           _buildDetailRow(Icons.email_outlined, "Email", _profile!.email, textColor, subTextColor),
//           _buildDetailRow(Icons.phone_android, "Phone", _profile!.phone, textColor, subTextColor),
//           _buildDetailRow(Icons.location_on_outlined, "Address", _profile!.address, textColor, subTextColor),
//           _buildDetailRow(Icons.local_post_office_outlined, "Post", _profile!.post, textColor, subTextColor),
//           _buildDetailRow(Icons.pin_drop_outlined, "Pincode", _profile!.pincode, textColor, subTextColor),
//
//           const SizedBox(height: 30),
//
//           SizedBox(
//             width: double.infinity,
//             height: 50,
//             child: ElevatedButton.icon(
//               onPressed: _launchMaps,
//               icon: const Icon(Icons.map, color: Colors.white),
//               label: const Text("Open Location in Maps", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: theme.primaryColor,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(IconData icon, String label, String value, Color textColor, Color subTextColor) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 20, color: subTextColor),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label, style: TextStyle(fontSize: 12, color: subTextColor)),
//                 const SizedBox(height: 2),
//                 Text(
//                     value.isEmpty || value == "null" ? "Not set" : value,
//                     style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.w500)
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatColumn(String count, String label, Color textColor, Color subTextColor) {
//     return Column(
//       children: [
//         Text(count, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
//         Text(label, style: TextStyle(color: subTextColor, fontSize: 13)),
//       ],
//     );
//   }
//
//   Widget _buildProductTile(ProductModel product, ThemeData theme) {
//     final isDark = theme.brightness == Brightness.dark;
//     return GestureDetector(
//       onTap: () => _showProductDetails(product, theme),
//       child: Container(
//         decoration: BoxDecoration(
//             color: theme.cardColor,
//             border: Border.all(
//                 color: isDark ? Colors.grey.shade800 : Colors.white,
//                 width: 0.5
//             )
//         ),
//         child: Image.network(
//           product.image,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return Center(child: Icon(Icons.broken_image, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400));
//           },
//         ),
//       ),
//     );
//   }
//
//   // --- DIALOGS & SHEETS ---
//
//   void _showProofDialog(String url, ThemeData theme) {
//     if (url.isEmpty || url.endsWith("null")) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: const Text("No proof document available"),
//         backgroundColor: theme.primaryColor,
//       ));
//       return;
//     }
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         child: Stack(
//           alignment: Alignment.topRight,
//           children: [
//             InteractiveViewer(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: Container(
//                   color: Colors.white, // Keep background white for images to be visible clearly
//                   child: Image.network(url, fit: BoxFit.contain, errorBuilder: (c,e,s)=>const Padding(padding:EdgeInsets.all(20), child: Text("Error loading proof"))),
//                 ),
//               ),
//             ),
//             IconButton(
//               onPressed: () => Navigator.pop(context),
//               icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
//               style: IconButton.styleFrom(backgroundColor: Colors.black54),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showProductDetails(ProductModel product, ThemeData theme) {
//     final isDark = theme.brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: theme.cardColor, // Dark mode aware
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return DraggableScrollableSheet(
//           expand: false,
//           initialChildSize: 0.6,
//           maxChildSize: 0.9,
//           builder: (context, scrollController) {
//             return Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: ListView(
//                 controller: scrollController,
//                 children: [
//                   Center(
//                     child: Container(
//                       width: 50, height: 5,
//                       decoration: BoxDecoration(color: isDark ? Colors.grey.shade700 : Colors.grey[300], borderRadius: BorderRadius.circular(10)),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: Container(
//                         color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
//                         child: Image.network(product.image, height: 250, width:double.infinity, fit: BoxFit.cover)
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//
//                   Text(product.product_name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
//                   const SizedBox(height: 5),
//                   Text("Category: ${product.CATEGORY_NAME}", style: TextStyle(color: subTextColor)),
//                   const SizedBox(height: 15),
//
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text("₹ ${product.price}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: theme.primaryColor)),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                         decoration: BoxDecoration(
//                             color: theme.primaryColor.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(5)
//                         ),
//                         child: Text(
//                             "Stock: ${product.quantity}",
//                             style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)
//                         ),
//                       )
//                     ],
//                   ),
//                   const SizedBox(height: 15),
//                   Text("Description", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
//                   const SizedBox(height: 5),
//                   Text(product.description, style: TextStyle(color: subTextColor, height: 1.5)),
//
//                   const SizedBox(height: 30),
//
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                             Navigator.push(context, MaterialPageRoute(builder: (context) => editStock(
//                               id: product.id,
//                               price: product.price,
//                               quantity: product.quantity,
//                             )));
//                           },
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: theme.primaryColor,
//                               foregroundColor: Colors.white
//                           ),
//                           child: const Text("Edit Stock"),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                             // Delete logic
//                           },
//                           style: OutlinedButton.styleFrom(
//                               foregroundColor: Colors.red,
//                               side: const BorderSide(color: Colors.red)
//                           ),
//                           child: const Text("Delete"),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // --- SHIMMER LOADING (SKELETON) ---
//
//   Widget _buildPageShimmer(ThemeData theme) {
//     final isDark = theme.brightness == Brightness.dark;
//     final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
//     final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;
//
//     return Shimmer.fromColors(
//       baseColor: baseColor,
//       highlightColor: highlightColor,
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Skeleton
//               Row(
//                 children: [
//                   const CircleAvatar(radius: 40, backgroundColor: Colors.white),
//                   const SizedBox(width: 20),
//                   Expanded(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         Container(width: 40, height: 10, color: Colors.white),
//                         Container(width: 40, height: 10, color: Colors.white),
//                         Container(width: 40, height: 10, color: Colors.white),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//               const SizedBox(height: 20),
//               Container(width: 150, height: 20, color: Colors.white), // Name
//               const SizedBox(height: 8),
//               Container(width: 200, height: 12, color: Colors.white), // Bio
//               const SizedBox(height: 20),
//
//               // Buttons Skeleton
//               Row(
//                 children: [
//                   Expanded(child: Container(height: 35, color: Colors.white)),
//                   const SizedBox(width: 10),
//                   Expanded(child: Container(height: 35, color: Colors.white)),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               const Divider(),
//               const SizedBox(height: 10),
//
//               // Grid Skeleton
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 2,
//                   mainAxisSpacing: 2,
//                 ),
//                 itemCount: 12,
//                 itemBuilder: (_, __) => Container(color: Colors.white),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // --- MODELS ---
//
// class DistributorProfileModel {
//   final String id;
//   final String name;
//   final String email;
//   final String phone;
//   final String profile_image;
//   final String bio;
//   final String address;
//   final String place;
//   final String pincode;
//   final String post;
//   final String latitude;
//   final String longitude;
//   final String proof;
//
//   DistributorProfileModel(
//       this.id, this.name, this.email, this.phone, this.profile_image,
//       this.bio, this.address, this.place, this.pincode, this.post,
//       this.latitude, this.longitude, this.proof
//       );
// }
//
// class ProductModel {
//   final String id;
//   final String product_name;
//   final String price;
//   final String image;
//   final String description;
//   final String quantity;
//   final String CATEGORY;
//   final String CATEGORY_NAME;
//
//   ProductModel(
//       this.id, this.product_name, this.price, this.image,
//       this.description, this.quantity, this.CATEGORY, this.CATEGORY_NAME
//       );
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// Import your edit pages
import 'package:snap2bill/Distributordirectory/Editfolder/edit_distributor_profile.dart';
import 'package:snap2bill/Distributordirectory/Editfolder/editStock.dart';

class distributor_profile_page extends StatefulWidget {
  const distributor_profile_page({Key? key}) : super(key: key);

  @override
  State<distributor_profile_page> createState() => _distributor_profile_pageState();
}

class _distributor_profile_pageState extends State<distributor_profile_page> {
  DistributorProfileModel? _profile;
  List<ProductModel> _products = [];
  bool _isLoading = true;

  final PageController _pageController = PageController();
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await Future.wait([_getProfile(), _getProducts()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _getProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ip = prefs.getString("ip");
      String? uid = prefs.getString("uid");
      if (ip == null || uid == null) return;

      var response = await http.post(Uri.parse("$ip/distributor_view_profile"), body: {"uid": uid});
      var jsonData = json.decode(response.body);
      if (jsonData["data"] != null && jsonData["data"].isNotEmpty) {
        var item = jsonData["data"][0];
        setState(() {
          _profile = DistributorProfileModel(
            item["id"].toString(), item["name"].toString(), item["email"].toString(),
            item["phone"].toString(), _joinUrl(ip, item["profile_image"].toString()),
            item["bio"].toString(), item["address"].toString(), item["place"].toString(),
            item["pincode"].toString(), item["post"].toString(), item["latitude"].toString(),
            item["longitude"].toString(), _joinUrl(ip, item["proof"].toString()),
          );
        });
      }
    } catch (e) { debugPrint("Profile Error: $e"); }
  }

  Future<void> _getProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base = prefs.getString("ip") ?? "";
      final uid = prefs.getString("uid") ?? "";
      final res = await http.post(Uri.parse("$base/distributor_products"), body: {"uid": uid});
      if (res.statusCode == 200) {
        final js = json.decode(res.body);
        if (js is Map && js['status'] == 'ok' && js['data'] != null) {
          List<ProductModel> temp = [];
          for (final it in (js['data'] as List)) {
            temp.add(ProductModel(
              (it["id"] ?? "").toString(), (it["product_name"] ?? "").toString(),
              (it["price"] ?? "").toString(), _joinUrl(base, (it["image"] ?? "").toString()),
              (it["description"] ?? "").toString(), (it["quantity"] ?? "").toString(),
              (it["CATEGORY"] ?? "").toString(), (it["CATEGORY_NAME"] ?? "").toString(),
            ));
          }
          setState(() => _products = temp);
        }
      }
    } catch (e) { debugPrint("Product Error: $e"); }
  }

  String _joinUrl(String base, String path) {
    if (path.trim().isEmpty || path == "null") return "";
    String cleanBase = base.endsWith("/") ? base.substring(0, base.length - 1) : base;
    String cleanPath = path.startsWith("/") ? path : "/$path";
    return cleanBase + cleanPath;
  }

  Future<void> _launchMaps() async {
    if (_profile == null) return;
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=${_profile!.latitude},${_profile!.longitude}");
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _showImagePopup(BuildContext context, String imageUrl) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false, barrierDismissible: true,
      pageBuilder: (context, _, __) => Scaffold(
        backgroundColor: Colors.black.withOpacity(0.9),
        body: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Hero(
              tag: 'profile_hero',
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const Icon(Icons.lock_person_outlined, size: 22),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(_profile?.name ?? "Profile", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          _buildProfileHeader(theme, textColor, isDark),
          _buildTabSwitcher(theme, isDark),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _activeTab = index),
              children: [
                _buildProductGrid(theme, isDark),
                _buildContactDetails(theme, textColor, isDark),
              ],
            ),
          ),
          // ✅ THIS IS THE SPACE FOR THE NAVIGATION BAR
          const SizedBox(height: 70),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, Color textColor, bool isDark) {
    if (_profile == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _showImagePopup(context, _profile!.profile_image),
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? Colors.blueAccent.withOpacity(0.7) : Colors.grey.shade300, width: 2),
                  ),
                  child: Hero(
                    tag: 'profile_hero',
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
                      backgroundImage: _profile!.profile_image.isNotEmpty ? NetworkImage(_profile!.profile_image) : null,
                      child: _profile!.profile_image.isEmpty ? const Icon(Icons.person, size: 40) : null,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(label: "Products", count: _products.length.toString(), color: textColor),
                    _StatItem(label: "Rating", count: "4.5", color: textColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(_profile!.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: textColor)),
          if (_profile!.bio.isNotEmpty && _profile!.bio != "null")
            Text(_profile!.bio, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => edit_distributor_profile_sub(
                    id: _profile!.id, name: _profile!.name, email: _profile!.email, phone: _profile!.phone, bio: _profile!.bio,
                    address: _profile!.address, place: _profile!.place, pincode: _profile!.pincode, post: _profile!.post,
                    latitude: _profile!.latitude, longitude: _profile!.longitude,
                  ))),
                  style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200, foregroundColor: textColor, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showProofDialog(_profile!.proof, theme),
                  style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200, foregroundColor: textColor, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text("View Proof", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher(ThemeData theme, bool isDark) {
    return Column(children: [
      const Divider(height: 1),
      Row(children: [
        _TabButton(icon: Icons.grid_on_rounded, isActive: _activeTab == 0, onTap: () => _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)),
        _TabButton(icon: Icons.info_outline_rounded, isActive: _activeTab == 1, onTap: () => _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)),
      ]),
      const Divider(height: 1),
    ]);
  }

  Widget _buildProductGrid(ThemeData theme, bool isDark) {
    if (_products.isEmpty) return const Center(child: Text("No products found"));
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 20), // Added bottom padding to grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
      itemCount: _products.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => _showProductDetails(_products[index], theme),
        child: Image.network(_products[index].image, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: isDark ? Colors.grey[900] : Colors.grey[200], child: const Icon(Icons.broken_image))),
      ),
    );
  }

  Widget _buildContactDetails(ThemeData theme, Color textColor, bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 30), // Added bottom padding to info list
      children: [
        _InfoItem(icon: Icons.alternate_email_rounded, label: "Email Address", value: _profile!.email, color: textColor),
        _InfoItem(icon: Icons.phone_android_rounded, label: "Mobile Number", value: _profile!.phone, color: textColor),
        _InfoItem(icon: Icons.business_rounded, label: "Business Location", value: "${_profile!.address}, ${_profile!.place}", color: textColor),
        _InfoItem(icon: Icons.local_post_office_rounded, label: "Post Office", value: _profile!.post, color: textColor),
        _InfoItem(icon: Icons.pin_drop_rounded, label: "Pincode", value: _profile!.pincode, color: textColor),
        const SizedBox(height: 25),
        ElevatedButton.icon(
          onPressed: _launchMaps,
          icon: const Icon(Icons.map_rounded, color: Colors.white),
          label: const Text("Open Location in Maps", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ],
    );
  }

  void _showProofDialog(String url, ThemeData theme) {
    showDialog(context: context, builder: (_) => Dialog(child: InteractiveViewer(child: Image.network(url, errorBuilder: (c,e,s) => const Center(child: Text("No proof found"))))));
  }

  void _showProductDetails(ProductModel product, ThemeData theme) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6, expand: false,
        builder: (_, controller) => ListView(
          controller: controller, padding: const EdgeInsets.all(20),
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(product.image, height: 250, fit: BoxFit.cover)),
            const SizedBox(height: 15),
            Text(product.product_name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("₹ ${product.price}", style: TextStyle(fontSize: 20, color: theme.primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(product.description, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => editStock(id: product.id, price: product.price, quantity: product.quantity)));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white),
                    child: const Text("Edit Stock"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                    child: const Text("Delete Product"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Support Components
class _StatItem extends StatelessWidget {
  final String label, count;
  final Color color;
  const _StatItem({required this.label, required this.count, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(count, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))]);
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  const _TabButton({required this.icon, required this.isActive, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: InkWell(onTap: onTap, child: Container(height: 50, decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isActive ? Colors.blueAccent : Colors.transparent, width: 2.5))), child: Icon(icon, color: isActive ? Colors.blueAccent : Colors.grey))));
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _InfoItem({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(children: [
        Icon(icon, color: Colors.blueAccent.withOpacity(0.8), size: 24),
        const SizedBox(width: 18),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
            Text(value.isEmpty || value == "null" ? "Not Provided" : value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }
}

class DistributorProfileModel {
  final String id, name, email, phone, profile_image, bio, address, place, pincode, post, latitude, longitude, proof;
  DistributorProfileModel(this.id, this.name, this.email, this.phone, this.profile_image, this.bio, this.address, this.place, this.pincode, this.post, this.latitude, this.longitude, this.proof);
}

class ProductModel {
  final String id, product_name, price, image, description, quantity, CATEGORY, CATEGORY_NAME;
  ProductModel(this.id, this.product_name, this.price, this.image, this.description, this.quantity, this.CATEGORY, this.CATEGORY_NAME);
}