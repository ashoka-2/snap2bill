// lib/Distributordirectory/home_page.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

// Ensure this path points to the file containing the class above
import '../Distributordirectory/home_page.dart';
import '../Distributordirectory/search_page.dart';
import '../Distributordirectory/upload_page.dart';
import '../Distributordirectory/customer_page.dart';
import '../Distributordirectory/profile_page.dart';

// Renamed class to follow PascalCase convention
class DistributorNavigationBar extends StatefulWidget {
  const DistributorNavigationBar({super.key});

  @override
  State<DistributorNavigationBar> createState() => _DistributorNavigationBarState();
}

class _DistributorNavigationBarState extends State<DistributorNavigationBar> {
  int _selectedIndex = 0;

  // Define pages here
  final List<Widget> _pages = [
    const Home_page(), // This is the corrected class from the code above
    search_page(),
    upload_page(),
    customer_page(),
    distributor_profile_page(),
  ];

  final List<Color> tabColors = [
    Colors.purple,
    Colors.yellow,
    Colors.blue,
    Colors.green,
    Colors.red,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // IndexedStack preserves the state of the pages (keeps them alive)
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Colors.black.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                  child: GNav(
                    rippleColor: Colors.white.withOpacity(0.1),
                    hoverColor: Colors.white.withOpacity(0.1),
                    gap: 5,
                    activeColor: tabColors[_selectedIndex],
                    iconSize: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: tabColors[_selectedIndex].withOpacity(0.1),
                    color: Colors.black,
                    tabs: const [
                      GButton(icon: LineIcons.home, text: 'Home'),
                      GButton(icon: LineIcons.search, text: 'Search'),
                      GButton(icon: LineIcons.plus, text: 'Add'),
                      GButton(icon: LineIcons.users, text: 'Customers'),
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