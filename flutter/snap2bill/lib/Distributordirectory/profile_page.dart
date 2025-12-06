import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // Standard for opening maps

// Import your edit pages
import 'package:snap2bill/Distributordirectory/Editfolder/edit_distributor_profile.dart';
import 'package:snap2bill/Distributordirectory/Editfolder/editStock.dart';

class distributor_profile_page extends StatefulWidget {
  const distributor_profile_page({Key? key}) : super(key: key);

  @override
  State<distributor_profile_page> createState() => _distributor_profile_pageState();
}

class _distributor_profile_pageState extends State<distributor_profile_page> {
  // Data Holders
  DistributorProfileModel? _profile;
  List<ProductModel> _products = [];
  bool _isLoading = true;
  bool _isDeleting = false;

  // Toggle State: False = Grid View, True = Info/Details View
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  // --- DATA FETCHING ---
  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
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
      String? uid = prefs.getString("uid");

      if (ip == null || uid == null) return;

      var response = await http.post(
        Uri.parse("$ip/distributor_view_profile"),
        body: {"uid": uid},
      );

      var jsonData = json.decode(response.body);
      if (jsonData["data"] != null && jsonData["data"].isNotEmpty) {
        var item = jsonData["data"][0];

        // Handle profile image URL safely
        String imgUrl = "";
        if (item["profile_image"] != null && item["profile_image"] != "null") {
          imgUrl = "$ip${item["profile_image"]}";
        }

        String proofUrl = "";
        if (item["proof"] != null && item["proof"] != "null") {
          proofUrl = "$ip${item["proof"]}";
        }

        setState(() {
          _profile = DistributorProfileModel(
            item["id"].toString(),
            item["name"].toString(),
            item["email"].toString(),
            item["phone"].toString(),
            imgUrl, // Cleaned URL
            item["bio"].toString(),
            item["address"].toString(),
            item["place"].toString(),
            item["pincode"].toString(),
            item["post"].toString(),
            item["latitude"].toString(),
            item["longitude"].toString(),
            proofUrl,
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
      final uid = prefs.getString("uid") ?? "";

      final uri = Uri.parse("$base/distributor_products");
      final res = await http.post(uri, body: {"uid": uid});

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

    final lat = _profile!.latitude;
    final lng = _profile!.longitude;

    // Create Google Maps URL
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    if (_isLoading) {
      return Scaffold(backgroundColor: theme.scaffoldBackgroundColor, body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          _profile?.name ?? "Profile",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: Icon(Icons.menu, color: textColor), onPressed: (){}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAllData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. PROFILE HEADER
            SliverToBoxAdapter(
              child: _buildProfileHeader(theme, textColor),
            ),

            // 2. TOGGLE TABS (Grid vs Info)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Divider(height: 1, color: Colors.grey.shade300),
                  SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Grid Button (Products)
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _showDetails = false),
                            child: Icon(
                                Icons.grid_on,
                                color: !_showDetails ? textColor : Colors.grey.shade400
                            ),
                          ),
                        ),
                        // Info Button (Details)
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _showDetails = true),
                            child: Icon(
                                Icons.info_outline,
                                color: _showDetails ? textColor : Colors.grey.shade400
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                ],
              ),
            ),

            // 3. CONTENT AREA (Switch between Details or Grid)
            if (_showDetails)
            // --- VIEW A: CONTACT DETAILS ---
              SliverToBoxAdapter(
                child: _buildContactDetails(theme, textColor),
              )
            else
            // --- VIEW B: PRODUCT GRID ---
              _products.isEmpty
                  ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      const Text(
                        "No products found add new products",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
                  : SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return _buildProductTile(_products[index]);
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

  Widget _buildProfileHeader(ThemeData theme, Color textColor) {
    if (_profile == null) return const SizedBox();

    // Check if image exists
    bool hasImage = _profile!.profile_image.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: hasImage ? NetworkImage(_profile!.profile_image) : null,
                  // If no image, show default icon
                  child: !hasImage ? Icon(Icons.person, size: 40, color: Colors.grey.shade400) : null,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(_products.length.toString(), "Products", textColor),
                    _buildStatColumn("0", "Sold", textColor),
                    _buildStatColumn("4.5", "Rating", textColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            _profile!.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
          ),
          if (_profile!.bio.isNotEmpty && _profile!.bio != "null")
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(_profile!.bio, style: TextStyle(color: textColor)),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(
              "${_profile!.place}",
              style: TextStyle(color: Colors.blue.shade800, fontSize: 13),
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                    "Edit Profile",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => edit_distributor_profile_sub(
                        id: _profile!.id,
                        name: _profile!.name,
                        email: _profile!.email,
                        phone: _profile!.phone,
                        bio: _profile!.bio,
                        address: _profile!.address,
                        place: _profile!.place,
                        pincode: _profile!.pincode,
                        post: _profile!.post,
                        latitude: _profile!.latitude,
                        longitude: _profile!.longitude,
                      )));
                    },
                    theme: theme, textColor: textColor
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                    "View Proof",
                    onTap: () => _showProofDialog(_profile!.proof),
                    theme: theme, textColor: textColor
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- NEW: CONTACT DETAILS WIDGET ---
  Widget _buildContactDetails(ThemeData theme, Color textColor) {
    if (_profile == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Contact Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          _buildDetailRow(Icons.email_outlined, "Email", _profile!.email, textColor),
          _buildDetailRow(Icons.phone_android, "Phone", _profile!.phone, textColor),
          _buildDetailRow(Icons.location_on_outlined, "Address", _profile!.address, textColor),
          _buildDetailRow(Icons.local_post_office_outlined, "Post", _profile!.post, textColor),
          _buildDetailRow(Icons.pin_drop_outlined, "Pincode", _profile!.pincode, textColor),

          const SizedBox(height: 30),

          // MAP BUTTON
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _launchMaps,
              icon: const Icon(Icons.map, color: Colors.white),
              label: const Text("Open Location in Maps", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
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

  Widget _buildStatColumn(String count, String label, Color textColor) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
        Text(label, style: TextStyle(color: textColor, fontSize: 13)),
      ],
    );
  }

  Widget _buildActionButton(String label, {required VoidCallback onTap, required ThemeData theme, required Color textColor}) {
    return SizedBox(
      height: 32,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: theme.cardColor,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Text(label, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildProductTile(ProductModel product) {
    return GestureDetector(
      onTap: () => _showProductDetails(product),
      child: Container(
        color: Colors.grey.shade200,
        child: Image.network(
          product.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
          },
        ),
      ),
    );
  }

  void _showProofDialog(String url) {
    if (url.isEmpty || url.endsWith("null")) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No proof document available")));
      return;
    }
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(url, fit: BoxFit.contain, errorBuilder: (c,e,s)=>Container(color:Colors.white, padding:EdgeInsets.all(20), child: Text("Error loading proof"))),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 50, height: 5,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(product.image, height: 250, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 20),

                  Text(product.product_name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Category: ${product.CATEGORY_NAME}", style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("₹ ${product.price}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.indigo)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(5)),
                        child: Text("Stock: ${product.quantity}", style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(product.description, style: TextStyle(color: Colors.grey[700])),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => editStock(
                              id: product.id,
                              price: product.price,
                              quantity: product.quantity,
                            )));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: const Text("Edit Stock"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Add delete logic call here if needed, or implement locally in this file
                          },
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                          child: const Text("Delete"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ------------------------------------------------------------------
// REQUIRED DATA MODELS
// ------------------------------------------------------------------

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