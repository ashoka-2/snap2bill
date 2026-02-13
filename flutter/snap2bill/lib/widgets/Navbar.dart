//
// import 'package:flutter/material.dart';
// import 'package:hugeicons/hugeicons.dart'; // 🚀 Import HugeIcons
// import '../theme/colors.dart';
//
// class ThemeNavbar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final List<Widget>? actions;
//
//   // 🚀 Dynamic leading: Can be IconData OR HugeIcon data
//   final dynamic leadingIcon;
//   final VoidCallback? onLeadingPressed;
//
//   // Title alignment parameter
//   final bool centerTitle;
//
//   // Dynamic font size parameter
//   final double titleFontSize;
//
//   const ThemeNavbar({
//     super.key,
//     required this.title,
//     this.actions,
//     this.leadingIcon,
//     this.onLeadingPressed,
//     this.centerTitle = false,
//     this.titleFontSize = 16.0,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final bool hasLeading = leadingIcon != null && onLeadingPressed != null;
//     final int actionCount = actions?.length ?? 0;
//
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       centerTitle: centerTitle,
//       automaticallyImplyLeading: false,
//
//       // leadingWidth is 60 if icon exists, 0 if not
//       leadingWidth: hasLeading ? 60 : 0,
//
//       // titleSpacing logic for left vs center alignment
//       titleSpacing: centerTitle ? null : (hasLeading ? 2.0 : 16.0),
//
//       leading: hasLeading
//           ? Padding(
//         padding: const EdgeInsets.all(6.0),
//         child: Container(
//           decoration: BoxDecoration(
//             color: AppColors.getPillBg(context),
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: AppColors.getBorderColor(context).withValues(alpha: 0.3),
//               width: 1.5,
//             ),
//           ),
//           child: IconButton(
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//             // 🚀 SMART ICON BUILDER
//             icon: _buildIcon(context, leadingIcon, 20),
//             onPressed: onLeadingPressed,
//           ),
//         ),
//       )
//           : null,
//
//       title: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         decoration: BoxDecoration(
//           color: AppColors.getPillBg(context),
//           borderRadius: BorderRadius.circular(30),
//           border: Border.all(
//             color: AppColors.getBorderColor(context).withValues(alpha: 0.5),
//             width: 1.5,
//           ),
//         ),
//         child: Text(
//           title,
//           style: TextStyle(
//             color: AppColors.getTextColor(context).withValues(alpha: 0.8),
//             fontWeight: FontWeight.w800,
//             fontSize: titleFontSize,
//             letterSpacing: -0.5,
//           ),
//         ),
//       ),
//
//       actions: [
//         if (actions != null && actions!.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.all(6.0),
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: actionCount > 1 ? 4.0 : 0),
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: AppColors.getBorderColor(context).withValues(alpha: 0.5),
//                   width: 1.5,
//                 ),
//                 color: AppColors.getPillBg(context),
//                 shape: actionCount > 1 ? BoxShape.rectangle : BoxShape.circle,
//                 borderRadius: actionCount > 1 ? BorderRadius.circular(30) : null,
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: actions!.map((widget) {
//                   // If user passes an IconButton (even with HugeIcon inside), preserve styling
//                   if (widget is IconButton) {
//                     return SizedBox(
//                       width: 40,
//                       child: IconButton(
//                         onPressed: widget.onPressed,
//                         icon: widget.icon, // This supports HugeIcon() widget naturally
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         constraints: const BoxConstraints(),
//                         iconSize: 20,
//                         color: widget.color,
//                       ),
//                     );
//                   }
//                   return widget;
//                 }).toList(),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   // 🚀 HELPER: Decides whether to render Icon or HugeIcon
//   Widget _buildIcon(BuildContext context, dynamic iconData, double size) {
//     if (iconData is IconData) {
//       return Icon(
//           iconData,
//           color: AppColors.getIconColor(context),
//           size: size
//       );
//     } else {
//       return HugeIcon(
//           icon: iconData,
//           color: AppColors.getIconColor(context),
//           size: size
//       );
//     }
//   }
//
//   @override
//   Size get preferredSize => const Size.fromHeight(60);
// }

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/colors.dart';

class ThemeNavbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  // ✅ FIX 1: Type ko 'dynamic' se 'List<Widget>?' kar diya
  final List<Widget>? actions;

  // ✅ FIX 2: Leading icon can be IconData, HugeIconData, or a Widget
  final dynamic leadingIcon;

  final VoidCallback? onLeadingPressed;
  final bool centerTitle;
  final double titleFontSize;

  const ThemeNavbar({
    super.key,
    required this.title,
    this.actions,
    this.leadingIcon,
    this.onLeadingPressed,
    this.centerTitle = false,
    this.titleFontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasLeading = leadingIcon != null && onLeadingPressed != null;
    final int actionCount = actions?.length ?? 0;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leadingWidth: hasLeading ? 60 : 0,
      titleSpacing: centerTitle ? null : (hasLeading ? 2.0 : 16.0),

      leading: hasLeading
          ? Padding(
        padding: const EdgeInsets.all(6.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.getPillBg(context),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.getBorderColor(context).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            // ✅ FIX 3: Robust Icon Builder called here
            icon: _buildIcon(context, leadingIcon, 20),
            onPressed: onLeadingPressed,
          ),
        ),
      )
          : null,

      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.getPillBg(context),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.getBorderColor(context).withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.getTextColor(context).withValues(alpha: 0.8),
            fontWeight: FontWeight.w800,
            fontSize: titleFontSize,
            letterSpacing: -0.5,
          ),
        ),
      ),

      actions: [
        if (actions != null && actions!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: actionCount > 1 ? 8.0 : 0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.getBorderColor(context).withValues(alpha: 0.5),
                  width: 1.5,
                ),
                color: AppColors.getPillBg(context),
                shape: actionCount > 1 ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: actionCount > 1 ? BorderRadius.circular(30) : null,
              ),
              // ✅ FIX 4: Simplified Actions Logic
              // Humne map() hata diya kyunki widgets ko modify karna error create kar raha tha.
              // Ab ye seedha widgets render karega.
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              ),
            ),
          ),
      ],
    );
  }

  // ✅ FIX 5: Safe Icon Builder
  // Ye check karega ki input IconData hai, Widget hai, ya HugeIconData hai
  Widget _buildIcon(BuildContext context, dynamic iconData, double size) {
    Color iconColor = AppColors.getIconColor(context);

    if (iconData is IconData) {
      return Icon(iconData, color: iconColor, size: size);
    }
    else if (iconData is Widget) {
      return iconData; // Agar already Icon widget bheja hai to wahi dikhao
    }
    else {
      // Assuming it's HugeIconData
      return HugeIcon(
        icon: iconData,
        color: iconColor,
        size: size,
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}