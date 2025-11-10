import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/home_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'dart:typed_data';


class add_product extends StatelessWidget {
  const add_product({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: add_product_sub(),);
  }
}


class add_product_sub extends StatefulWidget {

  const add_product_sub({Key? key}) : super(key: key);

  @override
  State<add_product_sub> createState() => _add_product_subState();
}

class _add_product_subState extends State<add_product_sub> {
  final product_name = TextEditingController();
  final price = TextEditingController();
  final quantity = TextEditingController();
  final description = TextEditingController();
// =====================================================
  PlatformFile? _selectedFile;
  Uint8List? _webFileBytes;
  String? _result;
  bool _isLoading = false;

// 🔹 STEP 1: Declare Panchayath data list
  List<Map<String, dynamic>> category = [];  // ✅ Holds data fetched from Django

  // 🔹 STEP 2: Store selected Panchayath
  String? selectedCategory;  // ✅ Holds selected Panchayath ID

  // ================================
  // 🔹 STEP 3: Load data from Django
  // ================================
  Future<void> loadCategory() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse("${sh.getString('ip')}/view_category"), // replace with your function
      );
      var decode = json.decode(response.body);
      decode['data'].forEach((item){
        setState(() {
          selectedCategory =   item['id'].toString();
          category.add({
            // ✅ ID from Django model
            // ✅ Panchayath name field

            item['id'].toString():
            item['category_name'].toString()});


        });
        print(category);

      });

    } catch (e) {
      print("Error fetching Category: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadCategory(); // ✅ Call function on screen load
  }
  // =====================================================
  // 📸 PICK FILE FUNCTION
  // =====================================================
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any, // Any file type allowed
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
        _result = null;
      });

      if (kIsWeb) {
        _webFileBytes = result.files.first.bytes;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    double fieldWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      body:
      Container(child:
      Column(children: [
        TextField(
          controller: product_name,
          decoration: InputDecoration(
              hintText: 'Enter product name',
              labelText: 'Name',
              prefixIcon: Icon(Icons.abc),
              border: OutlineInputBorder()
          ),),SizedBox(height: 10,),
        TextField(controller: price,
          decoration: InputDecoration(
              hintText: 'Enter price',
              labelText: 'Price',
              prefixIcon: Icon(Icons.currency_rupee),
              border: OutlineInputBorder()
          ),),SizedBox(height: 10,),
        TextField(
          controller: quantity,
          decoration: InputDecoration(
              hintText: 'Enter quantity',
              labelText: 'Quantity',
              prefixIcon: Icon(Icons.abc),
              border: OutlineInputBorder()
          ),),SizedBox(height: 10,),
        TextField(controller: description,
          decoration: InputDecoration(
              hintText: 'Enter product description',
              labelText: 'Description',
              prefixIcon: Icon(Icons.abc),
              border: OutlineInputBorder()
          ),),SizedBox(height: 10,),
        SizedBox(
          width: fieldWidth,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: DropdownButton<String>(
              value: selectedCategory,                // ✅ Selected Value
              hint: Text('Select Category'),          // ✅ Placeholder
              isExpanded: true,
              underline: SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: Colors.green),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;           // ✅ Store selected
                });
              },
              items: category.map((item) {
                print("item${item['id']}");
                return DropdownMenuItem<String>(
                  value: item.keys.first,          // ✅ ID as value
                  child: Text(item.values.first),  // ✅ Display name
                );
              }).toList(),
            ),
          ),
        ),

        ElevatedButton.icon(
          icon: Icon(Icons.upload_file),
          label: Text("Select File"),
          onPressed: _pickFile,
        ),
        if (_selectedFile != null) ...[
          SizedBox(height: 10),
          Text("Selected: ${_selectedFile!.name}"),
        ],
        SizedBox(height: 10,),

        ElevatedButton(onPressed: () async {


          print(product_name.text);
          print(description.text);
          print(price.text);
          print(quantity.text);
          print(category);

          SharedPreferences sh=await SharedPreferences.getInstance();

          // =====================================================
          // 🌐 SERVER REQUEST (POST to Django)
          // =====================================================
          var request =   await http.MultipartRequest(
              'POST',
              Uri.parse('${sh.getString('ip')}/distributor_add_product')
          );

          // 🔹 Normal Form Data
          request.fields['product_name'] = product_name.text;
          request.fields['price'] = price.text;
          request.fields['quantity'] = quantity.text;
          request.fields['description'] = description.text;
          request.fields['category'] = selectedCategory.toString();
          request.fields['uid'] = sh.getString('uid').toString();




          // 🔹 File Upload Part
          if (kIsWeb) {
            request.files.add(http.MultipartFile.fromBytes(
              'file',
              _webFileBytes!,
              filename: _selectedFile!.name,
            ));
          } else {
            request.files.add(await http.MultipartFile.fromPath(
              'file',
              _selectedFile!.path!,
            ));
          }
          // =====================================================
          // 🌐 END SERVER UPLOAD SECTION
          // =====================================================

          var response = await request.send();

          Navigator.push(context, MaterialPageRoute(builder: (context)=>home_page()));

        }, child: Text('send'))
      ],

      ),),
    );
  }
}
