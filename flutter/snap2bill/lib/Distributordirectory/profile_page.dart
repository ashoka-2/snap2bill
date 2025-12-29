
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