//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:snap2bill/Distributordirectory/home_page.dart';
//
//
// class edit_product extends StatefulWidget {
//   final id;
//   final product_name;
//   final price;
//   final description;
//   final quantity;
//   final category;
//   final category_name;
//
//   const edit_product({
//     required this.id,
//     required this.product_name,
//     required this.price,
//     required this.description,
//     required this.quantity,
//     required this.category,
//     required this.category_name,
//
//   }) : super();
//
//   @override
//   State<edit_product> createState() =>
//       _edit_productState();
// }
//
// class _edit_productState
//     extends State<edit_product> {
//   final product_name = TextEditingController();
//   final price = TextEditingController();
//   final description = TextEditingController();
//   final quantity = TextEditingController();
//
//   List<Map<String, String>> categories = [];
//   String? selectedCategoryId;
//
//
//   @override
//   void initState() {
//     super.initState();
//     product_name.text = widget.product_name;
//     price.text = widget.price;
//     description.text = widget.description;
//     quantity.text = widget.quantity;
//     selectedCategoryId = widget.category?.toString();  // preselect
//     _loadCategories();
//   }
//
//
//   Future<void> _loadCategories() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     var res = await http.post(Uri.parse('${sh.getString("ip")}/view_category'));
//     var js = json.decode(res.body);
//     if (js['status'] == 'ok') {
//       List<Map<String, String>> list = [];
//       for (var c in js['data']) {
//         list.add({
//           'id': c['id'].toString(),
//           'name': c['category_name'].toString(),
//         });
//       }
//       setState(() {
//         categories = list;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue.shade50,
//       appBar: AppBar(
//         backgroundColor: Colors.blue.shade700,
//         centerTitle: true,
//         elevation: 0,
//         title: const Text(
//           "Edit Product",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Container(
//             width: 400,
//             margin: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.blue.withOpacity(0.15),
//                   blurRadius: 12,
//                   spreadRadius: 2,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(18.0),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 10),
//                   buildTextField("Name", product_name, Icons.image),
//                   const SizedBox(height: 12),
//                   buildTextField("Price", price, Icons.currency_rupee, keyboardType: TextInputType.number),
//                   const SizedBox(height: 12),
//                   buildTextField("Description", description, Icons.abc),
//                   const SizedBox(height: 12),
//                   buildTextField("Quantity", quantity, Icons.production_quantity_limits, keyboardType: TextInputType.number),
//                   const SizedBox(height: 12),
//
//
//
//
//                   // Category dropdown
//                   DropdownButtonFormField<String>(
//                     value: selectedCategoryId,
//                     items: categories.map((c) {
//                       return DropdownMenuItem<String>(
//                         value: c['id'],
//                         child: Text(c['name'] ?? ''),
//                       );
//                     }).toList(),
//                     onChanged: (v) {
//                       setState(() { selectedCategoryId = v; });
//                     },
//                     decoration: InputDecoration(
//                       labelText: "Category",
//                       prefixIcon: Icon(Icons.category, color: Colors.blue.shade700),
//                       filled: true,
//                       fillColor: Colors.blue.shade50,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.blue.shade200),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: Colors.blue.shade700, width: 1.8),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//
//
//
//
//
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue.shade700,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                       ),
//                       onPressed: () async {
//                         SharedPreferences sh =
//                         await SharedPreferences.getInstance();
//                         var data = await http.post(
//                           Uri.parse(
//                               '${sh.getString("ip")}/distributor_edit_product'),
//                           body: {
//                             'id': widget.id.toString(),
//                             'product_name': product_name.text,
//                             'price': price.text,
//                             'description': description.text,
//                             'quantity': quantity.text,
//                             'CATEGORY': (selectedCategoryId ?? widget.category.toString()),
//                             // 'uid': sh.getString("uid").toString()
//                           },
//                         );
//
//                         var decodeddata = json.decode(data.body);
//                         if (decodeddata['status'] == 'ok') {
//                           showDialog(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               title: const Text("Product Updated",
//                                   style: TextStyle(
//                                       color: Colors.blue,
//                                       fontWeight: FontWeight.bold)),
//                               content: const Text(
//                                   "Your product has been successfully updated."),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () {
//                                     Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                           const home_page()),
//                                     );
//                                   },
//                                   child: const Text(
//                                     "OK",
//                                     style: TextStyle(color: Colors.blue),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }
//                       },
//                       child: const Text(
//                         "Update Product",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 16),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildTextField(
//       String label,
//       TextEditingController controller,
//       IconData icon, {
//         bool enabled = true,
//         TextInputType keyboardType = TextInputType.text,
//       }) {
//     return TextField(
//       controller: controller,
//       enabled: enabled,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: Colors.blue.shade700),
//         filled: true,
//         fillColor: Colors.blue.shade50,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.blue.shade200),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.blue.shade700, width: 1.8),
//         ),
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:snap2bill/Distributordirectory/home_page.dart';

class edit_product extends StatefulWidget {
  final String id;
  final String product_name;
  final String price;
  final String description;
  final String quantity;
  final String category;       // category id
  final String category_name;  // category text

  const edit_product({
    Key? key,
    required this.id,
    required this.product_name,
    required this.price,
    required this.description,
    required this.quantity,
    required this.category,
    required this.category_name,
  }) : super(key: key);

  @override
  State<edit_product> createState() => _edit_productState();
}

class _edit_productState extends State<edit_product> {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final descCtrl  = TextEditingController();
  final qtyCtrl   = TextEditingController();

  List<Map<String, String>> categories = [];
  String? selectedCategoryId; // must be one of categories[].id to show as selected
  bool _loadingCategories = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    nameCtrl.text = widget.product_name;
    priceCtrl.text = widget.price;
    descCtrl.text  = widget.description;
    qtyCtrl.text   = widget.quantity;
    // Don't pre-set selectedCategoryId until categories are loaded.
    // We'll assign after fetching to ensure value exists in dropdown items.
    _loadCategories();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    descCtrl.dispose();
    qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final sh = await SharedPreferences.getInstance();
      final base = sh.getString("ip") ?? "";
      if (base.isEmpty) throw Exception("Missing base URL (ip).");

      final uri = Uri.parse(_joinUrl(base, "/view_category"));
      final res = await http.post(uri);

      if (res.statusCode != 200) {
        throw Exception("HTTP ${res.statusCode}: ${res.body}");
      }
      final js = json.decode(res.body);
      if (js is! Map || js['status'] != 'ok' || js['data'] == null) {
        throw Exception("Unexpected response: ${res.body}");
      }

      final List<Map<String, String>> list = [];
      for (final c in (js['data'] as List)) {
        list.add({
          'id': (c['id'] ?? '').toString(),
          'name': (c['category_name'] ?? '').toString(),
        });
      }

      setState(() {
        categories = list;
        // Preselect current category only if it exists in fetched list.
        final existing = categories.any((e) => e['id'] == widget.category);
        selectedCategoryId = existing ? widget.category : null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load categories: $e")),
      );
    } finally {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      // Basic validation (optional)
      if (nameCtrl.text.trim().isEmpty) {
        throw Exception("Name is required");
      }
      if (priceCtrl.text.trim().isEmpty) {
        throw Exception("Price is required");
      }
      if (qtyCtrl.text.trim().isEmpty) {
        throw Exception("Quantity is required");
      }

      final sh = await SharedPreferences.getInstance();
      final base = sh.getString("ip") ?? "";
      if (base.isEmpty) throw Exception("Missing base URL (ip).");

      final uri = Uri.parse(_joinUrl(base, "/distributor_edit_product"));
      final body = {
        'id': widget.id,
        'product_name': nameCtrl.text,
        'price': priceCtrl.text,
        'description': descCtrl.text,
        'quantity': qtyCtrl.text,
        // Only send CATEGORY if user changed it; otherwise keep current.
        'CATEGORY': (selectedCategoryId ?? widget.category),
      };

      final res = await http.post(uri, body: body);
      if (res.statusCode != 200) {
        throw Exception("HTTP ${res.statusCode}: ${res.body}");
      }

      final decoded = json.decode(res.body);
      if (decoded is! Map || decoded['status'] != 'ok') {
        final msg = (decoded is Map && decoded['message'] != null)
            ? decoded['message'].toString()
            : "Update failed: ${res.body}";
        throw Exception(msg);
      }

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Product Updated",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          content: const Text("Your product has been successfully updated."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );

      if (!mounted) return;
      // Go home (or pop and refresh previous screen).
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const home_page()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _joinUrl(String base, String path) {
    if (base.endsWith("/") && path.startsWith("/")) return base + path.substring(1);
    if (!base.endsWith("/") && !path.startsWith("/")) return "$base/$path";
    return base + path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Edit Product",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 400,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildTextField("Name", nameCtrl, Icons.image),
                  const SizedBox(height: 12),
                  _buildTextField("Price", priceCtrl, Icons.currency_rupee,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildTextField("Description", descCtrl, Icons.abc),
                  const SizedBox(height: 12),
                  _buildTextField("Quantity", qtyCtrl,
                      Icons.production_quantity_limits,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),

                  // Category dropdown (safe when list empty; shows hint and disables when loading)
                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    items: categories
                        .map((c) => DropdownMenuItem<String>(
                      value: c['id'],
                      child: Text(c['name'] ?? ''),
                    ))
                        .toList(),
                    onChanged: _loadingCategories
                        ? null
                        : (v) => setState(() => selectedCategoryId = v),
                    decoration: InputDecoration(
                      labelText: "Category",
                      hintText: _loadingCategories
                          ? "Loading categories..."
                          : (categories.isEmpty
                          ? "${widget.category_name} (no categories)"
                          : widget.category_name),
                      prefixIcon:
                      Icon(Icons.category, color: Colors.blue.shade700),
                      filled: true,
                      fillColor: Colors.blue.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        BorderSide(color: Colors.blue.shade700, width: 1.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _submitting ? "Updating..." : "Update Product",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData icon, {
        bool enabled = true,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: Colors.blue.shade700, width: 1.8),
        ),
      ),
    );
  }
}
