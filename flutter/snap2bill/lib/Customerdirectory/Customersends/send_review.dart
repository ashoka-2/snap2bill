// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Customerdirectory/distributor_page.dart';
//
//
//
//
//
//
// class send_review extends StatefulWidget {
//   const send_review({Key? key}) : super(key: key);
//
//   @override
//   State<send_review> createState() => _send_reviewState();
// }
//
// class _send_reviewState extends State<send_review> {
//   final reviews = new TextEditingController();
//   final rating = new TextEditingController();
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
//                 TextFormField(controller: reviews,
//                   decoration: InputDecoration(
//                       labelText: "Review",
//                       hintText: 'Enter your review',
//                       prefixIcon: Icon(Icons.reviews),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
//                   ),
//                 ),
//                 SizedBox(height: 10,),
//                 TextFormField(controller: rating,
//                   decoration: InputDecoration(
//                       labelText: "Rating",
//                       hintText: 'Rate your distributor',
//                       prefixIcon: Icon(Icons.reviews),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
//                   ),
//                 ),
//                 SizedBox(height: 10,),
//                 ElevatedButton(onPressed: () async {
//                   SharedPreferences sh=await SharedPreferences.getInstance();
//                   var data = await http.post(Uri.parse('${sh.getString("ip")}/send_review'),
//               body: {
//                 'reviews':reviews.text,
//                 'rating':rating.text,
//                 'cid':sh.getString('cid'),
//                 'uid':sh.getString('uid'),
//
//               }
//               );
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>distributor_page()));
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


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:snap2bill/Customerdirectory/distributor_page.dart';

class send_review extends StatefulWidget {
  const send_review({Key? key}) : super(key: key);

  @override
  State<send_review> createState() => _send_reviewState();
}

class _send_reviewState extends State<send_review> {
  final TextEditingController reviews = TextEditingController();
  double rating = 0.0;
  bool isLoading = false;

  Future<void> submitReview() async {
    if (reviews.text.isEmpty || rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a review and select a rating.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? ip = sh.getString('ip');
    String? cid = sh.getString('cid');
    String? uid = sh.getString('uid');

    try {
      var response = await http.post(
        Uri.parse("$ip/send_review"),
        body: {
          'reviews': reviews.text,
          'rating': rating.toString(),
          'cid': cid,
          'uid': uid,
        },
      );

      var jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == 'ok') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Review sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => distributor_page()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Failed to send review. Try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => isLoading = false);
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
          "Send Review",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Share Your Experience",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
                ),
                const SizedBox(height: 20),

                // ⭐ Rating Bar
                RatingBar.builder(
                  initialRating: rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (value) {
                    setState(() {
                      rating = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  "Rating: ${rating.toInt()} Star${rating > 1 ? 's' : ''}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),

                // 📝 Review Field
                TextFormField(
                  controller: reviews,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Review",
                    hintText: 'Write your feedback here...',
                    prefixIcon: const Icon(Icons.reviews),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),

                // 📨 Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.send),
                    label: Text(
                      isLoading ? "Sending..." : "Send Review",
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: isLoading ? null : submitReview,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
