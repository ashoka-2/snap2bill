

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

class EditStock extends StatefulWidget {
  final dynamic id;
  final dynamic price;
  final dynamic quantity;
  final dynamic unitId; // 🚀 Received from the product list

  const EditStock({
    Key? key,
    required this.id,
    required this.price,
    required this.quantity,
    required this.unitId, // 🚀 Required to show existing unit
  }) : super(key: key);

  @override
  State<EditStock> createState() => _EditStockState();
}

class _EditStockState extends State<EditStock> {
  final quantity = TextEditingController();
  final price = TextEditingController();
  bool _isLoading = false;

  List<dynamic> _units = [];
  String? _selectedUnitId;

  late Color successColor;

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
        
        CustomSnackBar.show(context, "Product updated successfully", backgroundColor: successColor);


        if (response.statusCode == 200) {
          if (!mounted) return;
          Navigator.pop(context, 'refresh');
        } else {
          throw Exception("Failed to update");
        }
      }
    } catch (e) {

      CustomSnackBar.show(context, Text("Error Updating Stock: $e") as String,
          backgroundColor: AppColors.dangerColor);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    successColor = AppColors.getSuccessColor(context);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? AppColors.WhiteColor: Colors.black87;
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
                  color: isDark ? const Color(0xFF2C2C2C) : AppColors.orangeColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    Icons.inventory_2_outlined,
                    size: 45,
                    color: isDark ? AppColors.WhiteColor: AppColors.orangeColor,
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
                      color: isDark? Colors.black.withValues(alpha:0.3): Colors.black.withValues(alpha:0.05),
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
                              Text("Unit", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor.withValues(alpha:0.7))),
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
                color: isDark ? AppColors.WhiteColor: Colors.black,
                textColor: isDark ? AppColors.BlackColor: Colors.white,
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
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor.withValues(alpha:0.7))),
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
            prefixIcon: Icon(icon, color: textColor.withValues(alpha:0.5), size: 20),
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