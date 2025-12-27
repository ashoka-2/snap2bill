import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/dataModels.dart';

class ProductService {

  static Future<List<ProductData>> customerProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString("ip") ?? "";
    final cid = prefs.getString("cid") ?? "";

    final res = await http.post(
      Uri.parse("$ip/customer_view_products"),
      body: {'cid': cid},
    );

    final jsonData = jsonDecode(res.body);
    return _map(jsonData['data'], ip);
  }

  static Future<List<ProductData>> distributorProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString("ip") ?? "";
    final uid = prefs.getString("uid") ?? "";

    final res = await http.post(
      Uri.parse("$ip/view_other_products"),
      body: {'uid': uid},
    );

    final jsonData = jsonDecode(res.body);
    return _map(jsonData['data'], ip);
  }

  static List<ProductData> _map(List data, String ip) {
    return data.map((e) => ProductData.fromJson(e, ip)).toList();
  }
}
