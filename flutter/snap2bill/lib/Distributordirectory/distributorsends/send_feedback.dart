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
//                   var data = await http.post(Uri.parse('${prefs.getString("ip")}/send_feedback'),
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
import 'package:snap2bill/theme/colors.dart';
import 'package:snap2bill/widgets/distributorNavigationbar.dart';

// Make sure these point to your actual file locations
import '../../widgets/Navbar.dart';
import '../../widgets/SnackBar.dart';
import '../../widgets/app_button.dart';

class send_feedback extends StatefulWidget {
  const send_feedback({Key? key}) : super(key: key);

  @override
  State<send_feedback> createState() => _send_feedbackState();
}

class _send_feedbackState extends State<send_feedback> {
  final feedbackController = TextEditingController();
  bool _isLoading = false;

  late Color successColor;

  // --- API Logic ---
  Future<void> submitFeedback() async {

    // 1. Validation
    if (feedbackController.text.trim().isEmpty) {
      CustomSnackBar.show(context, "Please enter your feedback first.", backgroundColor: AppColors.dangerColor);

      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var ip = prefs.getString("ip") ?? "";
      var uid = prefs.getString("uid") ?? "";

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
        CustomSnackBar.show(context, "Thank you! Feedback sent successfully.", backgroundColor: successColor, durationMs: 800);

        // Navigate back to Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  DistributorNavigationBar(initialIndex: 0,)),
        );
      } else {
        throw Exception('Failed to send feedback (Status: ${res.statusCode})');
      }
    } catch (e) {

      CustomSnackBar.show(context, Text('Error: $e') as String,
          backgroundColor: AppColors.dangerColor);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Theme Handling ---
    successColor = AppColors.getSuccessColor(context);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Design Colors
    final bgColor = AppColors.getScaffoldBg(context);
    final textColor = AppColors.getTextColor(context);
    final cardColor = AppColors.getCardColor(context);
    final hintColor = AppColors.getHintColor(context);
    final borderColor = AppColors.getBorderColor(context);
    // Button Colors
    final buttonColor = AppColors.getButtonColor(context);
    final buttonTextColor = AppColors.getTextColor2(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: ThemeNavbar(title: "Send Feedback",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: ()=>{
          if (Navigator.canPop(context)) Navigator.pop(context)
        },
        centerTitle: true,

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
                      color: Colors.black.withValues(alpha:0.05),
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
                      color: isDark? Colors.black.withValues(alpha:0.3): Colors.black.withValues(alpha:0.05),
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
                            color: textColor.withValues(alpha:0.7)
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