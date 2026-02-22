
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Customerdirectory/custviews/viewCart.dart';
import 'package:snap2bill/theme/colors.dart';

import '../../widgets/Navbar.dart';
import '../../widgets/SnackBar.dart';
import '../../widgets/app_button.dart';

class addOrder extends StatefulWidget {
  final String? pid;
  const addOrder({Key? key, this.pid}) : super(key: key);

  @override
  State<addOrder> createState() => _addOrderState();
}

class _addOrderState extends State<addOrder> {
  final TextEditingController _qtyController = TextEditingController(text: "1");
  Map<String, dynamic>? productData;
  List<dynamic> fbtProducts = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _ip = "";
  late Color successColor, dangerColor;



  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  // Agar user poora text delete kar de toh default 1 return karega
  int get currentQty => int.tryParse(_qtyController.text) ?? 1;

  Future<void> _fetchDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _ip = prefs.getString("ip") ?? "";
    String pid = widget.pid ?? prefs.getString("pid") ?? "";

    final response = await http.post(
      Uri.parse("$_ip/get_product_details"),
      body: {'pid': pid},
    );

    if (response.statusCode == 200) {
      setState(() {
        productData = json.decode(response.body)['data'];
      });

      _fetchSuggestions(pid);
      _saveToRecentOnServer(pid);
    }
  }

  Future<void> _saveToRecentOnServer(String sid) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await http.post(
        Uri.parse("$_ip/add_to_recent"),
        body: {
          'cid': prefs.getString("cid"),
          'sid': sid,
        },
      );
    } catch (e) {
      debugPrint("Error logging recent view: $e");
    }
  }

  Future<void> _fetchSuggestions(String sid) async {
    try {
      final response = await http.post(
        Uri.parse("$_ip/get_incremental_suggestions"),
        body: {'sid': sid},
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            fbtProducts = data['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("FBT Fetch Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addToCart({String? customPid, String? customQty}) async {
    if (currentQty < 1) {
      setState(() => _qtyController.text = "1");
    }

    setState(() => _isSubmitting = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse("$_ip/addorder"),
      body: {
        "quantity": customQty ?? _qtyController.text,
        'cid': prefs.getString("cid"),
        'pid': customPid ?? (widget.pid ?? prefs.getString("pid")),
      },
    );

    if (json.decode(response.body)['status'] == 'ok') {
      CustomSnackBar.show(context, "Added to cart!", backgroundColor: successColor);

      if (customPid == null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const viewCart())
        ).then((_) {
          Navigator.pop(context, "refresh");
        });
      }
    }
    setState(() => _isSubmitting = false);
  }

  @override
  @override
  Widget build(BuildContext context) {
    successColor = AppColors.getSuccessColor(context);
    dangerColor = AppColors.getDangerColor(context);

    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    int availableStock = int.tryParse(productData!['stock_quantity'].toString()) ?? 0;
    bool isOutOfStock = availableStock <= 0;

    double price = double.tryParse(productData!['price'].toString()) ?? 0.0;
    double totalPrice = price * currentQty;
    String unit = productData!['unit_name'] ?? "Unit";

    final bgColor = AppColors.getScaffoldBg(context);
    final textColor = AppColors.getTextColor(context);
    final cardColor = AppColors.getCardColor(context);
    final subTextColor = AppColors.getTextSubColor(context);
    final borderColor = AppColors.getBorderColor(context).withValues(alpha: 0.5);
    final primaryColor = AppColors.getPrimaryColor(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: ThemeNavbar(
        title: "Order Product",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () => Navigator.pop(context, "refresh"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            const SizedBox(height: 25),

            // 🔥 Stock Status Badge (Optional but looks premium)
            if (isOutOfStock)
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: dangerColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text("Currently Out of Stock", style: TextStyle(color: dangerColor, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            else
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: successColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text("In Stock: $availableStock", style: TextStyle(color: successColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),

            _buildMainInfo(cardColor, primaryColor, textColor, subTextColor, borderColor, unit, availableStock, isOutOfStock),
            const SizedBox(height: 20),
            _buildDescription(cardColor, textColor, subTextColor),
            const SizedBox(height: 30),

            if (fbtProducts.isNotEmpty) ...[
              Text(
                "Frequently Bought Together",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fbtProducts.length,
                  itemBuilder: (context, index) {
                    var item = fbtProducts[index];
                    return _buildFBTCard(item, cardColor, textColor, subTextColor, primaryColor);
                  },
                ),
              ),
            ],
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(cardColor, subTextColor, unit, primaryColor, totalPrice, isOutOfStock),
    );
  }

  // WIDGET HELPERS
  Widget _buildProductImage() {
    return Container(
      height: 320, width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: AppColors.BlackColor.withValues(alpha:0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Hero(
        tag: 'prod_${productData!['id']}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: _ip + productData!['image'],
              fit: BoxFit.cover, // 🔥 UPDATE: BoxFit.fill ki jagah cover taaki image stretch na ho
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFBTCard(item, cardColor, textColor, subTextColor, primaryColor) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: subTextColor.withValues(alpha:0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: _ip + item['image'],
                fit: BoxFit.cover, // 🔥 UPDATE: Card me bhi cover zyada premium lagta hai
                width: double.infinity,
                errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(item['product_name'], maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
          Text("₹${item['price']}", style: TextStyle(fontSize: 12, color: successColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          InkWell(
            onTap: () {
              SharedPreferences.getInstance().then((prefs) {
                prefs.setString("pid", item['id'].toString());
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => addOrder(pid: item['id'].toString())));
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(color: primaryColor.withValues(alpha:0.1), borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Text("+ Add", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMainInfo(cardColor, primaryColor, textColor, subTextColor, borderColor, unit, int availableStock, bool isOutOfStock) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(productData!['category'].toString().toUpperCase(), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Text(productData!['product_name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Unit Price", style: TextStyle(color: subTextColor, fontSize: 12)),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("₹${productData!['price']}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: successColor))),
                ]),
              ),
              const SizedBox(width: 10,),
              // 🚀 Agar Out of Stock hai, toh selector hide kar do
              if (!isOutOfStock)
                _buildQtySelector(primaryColor, borderColor, textColor, subTextColor, unit, availableStock),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtySelector(primaryColor, borderColor, textColor, subTextColor, unit, int availableStock) {
    return Container(
      decoration: BoxDecoration(color: AppColors.getPillBg(context), borderRadius: BorderRadius.circular(18), border: Border.all(color: borderColor)),
      child: Row(children: [
        IconButton(
            onPressed: () {
              if (currentQty > 1) {
                setState(() => _qtyController.text = (currentQty - 1).toString());
              }
            },
            icon: Icon(Icons.remove_circle_outline, color: primaryColor)
        ),
        SizedBox(
            width: 55,
            child: TextField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  if (v.isNotEmpty) {
                    int val = int.tryParse(v) ?? 1;
                    // 🔥 UPDATE: User stock limit (ya max 100) se upar type nahi kar sakta
                    int maxAllowed = availableStock > 100 ? 100 : availableStock;

                    if (val > maxAllowed) {
                      _qtyController.text = maxAllowed.toString();
                      _qtyController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _qtyController.text.length)
                      );
                      CustomSnackBar.show(context, "Only $maxAllowed items in stock", backgroundColor: dangerColor);
                    }
                  }
                  setState(() {});
                },
                decoration: const InputDecoration(border: InputBorder.none)
            )
        ),
        IconButton(
            onPressed: () {
              // 🔥 UPDATE: Plus button bhi stock se upar nahi jayega
              int maxAllowed = availableStock > 100 ? 100 : availableStock;
              if (currentQty < maxAllowed) {
                setState(() => _qtyController.text = (currentQty + 1).toString());
              } else {
                CustomSnackBar.show(context, "Maximum stock reached", backgroundColor: dangerColor);
              }
            },
            icon: Icon(Icons.add_circle_outline, color: primaryColor)
        ),
      ]),
    );
  }

  Widget _buildDescription(cardColor, textColor, subTextColor) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 12),
        Text(productData!['description'] ?? "No description available.", style: TextStyle(color: subTextColor, height: 1.6, fontSize: 14)),
      ]),
    );
  }

  Widget _buildBottomBar(cardColor, subTextColor, unit, primaryColor, totalPrice, bool isOutOfStock) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
      decoration: BoxDecoration(color: cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Total ($currentQty $unit)", style: TextStyle(color: subTextColor, fontSize: 13)),
          Text("₹${totalPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isOutOfStock ? Colors.grey : primaryColor)),
        ]),
        const SizedBox(width: 10),
        Expanded(
            child: InkWell(
              onTap: isOutOfStock ? null : _addToCart, // 🛑 Disable click if out of stock
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: isOutOfStock ? Colors.grey.withOpacity(0.5) : primaryColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isOutOfStock ? Icons.remove_shopping_cart : Icons.shopping_cart_outlined, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      isOutOfStock ? "OUT OF STOCK" : "ADD TO CART",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
        ),
      ]),
    );
  }
}