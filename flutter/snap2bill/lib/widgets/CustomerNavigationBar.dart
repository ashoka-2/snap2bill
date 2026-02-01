// import 'dart:ui'; // Required for ImageFilter
// import 'package:flutter/material.dart';
// import 'package:google_nav_bar/google_nav_bar.dart';
// import 'package:line_icons/line_icons.dart';
// import 'package:hugeicons/hugeicons.dart';
// import 'package:flutter/services.dart';
// // Your page imports (adjust these paths to your project structure)
// import 'package:snap2bill/Customerdirectory/customer_home_page.dart';
// import 'package:snap2bill/Customerdirectory/distributor_page.dart';
// import 'package:snap2bill/Customerdirectory/profile_page.dart';
//
// import 'package:snap2bill/theme/colors.dart';
//
// import '../screens/search_page.dart';
//
//
// /// CustomerNavigationBar
// /// - `initialIndex` lets you open the nav bar with a specific tab selected.
// /// - Use `CustomerNavigationBar.navKey.currentState?.openTab(index)` to switch tabs
// ///   programmatically when the widget is already mounted in the tree.
// class CustomerNavigationBar extends StatefulWidget {
//   // Optional global key to control the nav bar externally when it's mounted.
//   static final GlobalKey<_CustomerNavigationBarState> navKey =
//   GlobalKey<_CustomerNavigationBarState>();
//
//   final int initialIndex;
//
//   // You may attach the global key when creating the widget:
//   // CustomerNavigationBar(key: CustomerNavigationBar.navKey, initialIndex: 3)
//   const CustomerNavigationBar({
//     Key? key,
//     this.initialIndex = 0,
//   }) : super(key: key);
//
//   @override
//   State<CustomerNavigationBar> createState() => _CustomerNavigationBarState();
// }
//
// class _CustomerNavigationBarState extends State<CustomerNavigationBar> {
//   late int _selectedIndex;
//   late final List<Widget> _pages;
//
//   // Colors for tab backgrounds (keeps your original palette)
//   // final List<Color> tabColors = [
//   //   Colors.purple,
//   //   AppColors.getPrimaryColor(context),
//   //   Colors.green,
//   //   Colors.red,
//   // ];
//
//
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.initialIndex.clamp(0, 3);
//     _pages = const [
//       CustomerHomePage(),
//       SearchPage(),
//       DistributorPage(),
//       ProfilePage(),
//     ];
//   }
//
//   /// External method to switch tabs when this widget is already mounted.
//   /// Example: CustomerNavigationBar.navKey.currentState?.openTab(3);
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
//     final borderColor = isDark
//         ? Colors.white.withValues(alpha:0.2)
//         : Colors.black.withValues(alpha:0.2);
//     final glassColor = isDark
//         ? Colors.black.withValues(alpha:0.4)
//         : Colors.white.withValues(alpha:0.1);
//
//     return Scaffold(
//       extendBody: true,
//       body: IndexedStack(index: _selectedIndex, children: _pages),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(5.0),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(50),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: glassColor,
//                 borderRadius: BorderRadius.circular(50),
//                 border: Border.all(color: borderColor, width: 1.5),
//               ),
//               child: SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
//                   child: GNav(
//                     rippleColor:
//                     isDark ? Colors.white.withValues(alpha:0.1) : Colors.black.withValues(alpha:0.1),
//                     hoverColor:
//                     isDark ? Colors.white.withValues(alpha:0.1) : Colors.black.withValues(alpha:0.1),
//                     gap: 5,
//                     activeColor:AppColors.getTextColor(context),
//                     iconSize: 24,
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                     duration: const Duration(milliseconds: 400),
//                     tabBackgroundColor: AppColors.getTextColor(context).withValues(alpha:0.15),
//                     color: inactiveIconColor,
//                     tabs:  [
//                       GButton(icon: LineIcons.home,
//
//                           leading: HugeIcon(
//                         icon: HugeIcons.strokeRoundedHome09,
//                         strokeWidth: _selectedIndex == 0 ? 3 : 2,),
//
//                           text: 'Home'),
//                       GButton(icon: LineIcons.search,
//
//                           leading: HugeIcon(
//                         icon: HugeIcons.strokeRoundedSearch01,
//                         strokeWidth: _selectedIndex == 1 ? 3 : 2,),
//
//                           text: 'Search'),
//                       GButton(icon: LineIcons.users,
//
//                           leading: HugeIcon(
//                         icon: HugeIcons.strokeRoundedUserGroup03,
//                         strokeWidth: _selectedIndex == 2 ? 2.5 : 2,),
//
//                           text: 'Distributors'),
//                       GButton(icon: LineIcons.user,
//
//                           leading: HugeIcon(
//                         icon: HugeIcons.strokeRoundedUserCircle02,
//                         strokeWidth: _selectedIndex == 3 ? 3 : 2,),
//
//                           text: 'Profile'),
//                     ],
//                     selectedIndex: _selectedIndex,
//                     onTabChange: (index) {
//                       setState(() {
//                         _selectedIndex = index;
//                       });
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
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:snap2bill/Customerdirectory/customer_home_page.dart';
import 'package:snap2bill/Customerdirectory/distributor_page.dart';
import 'package:snap2bill/Customerdirectory/profile_page.dart';
import 'package:snap2bill/theme/colors.dart';
import '../screens/search_page.dart';

class CustomerNavigationBar extends StatefulWidget {
  static final GlobalKey<_CustomerNavigationBarState> navKey = GlobalKey<_CustomerNavigationBarState>();
  final int initialIndex;

  const CustomerNavigationBar({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<CustomerNavigationBar> createState() => _CustomerNavigationBarState();
}

class _CustomerNavigationBarState extends State<CustomerNavigationBar> {
  late int _selectedIndex;
  late final List<Widget> _pages;
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 3);
    _pages = const [
      CustomerHomePage(),
      SearchPage(),
      DistributorPage(),
      ProfilePage(),
    ];
  }

  void openTab(int index) {
    if (!mounted) return;
    if (index < 0 || index >= _pages.length) return;
    setState(() => _selectedIndex = index);
  }

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

    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenWidth = mediaQuery.size.width;

    final inactiveIconColor = isDark ? AppColors.WhiteColor : Colors.black;
    final borderColor = isDark ? Colors.white.withAlpha(51) : Colors.black.withAlpha(51);
    final glassColor = isDark ? Colors.black.withAlpha(102) : Colors.white.withAlpha(25);

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
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 15,
              left: isLandscape ? screenWidth * 0.25 : 15,
              right: isLandscape ? screenWidth * 0.25 : 15,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: glassColor,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                      child: GNav(
                        gap: 8,
                        activeColor: AppColors.getTextColor(context),
                        iconSize: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        duration: const Duration(milliseconds: 400),
                        tabBackgroundColor: AppColors.getTextColor(context).withAlpha(38),
                        color: inactiveIconColor,
                        tabs: [
                          // 🚀 Fixed Nav Items
                          _buildNavItem(HugeIcons.strokeRoundedHome09, 'Home', 0),
                          _buildNavItem(HugeIcons.strokeRoundedSearch01, 'Search', 1),
                          _buildNavItem(HugeIcons.strokeRoundedUserGroup03, 'Distributors', 2),
                          _buildNavItem(HugeIcons.strokeRoundedUserCircle02, 'Profile', 3),
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

  // 🚀 Fixed Helper Function: IconData ki jagah dynamic use kiya HugeIcons ke liye
  GButton _buildNavItem(dynamic iconData, String text, int index) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GButton(
      icon: LineIcons.home, // Dummy icon for GNav base
      leading: HugeIcon(
        icon: iconData, // 🚀 HugeIcons naya format support karega
        color: isSelected
            ? AppColors.getTextColor(context)
            : (isDark ? Colors.white70 : Colors.black87),
        size: 24,
        strokeWidth: isSelected ? 2.5 : 2.0,
      ),
      text: text,
    );
  }
}