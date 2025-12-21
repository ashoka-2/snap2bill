import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/theme/colors.dart';
import '../Customerdirectory/Customersends/addOrder.dart';

class ViewWishlist extends StatefulWidget {
  const ViewWishlist({Key? key}) : super(key: key);

  @override
  State<ViewWishlist> createState() => _ViewWishlistState();
}

class _ViewWishlistState extends State<ViewWishlist> {
  List _wishlistItems = [];
  bool _isLoading = true;
  String _baseUrl = ""; // IP address store karne ke liye

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  // ---------- Image URL Helper (Same as your DataModel logic) ----------
  String _joinUrl(String base, String path) {
    if (path.isEmpty || path == "null" || base.isEmpty) return "";
    if (path.startsWith("http")) return path;

    if (base.endsWith("/") && path.startsWith("/")) {
      return base + path.substring(1);
    }
    if (!base.endsWith("/") && !path.startsWith("/")) {
      return "$base/$path";
    }
    return base + path;
  }

  // ---------- Fetch Wishlist Data ----------
  Future<void> _fetchWishlist() async {
    // Note: Sirf pehli baar loading dikhayenge, refresh par smooth update ke liye list reset nahi karenge
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? ip = sh.getString("ip");
      _baseUrl = ip ?? "";

      String? cid = sh.getString("cid"); // Customer ID
      String? uid = sh.getString("uid"); // Distributor ID

      var response = await http.post(
        Uri.parse("$ip/view_wishlist"),
        body: {
          'cid': cid ?? "",
          'uid': uid ?? "",
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (mounted) {
          setState(() {
            _wishlistItems = jsonData['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showSnackBar("Connection Error", Colors.red);
    }
  }

  // ---------- Remove Item from Wishlist ----------
  Future<void> _removeItem(String wid) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? ip = sh.getString("ip");

      var response = await http.post(
        Uri.parse("$ip/remove_from_wishlist"),
        body: {'wid': wid},
      );

      if (response.statusCode == 200) {
        _showSnackBar("Removed from Wishlist", Colors.grey);
        // List refresh karein
        _fetchWishlist();
      }
    } catch (e) {
      _showSnackBar("Error removing item", Colors.red);
    }
  }

  // ---------- Snackbar ----------
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(milliseconds: 800)
      ),
    );
  }

  // Error image placeholder
  Widget _errorImage() {
    return Container(
      width: 80, height: 80,
      color: Colors.grey.shade300,
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wishlist"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wishlistItems.isEmpty
          ? const Center(child: Text("Your wishlist is empty"))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _wishlistItems.length,
        itemBuilder: (context, index) {
          var item = _wishlistItems[index];
          String fullImageUrl = _joinUrl(_baseUrl, item['image'] ?? "");

          return Card(
            // ✅ CRITICAL FIX: ValueKey use kiya taaki ListView items refresh ke waqt crash na hon
            key: ValueKey(item['wishlist_id'].toString()),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: fullImageUrl.isNotEmpty
                        ? Image.network(
                      fullImageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _errorImage(),
                    )
                        : _errorImage(),
                  ),
                  const SizedBox(width: 12),

                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            item['product_name'] ?? "No Name",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)
                        ),
                        Text(
                            item['category_name'] ?? "General",
                            style: const TextStyle(color: Colors.grey, fontSize: 12)
                        ),
                        const SizedBox(height: 4),
                        Text(
                            "₹${item['price']}",
                            style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 15)
                        ),
                        Text(
                            "By: ${item['distributor_name']}",
                            style: const TextStyle(fontSize: 11, color: Colors.blueGrey)
                        ),
                      ],
                    ),
                  ),

                  // Actions (Remove & Add to Cart)
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _removeItem(item['wishlist_id'].toString()),
                        tooltip: "Remove",
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          // Stock ID set kar rahe hain order ke liye
                          prefs.setString("pid", item['id'].toString());

                          if (!mounted) return;
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const addOrder())
                          ).then((_) {
                            // Agar cart se wapis aayein toh list refresh kar saken
                            _fetchWishlist();
                          });
                        },
                        tooltip: "Add to Cart",
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}