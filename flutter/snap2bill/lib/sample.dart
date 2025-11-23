// // // // import 'dart:convert';
// // // //
// // // // import 'package:easytankapp/send_complaint.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // // import 'package:url_launcher/url_launcher.dart';
// // // // // import 'worker_add_service.dart';
// // // // import 'package:http/http.dart' as http;
// // // //
// // // // import 'common/color_extension.dart';
// // // //
// // // // // void main() {
// // // // //   runApp(MyApp());
// // // // // }
// // // // //
// // // // class userview_reply extends StatefulWidget {
// // // //   const userview_reply({Key? key, this.title="View reply"}) : super(key: key);
// // // //
// // // //   final String title;
// // // //
// // // //   @override
// // // //   _userview_replyState  createState() => _userview_replyState();
// // // //
// // // // }
// // // //
// // // // class _userview_replyState  extends State<userview_reply> {
// // // //
// // // //
// // // //
// // // //   Future<List<Joke>> _getJokes() async {
// // // //     SharedPreferences prefs = await SharedPreferences.getInstance();
// // // //     String b = prefs.getString("lid").toString();
// // // //     String foodimage="";
// // // //     var data =
// // // //     await http.post(Uri.parse(prefs.getString("ip").toString()+"/user_view_reply"),
// // // //         body: {"id":b}
// // // //     );
// // // //
// // // //     var jsonData = json.decode(data.body);
// // // // //    print(jsonData);
// // // //     List<Joke> jokes = [];
// // // //     for (var joke in jsonData["message"]) {
// // // //       print(joke);
// // // //       Joke newJoke = Joke(
// // // //           joke["id"].toString(),
// // // //           joke["complaint"],
// // // //           joke["complaint_date"].toString(),
// // // //           joke["reply"].toString(),
// // // //           joke["reply_date"].toString()
// // // //       );
// // // //       jokes.add(newJoke);
// // // //     }
// // // //     return jokes;
// // // //   }
// // // //
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         backgroundColor:TColor.primary,
// // // //         title: Text(widget.title),
// // // //       ),
// // // //       body:
// // // //
// // // //
// // // //       Container(
// // // //
// // // //         child:
// // // //         FutureBuilder(
// // // //           future: _getJokes(),
// // // //           builder: (BuildContext context, AsyncSnapshot snapshot) {
// // // // //              print("snapshot"+snapshot.toString());
// // // //             if (snapshot.data == null) {
// // // //               return Container(
// // // //                 child: Center(
// // // //                   child: Text("Loading..."),
// // // //                 ),
// // // //               );
// // // //             } else {
// // // //               return ListView.builder(
// // // //                 itemCount: snapshot.data.length,
// // // //                 itemBuilder: (BuildContext context, int index) {
// // // //                   var i = snapshot.data![index];
// // // //                   return Padding(
// // // //                     padding: const EdgeInsets.all(8.0),
// // // //                     child: Card(
// // // //                       elevation: 3,
// // // //                       shape: RoundedRectangleBorder(
// // // //                         borderRadius: BorderRadius.circular(10),
// // // //                         side: BorderSide(color: Colors.grey.shade300),
// // // //                       ),
// // // //                       child: Padding(
// // // //                         padding: const EdgeInsets.all(16.0),
// // // //                         child: Column(
// // // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // // //                           children: [
// // // //
// // // //                             SizedBox(height: 10),
// // // //                             _buildRow("Date:", i.complaint_date.toString()),
// // // //                             _buildRow("Complaint:", i.complaint.toString()),
// // // //                             _buildRow("Reply:", i.reply.toString()),
// // // //                             _buildRow("Date:", i.reply_date.toString()),
// // // //
// // // //                           ],
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                   );
// // // //                 },
// // // //               );
// // // //
// // // //
// // // //             }
// // // //           },
// // // //
// // // //
// // // //         ),
// // // //
// // // //
// // // //
// // // //
// // // //
// // // //       ),
// // // //
// // // //       floatingActionButton: FloatingActionButton(
// // // //         child: Icon(Icons.add),
// // // //         onPressed: () {
// // // //           Navigator.push(context, MaterialPageRoute(
// // // //               builder: (context)=>user_send_complaint(
// // // //               )));
// // // //         },
// // // //
// // // //       ),
// // // //     );
// // // //   }
// // // //   Widget _buildRow(String label, String value) {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.symmetric(vertical: 4),
// // // //       child: Row(
// // // //         children: [
// // // //           SizedBox(
// // // //             width: 100,
// // // //             child: Text(
// // // //               label,
// // // //               style: TextStyle(
// // // //                 fontWeight: FontWeight.bold,
// // // //               ),
// // // //             ),
// // // //           ),
// // // //           SizedBox(width: 5),
// // // //           Flexible(
// // // //             child: Text(
// // // //               value,
// // // //               style: TextStyle(
// // // //                 color: Colors.grey.shade800,
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // //
// // // //
// // // // class Joke {
// // // //   final String id;
// // // //   final String complaint;
// // // //
// // // //   final String complaint_date;
// // // //   final String reply;
// // // //   final String reply_date;
// // // //
// // // //
// // // //
// // // //
// // // //   Joke(this.id,this.complaint, this.complaint_date,this.reply,this.reply_date);
// // // // //  print("hiiiii");
// // // // }
// // //
// // //
// // //
// // //
// // // //⚡ Flutter Flow: 🎨✨ Choose File from Gallery → 🚀 Send to Django Backend
// // //
// // // import 'dart:convert';
// // //
// // // import 'package:flutter/material.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // // =====================================================
// // // // 📦 IMPORTS (Required Libraries for Image Upload)
// // // // =====================================================
// // // import 'package:file_picker/file_picker.dart';
// // // import 'package:flutter/foundation.dart'; // kIsWeb
// // // import 'dart:typed_data';
// // //
// // //
// // //
// // // void main(){
// // //   runApp(add_missing_item());
// // // }
// // //
// // // class add_missing_item extends StatelessWidget {
// // //   const add_missing_item({Key? key}) : super(key: key);
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(home: add_missing_itemsub(),);
// // //   }
// // // }
// // //
// // // class add_missing_itemsub extends StatefulWidget {
// // //   const add_missing_itemsub({Key? key}) : super(key: key);
// // //
// // //   @override
// // //   State<add_missing_itemsub> createState() => _add_missing_itemsubState();
// // // }
// // //
// // // class _add_missing_itemsubState extends State<add_missing_itemsub> {
// // //
// // //   final item_name=new TextEditingController();
// // //   final description=new TextEditingController();
// // //   final location =new TextEditingController();
// // //
// // //   // =====================================================
// // //   // 📸 FILE UPLOAD VARIABLES
// // //   // =====================================================
// // //   PlatformFile? _selectedFile;
// // //   Uint8List? _webFileBytes;
// // //   String? _result;
// // //   bool _isLoading = false;
// // //
// // //   // =====================================================
// // //   // 📸 PICK FILE FUNCTION
// // //   // =====================================================
// // //   Future<void> _pickFile() async {
// // //     FilePickerResult? result = await FilePicker.platform.pickFiles(
// // //       allowMultiple: false,
// // //       type: FileType.any, // Any file type allowed
// // //     );
// // //
// // //     if (result != null) {
// // //       setState(() {
// // //         _selectedFile = result.files.first;
// // //         _result = null;
// // //       });
// // //
// // //       if (kIsWeb) {
// // //         _webFileBytes = result.files.first.bytes;
// // //       }
// // //     }
// // //   }
// // //   // =====================================================
// // //   // 📸 END FILE PICK SECTION
// // //   // =====================================================
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(body: Center(child:
// // //     SingleChildScrollView(child:
// // //     SizedBox(height: 500,width: 500,child:
// // //     Column(children: [
// // //
// // //       // =====================================================
// // //       // 📸 FILE SELECTOR BUTTON + PREVIEW
// // //       // =====================================================
// // //       ElevatedButton.icon(
// // //         icon: Icon(Icons.upload_file),
// // //         label: Text("Select File"),
// // //         onPressed: _pickFile,
// // //       ),
// // //       if (_selectedFile != null) ...[
// // //         SizedBox(height: 10),
// // //         Text("Selected: ${_selectedFile!.name}"),
// // //       ],
// // //       // =====================================================
// // //       // 📸 END FILE SELECTOR
// // //       // =====================================================
// // //
// // //       SizedBox(height: 20),
// // //       TextField(controller: item_name,
// // //         decoration: InputDecoration(
// // //           border: OutlineInputBorder(),
// // //           hintText: 'enter item name',
// // //           labelText: 'item name',
// // //         ),),SizedBox(height: 20,),
// // //       TextField(controller: description,
// // //         maxLines: 5,
// // //         decoration: InputDecoration(
// // //             hintText: 'enter description',
// // //             labelText: 'description',
// // //             border: OutlineInputBorder()
// // //         ),),SizedBox(height: 20,),
// // //       TextField(controller: location,
// // //         decoration: InputDecoration(
// // //           border: OutlineInputBorder(),
// // //           hintText: 'enter location',
// // //           labelText: 'location',
// // //         ),),SizedBox(height: 20,),
// // //
// // //
// // //
// // //       ElevatedButton(onPressed: () async {
// // //         print(item_name.text);
// // //         print(description.text);
// // //         print(location.text);
// // //
// // //         SharedPreferences sh=await SharedPreferences.getInstance();
// // //
// // //         // =====================================================
// // //         // 🌐 SERVER REQUEST (POST to Django)
// // //         // =====================================================
// // //         var request =   await http.MultipartRequest(
// // //             'POST',
// // //             Uri.parse('${sh.getString('ip')}/aadd_missing_item')
// // //         );
// // //
// // //         // 🔹 Normal Form Data
// // //         request.fields['item'] = item_name.text;
// // //         request.fields['des'] = description.text;
// // //         request.fields['loc'] = location.text;
// // //         request.fields['uid'] = sh.getString('uid').toString();
// // //
// // //         // 🔹 File Upload Part
// // //         if (kIsWeb) {
// // //           request.files.add(http.MultipartFile.fromBytes(
// // //             'file',
// // //             _webFileBytes!,
// // //             filename: _selectedFile!.name,
// // //           ));
// // //         } else {
// // //           request.files.add(await http.MultipartFile.fromPath(
// // //             'file',
// // //             _selectedFile!.path!,
// // //           ));
// // //         }
// // //         // =====================================================
// // //         // 🌐 END SERVER UPLOAD SECTION
// // //         // =====================================================
// // //
// // //         var response = await request.send();
// // //
// // //         Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
// // //
// // //       }, child: Text('send'))
// // //
// // //     ],),),),),);
// // //   }
// // // }
// //
// // // 🌐💫 Flutter Power: Handling Data from Django → Setting Dropdown Values 💫🌐
// //
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// //
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // class HarithaKarmaRegisterSub extends StatefulWidget {
// //   @override
// //   _HarithaKarmaRegisterSubState createState() => _HarithaKarmaRegisterSubState();
// // }
// //
// // class _HarithaKarmaRegisterSubState extends State<HarithaKarmaRegisterSub> {
// //
// //   // 🔹 STEP 1: Declare Panchayath data list
// //   List<Map<String, dynamic>> panchayath = [];  // ✅ Holds data fetched from Django
// //
// //   // 🔹 STEP 2: Store selected Panchayath
// //   String? selectedPanchayath;  // ✅ Holds selected Panchayath ID
// //
// //   // ================================
// //   // 🔹 STEP 3: Load data from Django
// //   // ================================
// //   Future<void> loadPanchayath() async {
// //     try {
// //       SharedPreferences sh = await SharedPreferences.getInstance();
// //       final response = await http.post(
// //         Uri.parse("${sh.getString('ip')}/loadpanchayath"), // replace with your function
// //       );
// //       var decode = json.decode(response.body);
// //       decode['data'].forEach((item){
// //         setState(() {
// //           panchayath.add({
// //             // ✅ ID from Django model
// //             // ✅ Panchayath name field
// //
// //             item['id'].toString():
// //             item['name'].toString()});
// //
// //
// //         });
// //         print(panchayath);
// //
// //       });
// //
// //     } catch (e) {
// //       print("Error fetching Panchayath: $e");
// //     }
// //   }
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     loadPanchayath(); // ✅ Call function on screen load
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     double fieldWidth = MediaQuery.of(context).size.width * 0.9;
// //
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Register Haritha Karma Sena")),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //
// //             // ================================
// //             // 🔹 STEP 4: Panchayath Dropdown UI
// //             // ================================
// //             SizedBox(
// //               width: fieldWidth,
// //               child: Container(
// //                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// //                 decoration: BoxDecoration(
// //                   border: Border.all(color: Colors.green, width: 1.5),
// //                   borderRadius: BorderRadius.circular(12),
// //                   color: Colors.white,
// //                 ),
// //                 child: DropdownButton<String>(
// //                   value: selectedPanchayath,                // ✅ Selected Value
// //                   hint: Text('Select Panchayath'),          // ✅ Placeholder
// //                   isExpanded: true,
// //                   underline: SizedBox(),
// //                   icon: Icon(Icons.arrow_drop_down, color: Colors.green),
// //                   onChanged: (value) {
// //                     setState(() {
// //                       selectedPanchayath = value;           // ✅ Store selected
// //                     });
// //                   },
// //                   items: panchayath.map((item) {
// //                     return DropdownMenuItem<String>(
// //                       value: item["id"].toString(),          // ✅ ID as value
// //                       child: Text(item["name"].toString()),  // ✅ Display name
// //                     );
// //                   }).toList(),
// //                 ),
// //               ),
// //             ),
// //
// //             SizedBox(height: 20),
// //
// //             // 🔹 Button to check selected value
// //             ElevatedButton(
// //               onPressed: () {
// //                 print("Selected Panchayath ID: $selectedPanchayath");
// //               },
// //               child: Text("Submit"),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
//
//
//
//
//
//
//
//
// //⚡ Flutter Flow: 🎨✨ Choose File from Gallery → 🚀 Send to Django Backend
//
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// // =====================================================
// // 📦 IMPORTS (Required Libraries for Image Upload)
// // =====================================================
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart'; // kIsWeb
// import 'dart:typed_data';
//
// import 'home.dart';
//
// void main(){
//   runApp(add_missing_item());
// }
//
// class add_missing_item extends StatelessWidget {
//   const add_missing_item({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: add_missing_itemsub(),);
//   }
// }
//
// class add_missing_itemsub extends StatefulWidget {
//   const add_missing_itemsub({Key? key}) : super(key: key);
//
//   @override
//   State<add_missing_itemsub> createState() => _add_missing_itemsubState();
// }
//
// class _add_missing_itemsubState extends State<add_missing_itemsub> {
//
//   final item_name=new TextEditingController();
//   final description=new TextEditingController();
//   final location =new TextEditingController();
//
//   // =====================================================
//   // 📸 FILE UPLOAD VARIABLES
//   // =====================================================
//   PlatformFile? _selectedFile;
//   Uint8List? _webFileBytes;
//   String? _result;
//   bool _isLoading = false;
//
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
//   // =====================================================
//   // 📸 END FILE PICK SECTION
//   // =====================================================
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Center(child:
//     SingleChildScrollView(child:
//     SizedBox(height: 500,width: 500,child:
//     Column(children: [
//
//       // =====================================================
//       // 📸 FILE SELECTOR BUTTON + PREVIEW
//       // =====================================================
//       ElevatedButton.icon(
//         icon: Icon(Icons.upload_file),
//         label: Text("Select File"),
//         onPressed: _pickFile,
//       ),
//       if (_selectedFile != null) ...[
//         SizedBox(height: 10),
//         Text("Selected: ${_selectedFile!.name}"),
//       ],
//       // =====================================================
//       // 📸 END FILE SELECTOR
//       // =====================================================
//
//       SizedBox(height: 20),
//       TextField(controller: item_name,
//         decoration: InputDecoration(
//           border: OutlineInputBorder(),
//           hintText: 'enter item name',
//           labelText: 'item name',
//         ),),SizedBox(height: 20,),
//       TextField(controller: description,
//         maxLines: 5,
//         decoration: InputDecoration(
//             hintText: 'enter description',
//             labelText: 'description',
//             border: OutlineInputBorder()
//         ),),SizedBox(height: 20,),
//       TextField(controller: location,
//         decoration: InputDecoration(
//           border: OutlineInputBorder(),
//           hintText: 'enter location',
//           labelText: 'location',
//         ),),SizedBox(height: 20,),
//
//
//
//       ElevatedButton(onPressed: () async {
//         print(item_name.text);
//         print(description.text);
//         print(location.text);
//
//         SharedPreferences sh=await SharedPreferences.getInstance();
//
//         // =====================================================
//         // 🌐 SERVER REQUEST (POST to Django)
//         // =====================================================
//         var request =   await http.MultipartRequest(
//             'POST',
//             Uri.parse('${sh.getString('ip')}/aadd_missing_item')
//         );
//
//         // 🔹 Normal Form Data
//         request.fields['item'] = item_name.text;
//         request.fields['des'] = description.text;
//         request.fields['loc'] = location.text;
//         request.fields['uid'] = sh.getString('uid').toString();
//
//         // 🔹 File Upload Part
//         if (kIsWeb) {
//           request.files.add(http.MultipartFile.fromBytes(
//             'file',
//             _webFileBytes!,
//             filename: _selectedFile!.name,
//           ));
//         } else {
//           request.files.add(await http.MultipartFile.fromPath(
//             'file',
//             _selectedFile!.path!,
//           ));
//         }
//         // =====================================================
//         // 🌐 END SERVER UPLOAD SECTION
//         // =====================================================
//
//         var response = await request.send();
//
//         Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
//
//       }, child: Text('send'))
//
//     ],),),),),);
//   }
// }