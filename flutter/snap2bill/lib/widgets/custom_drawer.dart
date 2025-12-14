import 'package:flutter/material.dart';

// Import necessary dependencies/widgets needed for the drawer
import '../main.dart';
import '../theme/theme.dart';
import '../screens/Login_page.dart'; // For logout navigation

/// Defines the data structure for a single item in the custom drawer.
class DrawerItemModel {
  final IconData icon;
  final String title;
  // Function to execute on tap. Returns the destination Widget (or Future<Widget> for async actions like Logout).
  final Function() onTap;
  final Color color;

  DrawerItemModel({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = Colors.black, // Default color to avoid passing it every time
  });
}

class CustomDrawer extends StatelessWidget {
  final List<DrawerItemModel> menuItems;

  const CustomDrawer({
    Key? key,
    required this.menuItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: ListView(
        children: [
          // --- DRAWER HEADER (Identical Style) ---
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.storefront, color:isDark?Colors.white:Colors.black.withOpacity(0.7), size: 40),
                      const SizedBox(width: 10),
                      Text("Menu", style: TextStyle(color:isDark?Colors.white:Colors.black.withOpacity(0.7), fontSize: 24)),
                    ],),

                    // Theme Toggle Button
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.grey.withOpacity(0.5),
                          border: Border.all(width: 1,color: Colors.grey)
                      ),
                      child: IconButton(
                        icon:  Icon(
                          ThemeService.instance.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          MyApp.changeTheme(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- DRAWER ITEMS LIST ---
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(bottom: 100),
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Column(
                  children: menuItems.map((item) {
                    final itemColor = item.color == Colors.red ? Colors.red : textColor;
                    return _drawerItem(context, isDark, item.icon, item.title, item.onTap, itemColor);
                  }).toList(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper for consistent drawer item style and navigation logic
  Widget _drawerItem(BuildContext context, bool isDark ,IconData icon, String title, Function() onTap, Color color) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context); // Close drawer first

        // Execute the onTap function (which returns Widget or Future<Widget>)
        final result = onTap();

        if (result is Widget) {
          // Case 1: Standard navigation (returns a Widget synchronously)
          if (!context.mounted) return;
          Navigator.push(context, MaterialPageRoute(builder: (context) => result));
        } else if (result is Future) {
          // Case 2: Logout/Async navigation (returns a Future that resolves to a Widget)
          final destination = await result;
          if (destination is Widget && context.mounted) {
            // If the destination is the login page (i.e., Logout), push and remove all previous routes
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => destination),
                  (route) => false,
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.only(top: 20,bottom: 20,left: 20,right: 20),
        margin: const EdgeInsets.only(bottom: 3),
        decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800:Colors.grey.shade200,
            borderRadius: BorderRadius.circular(5)
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10,),
            Text(title, style: TextStyle(color: color),)
          ],
        ),
      ),
    );
  }
}