// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Customerdirectory/customer_home_page.dart';
//
//
//
//
//
//
// class send_feedback extends StatefulWidget {
//   const send_feedback({Key? key}) : super(key: key);
//
//   @override
//   State<send_feedback> createState() => _send_feedbackState();
// }
//
// class _send_feedbackState extends State<send_feedback> {
//   final feedbacks = new TextEditingController();
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Container(
//             height: 200,
//             width: 500,
//
//             child: Column(
//               children: [
//                 TextFormField(controller: feedbacks,
//                   decoration: InputDecoration(
//                       labelText: "Feedback",
//                       hintText: 'Enter your feedback',
//                       prefixIcon: Icon(Icons.reviews),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
//                   ),
//                 ),
//                 SizedBox(height: 10,),
//                 ElevatedButton(onPressed: () async {
//                   SharedPreferences sh=await SharedPreferences.getInstance();
//                   var data = await http.post(Uri.parse('${sh.getString("ip")}/send_feedback'),
//                       body: {
//                         'feedbacks':feedbacks.text,
//                         'cid':sh.getString('cid'),
//                         'uid':sh.getString('uid'),
//
//                       }
//                   );
//                   Navigator.push(context, MaterialPageRoute(builder: (context)=>customer_home_page()));
//                 }, child: Text("Send"))
//               ],
//             ),
//
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Customerdirectory/customer_home_page.dart';

class send_feedback extends StatefulWidget {
  const send_feedback({Key? key}) : super(key: key);

  @override
  State<send_feedback> createState() => _send_feedbackState();
}

class _send_feedbackState extends State<send_feedback> {
  final feedbackController = TextEditingController();

  Future<void> submitFeedback() async {
    if (feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter feedback')));
      return;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    var ip = sh.getString("ip") ?? "";
    var cid = sh.getString("cid") ?? "";

    try {
      var res = await http.post(
        Uri.parse('$ip/send_feedback'),
        body: {
          'feedbacks': feedbackController.text,
          'cid': cid, // 👈 For customer
        },
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback sent successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const customer_home_page()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send feedback')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          "Send Feedback",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: feedbackController,
              decoration: InputDecoration(
                labelText: "Feedback",
                hintText: 'Enter your feedback',
                prefixIcon: const Icon(Icons.feedback),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitFeedback,
              child: const Text("Send"),
            ),
          ],
        ),
      ),
    );
  }
}
