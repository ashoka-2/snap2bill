
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

// Project specific imports
import '../theme/colors.dart';
import '../widgets/app_button.dart';
import 'viewCustomerProfile.dart';
import 'viewDistributorProfile.dart';
import '../widgets/CustomerNavigationBar.dart';
import '../widgets/SearchBar.dart';
import '../Customerdirectory/Customersends/addOrder.dart';
import '../Distributordirectory/customer_page.dart';
import '../widgets/distributorNavigationbar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> _results = [];
  bool _loading = false;
  bool _isLoadMoreRunning = false;
  int _page = 1;
  bool _hasNext = true;
  String _query = "";
  Timer? _debounce;

  late Color successColor;
  late Color dangerColor;

  final ScrollController _scrollController = ScrollController();

  String ip = "";
  String? cid;
  String? uid;

  @override
  void initState() {
    super.initState();
    _init();
    _scrollController.addListener(_loadMore);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ip = prefs.getString("ip") ?? "";
      cid = prefs.getString("cid");
      uid = prefs.getString("uid");
    });
    _fetchData("", 1);
  }

  void _loadMore() async {
    if (_hasNext && !_loading && !_isLoadMoreRunning &&
        _scrollController.position.extentAfter < 300) {
      setState(() => _isLoadMoreRunning = true);
      _page += 1;
      await _fetchData(_query, _page);
      setState(() => _isLoadMoreRunning = false);
    }
  }

  Future<void> _fetchData(String query, int page) async {
    // 🚀 Trigger Shimmer only on first load or new search
    if (page == 1) {
      setState(() {
        _results.clear(); // Important: Shimmer only shows if results are empty
        _loading = true;
      });
    }

    try {
      // Optional: Add a tiny delay if your local server is too fast to see the shimmer
      // await Future.delayed(const Duration(milliseconds: 500));

      final res = await http.get(Uri.parse("$ip/universal_search?q=$query&page=$page"));
      if (res.statusCode == 200) {
        final js = json.decode(res.body);
        if (js['status'] == 'ok') {
          setState(() {
            if (page == 1) {
              _results = js['data'] ?? [];
            } else {
              _results.addAll(js['data'] ?? []);
            }
            _hasNext = js['has_next'] ?? false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _page = 1;
      _hasNext = true;
      _query = value;
      _fetchData(value, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    successColor = AppColors.getSuccessColor(context);
    dangerColor = AppColors.getDangerColor(context);



    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: SearchAppBar(
          hintText: "Search products, people...",
          onChanged: _onSearchChanged,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _page = 1;
            _hasNext = true;
            await _fetchData(_query, 1);
          },
          child: _loading && _results.isEmpty
              ? (_query.isEmpty ? _buildGridShimmer(isDark) : _buildListShimmer(isDark))
              : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_results.isEmpty && !_loading) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Expanded(
          child: _query.isEmpty ? _buildDiscoveryGrid() : _buildSearchList(),
        ),
        if (_isLoadMoreRunning)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(child: Text("No results found.")),
      ],
    );
  }

  // ---------------- UI COMPONENTS ----------------

  Widget _buildDiscoveryGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MasonryGridView.count(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 100),
      crossAxisCount: 3,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemCount: _results.length,
      itemBuilder: (_, i) {
        final item = _results[i];
        return GestureDetector(
          onTap: () => _onItemTap(item),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              "$ip${item['image']}",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                color: isDark ? Colors.grey[800] : Colors.grey[300],
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchList() {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 100),
      itemCount: _results.length,
      itemBuilder: (_, i) {
        final item = _results[i];
        final type = item['type'];
        final color = type == 'product' ? AppColors.getPrimaryColor(context) : type == 'customer' ? successColor : dangerColor;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              color: color.withValues(alpha:0.06),
              borderRadius: BorderRadius.circular(14)
          ),
          child: ListTile(
            onTap: () => _onItemTap(item),
            leading: CircleAvatar(
              backgroundImage: NetworkImage("$ip${item['image']}"),
            ),
            title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(type == 'product' ? item['category'] : "${item['place']} • ${item['phone']}"),
            trailing: _badge(type, color),
          ),
        );
      },
    );
  }

  // ---------------- SHIMMERS ----------------

  Widget _buildGridShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: MasonryGridView.count(
        padding: const EdgeInsets.all(12),
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemCount: 15,
        itemBuilder: (_, i) => Container(
          height: [120.0, 180.0, 140.0, 160.0][i % 4],
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14)
          ),
        ),
      ),
    );
  }

  Widget _buildListShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 20,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 70,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14)
          ),
        ),
      ),
    );
  }

  Widget _badge(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha:.15), borderRadius: BorderRadius.circular(8)),
      child: Text(type.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  // 🚀 Navigation Logic
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
    // 1. Agar User CUSTOMER hai (cid login hai)
    if (cid != null && cid != "null" && cid!.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      String productId = item['id'].toString();
      await prefs.setString("pid", productId);

      Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => addOrder(pid: productId))
      );
    }
    else if (uid != null && uid != "null" && uid!.isNotEmpty) {
      _showProductDetailSheet(item);
    }
  }

  void _showProductDetailSheet(Map item) {
    final primaryColor = AppColors.getPrimaryColor(context);
    final bool isMyProduct = item['distributor_id'].toString() == uid.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),

            // PRODUCT INFO
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network("$ip${item['image']}", width: 70, height: 70, fit: BoxFit.cover),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("₹${item['price']}", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 30),

            // DISTRIBUTOR SECTION
            const Text("Distributor Details", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            Row(
              children: [
                InkWell(
                  onTap:(){
                    String distId = item['distributor_id'].toString();
                    String distName = item['distributor_name'].toString();

                    Navigator.pop(context);

                    if (uid == distId) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DistributorNavigationBar(initialIndex: 4)));
                      return;
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ViewDistributorProfile(distributorId: distId, distributorName:distName)));
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage("$ip${item['distributor_image']}"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isMyProduct ? "You (Owner)" : item['distributor_name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(item['distributor_phone'] ?? "", style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // --- BUTTONS LOGIC ---
            Row(
              children: [
                // 1. 🚀 CLOSE BUTTON (Hamesha dikhega aur Custom AppButton hoga)
                Expanded(
                  child: AppButton(
                    text: "CLOSE",
                    height: 45,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // 2. 🚀 CALL BUTTON (Sirf tab dikhega agar product MERA NAHI hai)
                if (!isMyProduct) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => launchUrl(Uri.parse("tel:${item['distributor_phone']}")),
                      icon: const Icon(Icons.call, size: 18),
                      label: const Text("CALL"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: successColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _onCustomerTap(Map item) {
    if (cid == item['id'].toString()) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CustomerNavigationBar(initialIndex: 3)));
      return;
    }
    final customer = Joke(
      item['id'].toString(),
      item['name'] ?? "",
      item['email'] ?? "",
      item['phone'] ?? "",
      "$ip${item['image']}",
      item['bio'] ?? "",
      item['address'] ?? "",
      item['place'] ?? "",
      item['pincode'] ?? "",
      item['post'] ?? "",
      ""
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => ViewCustomerProfile(customer: customer)));
  }

  void _onDistributorTap(Map item) {
    if (uid == item['id'].toString()) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DistributorNavigationBar(initialIndex: 4)));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => ViewDistributorProfile(distributorId: item['id'].toString(), distributorName: item['name'])));
  }
}