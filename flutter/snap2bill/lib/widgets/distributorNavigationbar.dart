// lib/widgets/distributorNavigationbar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

// Import your distributor pages (adjust paths if needed)
import '../Distributordirectory/home_page.dart';
import '../Distributordirectory/search_page.dart';
import '../Distributordirectory/scanItem.dart';
import '../Distributordirectory/customer_page.dart';
import '../Distributordirectory/profile_page.dart';

class DistributorNavigationBar extends StatefulWidget {
  /// Allows selecting which tab is active when opening the navbar
  final int initialIndex;

  /// GlobalKey to access the nav state if it's mounted
  static final GlobalKey<_DistributorNavigationBarState> navKey =
  GlobalKey<_DistributorNavigationBarState>();

  /// NOTE: constructor is intentionally NOT const because it uses a runtime key
  DistributorNavigationBar({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<DistributorNavigationBar> createState() =>
      _DistributorNavigationBarState();
}

class _DistributorNavigationBarState extends State<DistributorNavigationBar> {
  late int _selectedIndex;
  late final List<Widget> _pages;

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
    _pages =  [
      Home_page(),
      search_page(),
      CameraCapture(),
      customer_page(),
      distributor_profile_page(),
    ];
  }

  /// Programmatically change tab when mounted
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
    final borderColor =
    isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2);
    final glassColor =
    isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.1);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: glassColor,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
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
                        horizontal: 12, vertical: 10),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor:
                    tabColors[_selectedIndex].withOpacity(0.15),
                    color: inactiveIconColor,
                    tabs: const [
                      GButton(icon: LineIcons.home, text: 'Home'),
                      GButton(icon: LineIcons.search, text: 'Search'),
                      GButton(icon: LineIcons.plus, text: 'Add'),
                      GButton(icon: LineIcons.users, text: 'Customers'),
                      GButton(icon: LineIcons.user, text: 'Profile'),
                    ],
                    selectedIndex: _selectedIndex,
                    onTabChange: (index) {
                      setState(() => _selectedIndex = index);
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
