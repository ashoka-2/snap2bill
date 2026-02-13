import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/view/myProducts.dart';
import 'package:snap2bill/theme/colors.dart';

import '../../widgets/Navbar.dart';
import '../../widgets/SnackBar.dart';
import '../../widgets/app_button.dart';

class AddStock extends StatelessWidget {
  const AddStock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AddStockSub();
  }
}

class AddStockSub extends StatefulWidget {
  const AddStockSub({Key? key}) : super(key: key);

  @override
  State<AddStockSub> createState() => _AddStockSubState();
}

class _AddStockSubState extends State<AddStockSub> {
  TextEditingController stock = TextEditingController();
  TextEditingController price = TextEditingController();
  bool _isLoading = false;

  // 🚀 New variables for Units
  List<dynamic> _units = [];
  String? _selectedUnitId;

  late Color successColor;

  @override
  void initState() {
    super.initState();
    _fetchUnits(); // Fetch units on load
  }

  // 🚀 Fetch Units Logic
  Future<void> _fetchUnits() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "";
      // Ensure this URL matches your Django urls.py (e.g., path('view_units', views.view_units))
      final response = await http.get(Uri.parse("$ip/view_units"));
      if (response.statusCode == 200) {
        var js = json.decode(response.body);
        if (js['status'] == 'ok') {
          setState(() {
            _units = js['data'];
            if (_units.isNotEmpty) {
              // Try to find 'pcs' as default, else take first
              try {
                _selectedUnitId = _units.firstWhere((u) =>
                u['unit_name'].toString().toLowerCase() == 'pcs')['id'].toString();
              } catch (e) {
                _selectedUnitId = _units[0]['id'].toString();
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching units: $e");
    }
  }

// --- API Logic ---
  Future<void> _submitStock() async {
    if (stock.text.isEmpty || price.text.isEmpty) {
      CustomSnackBar.show(context, "Please fill all fields.", backgroundColor: AppColors.dangerColor);
      return;
    }

    // Frontend Validation
    if (price.text.length > 7 || stock.text.length > 3) {
      CustomSnackBar.show(context, "Input too long!", backgroundColor: AppColors.dangerColor);
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ip = prefs.getString("ip");
      String? pid = prefs.getString("pid");
      String? uid = prefs.getString("uid");

      if (ip != null) {
        final uri = Uri.parse("$ip/add_stock");
        final body = {
          'pid': pid ?? "",
          'uid': uid ?? "",
          'quantity': stock.text,
          'price': price.text,
          'unit_id': _selectedUnitId ?? "",
        };

        var response = await http.post(uri, body: body);

        // 🚀 STEP 1: Pehle print karo ki server ne kya bheja
        print("Server Response Status: ${response.statusCode}");
        print("Server Response Body: ${response.body}");

        if (response.statusCode == 200) {
          var decoded = json.decode(response.body);

          // 🚀 STEP 2: Status check ko handle karo (lowercase check added)
          if (decoded['status'].toString().toLowerCase() == 'ok') {
            if (!mounted) return;

            CustomSnackBar.show(context, "Product added successfully", backgroundColor: Colors.green);

            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyProducts())
            );
          } else {
            // 🚀 STEP 3: Agar server 'ok' nahi bhej raha toh asli message dikhao
            String errorMsg = decoded['message'] ?? "Server rejected the request";
            CustomSnackBar.show(context, errorMsg, backgroundColor: AppColors.dangerColor);
          }
        } else {
          CustomSnackBar.show(context, "Server Error: ${response.statusCode}", backgroundColor: AppColors.dangerColor);
        }
      }
    } catch (e) {
      print("Full Error: $e"); // Debugging ke liye
      CustomSnackBar.show(context, "Error: $e", backgroundColor: AppColors.dangerColor);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    successColor = AppColors.getSuccessColor(context);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    

    final bgColor = theme.scaffoldBackgroundColor;
final textColor = AppColors.getTextColor(context);
    final cardColor = theme.cardColor;
    final hintColor = isDark ? Colors.white38 : Colors.grey[500];
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;

    final buttonColor = isDark ? AppColors.WhiteColor: Colors.black;
    final buttonTextColor = isDark ? AppColors.BlackColor: Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: ThemeNavbar(
        title: "Add Stock",
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
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : AppColors.getPrimaryColor(context).withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.05),
                      blurRadius: 15, offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                    Icons.add_business_outlined,
                    size: 45,
                    color: isDark ? AppColors.WhiteColor: AppColors.getPrimaryColor(context)
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
                    Text(
                      "Stock Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Enter the new quantity and price to add.",
                      style: TextStyle(fontSize: 14, color: hintColor),
                    ),
                    const SizedBox(height: 25),

                    // 🚀 Quantity + Unit Dropdown Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildThemeTextField(
                            controller: stock,
                            label: "Quantity",
                            hint: "Ex: 50",
                            icon: Icons.inventory_2_outlined,
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
                              Text(
                                  "Unit",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: textColor.withValues(alpha:0.7)
                                  )
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedUnitId,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: borderColor),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                items: _units.map((u) {
                                  return DropdownMenuItem<String>(
                                    value: u['id'].toString(),
                                    child: Text(u['unit_name'],
                                        style: TextStyle(color: textColor, fontSize: 14)),
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
                      label: "Price per Unit",
                      hint: "Ex: 1200",
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
                text: "Add Stock",
                onPressed: _submitStock,
                isLoading: _isLoading,
                color: buttonColor,
                textColor: buttonTextColor,
                icon: Icons.add_shopping_cart,
                isTrailingIcon: false,
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
        Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor.withValues(alpha:0.7))
        ),
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
            filled: true,
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