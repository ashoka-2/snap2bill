
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
  List<dynamic> _items = [];
  bool _isInitialLoading = true;
  String? serverIp;

  // 🚀 Logic Variable: Buttons dikhane hain ya nahi
  bool isLocked = false;

  late Color successColor;
  late Color dangerColor;
  late Color cardColor;
  late Color textColor;
  late Color subTextColor;
  late Color primaryColor;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      serverIp = sp.getString("ip") ?? "";
      String orderId = sp.getString("id") ?? "";

      final res = await http.post(Uri.parse("$serverIp/view_orders_items"), body: {'oid': orderId});
      var js = json.decode(res.body);

      String status = (sp.getString("order_payment_status") ?? "pending").toLowerCase();
      String orderType = (js['order_type'] ?? "online").toString().toLowerCase();

      setState(() {
        _items = js['data'] ?? [];
        _isInitialLoading = false;

        bool isPaid = (status == 'paid' || status == 'online' || status == 'offline' || status == 'delivered');
        bool isDistributorBill = orderType.contains("offline");

        isLocked = isPaid || isDistributorBill;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isInitialLoading = false);
    }
  }

  String _getImageUrl(String path) {
    if (path.isEmpty || path == "null") return "";
    if (path.startsWith('http')) return path;
    return (serverIp ?? "") + (path.startsWith('/') ? path : '/$path');
  }

  Future<void> updateItem(int index, String qty) async {
    String itemId = _items[index]['id'].toString();
    var oldQty = _items[index]['quantity'];

    setState(() {
      _items[index]['quantity'] = qty;
    });

    SharedPreferences sp = await SharedPreferences.getInstance();
    final res = await http.post(
      Uri.parse("${sp.getString("ip")}/update_order_item"),
      body: {'id': itemId, 'quantity': qty, 'role': 'customer'},
    );

    var js = json.decode(res.body);
    if (js['status'] == 'ok') {
      CustomSnackBar.show(context, "Quantity updated successfully", backgroundColor: successColor);
    } else {
      setState(() {
        _items[index]['quantity'] = oldQty;
      });
      CustomSnackBar.show(context, js['message'] ?? "Error updating item", backgroundColor: dangerColor);
    }
  }

  Future<void> deleteItem(int index) async {
    String id = _items[index]['id'].toString();
    SharedPreferences sp = await SharedPreferences.getInstance();
    final res = await http.post(Uri.parse("${sp.getString("ip")}/delete_order_item"), body: {'id': id});

    var js = json.decode(res.body);
    if (js['status'] == 'ok') {
      CustomSnackBar.show(context, "Item removed", backgroundColor: dangerColor);
      setState(() {
        _items.removeAt(index);
      });
    } else {
      CustomSnackBar.show(context, js['message'] ?? "Cannot delete this item", backgroundColor: dangerColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    successColor = AppColors.getSuccessColor(context);
    dangerColor = AppColors.getDangerColor(context);
    final bgColor = AppColors.getScaffoldBg(context);
    cardColor = AppColors.getCardColor(context);
    textColor = AppColors.getTextColor(context);
    subTextColor = AppColors.getTextSubColor(context);
    primaryColor = AppColors.getPrimaryColor(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: ThemeNavbar(
        title: isLocked ? "View Order" : "Edit Order",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () => Navigator.pop(context),
        centerTitle: true,
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? Center(child: Text("No items found", style: TextStyle(color: subTextColor)))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: _items.length,
        itemBuilder: (context, index) => _buildItemCard(_items[index], index),
      ),
    );
  }

  Widget _buildItemCard(Map item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getBorderColor(context).withValues(alpha: 0.1), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.BlackColor.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              _getImageUrl(item['image'].toString()),
              width: 90, height: 90, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(width: 90, height: 90, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['product_name'] ?? "Product", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                Text("Price: ₹${item['price']}", style: TextStyle(color: subTextColor, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        "Qty: ${item['quantity']} ${item['unit_name'] ?? ''}",
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          "₹${((double.tryParse(item['price'].toString()) ?? 0) * (double.tryParse(item['quantity'].toString()) ?? 0)).toStringAsFixed(2)}",
                          maxLines: 1,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textColor),
                        ),
                      ),
                    ),
                  ],
                ),

                // 🚀 DYNAMIC BUTTONS LOGIC
                // Agar isLocked false hai, tabhi buttons dikhao
                if (!isLocked) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      EditButton(size: 40, onPressed: () => _openEditSheet(item, index)),
                      const SizedBox(width: 12),
                      DeleteButton(size: 40, onPressed: () => _confirmDeletion(index)),
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

  void _confirmDeletion(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item?"),
        content: const Text("This item will be removed from your order."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () { deleteItem(index); Navigator.pop(context); }, child: Text("Remove", style: TextStyle(color: dangerColor))),
        ],
      ),
    );
  }

  void _openEditSheet(Map item, int index) {
    TextEditingController qtyController = TextEditingController(text: item['quantity'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.getScaffoldBg(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(context).viewInsets.bottom + 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Edit Quantity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Quantity (1-100)",
                suffixText: item['unit_name'] ?? "",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 30),
            AppButton(
              text: "UPDATE QUANTITY",
              onPressed: () {
                int? qty = int.tryParse(qtyController.text);
                if (qty == null || qty <= 0 || qty > 100) {
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    CustomSnackBar.show(context, "Invalid quantity", backgroundColor: dangerColor);
                  });
                } else {
                  Navigator.pop(context);
                  CustomSnackBar.show(context, "Updating...", backgroundColor: primaryColor);
                  updateItem(index, qtyController.text);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}