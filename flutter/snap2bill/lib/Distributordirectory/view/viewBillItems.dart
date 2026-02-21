
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snap2bill/theme/colors.dart';
import 'package:snap2bill/widgets/app_button.dart';
import 'package:snap2bill/widgets/distributorNavigationbar.dart';
import '../../widgets/SearchBar.dart';
import '../../widgets/SnackBar.dart';

class viewBillItems extends StatefulWidget {
  const viewBillItems({Key? key}) : super(key: key);

  @override
  State<viewBillItems> createState() => _viewBillItemsState();
}

class _viewBillItemsState extends State<viewBillItems> {
  late Future<Map<String, dynamic>> futureData;
  String totalValue = "0";
  String? serverIp;
  List<dynamic> _items = []; // Items currently in the bill
  List<dynamic> _allUnits = [];

  // 🚀 New Variables for Search and Stock
  List<dynamic> _allStockProducts = []; // All products available to add
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  late Color dangerColor;

  @override
  void initState() {
    super.initState();
    _fetchUnits();
    _fetchDistributorStock(); // 🚀 Fetch available products
    futureData = fetchBillItems();
  }

  /// 🚀 Refreshes data and clears local list to trigger Shimmer
  Future<void> _loadInitialData() async {
    setState(() {
      _items = []; // Force empty to show shimmer
      futureData = fetchBillItems();
    });
    await _fetchUnits();
    await _fetchDistributorStock(); // Refresh stock list too
  }

  // 🚀 Fetch All Products for the Horizontal List
  Future<void> _fetchDistributorStock() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "";
      String uid = prefs.getString("uid") ?? "";

      final res = await http.post(
        Uri.parse("$ip/distributor_products"), // Assuming this endpoint exists
        body: {'uid': uid},
      );

      if (res.statusCode == 200) {
        var js = json.decode(res.body);
        if (js['status'] == 'ok') {
          setState(() {
            _allStockProducts = js['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Stock Fetch Error: $e");
    }
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

    // Get all IDs
    String oid = prefs.getString("oid") ?? "";
    String uid = prefs.getString("uid") ?? "";
    // 🚀 Ensure we get the correct customer ID
    String cid = prefs.getString("selected_cid") ?? prefs.getString("cid") ?? "";

    final res = await http.post(
      Uri.parse("$serverIp/view_distributor_ordersitems"),
      body: {
        "id": oid,
        "cid": cid, // 🚀 Send CID
        "uid": uid, // 🚀 Send UID
      },
    );

    if (res.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(res.body);

      if (jsonData['status'] == 'ok') {
        // 🚀 RECOVERED OID: If backend found a pending bill, save its ID!
        if (jsonData['oid'] != null && jsonData['oid'].toString() != "0") {
          await prefs.setString("oid", jsonData['oid'].toString());
        }

        if (jsonData['data'] != null) {
          setState(() {
            _items = jsonData['data'];
            _calculateLocalTotal();
          });
        }
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

  // ... (Your existing updateItem and deleteItem functions remain unchanged) ...
  Future<void> updateItem(String itemId, String qty, String price, String unitId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
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
        String errorMsg = js['message'] ?? "Error";
        if (errorMsg.toLowerCase().contains("too long")) {
          errorMsg = "Price is too high for the system!";
        }
        CustomSnackBar.show(context, errorMsg, backgroundColor: AppColors.dangerColor);
      }
    } catch (e) {
      CustomSnackBar.show(context, "Connection Error: $e", backgroundColor: AppColors.dangerColor);
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
    final subTextColor = AppColors.getTextSubColor(context);

    // Filter Logic for Bill Items
    List<dynamic> filteredBillItems = _items.where((item) {
      return item['product_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Filter Logic for Available Stock
    List<dynamic> filteredStock = _allStockProducts.where((item) {
      return item['product_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.getScaffoldBg(context),
      appBar: SearchAppBar(
        hintText: "Search products in bill or stock...",
        controller: _searchController,
        onLeadingPressed: () => Navigator.pop(context),
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
      ),

      // 🚀 MAGIC SHURU: Detect Screen Rotation
      body: OrientationBuilder(
        builder: (context, orientation) {
          // ==========================================
          // 📱 PORTRAIT MODE (Seedha Phone)
          // ==========================================
          if (orientation == Orientation.portrait) {
            return Column(
              children: [
                if (_allStockProducts.isNotEmpty)
                  SizedBox(
                    height: 165,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Text("Quick Add Products", style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            itemCount: filteredStock.length,
                            itemBuilder: (context, index) {
                              return _buildHorizontalStockCard(filteredStock[index], isDark);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                const Divider(height: 1),

                Expanded(
                  child: _buildBillItemsList(filteredBillItems, isDark, subTextColor),
                ),
              ],
            );
          }
          // ==========================================
          // 🖥️ LANDSCAPE MODE (Teda Phone / Windows)
          // ==========================================
          else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT SIDE: Available Stock (GridView mein dikhayenge kyunki jagah chodi hai)
                if (_allStockProducts.isNotEmpty)
                  Expanded(
                    flex: 2, // Screen ka 40% hissa lega
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: AppColors.getBorderColor(context).withValues(alpha: 0.2))),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            child: Text("Quick Add Stock", style: TextStyle(color: subTextColor, fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // 2 items side-by-side
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: filteredStock.length,
                              itemBuilder: (context, index) {
                                // Yahan hum wahi horizontal card use kar rahe hain, just grid format mein
                                return _buildHorizontalStockCard(filteredStock[index], isDark);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // RIGHT SIDE: Bill Items
                Expanded(
                  flex: 3, // Screen ka 60% hissa lega
                  child: _buildBillItemsList(filteredBillItems, isDark, subTextColor),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: _buildBottomBar(subTextColor),
    );
  }

  // 🚀 Naya Helper Widget taaki code repeat na ho (Portrait & Landscape dono isko use karenge)
  Widget _buildBillItemsList(List<dynamic> filteredBillItems, bool isDark, Color subTextColor) {
    return FutureBuilder<Map<String, dynamic>>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading(isDark);
        }
        if (snapshot.hasError) {
          return _buildEmptyOrErrorState(
              context, Icons.cloud_off_rounded, "Server Error", "Check connection", subTextColor);
        }
        if (!snapshot.hasData || _items.isEmpty) {
          if (_searchQuery.isEmpty) {
            return _buildEmptyOrErrorState(
                context, Icons.inventory_2_outlined, "No Items", "Add from stock", subTextColor);
          }
        }

        return RefreshIndicator(
          onRefresh: _loadInitialData,
          color: AppColors.primaryLight,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            itemCount: filteredBillItems.length,
            itemBuilder: (context, index) => _buildProductCard(filteredBillItems[index]),
          ),
        );
      },
    );
  }

  Future<void> _addToBill(Map product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("ip") ?? "";
    String uid = prefs.getString("uid") ?? "";

    // 1. Get Order ID (Might be "0" or empty for new bills)
    String oid = prefs.getString("oid") ?? "";
    if (oid == "0") oid = ""; // Normalize "0" to empty string for backend logic

    // 🚀 CRITICAL FIX: Try fetching 'selected_cid' first, then fallback to 'cid'
    String cid =  prefs.getString("cid") ?? "";

    // 🛑 Stop if we don't have enough info to create a bill
    // If OID is missing, we MUST have CID to create a new one.
    if (oid.isEmpty && cid.isEmpty) {
      CustomSnackBar.show(
          context,
          "Error: No Customer ID found. Please go back and select the customer again.",
          backgroundColor: dangerColor
      );
      return;
    }

    // CustomSnackBar.show(context, "Adding ${product['product_name']}...", backgroundColor: AppColors.primaryLight);

    try {
      final res = await http.post(
        Uri.parse("$ip/addtobill"),
        body: {
          'uid': uid,
          'cid': cid, // Now this will definitely have a value
          'oid': oid,
          'sid': product['id'].toString(),
          'quantity': "1",
          'price': product['price'].toString(),
        },
      );

      if (res.statusCode == 200) {
        var js = json.decode(res.body);
        if (js['status'] == 'ok') {

          // 🚀 SAVE OID: Important for the next item!
          // If the backend created a NEW bill, it sends us the new ID.
          if (js['oid'] != null && js['oid'].toString() != "0") {
            await prefs.setString("oid", js['oid'].toString());
          }

          _loadInitialData(); // Refresh the bill list
          // CustomSnackBar.show(context, "Item Added!", backgroundColor: AppColors.getSuccessColor(context));
        } else {
          CustomSnackBar.show(context, js['message'] ?? "Failed", backgroundColor: dangerColor);
        }
      }
    } catch (e) {
      CustomSnackBar.show(context, "Connection Error: $e", backgroundColor: dangerColor);
    }
  }

  Widget _buildHorizontalStockCard(Map item, bool isDark) {
    return GestureDetector(
      // ✅ CHANGED: Double Tap to Add
      onDoubleTap: () => _addToBill(item),

      // Optional: Single Tap Hint (Good UX)
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        CustomSnackBar.show(context, "Double tap to add", backgroundColor: AppColors.getPrimaryColor(context));
      },

      child: Container(
        width: 110,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
          border: Border.all(color: AppColors.getBorderColor(context).withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: CachedNetworkImage(
  imageUrl:
                  "$serverIp${item['image']}",
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (c, e, s) => Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 30, color: Colors.grey)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['product_name'] ?? "",
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.getTextColor(context))),
                  Text("₹${item['price']}",
                      style: TextStyle(fontSize: 11, color: AppColors.getPrimaryColor(context), fontWeight: FontWeight.w900)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget _buildEmptyOrErrorState(BuildContext context, IconData icon, String title, String subTitle, Color? color) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
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
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
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
    final subTextColor = AppColors.getTextSubColor(context);

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
                child: CachedNetworkImage(
  imageUrl:
                  "$serverIp${item['image']}",
                  height: 90, width: 90, fit: BoxFit.cover,
                  errorWidget: (c, e, s) => Container(height: 90, width: 90, color: Colors.grey[200], child: const Icon(Icons.image_not_supported_outlined)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['product_name'].toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text("Rate: ₹${item['amount']} / ${item['unit_name']}", style: TextStyle(fontSize: 12, color: subTextColor)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.getPrimaryColor(context).withValues(alpha:0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text("${item['quantity']} ${item['unit_name']}", style: const TextStyle(color: Color(0xff23afda), fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const Spacer(),
                        Flexible(
                          flex: 3,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              "₹${((double.tryParse(item['amount'].toString()) ?? 0) * (double.tryParse(item['quantity'].toString()) ?? 0))
                                  .toStringAsFixed(3)
                                  .replaceFirst(RegExp(r'\.?0*\$'), '')}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor),
                            ),
                          ),
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
      useRootNavigator: false,
      backgroundColor: AppColors.getScaffoldBg(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(context).viewInsets.bottom + 30),
          child: SingleChildScrollView(
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
                    double? price = double.tryParse(priceController.text);

                    if (priceController.text.length > 7) {
                      Navigator.pop(context);
                      CustomSnackBar.show(context, "Price is too long!", backgroundColor: AppColors.dangerColor);
                      return;
                    }
                    if (qty != null && qty > 0 && price != null) {
                      updateItem(item['id'].toString(), qtyController.text, priceController.text, selectedUnitId ?? "");
                      Navigator.pop(context);
                    } else {
                      CustomSnackBar.show(context, "Invalid input", backgroundColor: AppColors.dangerColor);
                    }
                  },
                ),
              ],
            ),
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
                  Flexible(
                      flex: 3,
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text("₹$totalValue", style: TextStyle(color: AppColors.getTextColor(context), fontSize: 20, fontWeight: FontWeight.w900)))),
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