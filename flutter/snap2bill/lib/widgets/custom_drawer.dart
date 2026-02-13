// // import 'package:flutter/material.dart';
// //
// // // Import necessary dependencies/widgets needed for the drawer
// // import '../main.dart';
// // import '../theme/colors.dart';
// // import '../theme/theme.dart';
// //
// // /// Defines the data structure for a single item in the custom drawer.
// // class DrawerItemModel {
// //   final IconData icon;
// //   final String title;
// //   // Function to execute on tap. Returns the destination Widget (or Future<Widget> for async actions like Logout).
// //   final Function() onTap;
// //   final Color color;
// //
// //   DrawerItemModel({
// //     required this.icon,
// //     required this.title,
// //     required this.onTap,
// //     this.color = Colors.black, // Default color to avoid passing it every time
// //   });
// // }
// //
// // class CustomDrawer extends StatelessWidget {
// //   final List<DrawerItemModel> menuItems;
// //
// //   late Color dangerColor;
// //
// //    CustomDrawer({
// //     Key? key,
// //     required this.menuItems,
// //   }) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     dangerColor = AppColors.getDangerColor(context);
// //
// //     final theme = Theme.of(context);
// //     final isDark = theme.brightness == Brightness.dark;
// //     final textColor = isDark ? AppColors.WhiteColor: Colors.black;
// //
// //     return Drawer(
// //       backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //       child: ListView(
// //         children: [
// //           // --- DRAWER HEADER (Identical Style) ---
// //           DrawerHeader(
// //             decoration: BoxDecoration(
// //               color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
// //             ),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisAlignment: MainAxisAlignment.end,
// //               children: [
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Row(children: [
// //                       Icon(Icons.storefront, color:isDark?Colors.white:Colors.black.withValues(alpha:0.7), size: 40),
// //                       const SizedBox(width: 10),
// //                       Text("Menu", style: TextStyle(color:isDark?Colors.white:Colors.black.withValues(alpha:0.7), fontSize: 24)),
// //                     ],),
// //
// //                     // Theme Toggle Button
// //                     Container(
// //                       decoration: BoxDecoration(
// //                           borderRadius: BorderRadius.circular(50),
// //                           color: Colors.grey.withValues(alpha:0.5),
// //                           border: Border.all(width: 1,color: Colors.grey)
// //                       ),
// //                       child: IconButton(
// //                         icon:  Icon(
// //                           ThemeService.instance.isDarkMode ? Icons.light_mode : Icons.dark_mode,
// //                           color: Colors.white,
// //                         ),
// //                         onPressed: () {
// //                           MyApp.changeTheme(context);
// //                         },
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //           // --- DRAWER ITEMS LIST ---
// //           SingleChildScrollView(
// //             child: Container(
// //               margin: const EdgeInsets.only(bottom: 100),
// //               padding: const EdgeInsets.all(20),
// //               child: ClipRRect(
// //                 borderRadius: BorderRadius.circular(30),
// //                 child: Column(
// //                   children: menuItems.map((item) {
// //                     final itemColor = item.color == dangerColor? dangerColor : textColor;
// //                     return _drawerItem(context, isDark, item.icon, item.title, item.onTap, itemColor);
// //                   }).toList(),
// //                 ),
// //               ),
// //             ),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // Helper for consistent drawer item style and navigation logic
// //   Widget _drawerItem(BuildContext context, bool isDark ,IconData icon, String title, Function() onTap, Color color) {
// //     return InkWell(
// //       onTap: () async {
// //         Navigator.pop(context); // Close drawer first
// //
// //         // Execute the onTap function (which returns Widget or Future<Widget>)
// //         final result = onTap();
// //
// //         if (result is Widget) {
// //           // Case 1: Standard navigation (returns a Widget synchronously)
// //           if (!context.mounted) return;
// //           Navigator.push(context, MaterialPageRoute(builder: (context) => result));
// //         } else if (result is Future) {
// //           // Case 2: Logout/Async navigation (returns a Future that resolves to a Widget)
// //           final destination = await result;
// //           if (destination is Widget && context.mounted) {
// //             // If the destination is the login page (i.e., Logout), push and remove all previous routes
// //             Navigator.pushAndRemoveUntil(
// //               context,
// //               MaterialPageRoute(builder: (_) => destination),
// //                   (route) => false,
// //             );
// //           }
// //         }
// //       },
// //       child: Container(
// //         padding: const EdgeInsets.only(top: 20,bottom: 20,left: 20,right: 20),
// //         margin: const EdgeInsets.only(bottom: 3),
// //         decoration: BoxDecoration(
// //             color: isDark ? Colors.grey.shade800:Colors.grey.shade200,
// //             borderRadius: BorderRadius.circular(5)
// //         ),
// //         child: Row(
// //           children: [
// //             Icon(icon, color: color),
// //             const SizedBox(width: 10,),
// //             Text(title, style: TextStyle(color: color),)
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
//
// import 'package:flutter/material.dart';
// import '../main.dart';
// import '../theme/colors.dart';
// import '../theme/theme.dart';
//
// class DrawerItemModel {
//   final IconData icon;
//   final String title;
//   final Function() onTap;
//   final Color color;
//
//   DrawerItemModel({
//     required this.icon,
//     required this.title,
//     required this.onTap,
//     this.color = Colors.black,
//   });
// }
//
// class CustomDrawer extends StatelessWidget {
//   final List<DrawerItemModel> menuItems;
//
//   const CustomDrawer({
//     Key? key,
//     required this.menuItems,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final dangerColor = AppColors.getDangerColor(context);
//     final primaryColor = AppColors.getPrimaryColor(context);
//
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     // Text color for list items
//     final textColor = isDark ? AppColors.WhiteColor : Colors.black87;
//
//     return Drawer(
//       backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//       child: Column( // ListView hata kar Column use kiya taaki structure better ho
//         children: [
//
//           /// ============================================================
//           /// ✨ NEW & IMPROVED HEADER
//           /// ============================================================
//           Container(
//             padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
//             width: double.infinity,
//             decoration: BoxDecoration(
//               // Gradient Background: Light Mode me Primary Color, Dark me Dark Grey
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: isDark
//                     ? [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)]
//                     : [primaryColor, primaryColor.withValues(alpha:0.7)],
//               ),
//               borderRadius: const BorderRadius.only(
//                 bottomRight: Radius.circular(30), // Stylish corner
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha:0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 )
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// --- TOP ROW: PROFILE ICON & THEME SWITCHER ---
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Avatar / App Logo Placeholder
//                     Container(
//                       height: 60,
//                       width: 60,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withValues(alpha:0.2),
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.white.withValues(alpha:0.5), width: 1.5),
//                       ),
//                       child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 35),
//                     ),
//
//                     // Stylish Theme Toggle Button
//                     Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         onTap: () => MyApp.changeTheme(context),
//                         borderRadius: BorderRadius.circular(50),
//                         child: Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withValues(alpha:0.1), // Glass effect
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white.withValues(alpha:0.3), width: 1),
//                           ),
//                           child: Icon(
//                             ThemeService.instance.isDarkMode
//                                 ? Icons.wb_sunny_rounded // Sun icon for dark mode
//                                 : Icons.nightlight_round, // Moon icon for light mode
//                             color: Colors.white,
//                             size: 22,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 /// --- APP NAME & SUBTITLE ---
//                 const Text(
//                   "Snap2Bill", // App Name looks better than "Menu"
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1,
//                   ),
//                 ),
//                 Text(
//                   "Smart Billing Solutions", // Tagline
//                   style: TextStyle(
//                     color: Colors.white.withValues(alpha:0.8),
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           /// ============================================================
//           /// 📋 LIST ITEMS (User's Original Logic)
//           /// ============================================================
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.only(left: 15,right: 15,top: 20, bottom: 100),
//               children: menuItems.map((item) {
//                 final itemColor = item.color == dangerColor ? dangerColor : textColor;
//                 return _drawerItem(context, isDark, item.icon, item.title, item.onTap, itemColor);
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper Widget (Same logic, slightly refined UI)
//   Widget _drawerItem(BuildContext context, bool isDark, IconData icon, String title, Function() onTap, Color color) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8), // Gap between items
//       decoration: BoxDecoration(
//         // Subtle background for items
//         color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isDark ? Colors.transparent : Colors.grey.shade200,
//         ),
//       ),
//       child: ListTile(
//         onTap: () async {
//           Navigator.pop(context);
//           final result = onTap();
//           if (result is Widget && context.mounted) {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => result));
//           } else if (result is Future) {
//             final destination = await result;
//             if (destination is Widget && context.mounted) {
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (_) => destination),
//                     (route) => false,
//               );
//             }
//           }
//         },
//         leading: Icon(icon, color: color, size: 24),
//         title: Text(
//           title,
//           style: TextStyle(
//             color: color,
//             fontWeight: FontWeight.w600,
//             fontSize: 15,
//           ),
//         ),
//         trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color.withValues(alpha:0.5)),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart'; // 🚀 IMPORTED
import '../main.dart';
import '../theme/colors.dart';
import '../theme/theme.dart';

class DrawerItemModel {
  // 🚀 CHANGED: IconData -> dynamic (Supports both HugeIcon & Material Icon)
  final dynamic icon;
  final String title;
  final Function() onTap;
  final Color color;

  DrawerItemModel({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = Colors.black,
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
    final dangerColor = AppColors.getDangerColor(context);
    final primaryColor = AppColors.getPrimaryColor(context);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? AppColors.WhiteColor : Colors.black87;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Column(
        children: [

          /// ============================================================
          /// ✨ HEADER (Updated with HugeIcons)
          /// ============================================================
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)]
                    : [primaryColor, primaryColor.withValues(alpha:0.7)],
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- TOP ROW ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar / App Logo
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha:0.5), width: 1.5),
                      ),
                      // 🚀 HugeIcon for Store
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedStore01,
                            color: Colors.white,
                            size: 20
                        ),
                      ),
                    ),

                    // Theme Toggle Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => MyApp.changeTheme(context),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha:0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha:0.3), width: 1),
                          ),
                          // 🚀 HugeIcon for Theme
                          child: HugeIcon(
                            icon: ThemeService.instance.isDarkMode
                                ? HugeIcons.strokeRoundedSun02
                                : HugeIcons.strokeRoundedMoon02,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// --- APP NAME ---
                const Text(
                  "Snap2Bill",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "Smart Billing Solutions",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          /// ============================================================
          /// 📋 LIST ITEMS (Dynamic Icons Support)
          /// ============================================================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 100),
              children: menuItems.map((item) {
                final itemColor = item.color == dangerColor ? dangerColor : textColor;
                return _drawerItem(context, isDark, item.icon, item.title, item.onTap, itemColor);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 🚀 Helper Widget (Smart Icon Logic)
  Widget _drawerItem(BuildContext context, bool isDark, dynamic icon, String title, Function() onTap, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.transparent : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        onTap: () async {
          Navigator.pop(context);
          final result = onTap();
          if (result is Widget && context.mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => result));
          } else if (result is Future) {
            final destination = await result;
            if (destination is Widget && context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => destination),
                    (route) => false,
              );
            }
          }
        },
        // 🚀 SMART ICON RENDERER
        leading: icon is IconData
            ? Icon(icon, color: color, size: 24)
            : HugeIcon(icon: icon, color: color, size: 24),

        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color.withValues(alpha:0.5)),
      ),
    );
  }
}