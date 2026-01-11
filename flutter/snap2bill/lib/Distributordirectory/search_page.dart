

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../screens/viewCustomerProfile.dart';
import '../screens/viewDistributorProfile.dart';
import '../widgets/CustomerNavigationBar.dart';
import '../widgets/SearchBar.dart';
import '../Customerdirectory/Customersends/addOrder.dart';
import '../Distributordirectory/customer_page.dart'; // Joke model
import '../widgets/distributorNavigationbar.dart';

class search_page extends StatefulWidget {
  const search_page({Key? key}) : super(key: key);

  @override
  State<search_page> createState() => _search_pageState();
}

class _search_pageState extends State<search_page> {
  List<dynamic> _results = [];
  bool _loading = false;
  String _query = "";
  Timer? _debounce;

  String ip = "";
  String? cid;
  String? uid;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    ip = prefs.getString("ip") ?? "";
    cid = prefs.getString("cid");
    uid = prefs.getString("uid");
    _fetchData("");
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      setState(() => _query = value);
      _fetchData(value);
    });
  }

  Future<void> _fetchData(String query) async {
    setState(() => _loading = true);
    final res = await http.get(Uri.parse("$ip/universal_search?q=$query"));
    if (res.statusCode == 200) {
      final js = json.decode(res.body);
      if (js['status'] == 'ok') {
        setState(() {
          _results = js['data'] ?? [];
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: SearchAppBar(
          hintText: "Search products, customers, distributors",
          onChanged: _onSearchChanged,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _query.isEmpty
            ? _buildDiscoveryGrid()
            : _buildSearchList(),
      ),
    );
  }

  // ---------------- PRODUCT GRID ----------------
  Widget _buildDiscoveryGrid() {
    final products = _results.where((e) => e['type'] == 'product').toList();

    return MasonryGridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      itemCount: products.length,
      itemBuilder: (_, i) {
        final item = products[i];
        return GestureDetector(
          onTap: () => _onProductTap(item),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network("$ip${item['image']}", fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  // ---------------- SEARCH LIST ----------------
  Widget _buildSearchList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _results.length,
      itemBuilder: (_, i) {
        final item = _results[i];
        final type = item['type'];

        final color = type == 'product'
            ? Colors.blue
            : type == 'customer'
            ? Colors.green
            : Colors.orange;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            onTap: () => _onItemTap(item),
            leading: CircleAvatar(
              backgroundImage: NetworkImage("$ip${item['image']}"),
            ),
            title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              type == 'product'
                  ? " ${item['category']}"
                  : "${item['place']} • ${item['phone']}",
              style: TextStyle(color: color),
            ),
            trailing: _badge(type, color),
          ),
        );
      },
    );
  }

  Widget _badge(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(type.toUpperCase(),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  // ---------------- TAP LOGIC ----------------
  void _onItemTap(Map item) {
    if (item['type'] == 'product') {
      _onProductTap(item);
    } else if (item['type'] == 'customer') {
      _onCustomerTap(item);
    } else {
      _onDistributorTap(item);
    }
  }

  Future<void> _onProductTap(Map item) async {
    if (cid != null && cid != "null" && cid!.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("pid", item['id'].toString());
      await prefs.setString("uid", item['id'].toString());
      Navigator.push(context, MaterialPageRoute(builder: (_) => const addOrder()));
    }
  }

  void _onCustomerTap(Map item) {
    if (cid == item['id'].toString()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CustomerNavigationBar(initialIndex: 3)),
      );
      return;
    }

    final customer = Joke(
      item['id'].toString(),
      item['name'] ?? "",
      item['email'] ?? "",
      item['phone'] ?? "",
      "$ip${item['image']}",
      "",
      "",
      item['place'] ?? "",
      "",
      "",
      "",
    );

    Navigator.push(context,
        MaterialPageRoute(builder: (_) => ViewCustomerProfile(customer: customer)));
  }

  void _onDistributorTap(Map item) {
    if (uid == item['id'].toString()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DistributorNavigationBar(initialIndex: 4)),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewDistributorProfile(
          distributorId: item['id'].toString(),
          distributorName: item['name'],
        ),
      ),
    );
  }
}
