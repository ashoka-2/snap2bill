import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class ViewDistributorProfile extends StatefulWidget {
  final String distributorId;
  final String distributorName; // Optional, for app bar title before loading

  const ViewDistributorProfile({
    Key? key,
    required this.distributorId,
    this.distributorName = "Distributor Profile",
  }) : super(key: key);

  @override
  State<ViewDistributorProfile> createState() => _ViewDistributorProfileState();
}

class _ViewDistributorProfileState extends State<ViewDistributorProfile> {
  // Data Holders
  DistributorProfileModel? _profile;
  List<ProductModel> _products = [];
  bool _isLoading = true;

  // Toggle State: False = Grid View, True = Info/Details View
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  // --- DATA FETCHING ---
  Future<void> _fetchAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // Optional delay to see Shimmer
    await Future.delayed(const Duration(milliseconds: 800));

    await Future.wait([
      _getProfile(),
      _getProducts(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ip = prefs.getString("ip");

      if (ip == null) return;

      // Fetching specific distributor profile by ID
      var response = await http.post(
        Uri.parse("$ip/distributor_view_profile"),
        body: {"uid": widget.distributorId},
      );

      var jsonData = json.decode(response.body);
      if (jsonData["data"] != null && jsonData["data"].isNotEmpty) {
        var item = jsonData["data"][0];

        String imgUrl = "";
        if (item["profile_image"] != null && item["profile_image"] != "null") {
          imgUrl = "$ip${item["profile_image"]}";
        }

        // Proof is usually private, so we might not need to load it here
        // or load it but not show the button.

        setState(() {
          _profile = DistributorProfileModel(
            item["id"].toString(),
            item["name"].toString(),
            item["email"].toString(),
            item["phone"].toString(),
            imgUrl,
            item["bio"].toString(),
            item["address"].toString(),
            item["place"].toString(),
            item["pincode"].toString(),
            item["post"].toString(),
            item["latitude"].toString(),
            item["longitude"].toString(),
            "", // Hiding proof for public view
          );
        });
      }
    } catch (e) {
      debugPrint("Profile Error: $e");
    }
  }

  Future<void> _getProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base = prefs.getString("ip") ?? "";

      final uri = Uri.parse("$base/distributor_products");
      // Fetching products for the SPECIFIC distributor ID
      final res = await http.post(uri, body: {"uid": widget.distributorId});

      if (res.statusCode == 200) {
        final js = json.decode(res.body);
        if (js is Map && js['status'] == 'ok' && js['data'] != null) {
          List<ProductModel> temp = [];
          for (final it in (js['data'] as List)) {
            temp.add(ProductModel(
              (it["id"] ?? "").toString(),
              (it["product_name"] ?? "").toString(),
              (it["price"] ?? "").toString(),
              _joinUrl(base, (it["image"] ?? "").toString()),
              (it["description"] ?? "").toString(),
              (it["quantity"] ?? "").toString(),
              (it["CATEGORY"] ?? "").toString(),
              (it["CATEGORY_NAME"] ?? "").toString(),
            ));
          }
          setState(() {
            _products = temp;
          });
        }
      }
    } catch (e) {
      debugPrint("Product Error: $e");
    }
  }

  String _joinUrl(String base, String path) {
    if (path.trim().isEmpty || path == "null") return "";
    if (base.endsWith("/") && path.startsWith("/")) return base + path.substring(1);
    if (!base.endsWith("/") && !path.startsWith("/")) return "$base/$path";
    return base + path;
  }

  Future<void> _launchMaps() async {
    if (_profile == null) return;
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=${_profile!.latitude},${_profile!.longitude}");

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open maps")));
      }
    } catch (e) {
      debugPrint("Map Error: $e");
    }
  }

  Future<void> _makeCall() async {
    if (_profile == null) return;
    final Uri launchUri = Uri(scheme: 'tel', path: _profile!.phone);
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final iconColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isLoading
            ? Text(widget.distributorName, style: TextStyle(color: textColor, fontWeight: FontWeight.bold))
            : Text(
          _profile?.name ?? "Profile",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? _buildPageShimmer(theme)
          : RefreshIndicator(
        onRefresh: _fetchAllData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. PROFILE HEADER
            SliverToBoxAdapter(
              child: _buildProfileHeader(theme, textColor, subTextColor),
            ),

            // 2. TOGGLE TABS
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                  Container(
                    height: 50,
                    color: theme.scaffoldBackgroundColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _showDetails = false),
                            child: Icon(Icons.grid_on, color: !_showDetails ? theme.primaryColor : iconColor),
                          ),
                        ),
                        Container(width: 1, height: 20, color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _showDetails = true),
                            child: Icon(Icons.info_outline, color: _showDetails ? theme.primaryColor : iconColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ],
              ),
            ),

            // 3. CONTENT AREA
            if (_showDetails)
              SliverToBoxAdapter(
                child: _buildContactDetails(theme, textColor, subTextColor),
              )
            else
              _products.isEmpty
                  ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 60, color: subTextColor),
                      const SizedBox(height: 10),
                      Text("No products listed", style: TextStyle(color: subTextColor, fontSize: 16)),
                    ],
                  ),
                ),
              )
                  : SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return _buildProductTile(_products[index], theme);
                  },
                  childCount: _products.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 1.0,
                ),
              ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 50)),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildProfileHeader(ThemeData theme, Color textColor, Color subTextColor) {
    if (_profile == null) return const SizedBox();

    bool hasImage = _profile!.profile_image.isNotEmpty;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, width: 2),
                ),
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.cardColor,
                  backgroundImage: hasImage ? NetworkImage(_profile!.profile_image) : null,
                  child: !hasImage ? Icon(Icons.person, size: 40, color: subTextColor) : null,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(_products.length.toString(), "Products", textColor, subTextColor),
                    _buildStatColumn("0", "Sold", textColor, subTextColor),
                    _buildStatColumn("4.5", "Rating", textColor, subTextColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            _profile!.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
          ),

          if (_profile!.bio.isNotEmpty && _profile!.bio != "null")
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(_profile!.bio, style: TextStyle(color: subTextColor)),
            ),

          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 14, color: theme.primaryColor),
                const SizedBox(width: 4),
                Text(
                  "${_profile!.place}",
                  style: TextStyle(color: theme.primaryColor, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action Button - Call Instead of Edit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _makeCall,
              icon: const Icon(Icons.call, size: 18),
              label: const Text("Contact Distributor"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetails(ThemeData theme, Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Business Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 20),

          _buildDetailRow(Icons.email_outlined, "Email", _profile!.email, textColor, subTextColor),
          _buildDetailRow(Icons.phone_android, "Phone", _profile!.phone, textColor, subTextColor),
          _buildDetailRow(Icons.location_on_outlined, "Address", _profile!.address, textColor, subTextColor),
          _buildDetailRow(Icons.local_post_office_outlined, "Post", _profile!.post, textColor, subTextColor),
          _buildDetailRow(Icons.pin_drop_outlined, "Pincode", _profile!.pincode, textColor, subTextColor),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _launchMaps,
              icon: const Icon(Icons.map, color: Colors.white),
              label: const Text("Open Location in Maps", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: subTextColor),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: subTextColor)),
                const SizedBox(height: 2),
                Text(
                    value.isEmpty || value == "null" ? "Not set" : value,
                    style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.w500)
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label, Color textColor, Color subTextColor) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
        Text(label, style: TextStyle(color: subTextColor, fontSize: 13)),
      ],
    );
  }

  Widget _buildProductTile(ProductModel product, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showProductDetails(product, theme),
      child: Container(
        decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.white, width: 0.5)
        ),
        child: Image.network(
          product.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(child: Icon(Icons.broken_image, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400));
          },
        ),
      ),
    );
  }

  void _showProductDetails(ProductModel product, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5, // Smaller initial size since no buttons
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 50, height: 5,
                      decoration: BoxDecoration(color: isDark ? Colors.grey.shade700 : Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                        child: Image.network(product.image, height: 250, width: double.infinity, fit: BoxFit.cover)
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(product.product_name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 5),
                  Text("Category: ${product.CATEGORY_NAME}", style: TextStyle(color: subTextColor)),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("₹ ${product.price}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: theme.primaryColor)),
                      // Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5)
                        ),
                        child: Text(
                          // Read Only Status
                            "Available",
                            style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text("Description", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 5),
                  Text(product.description, style: TextStyle(color: subTextColor, height: 1.5)),

                  const SizedBox(height: 20),
                  // NO EDIT/DELETE BUTTONS HERE
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- SHIMMER ---
  Widget _buildPageShimmer(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 40, backgroundColor: Colors.white),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(width: 40, height: 10, color: Colors.white),
                        Container(width: 40, height: 10, color: Colors.white),
                        Container(width: 40, height: 10, color: Colors.white),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Container(width: 150, height: 20, color: Colors.white),
              const SizedBox(height: 8),
              Container(width: 200, height: 12, color: Colors.white),
              const SizedBox(height: 20),
              Container(height: 35, width: double.infinity, color: Colors.white),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: 12,
                itemBuilder: (_, __) => Container(color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Models needed for this file
class DistributorProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profile_image;
  final String bio;
  final String address;
  final String place;
  final String pincode;
  final String post;
  final String latitude;
  final String longitude;
  final String proof;

  DistributorProfileModel(
      this.id, this.name, this.email, this.phone, this.profile_image,
      this.bio, this.address, this.place, this.pincode, this.post,
      this.latitude, this.longitude, this.proof
      );
}

class ProductModel {
  final String id;
  final String product_name;
  final String price;
  final String image;
  final String description;
  final String quantity;
  final String CATEGORY;
  final String CATEGORY_NAME;

  ProductModel(
      this.id, this.product_name, this.price, this.image,
      this.description, this.quantity, this.CATEGORY, this.CATEGORY_NAME
      );
}