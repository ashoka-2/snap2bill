import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dataModels.dart';

class CategoryService {
  static Future<List<CategoryData>> fetchCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String ip = prefs.getString("ip") ?? "";

    // Always include "All"
    List<CategoryData> categories = [
      CategoryData(id: "All", name: "All"),
    ];

    if (ip.isEmpty) return categories;

    try {
      final res = await http.post(
        Uri.parse("$ip/view_category"),
      );

      if (res.statusCode != 200) return categories;

      final jsonData = jsonDecode(res.body);

      if (jsonData["data"] == null) return categories;

      for (var item in jsonData["data"]) {
        categories.add(CategoryData.fromJson(item));
      }
    } catch (e) {
      // Fail silently, UI still works with "All"
    }

    return categories;
  }
}
