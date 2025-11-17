// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Distributordirectory/home_page.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart'; // kIsWeb
// import 'dart:typed_data';
//
//
// class add_product extends StatelessWidget {
//   const add_product({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: add_product_sub(),);
//   }
// }
//
//
// class add_product_sub extends StatefulWidget {
//
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
// // =====================================================
//   PlatformFile? _selectedFile;
//   Uint8List? _webFileBytes;
//   String? _result;
//   bool _isLoading = false;
//
// // 🔹 STEP 1: Declare Panchayath data list
//   List<Map<String, dynamic>> category = [];  // ✅ Holds data fetched from Django
//
//   // 🔹 STEP 2: Store selected Panchayath
//   String? selectedCategory;  // ✅ Holds selected Panchayath ID
//
//   // ================================
//   // 🔹 STEP 3: Load data from Django
//   // ================================
//   Future<void> loadCategory() async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       final response = await http.post(
//         Uri.parse("${sh.getString('ip')}/view_category"), // replace with your function
//       );
//       var decode = json.decode(response.body);
//       decode['data'].forEach((item){
//         setState(() {
//           selectedCategory =   item['id'].toString();
//           category.add({
//             // ✅ ID from Django model
//             // ✅ Panchayath name field
//
//             item['id'].toString():
//             item['category_name'].toString()});
//
//
//         });
//         print(category);
//
//       });
//
//     } catch (e) {
//       print("Error fetching Category: $e");
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     loadCategory(); // ✅ Call function on screen load
//   }
//   // =====================================================
//   // 📸 PICK FILE FUNCTION
//   // =====================================================
//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: false,
//       type: FileType.any, // Any file type allowed
//     );
//
//     if (result != null) {
//       setState(() {
//         _selectedFile = result.files.first;
//         _result = null;
//       });
//
//       if (kIsWeb) {
//         _webFileBytes = result.files.first.bytes;
//       }
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     double fieldWidth = MediaQuery.of(context).size.width * 0.9;
//
//     return Scaffold(
//       body:
//       Container(child:
//       Column(children: [
//         TextField(
//           controller: product_name,
//           decoration: InputDecoration(
//               hintText: 'Enter product name',
//               labelText: 'Name',
//               prefixIcon: Icon(Icons.abc),
//               border: OutlineInputBorder()
//           ),),SizedBox(height: 10,),
//         TextField(controller: price,
//           decoration: InputDecoration(
//               hintText: 'Enter price',
//               labelText: 'Price',
//               prefixIcon: Icon(Icons.currency_rupee),
//               border: OutlineInputBorder()
//           ),),SizedBox(height: 10,),
//         TextField(
//           controller: quantity,
//           decoration: InputDecoration(
//               hintText: 'Enter quantity',
//               labelText: 'Quantity',
//               prefixIcon: Icon(Icons.abc),
//               border: OutlineInputBorder()
//           ),),SizedBox(height: 10,),
//         TextField(controller: description,
//           decoration: InputDecoration(
//               hintText: 'Enter product description',
//               labelText: 'Description',
//               prefixIcon: Icon(Icons.abc),
//               border: OutlineInputBorder()
//           ),),SizedBox(height: 10,),
//         SizedBox(
//           width: fieldWidth,
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.green, width: 1.5),
//               borderRadius: BorderRadius.circular(12),
//               color: Colors.white,
//             ),
//             child: DropdownButton<String>(
//               value: selectedCategory,                // ✅ Selected Value
//               hint: Text('Select Category'),          // ✅ Placeholder
//               isExpanded: true,
//               underline: SizedBox(),
//               icon: Icon(Icons.arrow_drop_down, color: Colors.green),
//               onChanged: (value) {
//                 setState(() {
//                   selectedCategory = value;           // ✅ Store selected
//                 });
//               },
//               items: category.map((item) {
//                 print("item${item['id']}");
//                 return DropdownMenuItem<String>(
//                   value: item.keys.first,          // ✅ ID as value
//                   child: Text(item.values.first),  // ✅ Display name
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//
//         ElevatedButton.icon(
//           icon: Icon(Icons.upload_file),
//           label: Text("Select File"),
//           onPressed: _pickFile,
//         ),
//         if (_selectedFile != null) ...[
//           SizedBox(height: 10),
//           Text("Selected: ${_selectedFile!.name}"),
//         ],
//         SizedBox(height: 10,),
//
//         ElevatedButton(onPressed: () async {
//
//
//           print(product_name.text);
//           print(description.text);
//           print(price.text);
//           print(quantity.text);
//           print(category);
//
//           SharedPreferences sh=await SharedPreferences.getInstance();
//
//           // =====================================================
//           // 🌐 SERVER REQUEST (POST to Django)
//           // =====================================================
//           var request =   await http.MultipartRequest(
//               'POST',
//               Uri.parse('${sh.getString('ip')}/distributor_add_product')
//           );
//
//           // 🔹 Normal Form Data
//           request.fields['product_name'] = product_name.text;
//           request.fields['price'] = price.text;
//           request.fields['quantity'] = quantity.text;
//           request.fields['description'] = description.text;
//           request.fields['category'] = selectedCategory.toString();
//           request.fields['uid'] = sh.getString('uid').toString();
//
//
//
//
//           // 🔹 File Upload Part
//           if (kIsWeb) {
//             request.files.add(http.MultipartFile.fromBytes(
//               'file',
//               _webFileBytes!,
//               filename: _selectedFile!.name,
//             ));
//           } else {
//             request.files.add(await http.MultipartFile.fromPath(
//               'file',
//               _selectedFile!.path!,
//             ));
//           }
//           // =====================================================
//           // 🌐 END SERVER UPLOAD SECTION
//           // =====================================================
//
//           var response = await request.send();
//
//           Navigator.push(context, MaterialPageRoute(builder: (context)=>home_page()));
//
//         }, child: Text('send'))
//       ],
//
//       ),),
//     );
//   }
// }
//
//
// //
// // import 'dart:convert';
// //
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:snap2bill/Distributordirectory/home_page.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'package:flutter/foundation.dart'; // kIsWeb
// // import 'dart:typed_data';
// //
// // class add_product extends StatelessWidget {
// //   const add_product({Key? key}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // Return widget directly to avoid nested MaterialApp
// //     return const add_product_sub();
// //   }
// // }
// //
// // class add_product_sub extends StatefulWidget {
// //   const add_product_sub({Key? key}) : super(key: key);
// //
// //   @override
// //   State<add_product_sub> createState() => _add_product_subState();
// // }
// //
// // class _add_product_subState extends State<add_product_sub> {
// //   final product_name = TextEditingController();
// //   final price = TextEditingController();
// //   final quantity = TextEditingController();
// //   final description = TextEditingController();
// //
// //   PlatformFile? _selectedFile;
// //   Uint8List? _webFileBytes;
// //   bool _isLoading = false;
// //
// //   List<Map<String, dynamic>> category = [];
// //   String? selectedCategory;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     loadCategory();
// //   }
// //
// //   Future<void> loadCategory() async {
// //     try {
// //       SharedPreferences sh = await SharedPreferences.getInstance();
// //       final response = await http.post(Uri.parse("${sh.getString('ip')}/view_category"));
// //       var decode = json.decode(response.body);
// //       if (decode['data'] != null) {
// //         category.clear();
// //         for (var item in decode['data']) {
// //           category.add({item['id'].toString(): item['category_name'].toString()});
// //         }
// //         // no default selected — user must choose
// //         setState(() {});
// //       }
// //     } catch (e) {
// //       debugPrint("Error fetching Category: $e");
// //     }
// //   }
// //
// //   // Only images allowed
// //   bool _isImageExt(String? ext) {
// //     if (ext == null) return false;
// //     final e = ext.toLowerCase();
// //     return ["jpg", "jpeg", "png", "gif", "bmp", "webp"].contains(e);
// //   }
// //
// //   Future<void> _pickFile() async {
// //     FilePickerResult? result = await FilePicker.platform.pickFiles(
// //       allowMultiple: false,
// //       type: FileType.custom,
// //       allowedExtensions: ["jpg", "jpeg", "png", "gif", "bmp", "webp"],
// //       withData: kIsWeb,
// //     );
// //
// //     if (result != null) {
// //       final f = result.files.first;
// //       if (!_isImageExt(f.extension)) {
// //         _showMessage("Please select an image file (jpg, png, webp, ...)", error: true);
// //         return;
// //       }
// //       setState(() {
// //         _selectedFile = f;
// //       });
// //       if (kIsWeb) _webFileBytes = f.bytes;
// //     }
// //   }
// //
// //   void _showMessage(String text, {bool error = false}) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(text), backgroundColor: error ? Colors.redAccent : Colors.green),
// //     );
// //   }
// //
// //   bool _validate() {
// //     if (product_name.text.trim().isEmpty) {
// //       _showMessage("Enter product name", error: true);
// //       return false;
// //     }
// //     if (price.text.trim().isEmpty) {
// //       _showMessage("Enter price", error: true);
// //       return false;
// //     }
// //     if (quantity.text.trim().isEmpty) {
// //       _showMessage("Enter quantity", error: true);
// //       return false;
// //     }
// //     if (selectedCategory == null || selectedCategory!.isEmpty) {
// //       _showMessage("Select category", error: true);
// //       return false;
// //     }
// //     if (_selectedFile == null) {
// //       _showMessage("Select an image to upload", error: true);
// //       return false;
// //     }
// //     if (!_isImageExt(_selectedFile!.extension)) {
// //       _showMessage("Selected file is not an image", error: true);
// //       return false;
// //     }
// //     return true;
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     double fieldWidth = MediaQuery.of(context).size.width * 0.96;
// //     final theme = Theme.of(context);
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
// //           onPressed: () => Navigator.of(context).pop(),
// //         ),
// //         title: const Text('Add Product'),
// //         centerTitle: true,
// //         backgroundColor: Colors.white,
// //         foregroundColor: Colors.black,
// //         elevation: 1,
// //       ),
// //       body: SafeArea(
// //         child: Stack(
// //           children: [
// //             SingleChildScrollView(
// //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
// //               child: Column(
// //                 children: [
// //                   Card(
// //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                     elevation: 3,
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(14),
// //                       child: Column(
// //                         children: [
// //                           TextField(
// //                             controller: product_name,
// //                             decoration: InputDecoration(
// //                               labelText: 'Name',
// //                               hintText: 'Enter product name',
// //                               prefixIcon: const Icon(Icons.shopping_bag_outlined),
// //                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
// //                               contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
// //                             ),
// //                           ),
// //                           const SizedBox(height: 12),
// //                           Row(
// //                             children: [
// //                               Expanded(
// //                                 child: TextField(
// //                                   controller: price,
// //                                   keyboardType: TextInputType.number,
// //                                   decoration: InputDecoration(
// //                                     labelText: 'Price',
// //                                     hintText: 'Enter price',
// //                                     prefixIcon: const Icon(Icons.currency_rupee),
// //                                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
// //                                     contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
// //                                   ),
// //                                 ),
// //                               ),
// //                               const SizedBox(width: 12),
// //                               SizedBox(
// //                                 width: 120,
// //                                 child: TextField(
// //                                   controller: quantity,
// //                                   keyboardType: TextInputType.number,
// //                                   decoration: InputDecoration(
// //                                     labelText: 'Qty',
// //                                     hintText: '0',
// //                                     prefixIcon: const Icon(Icons.format_list_numbered),
// //                                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
// //                                     contentPadding:
// //                                     const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 12),
// //                           TextField(
// //                             controller: description,
// //                             maxLines: 3,
// //                             decoration: InputDecoration(
// //                               labelText: 'Description',
// //                               hintText: 'Enter product description',
// //                               prefixIcon: const Icon(Icons.note_outlined),
// //                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
// //                               contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
// //                             ),
// //                           ),
// //                           const SizedBox(height: 12),
// //                           // Category dropdown
// //                           Container(
// //                             width: fieldWidth,
// //                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //                             decoration: BoxDecoration(
// //                               border: Border.all(color: Colors.green, width: 1),
// //                               borderRadius: BorderRadius.circular(10),
// //                               color: Colors.white,
// //                             ),
// //                             child: DropdownButtonHideUnderline(
// //                               child: DropdownButton<String>(
// //                                 value: selectedCategory,
// //                                 hint: const Text('Select Category'),
// //                                 isExpanded: true,
// //                                 icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
// //                                 onChanged: (value) {
// //                                   setState(() => selectedCategory = value);
// //                                 },
// //                                 items: category.map((item) {
// //                                   return DropdownMenuItem<String>(
// //                                     value: item.keys.first,
// //                                     child: Text(item.values.first.toString()),
// //                                   );
// //                                 }).toList(),
// //                               ),
// //                             ),
// //                           ),
// //                           const SizedBox(height: 14),
// //                           // File picker (image only)
// //                           GestureDetector(
// //                             onTap: _pickFile,
// //                             child: ImagePickerArea(
// //                               selectedFile: _selectedFile,
// //                               webFileBytes: _webFileBytes,
// //                             ),
// //                           ),
// //                           const SizedBox(height: 12),
// //                           SizedBox(
// //                             width: double.infinity,
// //                             child: ElevatedButton.icon(
// //                               icon: const Icon(Icons.send),
// //                               label: const Padding(
// //                                 padding: EdgeInsets.symmetric(vertical: 14),
// //                                 child: Text('Send', style: TextStyle(fontSize: 16)),
// //                               ),
// //                               onPressed: _isLoading
// //                                   ? null
// //                                   : () async {
// //                                 if (!_validate()) return;
// //                                 setState(() => _isLoading = true);
// //                                 try {
// //                                   SharedPreferences sh = await SharedPreferences.getInstance();
// //                                   var request = http.MultipartRequest(
// //                                       'POST',
// //                                       Uri.parse('${sh.getString('ip')}/distributor_add_product'));
// //                                   request.fields['product_name'] = product_name.text;
// //                                   request.fields['price'] = price.text;
// //                                   request.fields['quantity'] = quantity.text;
// //                                   request.fields['description'] = description.text;
// //                                   request.fields['category'] = selectedCategory.toString();
// //                                   request.fields['uid'] = sh.getString('uid').toString();
// //
// //                                   if (kIsWeb) {
// //                                     if (_webFileBytes != null) {
// //                                       request.files.add(http.MultipartFile.fromBytes(
// //                                         'file',
// //                                         _webFileBytes!,
// //                                         filename: _selectedFile!.name,
// //                                       ));
// //                                     }
// //                                   } else {
// //                                     if (_selectedFile != null && _selectedFile!.path != null) {
// //                                       request.files.add(await http.MultipartFile.fromPath(
// //                                         'file',
// //                                         _selectedFile!.path!,
// //                                       ));
// //                                     }
// //                                   }
// //
// //                                   var response = await request.send();
// //                                   if (response.statusCode == 200) {
// //                                     _showMessage("Product added");
// //                                     await Future.delayed(const Duration(milliseconds: 400));
// //                                     Navigator.pushReplacement(context,
// //                                         MaterialPageRoute(builder: (context) => const home_page()));
// //                                   } else {
// //                                     _showMessage("Upload failed: ${response.statusCode}", error: true);
// //                                   }
// //                                 } catch (e) {
// //                                   debugPrint("Upload error: $e");
// //                                   _showMessage("Error: $e", error: true);
// //                                 } finally {
// //                                   if (mounted) setState(() => _isLoading = false);
// //                                 }
// //                               },
// //                               style: ElevatedButton.styleFrom(
// //                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 30),
// //                 ],
// //               ),
// //             ),
// //             if (_isLoading)
// //               Container(
// //                 color: Colors.black38,
// //                 child: const Center(child: CircularProgressIndicator()),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // /// Image-only picker area with preview
// // class ImagePickerArea extends StatelessWidget {
// //   final PlatformFile? selectedFile;
// //   final Uint8List? webFileBytes;
// //
// //   const ImagePickerArea({Key? key, this.selectedFile, this.webFileBytes}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     return Container(
// //       width: double.infinity,
// //       constraints: const BoxConstraints(minHeight: 120),
// //       decoration: BoxDecoration(
// //         color: Colors.grey.shade50,
// //         borderRadius: BorderRadius.circular(10),
// //         border: Border.all(color: Colors.grey.shade300, width: 1.2),
// //       ),
// //       padding: const EdgeInsets.all(12),
// //       child: selectedFile == null
// //           ? Row(
// //         children: [
// //           Icon(Icons.photo_camera_outlined, size: 36, color: Colors.grey.shade600),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Text(
// //               "Tap to select an image",
// //               style: theme.textTheme.bodyMedium!.copyWith(color: Colors.grey.shade700),
// //             ),
// //           )
// //         ],
// //       )
// //           : Row(
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         children: [
// //           if (webFileBytes != null)
// //             Container(
// //               height: 84,
// //               width: 84,
// //               decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(8),
// //                 image: DecorationImage(image: MemoryImage(webFileBytes!), fit: BoxFit.cover),
// //               ),
// //             )
// //           else if (selectedFile!.path != null)
// //             Container(
// //               height: 84,
// //               width: 84,
// //               decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(8),
// //                 color: Colors.grey.shade200,
// //               ),
// //               child: const Icon(Icons.image_outlined, size: 36, color: Colors.grey),
// //             )
// //           else
// //             Container(
// //               height: 84,
// //               width: 84,
// //               decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(8),
// //                 color: Colors.grey.shade200,
// //               ),
// //               child: const Icon(Icons.insert_drive_file_outlined, size: 36, color: Colors.grey),
// //             ),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(selectedFile!.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
// //                 const SizedBox(height: 6),
// //                 Text("${(selectedFile!.size / 1024).toStringAsFixed(1)} KB", style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
// //               ],
// //             ),
// //           ),
// //           IconButton(
// //             icon: const Icon(Icons.clear),
// //             onPressed: () {
// //               // Clear selection by calling Navigator to pop a small dialog to instruct user
// //               // Parent manages the state; show quick instruction
// //               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tap the box to pick a different image.")));
// //             },
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // }
