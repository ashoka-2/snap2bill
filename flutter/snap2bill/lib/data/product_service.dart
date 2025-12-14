import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dataModels.dart';

class ProductService {
  /// ---------------- CUSTOMER PRODUCTS ----------------
  static Future<List<ProductData>> customerProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String ip = prefs.getString("ip") ?? "";

    if (ip.isEmpty) return [];

    try {
      final res = await http.post(
        Uri.parse("$ip/customer_view_products"),
      );

      if (res.statusCode != 200) return [];

      final jsonData = jsonDecode(res.body);

      if (jsonData["data"] == null) return [];

      return _map(jsonData["data"], ip);
    } catch (e) {
      return [];
    }
  }

  /// ---------------- DISTRIBUTOR PRODUCTS ----------------
  static Future<List<ProductData>> distributorProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String ip = prefs.getString("ip") ?? "";
    final String uid = prefs.getString("uid") ?? "";

    if (ip.isEmpty || uid.isEmpty) return [];

    try {
      final res = await http.post(
        Uri.parse("$ip/view_other_products"),
        body: {"uid": uid},
      );

      if (res.statusCode != 200) return [];

      final jsonData = jsonDecode(res.body);

      if (jsonData["data"] == null) return [];

      return _map(jsonData["data"], ip);
    } catch (e) {
      return [];
    }
  }

  /// ---------------- MAPPER (SINGLE SOURCE OF TRUTH) ----------------
  static List<ProductData> _map(List data, String ip) {
    return data
        .map<ProductData>(
          (item) => ProductData.fromJson(item, ip),
    )
        .toList();
  }
}
