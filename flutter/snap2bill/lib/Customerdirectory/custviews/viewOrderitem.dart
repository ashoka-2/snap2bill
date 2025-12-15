import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewOrderItems extends StatefulWidget {
  const ViewOrderItems({Key? key}) : super(key: key);

  @override
  State<ViewOrderItems> createState() => _ViewOrderItemsState();
}

class _ViewOrderItemsState extends State<ViewOrderItems> {
  late Future<Map<String, dynamic>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchItems();
  }

  /// ---------------- API ----------------

  Future<Map<String, dynamic>> fetchItems() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String ip = sp.getString("ip")!;
    String cid = sp.getString("id")!;

    final res = await http.post(
      Uri.parse("$ip/view_orders_items"),
      body: {'cid': cid},
    );

    return json.decode(res.body);
  }

  Future<void> deleteItem(String id) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String ip = sp.getString("ip")!;

    await http.post(
      Uri.parse("$ip/delete_order_item"),
      body: {'id': id},
    );

    setState(() {
      futureData = fetchItems();
    });
  }

  Future<void> updateItem(
      String itemId, String stockId, String qty) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String ip = sp.getString("ip")!;

    await http.post(
      Uri.parse("$ip/update_order_item"),
      body: {
        'id': itemId,
        'stock_id': stockId,
        'quantity': qty,
      },
    );

    setState(() {
      futureData = fetchItems();
    });
  }

  /// ---------------- EDIT SHEET ----------------

  void openEditSheet(
      BuildContext context, Map item, List stockList) {

    /// ALL stock ids
    final stockIds =
    stockList.map((s) => s['id'].toString()).toList();

    /// FIX: use stock_id (NOT order item id)
    String? selectedStockId =
    stockIds.contains(item['stock_id'].toString())
        ? item['stock_id'].toString()
        : null;

    TextEditingController qty =
    TextEditingController(text: item['quantity'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Order Item",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              /// PRODUCT SELECT
              DropdownButtonFormField<String>(
                value: selectedStockId,
                items: stockList.map<DropdownMenuItem<String>>((s) {
                  return DropdownMenuItem(
                    value: s['id'].toString(),
                    child: Text(s['product_name']),
                  );
                }).toList(),
                onChanged: (v) {
                  selectedStockId = v!;
                },
                decoration: const InputDecoration(
                  labelText: "Product",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              /// QUANTITY
              TextField(
                controller: qty,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              /// UPDATE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedStockId != null) {
                      updateItem(
                        item['id'].toString(),
                        selectedStockId!,
                        qty.text,
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Update Item"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Items"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!['data'].isEmpty) {
            return const Center(child: Text("No products in order"));
          }

          List items = snapshot.data!['data'];
          List stockList = snapshot.data!['data2'];

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      /// IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item['image'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image),
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// DETAILS
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['product_name'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text("₹${item['price']}"),
                            Text("Qty: ${item['quantity']}"),
                          ],
                        ),
                      ),

                      /// ACTIONS
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              openEditSheet(
                                context,
                                item,
                                stockList,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              bool confirm = await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Remove Product"),
                                  content: const Text(
                                      "Remove this product from order?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        "Remove",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm) {
                                deleteItem(item['id'].toString());
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
