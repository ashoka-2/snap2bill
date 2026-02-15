//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snap2bill/Distributordirectory/view/viewOrderItems.dart';
//
// import '../../theme/colors.dart';
// import '../../widgets/Navbar.dart';
//
// class ViewAllOrders extends StatelessWidget {
//   const ViewAllOrders({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const ViewAllOrdersSub();
//   }
// }
//
// class ViewAllOrdersSub extends StatefulWidget {
//   const ViewAllOrdersSub({Key? key}) : super(key: key);
//
//   @override
//   State<ViewAllOrdersSub> createState() => _ViewAllOrdersSubState();
// }
//
// class _ViewAllOrdersSubState extends State<ViewAllOrdersSub> {
//   late Future<List<Joke>> _orderFuture;
//
//   late Color successColor;
//   late Color dangerColor;
//
//   @override
//   void initState() {
//     super.initState();
//     _orderFuture = _getJokes();
//   }
//
//   /// ---------------- REFRESH LOGIC ----------------
//   Future<void> _handleRefresh() async {
//     setState(() {
//       _orderFuture = _getJokes();
//     });
//     await _orderFuture;
//   }
//
//   /// ---------------- API CALL ----------------
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String ip = prefs.getString("ip") ?? "";
//     String uid = prefs.getString("uid") ?? "";
//
//     // Check if we are filtering by a specific customer (sent from Customer Page)
//     String? cid = prefs.getString("selected_customer_id");
//
//     try {
//       var data = await http.post(
//         Uri.parse("$ip/view_distributor_allorders"),
//         body: {
//           "uid": uid,
//           "cid": cid ?? "", // Filter by customer ID if it exists
//         },
//       );
//
//       var jsonData = json.decode(data.body);
//       List<Joke> jokes = [];
//
//       if (jsonData["status"] == "ok") {
//         for (var joke in jsonData["data"]) {
//           jokes.add(Joke(
//             joke["id"].toString(),
//             joke["payment_status"].toString(),
//             joke["payment_date"].toString(),
//             joke["date"].toString(),
//             joke["amount"].toString(),
//             joke["username"].toString(),
//             joke["distributor"] ?? "",
//             joke["order_type"].toString(),
//           ));
//         }
//       }
//       return jokes;
//     } catch (e) {
//       debugPrint("Error fetching orders: $e");
//       return [];
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     successColor = AppColors.getSuccessColor(context);
//     dangerColor = AppColors.getDangerColor(context);
//
//
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//
//
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: ThemeNavbar(title: "Order History",
//         leadingIcon: Icons.arrow_back_ios_rounded,
//         onLeadingPressed: ()=>{
//           if (Navigator.canPop(context)) Navigator.pop(context)
//         },
//         centerTitle: true,
//
//       ),
//       body: RefreshIndicator(
//         onRefresh: _handleRefresh,
//         color: theme.primaryColor,
//         child: FutureBuilder<List<Joke>>(
//           future: _orderFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return _buildEmptyState(theme);
//             }
//
//             return ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 return _buildModernOrderCard(snapshot.data![index], theme, isDark);
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   /// ---------------- EMPTY STATE ----------------
//   Widget _buildEmptyState(ThemeData theme) {
//     return Center(
//       child: Column(
//         mainAxisAlignment:MainAxisAlignment.center,
//         children: [
//           Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
//           const SizedBox(height: 16),
//           Text("No orders found",
//               style: TextStyle(color: Colors.grey, fontSize: 16)),
//         ],
//       ),
//     );
//   }
//
//   /// ---------------- ORDER CARD ----------------
//   Widget _buildModernOrderCard(Joke item, ThemeData theme, bool isDark) {
//     bool isPending = item.payment_status.toLowerCase() == "pending";
//     Color statusColor = isPending ? AppColors.orangeColor : successColor;
//     bool isOffline = item.type.toLowerCase().contains("offline");
//     String labelTitle = isOffline ? "Bill" : "Order";
//     Color labelColor = isOffline ? Colors.deepPurpleAccent : AppColors.getPrimaryColor(context);
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: isDark? Colors.black.withValues(alpha:0.3): Colors.black.withValues(alpha:0.05),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           )
//         ],
//       ),
//       child: InkWell(
//         onTap: () async {
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           prefs.setString("id", item.id); // Set the order ID for the next page
//           Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewOrderItems()));
//         },
//         borderRadius: BorderRadius.circular(24),
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header: Order ID and Status
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "$labelTitle #${item.id}", // 🚀 Updated label here
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: labelColor
//                     ),
//                   ),
//                   _buildStatusChip(item.payment_status.toUpperCase(), statusColor),
//                 ],
//               ),
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 child: Divider(height: 1, thickness: 0.5),
//               ),
//
//               // Detail Rows
//               _buildInfoRow(Icons.person_outline, "Customer", item.username, isDark),
//               const SizedBox(height: 10),
//               _buildInfoRow(Icons.calendar_today_outlined, "Placed on", item.date, isDark),
//               const SizedBox(height: 10),
//               _buildInfoRow(Icons.payments_outlined, "Paid on",
//                   item.payment_date == "None" || item.payment_date == "null" ? "Awaiting" : item.payment_date, isDark),
//
//               const SizedBox(height: 20),
//
//               // Footer: Amount
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text("Bill Amount", style: TextStyle(color: Colors.grey, fontSize: 13)),
//                   Flexible(
//                     flex: 3,
//                     child: FittedBox(
//                       fit: BoxFit.scaleDown,
//                       alignment: Alignment.centerRight,
//                       child: Text(
//                         "₹${item.amount}",
//                         style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w800,
//                             color: isDark ? AppColors.WhiteColor: Colors.black87
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatusChip(String label, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha:0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.bold,
//           color: color,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
//     return Row(
//       children: [
//         Icon(icon, size: 18, color: Colors.grey[400]),
//         const SizedBox(width: 10),
//         Text("$label: ", style: const TextStyle(color: Colors.grey, fontSize: 13)),
//         Expanded(
//           child: Text(
//             value,
//             style: TextStyle(
//                 color: isDark ? Colors.grey[300] : Colors.black87,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class Joke {
//   final String id;
//   final String payment_status;
//   final String payment_date;
//   final String date;
//   final String amount;
//   final String username;
//   final String distributor;
//   final String type;
//
//   Joke(this.id, this.payment_status, this.payment_date, this.date, this.amount, this.username, this.distributor, this.type);
// }

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/Distributordirectory/view/viewOrderItems.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../theme/colors.dart';
import '../../widgets/Navbar.dart';
import '../../widgets/SnackBar.dart';

class ViewAllOrders extends StatelessWidget {
  const ViewAllOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ViewAllOrdersSub();
  }
}

class ViewAllOrdersSub extends StatefulWidget {
  const ViewAllOrdersSub({Key? key}) : super(key: key);

  @override
  State<ViewAllOrdersSub> createState() => _ViewAllOrdersSubState();
}

class _ViewAllOrdersSubState extends State<ViewAllOrdersSub> {
  late Future<List<Joke>> _orderFuture;

  // 🚀 1. Date Filter State
  DateTime? _selectedDate;

  late Color successColor;
  late Color dangerColor;
  late Color cardColor;
  late Color textColor;
  late Color subTextColor;
  late Color primaryColor;

  @override
  void initState() {
    super.initState();
    _orderFuture = _getJokes();
  }

  // 🚀 Refresh Logic
  Future<void> _handleRefresh() async {
    setState(() {
      _orderFuture = _getJokes();
    });
    await _orderFuture;
  }

  // 🚀 2. Date Picker Logic
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final bool isDark = AppColors.isDarkMode(context);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.getPrimaryColor(context),
              brightness: isDark ? Brightness.dark : Brightness.light,
            ).copyWith(
              primary: AppColors.getPrimaryColor(context),
              onPrimary: AppColors.WhiteColor,
              surface: AppColors.getCardColor(context),
              onSurface: AppColors.getTextColor(context),
            ),
            dialogBackgroundColor: AppColors.getCardColor(context),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.getPrimaryColor(context),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _orderFuture = _getJokes();
      });
    }
  }

  // 🚀 3. Clear Filter Logic
  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
      _orderFuture = _getJokes();
    });
  }

  Future<void> _generatePdf(Joke order, String action) async {
    // 🚀 1. Show Custom Snackbar
    CustomSnackBar.show(
        context,
        "Preparing Invoice with Images...",
        backgroundColor: primaryColor
    );

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "";

      var res = await http.post(
        Uri.parse("$ip/view_distributor_ordersitems"),
        body: {"id": order.id},
      );

      if (res.statusCode != 200) {
        CustomSnackBar.show(context, "Error fetching items", backgroundColor: dangerColor);
        return;
      }

      var jsonData = json.decode(res.body);
      List items = jsonData['data'] ?? [];

      final pdf = pw.Document();
      final font = await PdfGoogleFonts.nunitoRegular();
      final boldFont = await PdfGoogleFonts.nunitoBold();
      final italicFont = await PdfGoogleFonts.nunitoItalic();

      // 🚀 Helper to download images for the PDF
      Future<Uint8List?> _downloadImage(String urlPath) async {
        try {
          String fullUrl = urlPath.startsWith('http') ? urlPath : "$ip$urlPath";
          final response = await http.get(Uri.parse(fullUrl)).timeout(const Duration(seconds: 5));
          if (response.statusCode == 200) return response.bodyBytes;
        } catch (e) {
          debugPrint("Image Download Error: $e");
        }
        return null;
      }

      // Pre-download all images before building the PDF
      List<Uint8List?> itemImages = [];
      for (var item in items) {
        final img = await _downloadImage(item['image'] ?? "");
        itemImages.add(img);
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          // 🚀 FOOTER: Har page ke niche "Bill Generated by Snap2Bill" dikhayega
          footer: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Bill Generated by Snap2Bill",
                      style: pw.TextStyle(font: italicFont, fontSize: 10, color: PdfColors.grey600),
                    ),
                    pw.Text(
                      "Page ${context.pageNumber} of ${context.pagesCount}",
                      style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ],
            );
          },
          build: (pw.Context context) {
            return [
              // --- HEADER ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("INVOICE", style: pw.TextStyle(fontSize: 26, font: boldFont, color: PdfColors.blue900)),
                  pw.Text("Date: ${order.date}", style: pw.TextStyle(font: font, fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 25),

              // --- INFO SECTION ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Bill To:", style: pw.TextStyle(color: PdfColors.grey700, font: boldFont, fontSize: 10)),
                      pw.Text(order.username, style: pw.TextStyle(fontSize: 15, font: boldFont)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Order ID: #${order.id}", style: pw.TextStyle(font: boldFont, fontSize: 12)),
                      pw.Text(
                          "Status: ${order.payment_status.toUpperCase()}",
                          style: pw.TextStyle(
                              color: order.payment_status.toLowerCase() == 'pending' ? PdfColors.orange : PdfColors.green,
                              font: boldFont,
                              fontSize: 10
                          )
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 25),

              // --- ITEMS TABLE ---
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(40),  // Pic
                  1: const pw.FlexColumnWidth(3),   // Product Name
                  2: const pw.FlexColumnWidth(1),   // Qty
                  3: const pw.FlexColumnWidth(1.5), // Price
                  4: const pw.FlexColumnWidth(1.5), // Total
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Pic", style: pw.TextStyle(font: boldFont, fontSize: 11))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Product", style: pw.TextStyle(font: boldFont, fontSize: 11))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Qty", style: pw.TextStyle(font: boldFont, fontSize: 11))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Price", style: pw.TextStyle(font: boldFont, fontSize: 11))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Total", textAlign: pw.TextAlign.right, style: pw.TextStyle(font: boldFont, fontSize: 11))),
                    ],
                  ),
                  // Table Rows
                  for (int i = 0; i < items.length; i++)
                    pw.TableRow(
                      verticalAlignment: pw.TableCellVerticalAlignment.middle,
                      children: [
                        // IMAGE CELL
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: itemImages[i] != null
                              ? pw.Image(pw.MemoryImage(itemImages[i]!), height: 35, width: 35, fit: pw.BoxFit.cover)
                              : pw.SizedBox(height: 35, width: 35),
                        ),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(items[i]['product_name'] ?? "N/A", style: pw.TextStyle(font: font, fontSize: 11))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("${items[i]['quantity']} ${items[i]['unit_name']}", style: pw.TextStyle(font: font, fontSize: 11))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("${items[i]['amount']}", style: pw.TextStyle(font: font, fontSize: 11))),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            (double.parse(items[i]['amount'].toString()) * int.parse(items[i]['quantity'].toString())).toStringAsFixed(2),
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(font: boldFont, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              pw.SizedBox(height: 25),

              // --- TOTAL SECTION ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Grand Total:", style: pw.TextStyle(fontSize: 14, font: font, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text(
                          "INR ${order.amount}",
                          style: pw.TextStyle(fontSize: 20, font: boldFont, color: PdfColors.blue900)
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 50),
              pw.Center(
                child: pw.Text("Thank you for choosing us!", style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700)),
              ),
            ];
          },
        ),
      );

      // 🚀 4. Action: Print or Share
      if (action == 'print') {
        await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'Invoice-${order.id}');
      } else {
        await Printing.sharePdf(bytes: await pdf.save(), filename: 'Invoice-${order.id}.pdf');
      }

      CustomSnackBar.show(context, "Invoice Ready!", backgroundColor: successColor);

    } catch (e) {
      debugPrint("PDF Error: $e");
      CustomSnackBar.show(context, "Something went wrong during PDF generation", backgroundColor: dangerColor);
    }
  }

  /// ---------------- API CALL ----------------
  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("ip") ?? "";
    String uid = prefs.getString("uid") ?? "";
    String? cid = prefs.getString("selected_customer_id");

    try {
      var data = await http.post(
        Uri.parse("$ip/view_distributor_allorders"), // 🚀 THIS IS THE ONLY CHANGE (URL)
        body: {
          "uid": uid,
          "cid": cid ?? "",
        },
      );

      var jsonData = json.decode(data.body);
      List<Joke> jokes = [];

      if (jsonData["status"] == "ok") {
        for (var joke in jsonData["data"]) {
          Joke newJoke = Joke(
            joke["id"].toString(),
            joke["payment_status"].toString(),
            joke["payment_date"].toString(),
            joke["date"].toString(),
            joke["amount"].toString(),
            joke["username"].toString(),
            joke["distributor"] ?? "",
            joke["order_type"].toString(),
          );

          // 🚀 Filter Logic
          if (_selectedDate != null) {
            try {
              DateTime orderDate = DateTime.parse(newJoke.date);
              if (orderDate.year == _selectedDate!.year &&
                  orderDate.month == _selectedDate!.month &&
                  orderDate.day == _selectedDate!.day) {
                jokes.add(newJoke);
              }
            } catch (e) {
              debugPrint("Date Parse Error: $e");
            }
          } else {
            jokes.add(newJoke);
          }
        }
      }
      return jokes;
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    successColor = AppColors.getSuccessColor(context);
    dangerColor = AppColors.getDangerColor(context);
    cardColor = AppColors.getCardColor(context);
    textColor = AppColors.getTextColor(context);
    subTextColor = AppColors.getTextSubColor(context);
    primaryColor = AppColors.getPrimaryColor(context);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: ThemeNavbar(
        title: "All Orders",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
        centerTitle: true,
        // 🚀 Calendar Action Button
        actions: [
          _selectedDate != null
              ? IconButton(
            icon: Icon(Icons.filter_alt_off_rounded, color: dangerColor),
            tooltip: "Clear Filter",
            onPressed: _clearDateFilter,
          )
              : IconButton(
            icon: Icon(Icons.calendar_month_rounded, color: textColor),
            tooltip: "Filter by Date",
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // 🚀 Selected Date Indicator
          if (_selectedDate != null)
            Container(
              width: double.infinity,
              color: primaryColor.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Showing orders for: ", style: TextStyle(color: subTextColor, fontSize: 13)),
                  Text(
                    "${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: theme.primaryColor,
              child: FutureBuilder<List<Joke>>(
                future: _orderFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return ListView(children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      _buildEmptyState(theme),
                    ]);
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _buildModernOrderCard(snapshot.data![index], theme, isDark);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(_selectedDate != null ? "No orders on this date" : "No orders found", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildModernOrderCard(Joke item, ThemeData theme, bool isDark) {
    bool isPending = item.payment_status.toLowerCase() == "pending";
    Color statusColor = isPending ? AppColors.orangeColor : successColor;
    bool isOffline = item.type.toLowerCase().contains("offline");
    String labelTitle = isOffline ? "Bill" : "Order";
    Color labelColor = isOffline ? Colors.deepPurpleAccent : AppColors.getPrimaryColor(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.getBorderColor(context).withValues(alpha:0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child:
      InkWell(
        onTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("id", item.id);
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewOrderItems()));
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$labelTitle #${item.id}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: labelColor),
                  ),

                  // 🚀 3-DOT MENU FOR PRINT/PDF
                  Row(
                    children: [
                      _buildStatusChip(item.payment_status.toUpperCase(), statusColor),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 30,
                        width: 30,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.more_vert, size: 30, color: subTextColor),
                          onSelected: (value) {
                            if (value == 'print') {
                              _generatePdf(item, 'print');
                            } else if (value == 'pdf') {
                              _generatePdf(item, 'share');
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'print',
                              child: Row(
                                children: [
                                  Icon(Icons.print, color: Colors.grey),
                                  SizedBox(width: 10),
                                  Text('Print Bill'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'pdf',
                              child: Row(
                                children: [
                                  Icon(Icons.picture_as_pdf, color: Colors.grey),
                                  SizedBox(width: 10),
                                  Text('Save/Share PDF'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, thickness: 0.5),
              ),
              _buildInfoRow(Icons.person_outline, "Customer", item.username, isDark),
              const SizedBox(height: 10),
              _buildInfoRow(Icons.calendar_today_outlined, "Placed on", item.date, isDark),
              const SizedBox(height: 10),
              _buildInfoRow(Icons.payments_outlined, "Paid on", item.payment_date == "None" || item.payment_date == "null" ? "Awaiting" : item.payment_date, isDark),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Bill Amount", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Flexible(
                    flex: 3,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        "₹${item.amount}",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? AppColors.WhiteColor : Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Expanded(
          child: Text(value, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87, fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class Joke {
  final String id;
  final String payment_status;
  final String payment_date;
  final String date;
  final String amount;
  final String username;
  final String distributor;
  final String type;

  Joke(this.id, this.payment_status, this.payment_date, this.date, this.amount, this.username, this.distributor, this.type);
}