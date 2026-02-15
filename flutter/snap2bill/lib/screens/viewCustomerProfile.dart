
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:snap2bill/Distributordirectory/customer_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/colors.dart';
import '../widgets/Navbar.dart';
import '../widgets/app_button.dart';

class ViewCustomerProfile extends StatelessWidget {
  final Joke customer;
  late Color iconColor;
  late Color subTextColor;
  late Color textColor;

   ViewCustomerProfile({Key? key, required this.customer}) : super(key: key);

  // ✅ Function to trigger phone dialer
  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // ✅ Function to trigger WhatsApp (preferred) or SMS
  Future<void> _messageCustomer(String phoneNumber) async {
    // Try WhatsApp first
    final Uri whatsappUri = Uri.parse("whatsapp://send?phone=$phoneNumber");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      // Fallback to standard SMS
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
      );
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    }
  }

  void _showFullTextDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    textColor = AppColors.getTextColor(context);
    iconColor = AppColors.getIconColor(context);
    final bgColor = AppColors.getScaffoldBg(context);
    subTextColor = AppColors.getTextSubColor(context);
    final primaryColor = AppColors.getPrimaryColor(context);
    

    return Scaffold(
      backgroundColor: bgColor,
      appBar:ThemeNavbar(title: "Customer Profile ",
        leadingIcon: Icons.arrow_back_ios_rounded,
        onLeadingPressed: ()=>{
          if (Navigator.canPop(context)) Navigator.pop(context)
        },
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 1. PROFILE IMAGE
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.primaryColor.withValues(alpha:0.5), width: 2),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: CachedNetworkImageProvider(customer.profile_image),
                onBackgroundImageError: (_, __) => const Icon(Icons.person, size: 40),
              ),
            ),
            const SizedBox(height: 15),

            // 2. NAME
            Text(
              customer.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 5),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Verified Customer",
                style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 25),

            // 3. STATS ROW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Expanded(child: _buildClickableStatItem(context, "Place", customer.place,)),
                  Container(height: 30, width: 1, color: subTextColor),
                  Expanded(child: _buildClickableStatItem(context, "Pincode", customer.pincode,)),
                  Container(height: 30, width: 1, color: subTextColor),
                  Expanded(child: _buildClickableStatItem(context, "Post", customer.post,)),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ✅ IMPROVED CALL & MESSAGE BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child:Row(
                children: [
                  // --- CALL BUTTON ---
                  Expanded(
                    child:SecondaryButton(
                      onPressed: () => _makeCall(customer.phone),
                      color: AppColors.getSuccessColor(context),
                      leading: Lottie.asset(
                        'assets/lotties/call.json',
                        width: 30, // Slightly adjusted for better alignment with text
                        height: 30,
                        fit: BoxFit.contain,
                        repeat: true, // Set to false if you want it to play only once
                      ),
                      text: "Call",

                    ),
                  ),

                  const SizedBox(width: 10),

                  // --- WHATSAPP BUTTON WITH LOTTIE ---
                  Expanded(
                    child:SecondaryButton(text: "Whatsapp",
                      color: AppColors.getSuccessColor(context),
                      leading: Lottie.asset(
                        'assets/lotties/whatsapp.json',
                        width: 30, // Slightly adjusted for better alignment with text
                        height: 30,
                        fit: BoxFit.contain,
                        repeat: true, // Set to false if you want it to play only once
                      ),
                      onPressed: () => _messageCustomer(customer.phone),
                    ),

                  ),
                ],
              ),

            ),

            const SizedBox(height: 20),
            const Divider(),

            // 4. DETAILS SECTION
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Contact Information",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 15),

                  _buildInfoTile(context, Icons.email_outlined, "Email", customer.email,),
                  _buildInfoTile(context, Icons.phone_outlined, "Phone", customer.phone,),
                  _buildInfoTile(context, Icons.location_on_outlined, "Full Address",
                      "${customer.address}, ${customer.place}\n${customer.post}",),

                  const SizedBox(height: 20),

                  Text("Bio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color:AppColors.disabledColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (customer.bio == "null" || customer.bio.isEmpty)
                          ? "No bio available."
                          : customer.bio,
                      style: TextStyle(color: subTextColor, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableStatItem(BuildContext context, String label, String value,) {
    return InkWell(
      onTap: () => _showFullTextDialog(context, label, value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: subTextColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String value,) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: InkWell(
        onTap: () => _showFullTextDialog(context, title, value),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color:iconColor, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, color: subTextColor)),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}