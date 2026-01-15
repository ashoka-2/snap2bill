//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // REQUIRED FOR VALIDATION
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// // Make sure this points to your actual colors file
// import '../../widgets/Navbar.dart';
// import '../../widgets/app_button.dart';
//
// class editStock extends StatefulWidget {
//   final id;
//   final price;
//   final quantity;
//
//   const editStock({
//     Key? key,
//     required this.id,
//     required this.price,
//     required this.quantity,
//   }) : super(key: key);
//
//   @override
//   State<editStock> createState() => _editStockState();
// }
//
// class _editStockState extends State<editStock> {
//   final quantity = TextEditingController();
//   final price = TextEditingController();
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     price.text = widget.price.toString();
//     quantity.text = widget.quantity.toString();
//   }
//
//   // --- API Update Logic ---
//   Future<void> _updateStock() async {
//     // 1. Basic Validation: Check if empty
//     if (quantity.text.isEmpty || price.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill all fields")),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? ip = prefs.getString("ip");
//       String? pid = prefs.getString("pid");
//       String? uid = prefs.getString("uid");
//
//       if (ip != null) {
//         final uri = Uri.parse("$ip/edit_stock");
//
//         // Ensure we send valid strings
//         final body = {
//           'pid': pid ?? widget.id.toString(),
//           'uid': uid ?? "",
//           'quantity': quantity.text,
//           'price': price.text,
//         };
//
//         var response = await http.post(uri, body: body);
//
//         if (response.statusCode == 200) {
//           if (!mounted) return;
//           // Return to the previous screen cleanly
//           if (!mounted) return;
//           Navigator.pop(context, 'refresh');
//         } else {
//           throw Exception("Failed to update");
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error updating stock: $e")),
//       );
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // --- Theme Handling ---
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     // Design Colors
//     final bgColor = theme.scaffoldBackgroundColor;
//     final textColor = isDark ? Colors.white : Colors.black87;
//     final cardColor = theme.cardColor;
//     final hintColor = isDark ? Colors.white38 : Colors.grey[500];
//     // REMOVED inputFillColor variable
//     final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;
//
//     // Button Colors (Adapting based on theme)
//     final buttonColor = isDark ? Colors.white : Colors.black;
//     final buttonTextColor = isDark ? Colors.black : Colors.white;
//
//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: ThemeNavbar(title: "Update Stock",
//         leadingIcon: Icons.arrow_back_ios_rounded,
//         onLeadingPressed: ()=>{
//           if (Navigator.canPop(context)) Navigator.pop(context)
//         },
//         centerTitle: true,
//
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 10),
//
//               // --- Header Icon (Visual Appeal) ---
//               Container(
//                 height: 100,
//                 width: 100,
//                 decoration: BoxDecoration(
//                   color: isDark ? const Color(0xFF2C2C2C) : Colors.orange.shade50,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 15,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                     Icons.inventory_2_outlined,
//                     size: 45,
//                     color: isDark ? Colors.white : Colors.orange.shade800
//                 ),
//               ),
//               const SizedBox(height: 40),
//
//               // --- Form Card ---
//               Container(
//                 padding: const EdgeInsets.all(25),
//                 decoration: BoxDecoration(
//                   color: cardColor,
//                   borderRadius: BorderRadius.circular(24),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
//                       blurRadius: 20,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Update Details",
//                       style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: textColor
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//
//                     // Quantity Field
//                     _buildThemeTextField(
//                       controller: quantity,
//                       label: "Quantity",
//                       hint: "Available stock",
//                       icon: Icons.layers_outlined,
//                       isNumber: true,
//                       textColor: textColor,
//                       hintColor: hintColor!,
//                       borderColor: borderColor,
//                       // Validation: Digits Only
//                       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                     ),
//                     const SizedBox(height: 20),
//
//                     // Price Field
//                     _buildThemeTextField(
//                       controller: price,
//                       label: "Price",
//                       hint: "Product price",
//                       icon: Icons.currency_rupee,
//                       isNumber: true,
//                       textColor: textColor,
//                       hintColor: hintColor,
//                       borderColor: borderColor,
//                       // Validation: Digits Only
//                       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 40),
//
//               // --- APP BUTTON ---
//               AppButton(
//                 text: "Update Stock",
//                 onPressed: _updateStock,
//                 isLoading: _isLoading,
//
//                 // Theme Adaptation:
//                 color: buttonColor,        // White in DarkMode, Black in LightMode
//                 textColor: buttonTextColor, // Inverse of background
//
//                 // Optional styling extras:
//                 icon: Icons.check_circle_outline,
//                 isTrailingIcon: true,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // --- Helper for Beautiful TextFields ---
//   Widget _buildThemeTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     required Color textColor,
//     required Color hintColor,
//     required Color borderColor,
//     bool isNumber = false,
//     List<TextInputFormatter>? inputFormatters, // Added parameter
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//             label,
//             style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//                 color: textColor.withOpacity(0.7)
//             )
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//           // APPLY VALIDATION HERE
//           inputFormatters: inputFormatters,
//           style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(color: hintColor, fontSize: 14),
//             prefixIcon: Icon(icon, color: textColor.withOpacity(0.5), size: 20),
//             // Removed filled: true and fillColor completely
//             contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide.none,
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide(color: borderColor),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide(color: textColor, width: 1),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/theme/colors.dart';

import '../../widgets/Navbar.dart';
import '../../widgets/SnackBar.dart';
import '../../widgets/app_button.dart';

class editStock extends StatefulWidget {
  final dynamic id;
  final dynamic price;
  final dynamic quantity;
  final dynamic unitId; // 🚀 Received from the product list

  const editStock({
    Key? key,
    required this.id,
    required this.price,
    required this.quantity,
    required this.unitId, // 🚀 Required to show existing unit
  }) : super(key: key);

  @override
  State<editStock> createState() => _editStockState();
}

class _editStockState extends State<editStock> {
  final quantity = TextEditingController();
  final price = TextEditingController();
  bool _isLoading = false;

  List<dynamic> _units = [];
  String? _selectedUnitId;

  @override
  void initState() {
    super.initState();
    // Pre-fill existing data
    price.text = widget.price.toString();
    quantity.text = widget.quantity.toString();

    // 🚀 IMPORTANT: Set the initial dropdown value to the current unitId
    _selectedUnitId = widget.unitId?.toString();

    _fetchUnits();
  }

  Future<void> _fetchUnits() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "";
      final response = await http.get(Uri.parse("$ip/view_units"));
      if (response.statusCode == 200) {
        var js = json.decode(response.body);
        if (js['status'] == 'ok') {
          setState(() {
            _units = js['data'];

            // Validation: If passed unitId doesn't exist in the list,
            // fallback to first item to prevent errors
            if (_selectedUnitId == null && _units.isNotEmpty) {
              _selectedUnitId = _units[0]['id'].toString();
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching units: $e");
    }
  }

  Future<void> _updateStock() async {
    if (quantity.text.isEmpty || price.text.isEmpty) {
      CustomSnackBar.show(context, "Please fill all fields", backgroundColor: AppColors.dangerColor);

      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ip = prefs.getString("ip");
      String? uid = prefs.getString("uid");

      if (ip != null) {
        final uri = Uri.parse("$ip/edit_stock");

        final body = {
          'pid': widget.id.toString(),
          'uid': uid ?? "",
          'quantity': quantity.text,
          'price': price.text,
          'unit_id': _selectedUnitId ?? "",
        };

        var response = await http.post(uri, body: body);

        if (response.statusCode == 200) {
          if (!mounted) return;
          Navigator.pop(context, 'refresh');
        } else {
          throw Exception("Failed to update");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating stock: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = theme.cardColor;
    final hintColor = isDark ? Colors.white38 : Colors.grey[500];
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: ThemeNavbar(
        title: "Update Stock",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Header Icon
              Container(
                height: 100, width: 100,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    Icons.inventory_2_outlined,
                    size: 45,
                    color: isDark ? Colors.white : Colors.orange.shade800
                ),
              ),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 20, offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Update Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 25),

                    // Quantity + Unit Dropdown
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildThemeTextField(
                            controller: quantity,
                            label: "Quantity",
                            hint: "Available stock",
                            icon: Icons.layers_outlined,
                            isNumber: true,
                            textColor: textColor,
                            hintColor: hintColor!,
                            borderColor: borderColor,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Unit", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor.withOpacity(0.7))),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedUnitId,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: borderColor),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                items: _units.map((u) {
                                  return DropdownMenuItem<String>(
                                    value: u['id'].toString(),
                                    child: Text(u['unit_name'], style: TextStyle(color: textColor, fontSize: 14)),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedUnitId = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildThemeTextField(
                      controller: price,
                      label: "Price",
                      hint: "Product price",
                      icon: Icons.currency_rupee,
                      isNumber: true,
                      textColor: textColor,
                      hintColor: hintColor,
                      borderColor: borderColor,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              AppButton(
                text: "Update Stock",
                onPressed: _updateStock,
                isLoading: _isLoading,
                color: isDark ? Colors.white : Colors.black,
                textColor: isDark ? Colors.black : Colors.white,
                icon: Icons.check_circle_outline,
                isTrailingIcon: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color textColor,
    required Color hintColor,
    required Color borderColor,
    bool isNumber = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor.withOpacity(0.7))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: inputFormatters,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor, fontSize: 14),
            prefixIcon: Icon(icon, color: textColor.withOpacity(0.5), size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: textColor, width: 1)),
          ),
        ),
      ],
    );
  }
}