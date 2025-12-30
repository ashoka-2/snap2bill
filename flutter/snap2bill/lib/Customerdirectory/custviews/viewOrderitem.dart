

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

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

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Order Items", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!['data'].isEmpty) return const Center(child: Text("No items found"));

          List items = snapshot.data!['data'];
          List stockList = snapshot.data!['data2'] ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildItemCard(items[index], stockList, isDark),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(Map item, List stockList, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(_getImageUrl(item['image'].toString()), width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['product_name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                Text("Price: ₹${item['price']}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                Text("Quantity: ${item['quantity']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (!isPaid)
            Column(
              children: [
                IconButton(icon: const Icon(Icons.edit_note_rounded, color: Colors.blue), onPressed: () => _openEditSheet(context, item, stockList)),
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _confirmDeletion(item)),
              ],
            ),
        ],
      ),
    );
  }

  void _confirmDeletion(Map item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item?"),
        content: Text("Remove ${item['product_name']} from order?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () { deleteItem(item['id'].toString()); Navigator.pop(context); }, child: const Text("Remove", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _openEditSheet(BuildContext context, Map item, List stockList) {
    String? selectedStockId = item['sid'].toString(); // Current product ID
    TextEditingController qtyController = TextEditingController(text: item['quantity'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => StatefulBuilder( // Added for dropdown state within bottomsheet
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Update Item Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // ✅ PRODUCT SELECTION DROPDOWN (Restored)
              const Text("Select Product", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                value: selectedStockId,
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: stockList.map<DropdownMenuItem<String>>((s) {
                  return DropdownMenuItem(value: s['id'].toString(), child: Text(s['product_name']));
                }).toList(),
                onChanged: (v) => setModalState(() => selectedStockId = v),
              ),

              const SizedBox(height: 15),

              // ✅ QUANTITY FIELD (Restored)
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Quantity", border: OutlineInputBorder()),
              ),

              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    updateItem(item['id'].toString(), selectedStockId!, qtyController.text);
                    Navigator.pop(context);
                  },
                  child: const Text("Update Order", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}