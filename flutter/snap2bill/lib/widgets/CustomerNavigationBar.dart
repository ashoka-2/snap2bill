import 'dart:ui'; // Required for ImageFilter

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
// Import your home content file
import 'package:snap2bill/Customerdirectory/customer_home_page.dart';
// Import the other tabs
import 'package:snap2bill/Customerdirectory/distributor_page.dart';
import 'package:snap2bill/Customerdirectory/profile_page.dart';
import 'package:snap2bill/Customerdirectory/search_page.dart';

import '../Customerdirectory/chat_page.dart';

class CustomerNavigationBar extends StatefulWidget {
  const CustomerNavigationBar({Key? key}) : super(key: key);

  @override
  State<CustomerNavigationBar> createState() => _CustomerNavigationBarState();
}

class _CustomerNavigationBarState extends State<CustomerNavigationBar> {
  int _selectedIndex = 0;

  // Pages for IndexedStack
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const CustomerHomePage(),
      search_page(),
      chat_page(),
      distributor_page(),
      profile_page(),
    ];
  }

  // Changed Set to List for index access
  final List<Color> tabColors = [
    Colors.purple,
    Colors.yellow,
    Colors.blue,
    Colors.green,
    Colors.red,
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Detect Theme Brightness
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 2. Define Dynamic Colors
    // Inactive Icon Color: White if dark mode, Black if light mode
    final inactiveIconColor = isDark ? Colors.white : Colors.black;

    // Border Color: Lighter border for visibility in dark mode
    final borderColor = isDark
        ? Colors.white.withOpacity(0.2)
        : Colors.black.withOpacity(0.2);

    // Container Background: Use dark tint for dark mode, light tint for light mode
    final glassColor = isDark
        ? Colors.black.withOpacity(0.4)
        : Colors.white.withOpacity(0.1);

    return Scaffold(
      extendBody: true, // Allows body to extend behind the navbar
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: glassColor, // Updated dynamic background
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: borderColor, // Updated dynamic border
                  width: 1.5,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 8,
                  ),
                  child: GNav(
                    rippleColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    hoverColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    gap: 5,
                    activeColor: tabColors[_selectedIndex],
                    iconSize: 24,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: tabColors[_selectedIndex].withOpacity(
                      0.15,
                    ),

                    // --- DYNAMIC ICON COLOR ---
                    color: inactiveIconColor,

                    // --------------------------
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
