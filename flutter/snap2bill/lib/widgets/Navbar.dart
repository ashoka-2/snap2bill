import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ThemeNavbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  // 🚀 Dynamic leading parameters
  final IconData? leadingIcon;
  final VoidCallback? onLeadingPressed;

  // 🚀 Title alignment parameter
  final bool centerTitle;

  // 🚀 New: Dynamic font size parameter
  final double titleFontSize;

  const ThemeNavbar({
    super.key,
    required this.title,
    this.actions,
    this.leadingIcon,
    this.onLeadingPressed,
    this.centerTitle = false, // Default is left-aligned
    this.titleFontSize = 16.0, // Default is 16
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

      // leadingWidth is 60 if icon exists, 0 if not
      leadingWidth: hasLeading ? 60 : 0,

      // titleSpacing logic for left vs center alignment
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
            icon: Icon(
              leadingIcon,
              color: AppColors.getIconColor(context),
              size: 20,
            ),
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
            fontSize: titleFontSize, // 🚀 Now uses the dynamic parameter
            letterSpacing: -0.5,
          ),
        ),
      ),

      actions: [
        if (actions != null && actions!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: actionCount > 1 ? 4.0 : 0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.getBorderColor(context).withValues(alpha: 0.5),
                  width: 1.5,
                ),
                color: AppColors.getPillBg(context),
                shape: actionCount > 1 ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: actionCount > 1 ? BorderRadius.circular(30) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!.map((widget) {
                  if (widget is IconButton) {
                    return SizedBox(
                      width: 40,
                      child: IconButton(
                        onPressed: widget.onPressed,
                        icon: widget.icon,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        constraints: const BoxConstraints(),
                        iconSize: 20,
                        color: widget.color,
                      ),
                    );
                  }
                  return widget;
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}