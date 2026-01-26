import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:snap2bill/theme/colors.dart';
import 'package:snap2bill/widgets/CustomerNavigationBar.dart';

// Make sure these point to your actual file locations
import '../../widgets/Navbar.dart';
import '../../widgets/SnackBar.dart';
import '../../widgets/app_button.dart';

class send_review extends StatefulWidget {
  const send_review({Key? key}) : super(key: key);

  @override
  State<send_review> createState() => _send_reviewState();
}

class _send_reviewState extends State<send_review> {
  final TextEditingController reviews = TextEditingController();
  double rating = 0.0;
  bool isLoading = false;

  // --- API Logic ---
  Future<void> submitReview() async {
    // 1. Validation
    if (reviews.text.isEmpty || rating == 0.0) {
      CustomSnackBar.show(
        context,
        'Please select a rating and write a review',
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ip = prefs.getString('ip');
      String? cid = prefs.getString('cid');
      String? uid = prefs.getString('uid'); // Distributor ID

      if (ip == null) {
        throw Exception("IP address not found in storage");
      }

      final uri = Uri.parse("$ip/send_review");

      // DEBUG: Print what we are sending
      print("Sending to: $uri");
      print("Params: cid=$cid, uid=$uid, rating=$rating");

      var response = await http.post(
        uri,
        body: {
          'reviews': reviews.text,
          'rating': rating.toString(),
          'cid': cid ?? "",
          'uid': uid ?? "",
        },
      );

      // DEBUG: Print exactly what the server replied
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      // 2. Check for Server Errors (404, 500, etc)
      if (response.statusCode != 200) {
        throw Exception("Server Error: ${response.statusCode}");
      }

      // 3. Check for HTML response (The cause of your error)
      if (response.body.trim().startsWith("<") || response.body.isEmpty) {
        throw Exception("Server returned HTML/Empty instead of JSON. Check your PHP script.");
      }

      var jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == 'ok') {
        if (!mounted) return;

        CustomSnackBar.show(
          context,
          'Review sent successfully!',
          backgroundColor: Colors.green,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CustomerNavigationBar(initialIndex: 2,)),
        );
      } else {

        CustomSnackBar.show(
          context,
          'Failed to send review!',
          backgroundColor: AppColors.dangerColor,
        );
      }
    } catch (e) {
      print("CRITICAL ERROR: $e"); // View this in your Run tab

      CustomSnackBar.show(
        context,
        'Error : $e',
        backgroundColor: AppColors.dangerColor,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
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
      appBar: ThemeNavbar(title: "Write Review",
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
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.amber.shade50,
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
                    Icons.star_rounded,
                    size: 55,
                    color: isDark ? Colors.amber.shade200 : Colors.amber.shade600
                ),
              ),
              const SizedBox(height: 30),

              // --- Instruction Text ---
              Text(
                "Rate your experience",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "How was your experience with this distributor?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: hintColor),
              ),
              const SizedBox(height: 30),

              // --- Review Form Card ---
              Container(
                padding: const EdgeInsets.all(25),
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
                  children: [
                    // Rating Bar
                    RatingBar.builder(
                      initialRating: rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${rating.toString()} / 5.0",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                          fontSize: 16
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Divider(),
                    const SizedBox(height: 25),

                    // Review Text Field
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          "Your Review",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: textColor.withValues(alpha:0.7)
                          )
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: reviews,
                      maxLines: 4,
                      style: TextStyle(color: textColor, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Share your thoughts here...",
                        hintStyle: TextStyle(color: hintColor, fontSize: 14),
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
                text: "Submit Review",
                onPressed: submitReview,
                isLoading: isLoading,

                // Theme Adaptation
                color: buttonColor,
                textColor: buttonTextColor,

                // Icon Styling
                icon: Icons.check_circle_outline,
                isTrailingIcon: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}