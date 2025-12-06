import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Import your addStock page
import '../addfolder/addStock.dart';

class view_product extends StatelessWidget {
  const view_product({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const view_product_sub();
  }
}

class view_product_sub extends StatefulWidget {
  const view_product_sub({Key? key}) : super(key: key);

  @override
  State<view_product_sub> createState() => _view_product_subState();
}

class _view_product_subState extends State<view_product_sub> {
  // --- API LOGIC ---
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
          (it["quantity"] ?? "").toString(),
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
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          "All Products",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Joke>>(
        future: _getProducts(),
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

          // 2-COLUMN GRID
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two items per row
              childAspectRatio: 0.75, // Taller cards (Instagram reel/story ratio)
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              return _buildGridCard(items[index], theme);
            },
          );
        },
      ),
    );
  }

  Widget _buildGridCard(Joke i, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // 1. IMAGE BACKGROUND
            Positioned.fill(
              child: i.image.isEmpty
                  ? Container(
                color: theme.dividerColor,
                child: Icon(Icons.image, color: theme.disabledColor),
              )
                  : Image.network(
                i.image,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Container(
                  color: theme.dividerColor,
                  child: Icon(Icons.broken_image, color: theme.disabledColor),
                ),
              ),
            ),

            // 2. GRADIENT OVERLAY (For text readability)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),

            // 3. TEXT DETAILS (Bottom Left)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    i.product_name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Qty: ${i.quantity}",
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),

            // 4. THREE DOT MENU (Top Right)
            Positioned(
              top: 5,
              right: 5,
              child: PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert, color: Colors.white, size: 18),
                ),
                color: theme.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'add') {
                    _navigateToAddStock(i);
                  } else if (value == 'details') {
                    _showProductDetails(i, theme);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'add',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Add Stock'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('View Details'),
                      ],
                    ),
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => addStock()));
  }

  void _showProductDetails(Joke i, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(i.product_name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
              const SizedBox(height: 10),
              Text("Category: ${i.CATEGORY_NAME}", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              const SizedBox(height: 10),
              Text("Description:", style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
              Text(i.description, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToAddStock(i);
                  },
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
  final String quantity;
  final String CATEGORY;
  final String CATEGORY_NAME;

  Joke(
      this.id,
      this.product_name,
      this.image,
      this.description,
      this.quantity,
      this.CATEGORY,
      this.CATEGORY_NAME,
      );
}