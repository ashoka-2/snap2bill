
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/theme/colors.dart';
import 'package:snap2bill/widgets/app_button.dart';
import '../../widgets/Navbar.dart';
import '../../widgets/SnackBar.dart';

class ViewOrderItems extends StatefulWidget {
  const ViewOrderItems({Key? key}) : super(key: key);

  @override
  State<ViewOrderItems> createState() => _ViewOrderItemsState();
}

class _ViewOrderItemsState extends State<ViewOrderItems> {
  late Future<Map<String, dynamic>> futureData;
  String? serverIp;
  bool isPaid = false;

  @override
  void initState() {
    super.initState();
    futureData = fetchItems();
    _checkPaymentStatus();
  }

  void _checkPaymentStatus() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String status = sp.getString("order_payment_status") ?? "pending";
    setState(() {
      isPaid = (status == 'paid' || status == 'online' || status == 'offline');
    });
  }

  String _getImageUrl(String path) {
    if (path.isEmpty || path == "null") return "";
    if (path.startsWith('http')) return path;
    return (serverIp ?? "") + (path.startsWith('/') ? path : '/$path');
  }

  Future<Map<String, dynamic>> fetchItems() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    serverIp = sp.getString("ip") ?? "";
    String orderId = sp.getString("id") ?? "";
    final res = await http.post(Uri.parse("$serverIp/view_orders_items"), body: {'oid': orderId});
    return json.decode(res.body);
  }

  Future<void> deleteItem(String id) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await http.post(Uri.parse("${sp.getString("ip")}/delete_order_item"), body: {'id': id});
    setState(() { futureData = fetchItems(); });
  }

  Future<void> updateItem(String itemId, String stockId, String qty) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await http.post(
      Uri.parse("${sp.getString("ip")}/update_order_item"),
      body: {'id': itemId, 'stock_id': stockId, 'quantity': qty},
    );
    setState(() { futureData = fetchItems(); });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];

    return Scaffold(
      backgroundColor: AppColors.getScaffoldBg(context),
      appBar: ThemeNavbar(
        title: "Order Items",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!['data'] == null || snapshot.data!['data'].isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 70, color: subTextColor),
                  const SizedBox(height: 10),
                  Text("No items found in this order", style: TextStyle(color: subTextColor)),
                ],
              ),
            );
          }

          List items = snapshot.data!['data'];
          List stockList = snapshot.data!['data2'] ?? [];

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildItemCard(items[index], stockList),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(Map item, List stockList) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextColor(context);
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getBorderColor(context).withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              _getImageUrl(item['image'].toString()),
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                width: 90,
                height: 90,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['product_name'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text("Price: ₹${item['price']}", style: TextStyle(color: subTextColor, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Qty: ${item['quantity']}",
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Text(
                      "₹${(double.tryParse(item['price'].toString()) ?? 0) * (double.tryParse(item['quantity'].toString()) ?? 0)}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textColor),
                    ),
                  ],
                ),
                if (!isPaid) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      EditButton(
                        size: 40,
                        onPressed: () => _openEditSheet(context, item, stockList),
                      ),
                      const SizedBox(width: 12),
                      DeleteButton(
                        size: 40,
                        onPressed: () => _confirmDeletion(item),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeletion(Map item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Item?"),
        content: Text("Remove ${item['product_name']} from order?"),
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

  void _openEditSheet(BuildContext context, Map item, List stockList) {
    String? selectedStockId = item['sid'].toString();
    TextEditingController qtyController = TextEditingController(text: item['quantity'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.getScaffoldBg(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(context).viewInsets.bottom + 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Edit Order Item", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              const Text("Select Product", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedStockId,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                ),
                items: stockList.map<DropdownMenuItem<String>>((s) {
                  return DropdownMenuItem(value: s['id'].toString(), child: Text(s['product_name']));
                }).toList(),
                onChanged: (v) => setModalState(() => selectedStockId = v),
              ),
              const SizedBox(height: 20),
              const Text("Quantity (Max 100)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                maxLength: 3,
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "Enter quantity",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  prefixIcon: const Icon(Icons.shopping_basket_outlined),
                ),
              ),
              const SizedBox(height: 30),
              AppButton(
                text: "UPDATE ITEM",

                onPressed: () {
                  int? qty = int.tryParse(qtyController.text);
                  if (qty == null || qty <= 0) {
                    CustomSnackBar.show(
                      context,
                      'Enter a valid Quantity',
                      backgroundColor: AppColors.dangerColor,
                    );
                  } else if (qty > 100) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Quantity cannot exceed 100")));
                    CustomSnackBar.show(
                      context,
                      'Please select a rating and write a review',
                      backgroundColor: Colors.redAccent,
                    );
                  } else {
                    updateItem(item['id'].toString(), selectedStockId!, qtyController.text);
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
}