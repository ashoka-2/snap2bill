

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import '../../Customerdirectory/Customersends/addOrder.dart';

class ViewDistributorProfile extends StatefulWidget {
  final String distributorId;
  final String distributorName;
  final bool fromProductCard;

  const ViewDistributorProfile({
    Key? key,
    required this.distributorId,
    this.distributorName = "Distributor Profile",
    this.fromProductCard = false,
  }) : super(key: key);

  @override
  State<ViewDistributorProfile> createState() => _ViewDistributorProfileState();
}

class _ViewDistributorProfileState extends State<ViewDistributorProfile> {
  DistributorProfileModel? _profile;
  List<ProductModel> _products = [];
  bool _isLoading = true;
  final PageController _pageController = PageController();
  int _activeTab = 0;
  bool _isCustomer = false;

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

  // ✅ Swipe-to-Reload function
  Future<void> _fetchAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    SharedPreferences sh = await SharedPreferences.getInstance();

    String? cid = sh.getString("cid");
    setState(() {
      _isCustomer = (cid != null && cid.isNotEmpty && cid != "null");
    });

    await Future.wait([_getProfile(), _getProducts()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _getProfile() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? ip = sh.getString("ip");
      var response = await http.post(Uri.parse("$ip/distributor_view_profile"), body: {"uid": widget.distributorId});
      var jsonData = json.decode(response.body);
      if (jsonData["data"] != null && jsonData["data"].isNotEmpty) {
        var item = jsonData["data"][0];
        setState(() {
          _profile = DistributorProfileModel(
            item["id"].toString(), item["name"].toString(), item["email"].toString(),
            item["phone"].toString(), (item["profile_image"] != null) ? "$ip${item["profile_image"]}" : "",
            item["bio"].toString(), item["address"].toString(), item["place"].toString(),
            item["pincode"].toString(), item["post"].toString(), item["latitude"].toString(),
            item["longitude"].toString(), "",
          );
        });
      }
    } catch (e) { debugPrint("Profile Error: $e"); }
  }

  Future<void> _getProducts() async {
    try {
      final sh = await SharedPreferences.getInstance();
      final base = sh.getString("ip") ?? "";
      final res = await http.post(Uri.parse("$base/distributor_products"), body: {"uid": widget.distributorId});
      if (res.statusCode == 200) {
        final js = json.decode(res.body);
        if (js is Map && js['status'] == 'ok' && js['data'] != null) {
          List<ProductModel> temp = [];
          for (final it in (js['data'] as List)) {
            temp.add(ProductModel(
              (it["id"] ?? "").toString(), (it["product_name"] ?? "").toString(),
              (it["price"] ?? "").toString(), "$base${it["image"]}",
              (it["description"] ?? "").toString(), (it["quantity"] ?? "").toString(),
              (it["CATEGORY"] ?? "").toString(), (it["CATEGORY_NAME"] ?? "").toString(),
            ));
          }
          setState(() => _products = temp);
        }
      }
    } catch (e) { debugPrint("Product Error: $e"); }
  }

  void _showImagePopup(BuildContext context, String imageUrl) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      pageBuilder: (context, _, __) => Scaffold(
        backgroundColor: Colors.black.withOpacity(0.9),
        body: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Hero(
              tag: 'popup_hero',
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
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0, centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_profile?.name ?? widget.distributorName, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchAllData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            // ✅ Profile Header - Part of the main scroll
            SliverToBoxAdapter(
              child: _buildProfileHeader(theme, textColor, isDark),
            ),
            // ✅ Tabs - Part of the main scroll
            SliverToBoxAdapter(
              child: _buildToggleTabs(isDark, theme),
            ),
            // ✅ Tab Content - Takes remaining space but scrolls as one
            SliverFillRemaining(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _activeTab = index),
                children: [
                  _products.isEmpty
                      ? const Center(child: Text("No products listed"))
                      : _buildProductGrid(theme),
                  SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(), // Scroll handled by sliver
                    child: _buildContactDetails(theme, textColor),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, Color textColor, bool isDark) {
    if (_profile == null) return const SizedBox();

    Widget profileImage = CircleAvatar(
      radius: 40,
      backgroundImage: NetworkImage(_profile!.profile_image),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _showImagePopup(context, _profile!.profile_image),
                child: widget.fromProductCard
                    ? Hero(tag: 'distributor_hero_${widget.distributorId}', child: profileImage)
                    : profileImage,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(label: "Products", count: _products.length.toString(), color: textColor),
                    _StatItem(label: "Customers", count: "0", color: textColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(_profile!.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
          if (_profile!.bio.isNotEmpty) Text(_profile!.bio, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => launchUrl(Uri(scheme: 'tel', path: _profile!.phone)),
                  icon: const Icon(Icons.call, size: 18), label: const Text("Call"),
                  style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => launchUrl(Uri.parse("whatsapp://send?phone=${_profile!.phone}")),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18), label: const Text("WhatsApp"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTabs(bool isDark, ThemeData theme) {
    return Column(children: [
      const Divider(height: 1),
      Row(children: [
        Expanded(
          child: InkWell(
              onTap: () => _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: _activeTab == 0 ? theme.primaryColor : Colors.transparent, width: 2))
                  ),
                  child: Icon(Icons.grid_on, color: _activeTab == 0 ? theme.primaryColor : Colors.grey)
              )
          ),
        ),
        Expanded(
          child: InkWell(
              onTap: () => _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: _activeTab == 1 ? theme.primaryColor : Colors.transparent, width: 2))
                  ),
                  child: Icon(Icons.info_outline, color: _activeTab == 1 ? theme.primaryColor : Colors.grey)
              )
          ),
        ),
      ]),
      const Divider(height: 1),
    ]);
  }

  Widget _buildProductGrid(ThemeData theme) {
    return GridView.builder(
      key: const PageStorageKey('distributor_product_grid'),
      padding: const EdgeInsets.all(2),
      physics: const NeverScrollableScrollPhysics(), // Scroll handled by CustomScrollView
      shrinkWrap: true,
      itemCount: _products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2),
      itemBuilder: (context, index) {
        final product = _products[index];
        return GestureDetector(
          onTap: () => _showProductDetails(product, theme),
          child: Container(
            color: Colors.grey[200],
            child: Image.network(product.image, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image)),
          ),
        );
      },
    );
  }

  Widget _buildContactDetails(ThemeData theme, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _InfoTile(icon: Icons.email_outlined, label: "Email", value: _profile!.email, color: textColor),
          _InfoTile(icon: Icons.phone_android, label: "Phone", value: _profile!.phone, color: textColor),
          _InfoTile(icon: Icons.business_outlined, label: "Address", value: _profile!.address, color: textColor),
          _InfoTile(icon: Icons.local_post_office_outlined, label: "Post", value: _profile!.post, color: textColor),
          _InfoTile(icon: Icons.pin_drop_outlined, label: "Pincode", value: _profile!.pincode, color: textColor),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=${_profile!.latitude},${_profile!.longitude}");
              if (await canLaunchUrl(url)) await launchUrl(url);
            },
            icon: const Icon(Icons.map, color: Colors.white),
            label: const Text("Open in Maps", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, minimumSize: const Size(double.infinity, 50)),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(ProductModel product, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.6, maxChildSize: 0.9,
        builder: (context, sc) => ListView(
          controller: sc, padding: const EdgeInsets.all(20),
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(product.image, height: 250, fit: BoxFit.contain)),
            const SizedBox(height: 20),
            Text(product.product_name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("₹ ${product.price}", style: TextStyle(fontSize: 20, color: theme.primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Available Quantity: ${product.quantity}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),
            Text("Description", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(product.description, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 30),

            if (_isCustomer)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    SharedPreferences sh = await SharedPreferences.getInstance();
                    await sh.setString("pid", product.id);
                    await sh.setString("uid", widget.distributorId);
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const addOrder()));
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text("Add to Cart"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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
    return Expanded(child: InkWell(onTap: onTap, child: Container(height: 50, child: Icon(icon, color: isActive ? Colors.blueAccent : Colors.grey))));
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _InfoTile({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 20), child: Row(children: [Icon(icon, color: Colors.blueAccent), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)), Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color))])]));
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