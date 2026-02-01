import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/colors.dart';
import '../../widgets/Navbar.dart';

class ViewOrderItems extends StatelessWidget {
  const ViewOrderItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ViewOrderItemsSub();
  }
}

class ViewOrderItemsSub extends StatefulWidget {
  const ViewOrderItemsSub({Key? key}) : super(key: key);

  @override
  State<ViewOrderItemsSub> createState() => _ViewOrderItemsSubState();
}

class _ViewOrderItemsSubState extends State<ViewOrderItemsSub> {
  late Color cardColor;

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
    final bgColor = AppColors.getScaffoldBg(context);
    cardColor = AppColors.getCardColor(context);
    final textColor = AppColors.getTextColor(context);
    final subTextColor = AppColors.getTextSubColor(context);
    final inputFill = AppColors.getInputFieldColor(context);
    final iconColor = AppColors.getIconColor(context);
    final primaryColor = AppColors.getPrimaryColor(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: ThemeNavbar(title: "Order Items",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: ()=>{
          if (Navigator.canPop(context)) Navigator.pop(context)
        },
        centerTitle: true,

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
              return _buildProductCard(items[index], textColor, subTextColor);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(OrderItem item, Color textColor, Color? subTextColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.BlackColor.withValues(alpha:0.05), blurRadius: 15, offset: const Offset(0, 5)),
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
          const SizedBox(width: 10),

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
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🚀 Flexible use kiya taaki agar text bada ho toh ye container sikud jaye
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.getPrimaryColor(context).withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Qty: ${item.quantity} ${item.unit_name}",
                        maxLines: 1, // 🚀 Overflow prevent karne ke liye
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.getPrimaryColor(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5), // Bich mein thoda gap
                    // 🚀 Price text ko bhi Flexible mein rakha taaki overlap na ho
                    Flexible(
                      flex: 3,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          "₹${(double.parse(item.price) * double.parse(item.quantity))}",
                          style: TextStyle(
                            fontSize: 14, // Maximum size
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
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
  final String unit_name;

  OrderItem({
    required this.id,
    required this.quantity,
    required this.imageUrl,
    required this.price,
    required this.productName,
    required this.customerName,
    required this.unit_name,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json, String ip) {
    return OrderItem(
      id: json['id'].toString(),
      quantity: json['quantity'].toString(), // Matches your backend typo 'quantity'
      imageUrl: "$ip${json['image']}",      // Prepends Server IP to Image path
      price: json['amount'].toString(),
      productName: json['product_name'].toString(),
      customerName: json['username'].toString(),
      unit_name: (json['unit_name'] != null && json['unit_name'] != "null")
          ? json['unit_name'].toString()
          : "pcs",
    );
  }
}