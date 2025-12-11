// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Distributordirectory/home_page.dart';
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
//
//                       }
//                   );
//                   Navigator.push(context, MaterialPageRoute(builder: (context)=>home_page()));
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
import 'package:snap2bill/Distributordirectory/home_page.dart';

// Make sure these point to your actual file locations
import '../../widgets/app_button.dart';

class send_feedback extends StatefulWidget {
  const send_feedback({Key? key}) : super(key: key);

  @override
  State<send_feedback> createState() => _send_feedbackState();
}

class _send_feedbackState extends State<send_feedback> {
  final feedbackController = TextEditingController();
  bool _isLoading = false;

  // --- API Logic ---
  Future<void> submitFeedback() async {
    // 1. Validation
    if (feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      var ip = sh.getString("ip") ?? "";
      var uid = sh.getString("uid") ?? "";

      // Ensure IP is valid
      if (ip.isEmpty) {
        throw Exception("Server IP not found. Please log in again.");
      }

      var res = await http.post(
        Uri.parse('$ip/send_feedback'),
        body: {
          'feedbacks': feedbackController.text,
          'uid': uid,
        },
      );

      if (res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you! Feedback sent successfully')),
        );
        // Navigate back to Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home_page()),
        );
      } else {
        throw Exception('Failed to send feedback (Status: ${res.statusCode})');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Theme Handling ---
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Design Colors
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = theme.cardColor;
    final hintColor = isDark ? Colors.white38 : Colors.grey[500];
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;

    // Button Colors
    final buttonColor = isDark ? Colors.white : Colors.black;
    final buttonTextColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          "Feedback",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // --- Header Icon ---
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.purple.shade50,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 45,
                    color: isDark ? Colors.white : Colors.purple.shade400
                ),
              ),
              const SizedBox(height: 30),

              // --- Instruction Text ---
              Text(
                "We value your opinion!",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Let us know what you think about our app.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: hintColor),
              ),
              const SizedBox(height: 30),

              // --- Feedback Input Card ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Your Message",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textColor.withOpacity(0.7)
                        )
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: feedbackController,
                      maxLines: 6, // Make it tall for feedback
                      minLines: 4,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(color: textColor, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Type your feedback here...",
                        hintStyle: TextStyle(color: hintColor, fontSize: 14),
                        // Clean styling without fill color as requested
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: textColor, width: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- App Button ---
              AppButton(
                text: "Send Feedback",
                onPressed: submitFeedback,
                isLoading: _isLoading,

                // Theme Adaptation
                color: buttonColor,
                textColor: buttonTextColor,

                // Icon styling
                icon: Icons.send_rounded,
                isTrailingIcon: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}