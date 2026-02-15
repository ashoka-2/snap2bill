import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/dataModels.dart';

class ProductService {

  // ---------------- CUSTOMER PRODUCTS ----------------
  static Future<List<ProductData>> customerProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ip = prefs.getString("ip") ?? "";
      final cid = prefs.getString("cid") ?? "";

      final res = await http.post(
        Uri.parse("$ip/customer_view_products"),
        body: {'cid': cid},
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        if (jsonData['status'] == 'ok' && jsonData['data'] != null) {
          return _map(jsonData['data'], ip);
        }
      }
      return []; // Agar error ho toh empty list bhejo (Crash nahi hoga)
    } catch (e) {
      print("Error fetching customer products: $e");
      return [];
    }
  }

  // ---------------- DISTRIBUTOR PRODUCTS ----------------
  static Future<List<ProductData>> distributorProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ip = prefs.getString("ip") ?? "";
      final uid = prefs.getString("uid") ?? "";

      // 🚀 IMPORTANT: Ensure karein ki ye wahi URL hai jahan humne
      // Django mein 'is_liked' logic lagaya tha.
      final res = await http.post(
        Uri.parse("$ip/view_other_products"),
        body: {'uid': uid},
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        if (jsonData['status'] == 'ok' && jsonData['data'] != null) {
          return _map(jsonData['data'], ip);
        }
      }
      return [];
    } catch (e) {
      print("Error fetching distributor products: $e");
      return [];
    }
  }

  // ---------------- MAPPER ----------------
  static List<ProductData> _map(List data, String ip) {
    return data.map((e) => ProductData.fromJson(e, ip)).toList();
  }
}
