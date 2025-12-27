
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

// Navigation targets - Ensure these imports match your actual file paths
import 'package:snap2bill/Distributordirectory/view/viewCustomerProfile.dart';
import 'package:snap2bill/Distributordirectory/view/myProducts.dart';
import 'package:snap2bill/Distributordirectory/view/viewOrder.dart';

class customer_page extends StatelessWidget {
  const customer_page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const customer_page_sub();
  }
}

class customer_page_sub extends StatefulWidget {
  const customer_page_sub({Key? key}) : super(key: key);

  @override
  State<customer_page_sub> createState() => _customer_page_subState();
}

class _customer_page_subState extends State<customer_page_sub> {
  String _searchQuery = "";
  late Future<List<Joke>> _customerFuture;

  @override
  void initState() {
    super.initState();
    _customerFuture = _getCustomers();
  }

  // Swiping from top triggers this function
  Future<void> _handleRefresh() async {
    setState(() {
      _customerFuture = _getCustomers();
    });
    await _customerFuture;
  }

  Future<List<Joke>> _getCustomers() async {
    // Artificial delay to appreciate the shimmer effect
    await Future.delayed(const Duration(milliseconds: 800));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("ip") ?? "";
    String uid = prefs.getString("uid") ?? "";

    try {
      var response = await http.post(
        Uri.parse("$ip/distributor_view_customer"),
        body: {"uid": uid},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List<Joke> customers = [];

        if (jsonData["status"] == "ok" && jsonData["data"] != null) {
          for (var item in jsonData["data"]) {
            customers.add(Joke.fromJson(item, ip));
          }
        }
        return customers;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching customers: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        displacement: 40,
        color: Colors.blueAccent,
        child: CustomScrollView(
          // AlwaysScrollable ensures refresh works even with empty lists
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Search Bar
            SliverAppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              floating: true,
              snap: true,
              title: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Search linked customers...",
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            FutureBuilder<List<Joke>>(
              future: _customerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerList(isDark);
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add_disabled_outlined, size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 10),
                          const Text("No customers linked yet"),
                          const Text("Orders will automatically link customers", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }

                final filteredList = snapshot.data!.where((c) =>
                c.name.toLowerCase().contains(_searchQuery) ||
                    c.phone.contains(_searchQuery)
                ).toList();

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildCustomerCard(filteredList[index], theme, isDark),
                    childCount: filteredList.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Joke item, ThemeData theme, bool isDark) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () async {
          // Set selected customer ID to filter the order history page
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("selected_customer_id", item.id);

          Navigator.push(context, MaterialPageRoute(builder: (context) => const viewOrder()));
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewCustomerProfile(customer: item))),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: item.profile_image.startsWith("http") ? NetworkImage(item.profile_image) : null,
                  child: !item.profile_image.startsWith("http") ? const Icon(Icons.person, color: Colors.blue) : null,
                ),
              ),
              const SizedBox(width: 15),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(item.phone, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    Text(item.place, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              // Actions Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString("selected_customer_id", item.id);

                  if (value == 'view_bills') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const viewOrder()));
                  } else if (value == 'add_bill') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const myProducts()));
                  } else if (value == 'view_profile') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewCustomerProfile(customer: item)));
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'view_bills', child: ListTile(leading: Icon(Icons.history, color: Colors.blue), title: Text("Order History"))),
                  const PopupMenuItem(value: 'add_bill', child: ListTile(leading: Icon(Icons.receipt_long, color: Colors.blue), title: Text("Add Bill"))),
                  const PopupMenuItem(value: 'view_profile', child: ListTile(leading: Icon(Icons.person, color: Colors.blue), title: Text("Profile"))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList(bool isDark) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) => Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 90,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
          ),
        ),
        childCount: 6,
      ),
    );
  }
}

class Joke {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profile_image;
  final String bio;
  final String address;
  final String place;
  final String pincode;
  final String post;

  Joke(this.id, this.name, this.email, this.phone, this.profile_image, this.bio, this.address, this.place, this.pincode, this.post);

  factory Joke.fromJson(Map<String, dynamic> json, String ip) {
    String img = json['profile_image'].toString();
    return Joke(
      json['id'].toString(),
      json['name'] ?? "",
      json['email'] ?? "",
      json['phone'] ?? "",
      img.startsWith("http") ? img : "$ip$img",
      json['bio'] ?? "",
      json['address'] ?? "",
      json['place'] ?? "",
      json['pincode'] ?? "",
      json['post'] ?? "",
    );
  }
}