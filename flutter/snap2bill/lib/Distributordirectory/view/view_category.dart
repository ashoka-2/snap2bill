import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/colors.dart';
import '../../widgets/Navbar.dart';
import '../../widgets/SnackBar.dart';

class ViewCategory extends StatefulWidget {
  const ViewCategory({Key? key}) : super(key: key);

  @override
  State<ViewCategory> createState() => _ViewCategoryState();
}

class _ViewCategoryState extends State<ViewCategory> {

  // --- API Logic ---
  Future<List<Joke>> _getCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString("ip");

    if (ip == null) return [];

    try {
      var data = await http.post(
          Uri.parse("$ip/view_category"),
          body: {} // Sending empty body as per your original code
      );

      if (data.statusCode != 200) {
        debugPrint("Error fetching data: ${data.statusCode}");
        return [];
      }

      var jsonData = json.decode(data.body);

      if (jsonData["data"] == null) return [];

      List<Joke> categories = [];
      for (var item in jsonData["data"]) {
        Joke newCategory = Joke(
          (item["id"] ?? "").toString(),
          (item["category_name"] ?? "").toString(),
        );
        categories.add(newCategory);
      }
      return categories;
    } catch (e) {
      debugPrint("Error: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Theme Handling ---
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Design Colors
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? AppColors.WhiteColor: Colors.black87;
    final cardColor = theme.cardColor;
    final hintColor = isDark ? Colors.white38 : Colors.grey[500];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: ThemeNavbar(title: "All Categories",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: ()=>{
          if (Navigator.canPop(context)) Navigator.pop(context)
        },
        centerTitle: true,

      ),
      body: FutureBuilder<List<Joke>>(
        future: _getCategories(),
        builder: (BuildContext context, AsyncSnapshot<List<Joke>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading categories", style: TextStyle(color: textColor)));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 80, color: hintColor),
                  const SizedBox(height: 16),
                  Text(
                    "No categories found",
                    style: TextStyle(color: hintColor, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Modern Grid Layout
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 Items per row
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1, // Slightly wider than tall
            ),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              var i = items[index];
              return _buildCategoryCard(i, cardColor, textColor, isDark);
            },
          );
        },
      ),
    );
  }

  // --- Beautiful Tile Design ---
  Widget _buildCategoryCard(Joke i, Color cardColor, Color textColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark? Colors.black.withValues(alpha:0.3): Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {

          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Circle
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha:0.1) : Colors.indigo.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.grid_view_rounded, // Generic category icon
                  color: isDark ? AppColors.WhiteColor: Colors.indigo,
                  size: 24,
                ),
              ),
              const SizedBox(height: 15),

              // Category Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  i.category_name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Keeping your Model name as per request
class Joke {
  final String id;
  final String category_name;
  Joke(this.id, this.category_name);
}