import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:snap2bill/theme/colors.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String hintText;
  final Function(String) onChanged;
  final TextEditingController? controller;
  // 🚀 Added this to control the back button visibility
  final VoidCallback? onLeadingPressed;

  const SearchAppBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
    this.onLeadingPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      // 🚀 Prevents default back button from showing up automatically
      automaticallyImplyLeading: false,
      titleSpacing: 0,

      // 🚀 Shows the icon ONLY if onLeadingPressed is provided
      leading: onLeadingPressed != null
          ? Padding(
            padding: const EdgeInsets.all(7.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.getPillBg(context).withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.getBorderColor(context).withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.getTextColor(context),
                size: 20
                      ),
                      onPressed: onLeadingPressed,
                    ),
            ),
          )
          : null,

      title: Padding(
        padding: EdgeInsets.only(
            left: onLeadingPressed != null ? 0 : 16,
            right: 16
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color:AppColors.getBorderColor(context).withValues(alpha: 0.2) ,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[200],

              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(color: AppColors.getTextColor(context), fontSize: 14),
                cursorColor: Colors.blueAccent,
                decoration: InputDecoration(
                  isCollapsed: true,
                  filled: false,
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedSearch01,
                      size: 22, // Adjusted to fit perfectly in 40 height
                      color: Colors.grey.shade500,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    maxHeight: 40,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(right: 15),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}