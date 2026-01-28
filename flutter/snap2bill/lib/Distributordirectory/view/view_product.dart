import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Navigation targets
import '../../theme/colors.dart';
import '../../widgets/SearchBar.dart';
import '../distributorsends/addStock.dart';
// Custom Search Bar Widget

class ViewProduct extends StatelessWidget {
  const ViewProduct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ViewProductSub();
  }
}

class ViewProductSub extends StatefulWidget {
  const ViewProductSub({Key? key}) : super(key: key);

  @override
  State<ViewProductSub> createState() => _ViewProductSubState();
}

class _ViewProductSubState extends State<ViewProductSub> {
  String _searchQuery = "";
  late Future<List<Joke>> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _getProducts();
  }

  // --- API LOGIC (Unchanged) ---
  Future<List<Joke>> _getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final base = prefs.getString("ip") ?? "";
    final uid = prefs.getString("uid");

    if (base.isEmpty || uid == null || uid.isEmpty) return [];

    try {
      final uri = Uri.parse("$base/distributor_view_product");
      final res = await http.post(uri, body: {"uid": uid});

      if (res.statusCode != 200) throw Exception("HTTP ${res.statusCode}");

      final js = json.decode(res.body);
      if (js is! Map || js['status'] != 'ok' || js['data'] == null) return [];

      final List<Joke> out = [];
      for (final it in (js['data'] as List)) {
        out.add(Joke(
          (it["id"] ?? "").toString(),
          (it["product_name"] ?? "").toString(),
          _joinUrl(base, (it["image"] ?? "").toString()),
          (it["description"] ?? "").toString(),
          // (it["quantity"] ?? "").toString(),
          (it["CATEGORY"] ?? "").toString(),
          (it["CATEGORY_NAME"] ?? "").toString(),
        ));
      }
      return out;
    } catch (e) {
      debugPrint("Error: $e");
      return [];
    }
  }

  String _joinUrl(String base, String path) {
    if (path.isEmpty || path == "null") return "";
    if (base.endsWith("/") && path.startsWith("/")) return base + path.substring(1);
    if (!base.endsWith("/") && !path.startsWith("/")) return "$base/$path";
    return base + path;
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F9F9);

    return GestureDetector(
      // Keyboard closes when clicking outside the search bar
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bgColor,
        // 🚀 CUSTOM SEARCH APPBAR WITH BACK BUTTON
        appBar: SearchAppBar(
          hintText: "Search products or categories...",
          onLeadingPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        body: FutureBuilder<List<Joke>>(
          future: _productFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: theme.primaryColor));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error loading products", style: TextStyle(color: theme.colorScheme.error)));
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.grid_off, size: 60, color: theme.disabledColor),
                    const SizedBox(height: 10),
                    Text("No products available", style: TextStyle(color: theme.disabledColor)),
                  ],
                ),
              );
            }

            // 🚀 SEARCH FILTERING LOGIC (Name or Category)
            final filteredList = items.where((it) {
              return it.product_name.toLowerCase().contains(_searchQuery) ||
                  it.CATEGORY_NAME.toLowerCase().contains(_searchQuery);
            }).toList();

            if (filteredList.isEmpty) {
              return const Center(child: Text("No products match your search"));
            }

            // --- PINTEREST (MASONRY) LAYOUT ---
            return MasonryGridView.count(
              padding: const EdgeInsets.all(12),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return _buildPinterestCard(filteredList[index], isDark);
              },
            );
          },
        ),
      ),
    );
  }

  // Two-Container Style + Masonry Sizing
  Widget _buildPinterestCard(Joke i, bool isDark) {
    final topContainerColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF3E5D8);
    final bottomContainerColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? AppColors.WhiteColor: Colors.black;

    return InkWell(
      onTap: () {
        _navigateToAddStock(i);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: bottomContainerColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. IMAGE CONTAINER (Top)
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
                      height: 120,
                      child: Icon(Icons.image_not_supported, color: Colors.grey.shade400, size: 40),
                    )
                        : Image.network(
                      i.image,
                      fit: BoxFit.fitWidth,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 120,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (c, o, s) => Container(
                        height: 120,
                        child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white.withValues(alpha:0.6),
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_horiz, size: 18, color: Colors.black),
                        onSelected: (value) {
                          if (value == 'add') {
                            _navigateToAddStock(i);
                          } else if (value == 'details') {
                            _showProductDetails(i, isDark);
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                           PopupMenuItem<String>(
                            value: 'add',
                            child: Row(
                              children: [
                                Icon(Icons.add_circle_outline, color: AppColors.getPrimaryColor(context), size: 18),
                                SizedBox(width: 8),
                                Text('Add Stock'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'details',
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.grey, size: 18),
                                SizedBox(width: 8),
                                Text('Details'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. DETAILS CONTAINER (Bottom)
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
                      letterSpacing: 0,
                      height: 1
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    i.CATEGORY_NAME,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                  // const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          // color: isDark ? Colors.white.withValues(alpha:0.1) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text("",
                          // "Qty: ${i.quantity}",
                          style: TextStyle(
                            color: textColor.withValues(alpha:0.8),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.WhiteColor: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: isDark ? AppColors.BlackColor: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddStock(Joke i) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("pid", i.id);
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddStock()));
  }

  void _showProductDetails(Joke i, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final textColor = isDark ? AppColors.WhiteColor: Colors.black;
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(i.product_name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 10),
              Text("Category: ${i.CATEGORY_NAME}", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              Text("Description:", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              Text(i.description, style: TextStyle(color: textColor.withValues(alpha:0.8))),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToAddStock(i);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.WhiteColor: Colors.black,
                    foregroundColor: isDark ? AppColors.BlackColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Add Stock Now"),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

// Data Model
class Joke {
  final String id;
  final String product_name;
  final String image;
  final String description;
  // final String quantity;
  final String CATEGORY;
  final String CATEGORY_NAME;

  Joke(
      this.id,
      this.product_name,
      this.image,
      this.description,
      // this.quantity,
      this.CATEGORY,
      this.CATEGORY_NAME,
      );
}