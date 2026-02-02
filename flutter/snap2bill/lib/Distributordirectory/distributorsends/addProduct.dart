
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:snap2bill/theme/colors.dart';

import '../../widgets/SnackBar.dart';
import '../../widgets/distributorNavigationbar.dart';
import '../../widgets/Navbar.dart';
import '../../widgets/app_button.dart';

class add_product extends StatelessWidget {
  final XFile? capturedFile;

  const add_product({Key? key, this.capturedFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return add_product_sub(capturedFile: capturedFile);
  }
}

class add_product_sub extends StatefulWidget {
  final XFile? capturedFile;
  const add_product_sub({Key? key, this.capturedFile}) : super(key: key);

  @override
  State<add_product_sub> createState() => _add_product_subState();
}

class _add_product_subState extends State<add_product_sub> {
  final product_name = TextEditingController();
  final price = TextEditingController();
  final quantity = TextEditingController();
  final description = TextEditingController();

  PlatformFile? _selectedFile;
  Uint8List? _webFileBytes;
  bool _isLoading = false;

  List<Map<String, dynamic>> categoryList = [];
  List<Map<String, dynamic>> unitList = [];
  String? selectedCategory;
  String? selectedUnit;

  @override
  void initState() {
    super.initState();
    loadCategory();
    loadUnits();
    if (widget.capturedFile != null) {
      _selectedFile = PlatformFile(
        name: widget.capturedFile!.name,
        path: widget.capturedFile!.path,
        size: 0,
      );
      if (kIsWeb) {
        widget.capturedFile!.readAsBytes().then((bytes) {
          setState(() => _webFileBytes = bytes);
        });
      }
    }
  }

  Future<void> loadCategory() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      final response = await http.post(Uri.parse("${sh.getString('ip')}/view_category"));
      var decode = json.decode(response.body);
      if (decode['status'] == 'ok') {
        setState(() {
          categoryList = List<Map<String, dynamic>>.from(decode['data']).map((item) {
            return {
              "id": item['id'].toString(),
              "name": item['category_name'].toString(),
            };
          }).toList();
        });
      }
    } catch (e) { debugPrint("Error Category: $e"); }
  }

  Future<void> loadUnits() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      final response = await http.get(Uri.parse("${sh.getString('ip')}/view_units"));
      var decode = json.decode(response.body);
      if (decode['status'] == 'ok') {
        setState(() {
          unitList = List<Map<String, dynamic>>.from(decode['data']);
          try {
            selectedUnit = unitList.firstWhere(
                    (u) => u['unit_name'].toString().toUpperCase() == 'PCS')['id'].toString();
          } catch (e) {
            if (unitList.isNotEmpty) selectedUnit = unitList[0]['id'].toString();
          }
        });
      }
    } catch (e) { debugPrint("Unit Load Error: $e"); }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() => _selectedFile = result.files.first);
      if (kIsWeb) _webFileBytes = result.files.first.bytes;
    }
  }

  InputDecoration _getDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.getPrimaryColor(context), size: 20),
      filled: true,
      fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AppColors.getScaffoldBg(context);
    final cardColor = AppColors.getCardColor(context);
    final textColor = AppColors.getTextColor(context);
    final subTextColor = AppColors.getTextSubColor(context);
    final inputFill = AppColors.getInputFieldColor(context);
    final iconColor = AppColors.getIconColor(context);
    final primaryColor = AppColors.getPrimaryColor(context);


    return Scaffold(
      backgroundColor: bgColor,
      appBar: ThemeNavbar(
        title: "Add Manual Product",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () => Navigator.pop(context),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                height: 180, width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.getPrimaryColor(context).withValues(alpha:0.2)),
                ),
                child: _selectedFile != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: kIsWeb
                      ? Image.memory(_webFileBytes!, fit: BoxFit.cover)
                      : Image.file(File(_selectedFile!.path!), fit: BoxFit.cover),
                )
                    : const Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25)
              ),
              child: Column(
                children: [
                  TextField(
                      controller: product_name,
                      decoration: _getDecoration('Product Name', Icons.shopping_bag_outlined, isDark)
                  ),
                  const SizedBox(height: 15),

                  TextField(
                      controller: price,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: _getDecoration('Price', Icons.currency_rupee, isDark)
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                              controller: quantity,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: _getDecoration('Stock Qty', Icons.inventory_2_outlined, isDark)
                          )
                      ),
                      const SizedBox(width: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        width: 100,
                        height: 55,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedUnit,
                            hint: const Text('Unit'),
                            isExpanded: true,
                            onChanged: (v) => setState(() => selectedUnit = v),
                            items: unitList.map((u) => DropdownMenuItem(value: u['id'].toString(), child: Text(u['unit_name']))).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        hint: const Text('Select Category (Optional)'),
                        isExpanded: true,
                        onChanged: (v) => setState(() => selectedCategory = v),
                        items: categoryList.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name'] ?? ''))).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                      controller: description,
                      maxLines: 3,
                      decoration: _getDecoration('Description (Optional)', Icons.description_outlined, isDark)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            AppButton(
              text: "Save Product",
              isLoading: _isLoading,
              onPressed: _sendData,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendData() async {
    // 🚀 VALIDATION: Required fields check
    if (product_name.text.isEmpty || price.text.isEmpty || quantity.text.isEmpty || _selectedFile == null || selectedUnit == null) {
      CustomSnackBar.show(context, "Name, Price, Quantity, Unit are required...", backgroundColor: AppColors.getPrimaryColor(context), durationMs: 800);

      return;
    }

    setState(() => _isLoading = true);
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = '${sh.getString('ip')}/distributor_add_product';

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // 🚀 String Fields
      request.fields['product_name'] = product_name.text;
      request.fields['price'] = price.text;
      request.fields['quantity'] = quantity.text;
      request.fields['description'] = description.text.isEmpty ? "No description provided" : description.text;
      request.fields['unit_id'] = selectedUnit!;
      request.fields['uid'] = sh.getString('uid').toString();

      // 🚀 Handle Category ID (Must be an ID or a valid string your backend handles)
      if(selectedCategory != null) {
        request.fields['category'] = selectedCategory!;
      } else {
        // Find a default ID or handle on backend.
        // Sending '1' or '0' depending on your DB setup.
        request.fields['category'] = categoryList.isNotEmpty ? categoryList[0]['id'] : "1";
      }

      // 🚀 File Upload
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes('file', _webFileBytes!, filename: _selectedFile!.name));
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path!));
      }

      // 🚀 Send and Handle Response
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      var resData = json.decode(response.body);

      if (resData['status'] == 'ok') {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DistributorNavigationBar(initialIndex: 2)),
                  (route) => false
          );
        }
      } else {
        if (mounted) {
          CustomSnackBar.show(context,Text("Error: ${resData['message']}") as String, backgroundColor: AppColors.dangerColor);
        }
      }
    } catch (e) {
      debugPrint("Full Error: $e");
      CustomSnackBar.show(context, "Connection Error.", backgroundColor: AppColors.getPrimaryColor(context), durationMs: 800);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}