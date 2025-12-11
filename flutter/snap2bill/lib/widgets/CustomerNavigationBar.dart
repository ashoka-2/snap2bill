import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

// Your page imports (adjust these paths to your project structure)
import 'package:snap2bill/Customerdirectory/customer_home_page.dart';
import 'package:snap2bill/Customerdirectory/distributor_page.dart';
import 'package:snap2bill/Customerdirectory/profile_page.dart';
import 'package:snap2bill/Customerdirectory/search_page.dart';
import '../Customerdirectory/chat_page.dart';

/// CustomerNavigationBar
/// - `initialIndex` lets you open the nav bar with a specific tab selected.
/// - Use `CustomerNavigationBar.navKey.currentState?.openTab(index)` to switch tabs
///   programmatically when the widget is already mounted in the tree.
class CustomerNavigationBar extends StatefulWidget {
  // Optional global key to control the nav bar externally when it's mounted.
  static final GlobalKey<_CustomerNavigationBarState> navKey =
  GlobalKey<_CustomerNavigationBarState>();

  final int initialIndex;

  // You may attach the global key when creating the widget:
  // CustomerNavigationBar(key: CustomerNavigationBar.navKey, initialIndex: 3)
  const CustomerNavigationBar({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<CustomerNavigationBar> createState() => _CustomerNavigationBarState();
}

class _CustomerNavigationBarState extends State<CustomerNavigationBar> {
  late int _selectedIndex;
  late final List<Widget> _pages;

  // Colors for tab backgrounds (keeps your original palette)
  final List<Color> tabColors = [
    Colors.purple,
    Colors.yellow,
    Colors.blue,
    Colors.green,
    Colors.red,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 4);
    _pages = const [
      CustomerHomePage(),
      search_page(),
      chat_page(),
      distributor_page(),
      profile_page(),
    ];
  }

  /// External method to switch tabs when this widget is already mounted.
  /// Example: CustomerNavigationBar.navKey.currentState?.openTab(3);
  void openTab(int index) {
    if (!mounted) return;
    if (index < 0 || index >= _pages.length) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inactiveIconColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.2)
        : Colors.black.withOpacity(0.2);
    final glassColor = isDark
        ? Colors.black.withOpacity(0.4)
        : Colors.white.withOpacity(0.1);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
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
                    rippleColor:
                    isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    hoverColor:
                    isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                    gap: 5,
                    activeColor: tabColors[_selectedIndex],
                    iconSize: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: tabColors[_selectedIndex].withOpacity(0.15),
                    color: inactiveIconColor,
                    tabs: const [
                      GButton(icon: LineIcons.home, text: 'Home'),
                      GButton(icon: LineIcons.search, text: 'Search'),
                      GButton(icon: LineIcons.facebookMessenger, text: 'Chat'),
                      GButton(icon: LineIcons.users, text: 'Distributors'),
                      GButton(icon: LineIcons.user, text: 'Profile'),
                    ],
                    selectedIndex: _selectedIndex,
                    onTabChange: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
