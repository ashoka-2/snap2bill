

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/theme/colors.dart';
import 'package:snap2bill/widgets/app_button.dart';
import '../../widgets/Navbar.dart';

class viewBillItems extends StatefulWidget {
  const viewBillItems({Key? key}) : super(key: key);

  @override
  State<viewBillItems> createState() => _viewBillItemsState();
}

class _viewBillItemsState extends State<viewBillItems> {
  late Future<Map<String, dynamic>> futureData;
  String? serverIp;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    futureData = fetchBillItems();
  }

  /// --- API FETCH LOGIC ---
  Future<Map<String, dynamic>> fetchBillItems() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    serverIp = sp.getString("ip") ?? "";
    String orderId = sp.getString("oid") ?? "";

    final res = await http.post(
      Uri.parse("$serverIp/view_distributor_ordersitems"),
      body: {"id": orderId},
    );

    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception("Failed to load items");
    }
  }

  /// --- DELETE LOGIC ---
  Future<void> deleteItem(String id) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await http.post(
      Uri.parse("${sp.getString("ip")}/delete_order_item"),
      body: {'id': id},
    );
    setState(() {
      futureData = fetchBillItems();
    });
  }

  /// --- UPDATE LOGIC (Price & Quantity) ---
  Future<void> updateItem(String itemId, String qty, String price) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await http.post(
      Uri.parse("${sp.getString("ip")}/update_order_item"),
      body: {
        'id': itemId,
        'quantity': qty,
        'amount': price,
      },
    );
    setState(() {
      futureData = fetchBillItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];

    return Scaffold(
      backgroundColor: AppColors.getScaffoldBg(context),
      appBar: ThemeNavbar(
        title: "Edit Bill Items",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!['data'] == null || snapshot.data!['data'].isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 70, color: subTextColor),
                  const SizedBox(height: 10),
                  Text("No items found", style: TextStyle(color: subTextColor)),
                ],
              ),
            );
          }

          List items = snapshot.data!['data'];

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildProductCard(items[index]);
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.getScaffoldBg(context),
          border: Border(top: BorderSide(color: AppColors.getBorderColor(context).withOpacity(0.1), width: 1.5)),
        ),
        child: SafeArea(
          child: AppButton(
            text: "FINALIZE BILL",
            icon: Icons.done_all_rounded,
            isLoading: _isProcessing,
            onPressed: () {
              setState(() => _isProcessing = true);
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) setState(() => _isProcessing = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bill finalized successfully")));
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextColor(context);
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];

    return InkWell(
      onTap:() => _openEditSheet(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.getBorderColor(context).withOpacity(0.1), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
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
                  Text("Rate: ₹${item['amount']}", style: TextStyle(fontSize: 13, color: subTextColor)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text("Qty: ${item['quantity']}", style: const TextStyle(color: Color(0xff23afda), fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const Spacer(),
                      Text(
                        "₹${(double.tryParse(item['amount'].toString()) ?? 0) * (double.tryParse(item['quantity'].toString()) ?? 0)}",
                        style: TextStyle(
                            fontSize: 14, // 🚀 Total amount font size set to 14
                            fontWeight: FontWeight.w900,
                            color: textColor
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
            onPressed: () {
              deleteItem(item['id'].toString());
              Navigator.pop(context);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openEditSheet(Map item) {
    TextEditingController qtyController = TextEditingController(text: item['quantity'].toString());
    TextEditingController priceController = TextEditingController(text: item['amount'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.getScaffoldBg(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(context).viewInsets.bottom + 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Update Item Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text("${item['product_name']}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Price (₹)", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Quantity (Max 100)", style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        maxLength: 3, // 🚀 Physically limits to 3 digits
                        decoration: InputDecoration(
                          counterText: "",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          prefixIcon: const Icon(Icons.shopping_basket_outlined, size: 18),
                        ),
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
                if (qty == null || qty <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter a valid quantity")));
                } else if (qty > 100) {
                  // 🚀 Logic to restrict quantity above 100
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Quantity cannot exceed 100")));
                } else {
                  updateItem(
                    item['id'].toString(),
                    qtyController.text.trim(),
                    priceController.text.trim(),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated successfully")));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}