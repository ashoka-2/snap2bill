
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snap2bill/theme/colors.dart';
import 'package:snap2bill/widgets/app_button.dart';
import 'package:snap2bill/widgets/distributorNavigationbar.dart';
import '../../widgets/Navbar.dart';


class viewBillItems extends StatefulWidget {
  const viewBillItems({Key? key}) : super(key: key);

  @override
  State<viewBillItems> createState() => _viewBillItemsState();
}

class _viewBillItemsState extends State<viewBillItems> {
  late Future<Map<String, dynamic>> futureData;
  String totalValue = "0";
  String? serverIp;
  List<dynamic> _items = [];
  List<dynamic> _allUnits = [];

  late Color dangerColor;

  @override
  void initState() {
    super.initState();
    _fetchUnits();
    futureData = fetchBillItems();
  }

  /// 🚀 Refreshes data and clears local list to trigger Shimmer
  Future<void> _loadInitialData() async {
    setState(() {
      _items = []; // Force empty to show shimmer
      futureData = fetchBillItems();
    });
    await _fetchUnits();
  }

  Future<void> _fetchUnits() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "";
      final res = await http.get(Uri.parse("$ip/view_units"));
      if (res.statusCode == 200) {
        var js = json.decode(res.body);
        if (js['status'] == 'ok') {
          setState(() { _allUnits = js['data']; });
        }
      }
    } catch (e) {
      debugPrint("Unit Error: $e");
    }
  }

  Future<Map<String, dynamic>> fetchBillItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    serverIp = prefs.getString("ip") ?? "";
    String orderId = prefs.getString("oid") ?? "";

    final res = await http.post(
      Uri.parse("$serverIp/view_distributor_ordersitems"),
      body: {"id": orderId},
    );

    if (res.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(res.body);
      if (jsonData['data'] != null) {
        setState(() {
          _items = jsonData['data'];
          _calculateLocalTotal();
        });
      }
      return jsonData;
    } else {
      throw Exception("Server Error: ${res.statusCode}");
    }
  }

  void _calculateLocalTotal() {
    double newTotal = 0;
    for (var item in _items) {
      double price = double.tryParse(item['amount'].toString()) ?? 0;
      double qty = double.tryParse(item['quantity'].toString()) ?? 0;
      newTotal += (price * qty);
    }
    setState(() { totalValue = newTotal.toStringAsFixed(0); });
  }

  Future<void> updateItem(String itemId, String qty, String price, String unitId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final res = await http.post(
      Uri.parse("${prefs.getString("ip")}/update_order_item"),
      body: {
        'id': itemId,
        'quantity': qty,
        'amount': price,
        'unit_id': unitId,
        'role': 'distributor',
      },
    );

    var js = json.decode(res.body);
    if (js['status'] == 'ok') {
      _loadInitialData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(js['message'] ?? "Error")));
    }
  }

  Future<void> deleteItem(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await http.post(Uri.parse("${prefs.getString("ip")}/delete_order_item"), body: {'id': id});
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    dangerColor = AppColors.getDangerColor(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];

    return Scaffold(
      backgroundColor: AppColors.getScaffoldBg(context),
      appBar: ThemeNavbar(
        title: "Edit Bill Items",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () => Navigator.pop(context),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          // 1. SHOW SHIMMER: While loading data from server
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading(isDark);
          }

          // 2. SHOW ERROR: If server is down or has issues
          if (snapshot.hasError) {
            return _buildEmptyOrErrorState(
              context,
              Icons.cloud_off_rounded,
              "Server Connection Issue",
              "Please check your internet or server IP",
              subTextColor,
            );
          }

          // 3. SHOW EMPTY STATE: If server returns successfully but list is empty
          if (!snapshot.hasData || _items.isEmpty) {
            return _buildEmptyOrErrorState(
              context,
              Icons.inventory_2_outlined,
              "No Items added in bill",
              "Add products to see them here",
              subTextColor,
            );
          }

          // 4. DATA STATE: Show the list
          return RefreshIndicator(
            onRefresh: _loadInitialData,
            color: AppColors.primaryLight,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              itemCount: _items.length,
              itemBuilder: (context, index) => _buildProductCard(_items[index]),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(subTextColor),
    );
  }

  /// 🚀 Reusable Empty/Error UI
  Widget _buildEmptyOrErrorState(BuildContext context, IconData icon, String title, String subTitle, Color? color) {
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Column(
              children: [
                Icon(icon, size: 80, color: color?.withValues(alpha:0.5)),
                const SizedBox(height: 15),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 5),
                Text(subTitle, style: TextStyle(color: color?.withValues(alpha:0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🚀 Shimmer Loading UI
  Widget _buildShimmerLoading(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(
          height: 140,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextColor(context);
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getBorderColor(context).withValues(alpha:0.1), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  "$serverIp${item['image']}",
                  height: 90, width: 90, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(height: 90, width: 90, color: Colors.grey[200], child: const Icon(Icons.image_not_supported_outlined)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['product_name'].toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text("Rate: ₹${item['amount']} / ${item['unit_name']}", style: TextStyle(fontSize: 13, color: subTextColor)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.getPrimaryColor(context).withValues(alpha:0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text("${item['quantity']} ${item['unit_name']}", style: const TextStyle(color: Color(0xff23afda), fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const Spacer(),
                        Text(
                          "₹${(double.tryParse(item['amount'].toString()) ?? 0) * (double.tryParse(item['quantity'].toString()) ?? 0)}",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              EditButton(onPressed: () => _openEditSheet(item)),
              const SizedBox(width: 12),
              DeleteButton(onPressed: () => _confirmDeletion(item)),
            ],
          )
        ],
      ),
    );
  }

  void _openEditSheet(Map item) {
    TextEditingController qtyController = TextEditingController(text: item['quantity'].toString());
    TextEditingController priceController = TextEditingController(text: item['amount'].toString());
    String? selectedUnitId = item['unit_id']?.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.getScaffoldBg(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(context).viewInsets.bottom + 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Update Item Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 25),
              const Text("Price (₹)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 18)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          decoration: InputDecoration(counterText: "", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), prefixIcon: const Icon(Icons.shopping_basket_outlined, size: 18)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Unit", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: (_allUnits.any((u) => u['id'].toString() == selectedUnitId)) ? selectedUnitId : null,
                          isExpanded: true,
                          decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                          items: _allUnits.map((u) {
                            return DropdownMenuItem<String>(
                              value: u['id'].toString(),
                              child: Text(u['unit_name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setModalState(() { selectedUnitId = val; });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              AppButton(
                text: "SAVE UPDATES",
                onPressed: () {
                  int? qty = int.tryParse(qtyController.text);
                  if (qty != null && qty > 0 ) {
                    updateItem(item['id'].toString(), qtyController.text, priceController.text, selectedUnitId ?? "");
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(Color? subTextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.getScaffoldBg(context),
        border: Border(top: BorderSide(color: AppColors.getBorderColor(context).withValues(alpha:0.1), width: 1.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Amount", style: TextStyle(color: subTextColor, fontSize: 12)),
                  Text("₹$totalValue", style: TextStyle(color: AppColors.getTextColor(context), fontSize: 22, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              child: AppButton(
                text: "FINALIZE",
                height: 48,
                icon: Icons.done_all_rounded,
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await http.post(
                    Uri.parse(prefs.getString("ip").toString() + "/addFinalBill"),
                    body: {'id': prefs.getString("oid"), 'total': totalValue},
                  );
                  if (mounted) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DistributorNavigationBar(initialIndex: 2)));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletion(Map item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Item?"),
        content: Text("Remove ${item['product_name']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () { deleteItem(item['id'].toString()); Navigator.pop(context); },
            child:  Text("Remove", style: TextStyle(color: dangerColor)),
          ),
        ],
      ),
    );
  }
}