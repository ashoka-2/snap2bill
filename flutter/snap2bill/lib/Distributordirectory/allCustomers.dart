import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

// --- THE CRITICAL FIX: Import the model instead of redefining it ---
import 'package:snap2bill/Distributordirectory/customer_page.dart';

// Navigation targets
import 'package:snap2bill/Distributordirectory/view/viewCustomerProfile.dart';
import 'package:snap2bill/Distributordirectory/scanItem.dart';

class allCustomers extends StatelessWidget {
  const allCustomers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const allCustomers_sub();
  }
}

class allCustomers_sub extends StatefulWidget {
  const allCustomers_sub({Key? key}) : super(key: key);

  @override
  State<allCustomers_sub> createState() => _allCustomers_subState();
}

class _allCustomers_subState extends State<allCustomers_sub> {
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

    try {
      var response = await http.post(
        Uri.parse("$ip/viewAllCustomers"),
        body: {
          'uid':prefs.getString("uid")

      },
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
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Select Customer",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black87)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.blueAccent,
        child: Column(
          children: [
            // --- SEARCH BAR (Name, Email, Phone) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ],
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Search name, email or phone...",
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            Expanded(
              child: FutureBuilder<List<Joke>>(
                future: _customerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerList(isDark);
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  final filteredList = snapshot.data!.where((c) =>
                  c.name.toLowerCase().contains(_searchQuery) ||
                      c.email.toLowerCase().contains(_searchQuery) ||
                      c.phone.contains(_searchQuery)
                  ).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) =>
                        _buildCustomerCard(filteredList[index], theme, isDark),
                  );
                },
              ),
            ),
          ],
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
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          // --- CONTAINER CLICK -> ADD BILL (CameraCapture) ---
          onTap: () async {
            SharedPreferences sh = await SharedPreferences.getInstance();
            await sh.setString("cid", item.id);
            await sh.setString("oid", item.oid);
            await sh.setString("selected_customer_name", item.name);
            print(item.id+" customer id");
            Navigator.push(context, MaterialPageRoute(builder: (context) => CameraCapture()));
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // --- AVATAR CLICK -> VIEW PROFILE ---
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ViewCustomerProfile(customer: item))),
                  child: Hero(
                    tag: 'avatar_${item.id}',
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade50,
                      backgroundImage: item.profile_image.isNotEmpty
                          ? NetworkImage(item.profile_image)
                          : null,
                      child: item.profile_image.isEmpty
                          ? const Icon(Icons.person, color: Colors.blueAccent)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 4),
                      Text(item.email, style: const TextStyle(fontSize: 12, color: Colors.blueAccent)),
                      Text(item.phone, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("No customers found", style: TextStyle(color: Colors.grey)));
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
