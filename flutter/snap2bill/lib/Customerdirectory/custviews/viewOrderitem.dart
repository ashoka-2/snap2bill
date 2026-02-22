
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    String rawStockPrice = item['price'].toString();
    String rawFinalPrice = item['Discountedprice'].toString();
    double stockPrice = double.tryParse(rawStockPrice) ?? 0.0;
    double finalPrice = (rawFinalPrice != "null" && rawFinalPrice.isNotEmpty)
        ? double.tryParse(rawFinalPrice) ?? stockPrice
        : stockPrice;
    double quantity = double.tryParse(item['quantity'].toString()) ?? 0.0;
    double totalRowPrice = finalPrice * quantity;
    bool hasDiscount = finalPrice < stockPrice;

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
          // Image Section
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
  imageUrl:
              _getImageUrl(item['image'].toString()),
              width: 90, height: 90, fit: BoxFit.cover,
              errorWidget: (c, e, s) => Container(width: 90, height: 90, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
            ),
          ),
          const SizedBox(width: 15),

          // Content Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['product_name'] ?? "Product", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),

                const SizedBox(height: 6),

                // 🚀 PRICE DISPLAY SECTION
                if (hasDiscount)
                // CASE A: DISCOUNT HAI -> Strike Old + Show New
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      // OLD PRICE (Striked)
                      Text(
                        "₹$stockPrice",
                        style: const TextStyle(
                            decoration: TextDecoration.lineThrough, // 👈 Main Strike Code
                            decorationColor: Colors.red, // Strike color
                            decorationThickness: 2.0,
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      // NEW PRICE (Green/Highlighted)
                      Text(
                        "₹$finalPrice",
                        style: TextStyle(
                            color: successColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15
                        ),
                      ),
                    ],
                  )
                else
                // CASE B: NO DISCOUNT -> Normal Display
                  Text(
                      "Price: ₹$finalPrice",
                      style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w600)
                  ),

                const SizedBox(height: 8),

                // Quantity and Total Row
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
                          "₹${totalRowPrice.toStringAsFixed(2)}",
                          maxLines: 1,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textColor),
                        ),
                      ),
                    ),
                  ],
                ),

                // Buttons Logic (Only if not locked)
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

    // 🔥 NEW LOGIC: Maximum kitna add kar sakta hai?
    // Current quantity jo order me hai + Dukan me bacha hua stock
    int availableStock = int.tryParse(item['stock_quantity'].toString()) ?? 0;
    int currentQty = int.tryParse(item['quantity'].toString()) ?? 0;
    int maxAllowed = availableStock + currentQty;

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

              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Quantity (Max: $maxAllowed)",
                suffixText: item['unit_name'] ?? "",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 30),
            AppButton(
              text: "UPDATE QUANTITY",
              onPressed: () {
                int? qty = int.tryParse(qtyController.text);

                // 🔥 NEW: Check lagaya ki enter ki hui quantity allowed se zyada na ho
                if (qty == null || qty <= 0) {
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    CustomSnackBar.show(context, "Invalid quantity", backgroundColor: dangerColor);
                  });
                } else if (qty > maxAllowed) {
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    CustomSnackBar.show(context, "Cannot exceed $maxAllowed items (Stock Limit)", backgroundColor: dangerColor);
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