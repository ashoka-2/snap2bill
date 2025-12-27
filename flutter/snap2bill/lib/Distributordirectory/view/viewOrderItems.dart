import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class viewOrderItems extends StatelessWidget {
  const viewOrderItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const viewOrderItemsSub();
  }
}

class viewOrderItemsSub extends StatefulWidget {
  const viewOrderItemsSub({Key? key}) : super(key: key);

  @override
  State<viewOrderItemsSub> createState() => _viewOrderItemsSubState();
}

class _viewOrderItemsSubState extends State<viewOrderItemsSub> {
  Future<List<OrderItem>> _getOrderItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString("ip");
    String? orderId = prefs.getString("id"); // The specific Order ID

    if (ip == null || orderId == null) return [];

    try {
      var response = await http.post(
          Uri.parse("$ip/view_distributor_ordersitems"),
          body: {"id": orderId}
      );

      if (response.statusCode != 200) return [];

      var jsonData = json.decode(response.body);
      if (jsonData["status"] != "ok" || jsonData["data"] == null) return [];

      List<OrderItem> items = [];
      for (var item in jsonData["data"]) {
        items.add(OrderItem.fromJson(item, ip));
      }
      return items;
    } catch (e) {
      debugPrint("Error fetching order items: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = (isDark ? Colors.white70 : Colors.grey[600]) ?? Colors.grey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Item Details",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<OrderItem>>(
        future: _getOrderItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 70, color: subTextColor),
                  const SizedBox(height: 10),
                  Text("No items found in this order", style: TextStyle(color: subTextColor)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildProductCard(items[index], theme, isDark, textColor, subTextColor);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(OrderItem item, ThemeData theme, bool isDark, Color textColor, Color? subTextColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // PRODUCT IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              item.imageUrl,
              height: 90,
              width: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 90,
                width: 90,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // PRODUCT DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Price: ₹${item.price}",
                  style: TextStyle(fontSize: 14, color: subTextColor),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Qty: ${item.quantity}",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // Total for this item
                    Text(
                      "₹${double.parse(item.price) * double.parse(item.quantity)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Updated Model to match your specific backend return keys
class OrderItem {
  final String id;
  final String quantity;
  final String imageUrl;
  final String price;
  final String productName;
  final String customerName;

  OrderItem({
    required this.id,
    required this.quantity,
    required this.imageUrl,
    required this.price,
    required this.productName,
    required this.customerName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json, String ip) {
    return OrderItem(
      id: json['id'].toString(),
      quantity: json['quatity'].toString(), // Matches your backend typo 'quatity'
      imageUrl: "$ip${json['image']}",      // Prepends Server IP to Image path
      price: json['amount'].toString(),
      productName: json['product_name'].toString(),
      customerName: json['username'].toString(),
    );
  }
}