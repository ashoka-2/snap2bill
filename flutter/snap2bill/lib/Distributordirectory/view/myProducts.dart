import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Imports from your project structure
import 'package:snap2bill/Distributordirectory/Editfolder/edit_product.dart';
import '../../theme/theme.dart';
import '../Editfolder/editStock.dart';

class myProducts extends StatelessWidget {
  const myProducts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const myProductsSub();
  }
}

class myProductsSub extends StatefulWidget {
  const myProductsSub({Key? key}) : super(key: key);

  @override
  State<myProductsSub> createState() => _myProductsSubState();
}

class _myProductsSubState extends State<myProductsSub> {
  bool _isDeleting = false;

  // --- API LOGIC (Unchanged) ---
  Future<List<Joke>> _getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final base = prefs.getString("ip") ?? "";
    final uid = prefs.getString("uid");

    if (base.isEmpty) throw Exception("Missing base URL (ip).");
    if (uid == null || uid.isEmpty) throw Exception("Missing distributor id (uid).");

    final uri = Uri.parse("$base/distributor_products");
    final res = await http.post(uri, body: {"uid": uid});

    if (res.statusCode != 200) throw Exception("HTTP ${res.statusCode}: ${res.body}");

    final js = json.decode(res.body);
    if (js is! Map || js['status'] != 'ok' || js['data'] == null) {
      final msg = (js is Map && js['message'] != null) ? js['message'].toString() : "Unexpected response";
      throw Exception(msg);
    }

    final List<Joke> out = [];
    for (final it in (js['data'] as List)) {
      out.add(Joke(
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
    return out;
  }

  String _joinUrl(String base, String path) {
    if (path.isEmpty) return "";
    if (base.endsWith("/") && path.startsWith("/")) return base + path.substring(1);
    if (!base.endsWith("/") && !path.startsWith("/")) return "$base/$path";
    return base + path;
  }

  Future<void> _deleteProduct(String pid) async {
    if (_isDeleting) return;

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final ip = prefs.getString("ip") ?? "";
      final senderId = prefs.getString("id") ?? prefs.getString("uid") ?? "";

      final uri = Uri.parse("$ip/delete_distributor_product/$pid");
      final res = await http.post(uri, body: {'id': senderId});

      if (res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted successfully')));
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.instance.isDarkMode;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F9F9);
    final titleColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: titleColor, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          "My Products",
          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: FutureBuilder<List<Joke>>(
        future: _getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No products found"),
                ],
              ),
            );
          }

          // --- PINTEREST / MASONRY LAYOUT ---
          return MasonryGridView.count(
            padding: const EdgeInsets.all(12),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildPinterestCard(items[index], isDark);
            },
          );
        },
      ),
    );
  }

  // A card that sizes itself based on image height + content
  Widget _buildPinterestCard(Joke i, bool isDark) {
    final topContainerColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF3E5D8);
    final bottomContainerColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: bottomContainerColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [

          // 1. IMAGE CONTAINER
          Container(
            decoration: BoxDecoration(
              color: topContainerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: i.image.isEmpty
                      ? Container(
                    height: 150,
                    child: Icon(Icons.image_not_supported, color: Colors.grey.shade400, size: 40),
                  )
                      : Image.network(
                    i.image,
                    fit: BoxFit.fitWidth,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (c, o, s) => Container(
                      height: 150,
                      child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                    ),
                  ),
                ),

                // 3-Dot Menu
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white.withOpacity(0.6),
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_horiz, size: 18, color: Colors.black),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          // Open edit screen and wait for result
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => editStock(
                                id: i.id.toString(),
                                price: i.price.toString(),
                                quantity: i.quantity.toString(),
                              ),
                            ),
                          );

                          // If edit returned 'refresh', trigger a reload in this page
                          if (result == 'refresh') {
                            if (mounted) setState(() {
                              // Calling setState will re-run FutureBuilder -> _getProducts()
                            });
                          }
                        } else if (value == 'delete') {
                          _deleteProduct(i.id);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: ThemeService.instance.isDarkMode ? Colors.white : Colors.black),
                              const SizedBox(width: 8),
                              Text('Edit', style: TextStyle(color: ThemeService.instance.isDarkMode ? Colors.white : Colors.black)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    )

                  ),
                ),
              ],
            ),
          ),

          // 2. DETAILS CONTAINER
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  i.product_name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  i.CATEGORY_NAME,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
                const SizedBox(height: 12),

                // --- PRICE & QUANTITY ROW ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹${i.price}",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // QUANTITY PILL
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Qty: ${i.quantity}",
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Add Button
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Added to bill"), duration: Duration(milliseconds: 600)));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8), // Slightly larger for touch target
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: isDark ? Colors.black : Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Joke {
  final String id;
  final String product_name;
  final String price;
  final String image;
  final String description;
  final String quantity;
  final String CATEGORY;
  final String CATEGORY_NAME;

  Joke(
      this.id,
      this.product_name,
      this.price,
      this.image,
      this.description,
      this.quantity,
      this.CATEGORY,
      this.CATEGORY_NAME,
      );
}