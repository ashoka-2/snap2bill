import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Customerdirectory/Customersends/send_feedback.dart';

// Import your send feedback page
// Make sure this file exists in your project

class view_feedback extends StatefulWidget {
  const view_feedback({Key? key}) : super(key: key);

  @override
  State<view_feedback> createState() => _view_feedbackState();
}

class _view_feedbackState extends State<view_feedback> {

  // --- API Logic ---
  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString("ip");
    String? cid = prefs.getString("cid");

    // Basic validation
    if (ip == null || cid == null) return [];

    try {
      var data = await http.post(
          Uri.parse("$ip/view_feedback"),
          body: {"cid": cid} // Using CID as per your code
      );

      if (data.statusCode != 200) {
        debugPrint("Error fetching data: ${data.statusCode}");
        return [];
      }

      var jsonData = json.decode(data.body);

      if (jsonData["data"] == null) return [];

      List<Joke> jokes = [];
      for (var joke in jsonData["data"]) {
        Joke newJoke = Joke(
          (joke["id"] ?? "").toString(),
          (joke["feedbacks"] ?? "").toString(),
          (joke["feedback_date"] ?? "").toString(),
        );
        jokes.add(newJoke);
      }
      return jokes;
    } catch (e) {
      debugPrint("Error: $e");
      return [];
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
    final dateColor = isDark ? Colors.white54 : Colors.grey.shade600;

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
          "My Feedbacks",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),

      // --- Floating Button to Send Feedback ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const send_feedback())
          );
        },
        backgroundColor: isDark ? Colors.white : Colors.black,
        icon: Icon(Icons.edit_outlined, color: isDark ? Colors.black : Colors.white),
        label: Text(
            "Write Feedback",
            style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)
        ),
      ),

      body: FutureBuilder<List<Joke>>(
        future: _getJokes(),
        builder: (BuildContext context, AsyncSnapshot<List<Joke>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading feedbacks", style: TextStyle(color: textColor)));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mark_chat_read_outlined, size: 80, color: hintColor),
                  const SizedBox(height: 16),
                  Text(
                    "No feedbacks yet",
                    style: TextStyle(color: hintColor, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 80), // Bottom padding for FAB
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              var i = items[index];
              return _buildFeedbackCard(i, cardColor, textColor, dateColor, isDark);
            },
          );
        },
      ),
    );
  }

  // --- Beautiful Card Design ---
  Widget _buildFeedbackCard(Joke i, Color cardColor, Color textColor, Color dateColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon + Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon Bubble
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // Using Teal for Customer logic, or you can use your theme color
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.teal.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                      Icons.format_quote_rounded,
                      size: 20,
                      color: isDark ? Colors.white70 : Colors.teal.shade700
                  ),
                ),
                // Date Text
                Text(
                  i.feedback_date,
                  style: TextStyle(
                    color: dateColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Feedback Content
            Text(
              i.feedbacks,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keeping your original Model class name
class Joke {
  final String id;
  final String feedbacks;
  final String feedback_date;

  Joke(this.id, this.feedbacks, this.feedback_date);
}