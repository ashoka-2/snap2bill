import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Customerdirectory/Customersends/addOrder.dart';

class ViewWishlist extends StatefulWidget {
  const ViewWishlist({Key? key}) : super(key: key);

  @override
  State<ViewWishlist> createState() => _ViewWishlistState();
}

class _ViewWishlistState extends State<ViewWishlist> {
  List _wishlistItems = [];
  bool _isLoading = true;

  String _baseUrl = "";
  String? _cid; // customer id
  String? _uid; // distributor id

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  // ---------------- IMAGE URL JOINER ----------------
  String _joinUrl(String base, String path) {
    if (base.isEmpty || path.isEmpty || path == "null") return "";
    if (path.startsWith("http")) return path;

    if (base.endsWith("/") && path.startsWith("/")) {
      return base + path.substring(1);
    }
    if (!base.endsWith("/") && !path.startsWith("/")) {
      return "$base/$path";
    }
    return base + path;
  }

  // ---------------- FETCH WISHLIST ----------------
  Future<void> _fetchWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _baseUrl = prefs.getString("ip") ?? "";
      _cid = prefs.getString("cid");
      _uid = prefs.getString("uid");

      if (_baseUrl.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      Map<String, String> body = {};

      // 🔒 STRICT ROLE CHECK
      if (_cid != null && _cid!.isNotEmpty && (_uid == null || _uid!.isEmpty)) {
        body['cid'] = _cid!;
      } else if (_uid != null && _uid!.isNotEmpty && (_cid == null || _cid!.isEmpty)) {
        body['uid'] = _uid!;
      }

      final res = await http.post(
        Uri.parse("$_baseUrl/view_wishlist"),
        body: body,
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        setState(() {
          _wishlistItems = jsonData['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ---------------- REMOVE FROM WISHLIST ----------------
  Future<void> _removeItem(String wid) async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString("ip") ?? "";

    Map<String, String> body = {'wid': wid};

    if (_cid != null && _cid!.isNotEmpty) {
      body['cid'] = _cid!;
    } else if (_uid != null && _uid!.isNotEmpty) {
      body['uid'] = _uid!;
    }

    await http.post(
      Uri.parse("$ip/remove_from_wishlist"),
      body: body,
    );

    _fetchWishlist();
  }

  // ---------------- ERROR IMAGE ----------------
  Widget _errorImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey.shade300,
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    // ✅ CUSTOMER ONLY
    final bool isCustomer =
        _cid != null && _cid!.isNotEmpty && (_uid == null || _uid!.isEmpty);

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
          final item = _wishlistItems[index];
          final imageUrl = _joinUrl(_baseUrl, item['image'] ?? "");

          return Card(
            key: ValueKey(item['wishlist_id'].toString()),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _errorImage(),
                    )
                        : _errorImage(),
                  ),
                  const SizedBox(width: 12),

                  // DETAILS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['product_name'] ?? "No Name",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                        Text(
                          item['category_name'] ?? "",
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${item['price']}",
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "By: ${item['distributor_name']}",
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),

                  // ACTIONS
                  Column(
                    children: [
                      // REMOVE
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: () => _removeItem(
                            item['wishlist_id'].toString()),
                      ),

                      // 🛒 ADD TO CART (ONLY CUSTOMER)
                      if (isCustomer)
                        IconButton(
                          icon: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.green),
                          onPressed: () async {
                            final prefs =
                            await SharedPreferences.getInstance();
                            prefs.setString(
                                "pid", item['id'].toString());

                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const addOrder()),
                            ).then((_) => _fetchWishlist());
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
