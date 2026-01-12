// import 'dart:convert';
// import 'dart:io'; // 🚀 Required for File
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'dart:typed_data';
// import 'package:hugeicons/hugeicons.dart';
//
// // --- UPDATED IMPORTS ---
// import '../../widgets/distributorNavigationbar.dart';
// // Verify this path: if Navbar.dart is in lib/widgets/ use this:
// import '../../widgets/Navbar.dart';
//
// class add_product extends StatelessWidget {
//   const add_product({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const add_product_sub();
//   }
// }
//
// class add_product_sub extends StatefulWidget {
//   const add_product_sub({Key? key}) : super(key: key);
//
//   @override
//   State<add_product_sub> createState() => _add_product_subState();
// }
//
// class _add_product_subState extends State<add_product_sub> {
//   final product_name = TextEditingController();
//   final price = TextEditingController();
//   final quantity = TextEditingController();
//   final description = TextEditingController();
//
//   PlatformFile? _selectedFile;
//   Uint8List? _webFileBytes;
//   bool _isLoading = false;
//
//   List<Map<String, dynamic>> categoryList = [];
//   String? selectedCategory;
//
//   @override
//   void initState() {
//     super.initState();
//     loadCategory();
//   }
//
//   Future<void> loadCategory() async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       final response = await http.post(
//         Uri.parse("${sh.getString('ip')}/view_category"),
//       );
//       var decode = json.decode(response.body);
//
//       if (decode['status'] == 'ok') {
//         List<Map<String, dynamic>> temp = [];
//         // Fixed the category parsing logic based on your debug logs
//         for (var item in decode['data']) {
//           temp.add({
//             "id": item['id'].toString(),
//             "name": item['category_name'].toString()
//           });
//         }
//         setState(() {
//           categoryList = temp;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error fetching Category: $e");
//     }
//   }
//
//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: false,
//       type: FileType.image,
//     );
//
//     if (result != null) {
//       setState(() {
//         _selectedFile = result.files.first;
//       });
//
//       if (kIsWeb) {
//         _webFileBytes = result.files.first.bytes;
//       }
//     }
//   }
//
//   InputDecoration _getInputDecoration(String label, String hint, IconData icon, bool isDark) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,
//       prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
//       filled: true,
//       fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(15),
//         borderSide: BorderSide.none,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       // 🚀 This will now work once the import path above is correct
//       appBar: ThemeNavbar(
//         title: "Add New Product",
//         leadingIcon: Icons.arrow_back_ios_rounded,
//         onLeadingPressed: () => Navigator.pop(context),
//         centerTitle: true,
//       ),
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             children: [
//               // --- Image Picker ---
//               Center(
//                 child: GestureDetector(
//                   onTap: _pickFile,
//                   child: Container(
//                     height: 180,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: isDark ? Colors.white10 : Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: _selectedFile != null
//                         ? ClipRRect(
//                       borderRadius: BorderRadius.circular(20),
//                       child: kIsWeb
//                           ? Image.memory(_webFileBytes!, fit: BoxFit.cover)
//                       // 🚀 FIXED: Removed java.io.
//                           : Image.file(File(_selectedFile!.path!), fit: BoxFit.cover),
//                     )
//                         : const Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 25),
//
//               TextField(
//                 controller: product_name,
//                 decoration: _getInputDecoration('Product Name', 'Enter name', Icons.shopping_bag_outlined, isDark),
//               ),
//               const SizedBox(height: 15),
//
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: price,
//                       keyboardType: TextInputType.number,
//                       decoration: _getInputDecoration('Price', '0.00', Icons.currency_rupee, isDark),
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Expanded(
//                     child: TextField(
//                       controller: quantity,
//                       keyboardType: TextInputType.number,
//                       decoration: _getInputDecoration('Stock', 'Qty', Icons.inventory_2_outlined, isDark),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 15),
//
//               // --- Category Dropdown ---
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: isDark ? Colors.white10 : Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     value: selectedCategory,
//                     hint: const Text('Select Category'),
//                     isExpanded: true,
//                     onChanged: (value) => setState(() => selectedCategory = value),
//                     items: categoryList.map((item) {
//                       return DropdownMenuItem<String>(
//                         value: item['id'],
//                         child: Text(item['name']),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//
//               TextField(
//                 controller: description,
//                 maxLines: 3,
//                 decoration: _getInputDecoration('Description', 'Details...', Icons.description_outlined, isDark),
//               ),
//               const SizedBox(height: 30),
//
//               SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: isDark ? Colors.white : Colors.black,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                   ),
//                   onPressed: _isLoading ? null : _sendData,
//                   child: _isLoading
//                       ? const CircularProgressIndicator()
//                       : Text("Add Product", style: TextStyle(color: isDark ? Colors.black : Colors.white)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _sendData() async {
//     if (product_name.text.isEmpty || selectedCategory == null || _selectedFile == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Missing fields")));
//       return;
//     }
//
//     setState(() => _isLoading = true);
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       var request = http.MultipartRequest('POST', Uri.parse('${sh.getString('ip')}/distributor_add_product'));
//
//       request.fields['product_name'] = product_name.text;
//       request.fields['price'] = price.text;
//       request.fields['quantity'] = quantity.text;
//       request.fields['description'] = description.text;
//       request.fields['category'] = selectedCategory!;
//       request.fields['uid'] = sh.getString('uid').toString();
//
//       if (kIsWeb) {
//         request.files.add(http.MultipartFile.fromBytes('file', _webFileBytes!, filename: _selectedFile!.name));
//       } else {
//         request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path!));
//       }
//
//       await request.send();
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => DistributorNavigationBar(initialIndex: 0)),
//             (route) => false,
//       );
//     } catch (e) {
//       debugPrint("Error: $e");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart'; // Required for XFile
import 'package:hugeicons/hugeicons.dart';

import '../../widgets/distributorNavigationbar.dart';
import '../../widgets/Navbar.dart';

class add_product extends StatelessWidget {
  final XFile? capturedFile; // 🚀 Receive from Camera Page

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
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    loadCategory();

    // 🚀 LOGIC: If an image was passed from CameraCapture, initialize it here
    if (widget.capturedFile != null) {
      _selectedFile = PlatformFile(
        name: widget.capturedFile!.name,
        path: widget.capturedFile!.path,
        size: 0,
      );

      if (kIsWeb) {
        widget.capturedFile!.readAsBytes().then((bytes) {
          setState(() {
            _webFileBytes = bytes;
          });
        });
      }
    }
  }

  Future<void> loadCategory() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse("${sh.getString('ip')}/view_category"),
      );
      var decode = json.decode(response.body);
      if (decode['status'] == 'ok') {
        List<Map<String, dynamic>> temp = [];
        for (var item in decode['data']) {
          temp.add({
            "id": item['id'].toString(),
            "name": item['category_name'].toString()
          });
        }
        setState(() {
          categoryList = temp;
        });
      }
    } catch (e) {
      debugPrint("Error fetching Category: $e");
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });

      if (kIsWeb) {
        _webFileBytes = result.files.first.bytes;
      }
    }
  }

  InputDecoration _getInputDecoration(String label, String hint, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
      filled: true,
      fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: ThemeNavbar(
        title: "Add Manual Product",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () => Navigator.pop(context),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // --- Image Preview Area ---
              Center(
                child: GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                    ),
                    child: _selectedFile != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: kIsWeb
                          ? (_webFileBytes != null ? Image.memory(_webFileBytes!, fit: BoxFit.cover) : Container())
                          : Image.file(File(_selectedFile!.path!), fit: BoxFit.cover),
                    )
                        : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Select Product Image", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              TextField(
                controller: product_name,
                decoration: _getInputDecoration('Product Name', 'Enter name', Icons.shopping_bag_outlined, isDark),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: price,
                      keyboardType: TextInputType.number,
                      decoration: _getInputDecoration('Price', '0.00', Icons.currency_rupee, isDark),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: quantity,
                      keyboardType: TextInputType.number,
                      decoration: _getInputDecoration('Stock', 'Qty', Icons.inventory_2_outlined, isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // --- Category Dropdown ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    hint: const Text('Select Category'),
                    isExpanded: true,
                    onChanged: (value) => setState(() => selectedCategory = value),
                    items: categoryList.map((item) {
                      return DropdownMenuItem<String>(
                        value: item['id'],
                        child: Text(item['name']),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: description,
                maxLines: 3,
                decoration: _getInputDecoration('Description', 'Product details...', Icons.description_outlined, isDark),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _isLoading ? null : _sendData,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.blueAccent)
                      : Text("Save Product", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendData() async {
    if (product_name.text.isEmpty || selectedCategory == null || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields and provide an image")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      var request = http.MultipartRequest('POST', Uri.parse('${sh.getString('ip')}/distributor_add_product'));

      request.fields['product_name'] = product_name.text;
      request.fields['price'] = price.text;
      request.fields['quantity'] = quantity.text;
      request.fields['description'] = description.text;
      request.fields['category'] = selectedCategory!;
      request.fields['uid'] = sh.getString('uid').toString();

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes('file', _webFileBytes!, filename: _selectedFile!.name));
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path!));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DistributorNavigationBar(initialIndex: 2)),
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }
}