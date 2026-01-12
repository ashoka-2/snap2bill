// lib/widgets/distributorNavigationbar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:snap2bill/Distributordirectory/allCustomers.dart';

// Import your distributor pages (adjust paths if needed)
import '../Distributordirectory/home_page.dart';
import '../screens/search_page.dart';
import '../Distributordirectory/customer_page.dart';
import '../Distributordirectory/profile_page.dart';
import '../theme/colors.dart';

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

  // final List<Color> tabColors = [
  //   Colors.purple,
  //   Colors.yellow,
  //   Colors.blue,
  //   Colors.green,
  //   Colors.red,
  // ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 4);
    _pages =  [
      Home_page(),
      search_page(),
      allCustomers(),
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
    isDark ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.4);

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
                    activeColor: AppColors.getTextColor(context),
                    iconSize: 24,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor:AppColors.getTextColor(context).withOpacity(0.15),
                    color: inactiveIconColor,
                    tabs:  [
                      GButton(icon: Icons.home, // Dummy icon

                        leading: HugeIcon(
                          icon: HugeIcons.strokeRoundedHome09,
                          strokeWidth: _selectedIndex == 0 ? 3 : 2,
                        ),

                        text: 'Home' ,),
                      GButton(icon: LineIcons.search,

                          leading: HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,

                        strokeWidth: _selectedIndex == 1 ? 3 : 2,
                      ),

                          text: 'Search'),
                      GButton(icon: LineIcons.plus,

                          leading: HugeIcon(
                          icon: HugeIcons.strokeRoundedPlusSign,
                          strokeWidth: _selectedIndex == 2 ? 3 : 2,),

                          text: 'Add'),
                      GButton(icon: LineIcons.users,

                          leading: HugeIcon(
                        icon: HugeIcons.strokeRoundedUserGroup03,
                        strokeWidth: _selectedIndex == 3 ? 3 : 2,),

                          text: 'Customers'),
                      GButton(icon: LineIcons.user,

                          leading: HugeIcon(
                        icon: HugeIcons.strokeRoundedUserCircle02,
                        strokeWidth: _selectedIndex == 4 ? 3 : 2,),

                          text: 'Profile'),
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
