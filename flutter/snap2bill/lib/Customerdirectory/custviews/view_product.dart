import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:readmore/readmore.dart';

import 'package:snap2bill/Distributordirectory/addfolder/addOrder.dart';

class view_product extends StatelessWidget {
  const view_product({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const view_product_sub();
  }
}

class view_product_sub extends StatefulWidget {
  const view_product_sub({Key? key}) : super(key: key);

  @override
  State<view_product_sub> createState() => _view_product_subState();
}

class _view_product_subState extends State<view_product_sub> {

  // --- Helper to fix URLs ---
  String _joinUrl(String base, String path) {
    if (path.isEmpty || path == "null") return "";
    if (base.endsWith("/") && path.startsWith("/")) return base + path.substring(1);
    if (!base.endsWith("/") && !path.startsWith("/")) return "$base/$path";
    return base + path;
  }

  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String b = prefs.getString("lid").toString();
    String ip = prefs.getString("ip") ?? "";

    if (ip.isEmpty) return [];

    try {
      var data = await http.post(
          Uri.parse("$ip/customer_view_products"),
          body: {"id": b});

      if (data.statusCode != 200) return [];

      var jsonData = json.decode(data.body);
      List<Joke> jokes = [];

      if (jsonData["data"] != null) {
        for (var joke in jsonData["data"]) {
          Joke newJoke = Joke(
            joke["id"].toString(),
            joke["product_name"] ?? "Unknown",
            joke["price"].toString(),
            _joinUrl(ip, joke["image"].toString()),
            joke["description"].toString(),
            joke["quantity"].toString(),
            (joke["CATEGORY"] ?? "").toString(),
            (joke["CATEGORY_NAME"] ?? "").toString(),
            (joke["distributor_name"] ?? "Seller").toString(),
            _joinUrl(ip, (joke["distributor_image"] ?? "").toString()),
            (joke["distributor_phone"] ?? "").toString(),
          );
          jokes.add(newJoke);
        }
      }
      return jokes;
    } catch (e) {
      debugPrint("Error fetching data: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Feed",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_bag_outlined, color: textColor),
            onPressed: () {},
          )
        ],
      ),
      body: FutureBuilder(
        future: _getJokes(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.primaryColor));
          } else if (snapshot.data == null || snapshot.data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 60, color: theme.disabledColor),
                  const SizedBox(height: 10),
                  Text("No products found", style: TextStyle(color: theme.disabledColor)),
                ],
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                var i = snapshot.data![index];
                return _buildInstagramPost(context, i, theme, textColor, subTextColor);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildInstagramPost(BuildContext context, Joke i, ThemeData theme, Color textColor, Color subTextColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 0.5),
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.dividerColor,
                  radius: 18,
                  child: ClipOval(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: (i.distributor_image.isNotEmpty)
                          ? Image.network(
                        i.distributor_image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, size: 20, color: subTextColor);
                        },
                      )
                          : Icon(Icons.person, size: 20, color: subTextColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        i.distributor_name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                      ),
                      // VISIBLE CATEGORY IN HEADER
                      Text(
                        i.distributor_phone.isNotEmpty
                            ? "${i.CATEGORY_NAME} • ${i.distributor_phone}"
                            : i.CATEGORY_NAME,
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // 3-DOT MENU
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, color: textColor),
                  color: theme.cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'cart') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => addOrder()));
                    } else if (value == 'wishlist') {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: theme.primaryColor,
                          content: const Text("Added to Wishlist")));
                    } else if (value == 'share') {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: theme.primaryColor,
                          content: const Text("Sharing Product...")));
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'cart',
                      child: Row(
                        children: [
                          Icon(Icons.shopping_cart_outlined, color: textColor, size: 20),
                          const SizedBox(width: 10),
                          Text('Add to Cart', style: TextStyle(color: textColor)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'wishlist',
                      child: Row(
                        children: [
                          Icon(Icons.favorite_border, color: textColor, size: 20),
                          const SizedBox(width: 10),
                          Text('Add to Wishlist', style: TextStyle(color: textColor)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share_outlined, color: textColor, size: 20),
                          const SizedBox(width: 10),
                          Text('Share Product', style: TextStyle(color: textColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. IMAGE
          Container(
            height: 400,
            width: double.infinity,
            color: theme.brightness == Brightness.dark ? Colors.black26 : Colors.grey.shade100,
            child: Image.network(
              i.image,
              fit: BoxFit.cover,
              errorBuilder: (c, o, s) => Center(child: Icon(Icons.broken_image, color: subTextColor)),
            ),
          ),

          // 3. ACTION BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(Icons.favorite_border, color: textColor, size: 28),
                const SizedBox(width: 16),
                Icon(Icons.share_outlined, color: textColor, size: 28),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>addOrder()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: const Text("Add to Cart", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // 4. DETAILS & DESCRIPTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      i.product_name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                    ),
                    const Spacer(),
                    Text(
                      "₹${i.price}",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: theme.primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ReadMoreText(
                  i.description,
                  trimLines: 2,
                  colorClickableText: Colors.grey,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: ' read more',
                  trimExpandedText: ' show less',
                  style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
                  moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                  lessStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),

                const SizedBox(height: 8),

                // VISIBLE CATEGORY HASHTAG
                Text(
                  "#${i.CATEGORY_NAME.replaceAll(' ', '')}",
                  style: TextStyle(color: Colors.blue.shade400, fontSize: 13, fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Joke {
  final String id;
  final String product_name;
  final String price;
  final String image;
  final String description;
  final String quantity;
  final String CATEGORY;
  final String CATEGORY_NAME;
  final String distributor_name;
  final String distributor_image;
  final String distributor_phone;

  Joke(
      this.id,
      this.product_name,
      this.price,
      this.image,
      this.description,
      this.quantity,
      this.CATEGORY,
      this.CATEGORY_NAME,
      this.distributor_name,
      this.distributor_image,
      this.distributor_phone
      );
}