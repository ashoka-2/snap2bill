// // lib/widgets/distributorNavigationbar.dart
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:google_nav_bar/google_nav_bar.dart';
// import 'package:line_icons/line_icons.dart';
// import 'package:hugeicons/hugeicons.dart';
// import 'package:snap2bill/Distributordirectory/allCustomers.dart';
//
// // Import your distributor pages (adjust paths if needed)
// import '../Distributordirectory/home_page.dart';
// import '../screens/search_page.dart';
// import '../Distributordirectory/customer_page.dart';
// import '../Distributordirectory/profile_page.dart';
// import '../theme/colors.dart';
//
// class DistributorNavigationBar extends StatefulWidget {
//   /// Allows selecting which tab is active when opening the navbar
//   final int initialIndex;
//
//   /// GlobalKey to access the nav state if it's mounted
//   static final GlobalKey<_DistributorNavigationBarState> navKey =
//   GlobalKey<_DistributorNavigationBarState>();
//
//   /// NOTE: constructor is intentionally NOT const because it uses a runtime key
//   DistributorNavigationBar({
//     Key? key,
//     this.initialIndex = 0,
//   }) : super(key: key);
//
//   @override
//   State<DistributorNavigationBar> createState() =>
//       _DistributorNavigationBarState();
// }
//
// class _DistributorNavigationBarState extends State<DistributorNavigationBar> {
//   late int _selectedIndex;
//   late final List<Widget> _pages;
//
//   // final List<Color> tabColors = [
//   //   Colors.purple,
//   //   Colors.yellow,
//   //   AppColors.getPrimaryColor(context),
//   //   Colors.green,
//   //   Colors.red,
//   // ];
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.initialIndex.clamp(0, 4);
//     _pages =  [
//       HomePage(),
//       SearchPage(),
//       AllCustomers(),
//       CustomerPage(),
//       DistributorProfilePage(),
//     ];
//   }
//
//   /// Programmatically change tab when mounted
//   void openTab(int index) {
//     if (!mounted) return;
//     if (index < 0 || index >= _pages.length) return;
//     setState(() => _selectedIndex = index);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     final inactiveIconColor = isDark ? AppColors.WhiteColor: Colors.black;
//     final borderColor =
//     isDark ? Colors.white.withValues(alpha:0.2) : Colors.black.withValues(alpha:0.2);
//     final glassColor =
//     isDark ? Colors.black.withValues(alpha:0.5) : Colors.white.withValues(alpha:0.4);
//
//     return Scaffold(
//       extendBody: true,
//       body: IndexedStack(index: _selectedIndex, children: _pages),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(5.0),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(50),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
//             child: Container(
//
//               decoration: BoxDecoration(
//                 color: glassColor,
//                 borderRadius: BorderRadius.circular(50),
//                 border: Border.all(color: borderColor, width: 1.5),
//               ),
//               child: SafeArea(
//                 child: Padding(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
//                   child: GNav(
//                     rippleColor: isDark
//                         ? Colors.white.withValues(alpha:0.1)
//                         : Colors.black.withValues(alpha:0.1),
//                     hoverColor: isDark
//                         ? Colors.white.withValues(alpha:0.1)
//                         : Colors.black.withValues(alpha:0.1),
//                     gap: 5,
//                     activeColor: AppColors.getTextColor(context),
//                     iconSize: 24,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 10),
//                     duration: const Duration(milliseconds: 400),
//                     tabBackgroundColor:AppColors.getTextColor(context).withValues(alpha:0.15),
//                     color: inactiveIconColor,
//                     tabs:  [
//                       GButton(icon: Icons.home, // Dummy icon
//
//                         leading: HugeIcon(
//                           icon: HugeIcons.strokeRoundedHome09,
//                           strokeWidth: _selectedIndex == 0 ? 3 : 2,
//                         ),
//
//                         text: 'Home' ,),
//                       GButton(icon: LineIcons.search,
//
//                           leading: HugeIcon(
//                         icon: HugeIcons.strokeRoundedSearch01,
//
//                         strokeWidth: _selectedIndex == 1 ? 3 : 2,
//                       ),
//
//                           text: 'Search'),
//                       GButton(icon: LineIcons.plus,
//
//                           leading: HugeIcon(
//                           icon: HugeIcons.strokeRoundedPlusSign,
//                           strokeWidth: _selectedIndex == 2 ? 3 : 2,),
//
//                           text: 'Add'),
//                       GButton(icon: LineIcons.users,
//
//                           leading: HugeIcon(
//                         icon: HugeIcons.strokeRoundedUserGroup03,
//                         strokeWidth: _selectedIndex == 3 ? 3 : 2,),
//
//                           text: 'Customers'),
//                       GButton(icon: LineIcons.user,
//
//                           leading: HugeIcon(
//                         icon: HugeIcons.strokeRoundedUserCircle02,
//                         strokeWidth: _selectedIndex == 4 ? 3 : 2,),
//
//                           text: 'Profile'),
//                     ],
//                     selectedIndex: _selectedIndex,
//                     onTabChange: (index) {
//                       setState(() => _selectedIndex = index);
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🚀 SystemNavigator ke liye
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:snap2bill/Distributordirectory/allCustomers.dart';

import '../Distributordirectory/home_page.dart';
import '../screens/search_page.dart';
import '../Distributordirectory/customer_page.dart';
import '../Distributordirectory/profile_page.dart';
import '../theme/colors.dart';

class DistributorNavigationBar extends StatefulWidget {
  final int initialIndex;
  static final GlobalKey<_DistributorNavigationBarState> navKey = GlobalKey<_DistributorNavigationBarState>();

  DistributorNavigationBar({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<DistributorNavigationBar> createState() => _DistributorNavigationBarState();
}

class _DistributorNavigationBarState extends State<DistributorNavigationBar> {
  late int _selectedIndex;
  late final List<Widget> _pages;
  DateTime? _lastPressedAt; // 🚀 Exit logic ke liye

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 4);
    _pages = [
      HomePage(),
      SearchPage(),
      AllCustomers(),
      CustomerPage(),
      DistributorProfilePage(),
    ];
  }

  void openTab(int index) {
    if (!mounted) return;
    if (index < 0 || index >= _pages.length) return;
    setState(() => _selectedIndex = index);
  }

  // 🚀 Exit Logic: Home par le jayega ya exit karega
  Future<bool> _handlePop() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }
    final now = DateTime.now();
    if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Press back again to exit", textAlign: TextAlign.center),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          width: 220,
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    // 🚀 Landscape check & Width calculations
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenWidth = mediaQuery.size.width;

    final inactiveIconColor = isDark ? AppColors.WhiteColor : Colors.black;
    final borderColor = isDark ? Colors.white.withAlpha(51) : Colors.black.withAlpha(51);
    final glassColor = isDark ? Colors.black.withAlpha(127) : Colors.white.withAlpha(102);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handlePop();
        if (shouldPop && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 15,
              // 🚀 5 items hain isliye landscape mein width thodi zyada rakhi hai
              left: isLandscape ? screenWidth * 0.15 : 10,
              right: isLandscape ? screenWidth * 0.15 : 10,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: glassColor,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                      child: GNav(
                        rippleColor: isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(25),
                        hoverColor: isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(25),
                        gap: 6, // Spacing between icon and text
                        activeColor: AppColors.getTextColor(context),
                        iconSize: 22,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        duration: const Duration(milliseconds: 400),
                        tabBackgroundColor: AppColors.getTextColor(context).withAlpha(38),
                        color: inactiveIconColor,
                        tabs: [
                          _buildNavItem(HugeIcons.strokeRoundedHome09, 'Home', 0),
                          _buildNavItem(HugeIcons.strokeRoundedSearch01, 'Search', 1),
                          _buildNavItem(HugeIcons.strokeRoundedPlusSign, 'Add', 2),
                          _buildNavItem(HugeIcons.strokeRoundedUserGroup03, 'Customers', 3),
                          _buildNavItem(HugeIcons.strokeRoundedUserCircle02, 'Profile', 4),
                        ],
                        selectedIndex: _selectedIndex,
                        onTabChange: (index) => setState(() => _selectedIndex = index),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🚀 Helper function to handle HugeIcons dynamic types
  GButton _buildNavItem(dynamic iconData, String text, int index) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GButton(
      icon: Icons.home, // Dummy base icon
      leading: HugeIcon(
        icon: iconData,
        color: isSelected
            ? AppColors.getTextColor(context)
            : (isDark ? Colors.white70 : Colors.black87),
        size: 22,
        strokeWidth: isSelected ? 2.5 : 2,
      ),
      text: text,
      textStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.getTextColor(context),
      ),
    );
  }
}