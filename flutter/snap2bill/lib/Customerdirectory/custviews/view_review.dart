import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Customerdirectory/distributor_page.dart';
import 'package:snap2bill/widgets/CustomerNavigationBar.dart';

class view_review extends StatefulWidget {
  const view_review({Key? key}) : super(key: key);

  @override
  State<view_review> createState() => _view_reviewState();
}

class _view_reviewState extends State<view_review> {
  bool _isDeleting = false;

  // --- API Logic ---
  Future<List<Joke>> _getReviews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ip = prefs.getString("ip");
    String? uid = prefs.getString("uid");
    String? cid = prefs.getString("cid");

    if (ip == null) return [];

    try {
      var data = await http.post(
          Uri.parse("$ip/view_review"),
          body: {
            "uid": uid ?? "",
            "cid": cid ?? ""
          }
      );

      if (data.statusCode != 200) {
        debugPrint("Error fetching data: ${data.statusCode}");
        return [];
      }

      var jsonData = json.decode(data.body);

      if (jsonData["data"] == null) return [];

      List<Joke> reviews = [];
      for (var item in jsonData["data"]) {
        reviews.add(Joke(
          (item["id"] ?? "").toString(),
          (item["reviews"] ?? "").toString(),
          (item["rating"] ?? "0.0").toString(),
          (item["review_date"] ?? "").toString(),
          (item["username"] ?? "Anonymous").toString(),
          (item["distributor"] ?? "Unknown").toString(),
        ));
      }
      return reviews;
    } catch (e) {
      debugPrint("Error: $e");
      return [];
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    // 1. Show Confirmation Dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Review"),
        content: const Text("Are you sure you want to delete this review?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ip = prefs.getString("ip");

      if (ip != null) {
        final uri = Uri.parse("$ip/delete_review/$reviewId");
        await http.post(uri, body: {'id': prefs.getString("id").toString()});

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review deleted")));

        // Refresh the page or navigate away as per your original logic
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CustomerNavigationBar(initialIndex: 3,)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
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
          "Reviews",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),

      body: FutureBuilder<List<Joke>>(
        future: _getReviews(),
        builder: (BuildContext context, AsyncSnapshot<List<Joke>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading reviews", style: TextStyle(color: textColor)));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined, size: 80, color: hintColor),
                  const SizedBox(height: 16),
                  Text(
                    "No reviews found",
                    style: TextStyle(color: hintColor, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              var i = items[index];
              return _buildReviewCard(i, cardColor, textColor, dateColor, isDark);
            },
          );
        },
      ),
    );
  }

  // --- Beautiful Review Card ---
  Widget _buildReviewCard(Joke i, Color cardColor, Color textColor, Color dateColor, bool isDark) {
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
            // 1. Header: Distributor & Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        i.distributor,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "by ${i.username}",
                        style: TextStyle(
                          fontSize: 12,
                          color: dateColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rating Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        i.rating,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),

            // 2. Review Content
            Text(
              i.reviews,
              style: TextStyle(
                color: textColor.withOpacity(0.9),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 15),

            // 3. Footer: Date & Delete Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  i.review_date,
                  style: TextStyle(
                    color: dateColor,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                // Delete Icon Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isDeleting ? null : () => _deleteReview(i.id),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Model Class
class Joke {
  final String id;
  final String reviews;
  final String rating;
  final String review_date;
  final String username;
  final String distributor;

  Joke(this.id, this.reviews, this.rating, this.review_date, this.username, this.distributor);
}