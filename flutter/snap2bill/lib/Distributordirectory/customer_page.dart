
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

// Navigation targets
import 'package:snap2bill/screens/viewCustomerProfile.dart';
import 'package:snap2bill/Distributordirectory/view/myProducts.dart';
import 'package:snap2bill/Distributordirectory/view/viewOrder.dart';
import '../theme/colors.dart';
import '../widgets/SearchBar.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CustomerPageSub();
  }
}

class CustomerPageSub extends StatefulWidget {
  const CustomerPageSub({Key? key}) : super(key: key);

  @override
  State<CustomerPageSub> createState() => _CustomerPageSubState();
}

class _CustomerPageSubState extends State<CustomerPageSub> {
  String _searchQuery = "";
  late Future<List<Joke>> _customerFuture;

  @override
  void initState() {
    super.initState();
    _customerFuture = _getCustomers();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _customerFuture = _getCustomers();
    });
    await _customerFuture;
  }

  Future<List<Joke>> _getCustomers() async {
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
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: SearchAppBar(
          hintText: "Search your customers...",
          onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
        ),
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.getPrimaryColor(context),
          child: FutureBuilder<List<Joke>>(
            future: _customerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmerList(isDark);
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No linked customers found"));
              }

              final filteredList = snapshot.data!.where((c) =>
              c.name.toLowerCase().contains(_searchQuery) ||
                  c.phone.contains(_searchQuery) ||
                  c.place.toLowerCase().contains(_searchQuery)
              ).toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: filteredList.length,
                itemBuilder: (context, index) => _buildCustomerCard(filteredList[index], theme, isDark),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Joke item, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark? Colors.black.withValues(alpha:0.3): Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("selected_customer_id", item.id);
          Navigator.push(context, MaterialPageRoute(builder: (context) => const viewOrder()));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewCustomerProfile(customer: item))),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.getPrimaryColor(context).withValues(alpha: 0.2),
                  backgroundImage: item.profile_image.isNotEmpty ? NetworkImage(item.profile_image) : null,
                  child: item.profile_image.isEmpty ?  Icon(Icons.person, color: AppColors.getPrimaryColor(context)) : null,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(item.phone, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    Text(item.place, style: TextStyle(fontSize: 12, color: AppColors.getPrimaryColor(context))),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString("selected_customer_id", item.id);
                  if (value == 'view_bills') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const viewOrder()));
                  } else if (value == 'add_bill') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyProducts()));
                  } else if (value == 'view_profile') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewCustomerProfile(customer: item)));
                  }
                },
                itemBuilder: (context) => [
                   PopupMenuItem(value: 'view_bills', child: ListTile(leading: Icon(Icons.history, color: AppColors.getPrimaryColor(context)), title: Text("Order History"))),
                   PopupMenuItem(value: 'add_bill', child: ListTile(leading: Icon(Icons.receipt_long, color: AppColors.getPrimaryColor(context)), title: Text("Add Bill"))),
                   PopupMenuItem(value: 'view_profile', child: ListTile(leading: Icon(Icons.person, color: AppColors.getPrimaryColor(context)), title: Text("Profile"))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList(bool isDark) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 90,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}

// Global Model
class Joke {
  final String id, name, email, phone, profile_image, bio, address, place, pincode, post, oid;
  Joke(this.id, this.name, this.email, this.phone, this.profile_image, this.bio, this.address, this.place, this.pincode, this.post, this.oid);

  factory Joke.fromJson(Map<String, dynamic> json, String ip) {
    String img = json['profile_image']?.toString() ?? "";
    return Joke(
      json['id'].toString(),
      json['name']?.toString() ?? "Unknown",
      json['email']?.toString() ?? "",
      json['phone']?.toString() ?? "",
      img.startsWith("http") ? img : (img.isNotEmpty ? "$ip$img" : ""),
      json['bio']?.toString() ?? "",
      json['address']?.toString() ?? "",
      json['place']?.toString() ?? "",
      json['pincode']?.toString() ?? "",
      json['post']?.toString() ?? "",
      json['oid']?.toString() ?? "0",
    );
  }
}