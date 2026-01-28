import 'package:flutter/material.dart';
import 'dart:math';

import '../theme/colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  // 1. Made Icon optional (nullable) because your Login page doesn't pass one
  final IconData? icon;
  final bool isTrailingIcon;

  // 2. New properties to fix your specific errors
  final bool isLoading;
  final Color? borderColor;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color = Colors.white,
    this.textColor = Colors.white,
    this.isTrailingIcon = false,

    // Initialize new properties
    this.isLoading = false,
    this.borderColor,
    this.height= 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity, // Usually buttons in login forms take full width
      child: ElevatedButton(

        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.getButtonColor(context),
          side: borderColor != null ? BorderSide(color: borderColor!) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        // If loading, disable the button (null) so user can't click twice
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          // Show spinner when loading
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Only show Leading Icon if icon exists AND it is not trailing
            if (!isTrailingIcon && icon != null) ...[
              Icon(icon, color: AppColors.getTextColor2(context),size: 20,),
              const SizedBox(width: 10),
            ],

            Text(
              text,
              style: TextStyle(
                color: AppColors.getTextColor2(context),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Only show Trailing Icon if icon exists AND it is trailing
            if (isTrailingIcon && icon != null) ...[
              const SizedBox(width: 10),
              Icon(icon, color: AppColors.getTextColor2(context)),
            ],
          ],
        ),
      ),
    );
  }
}





class CartButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const CartButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.all(2.5), // ✅ border thickness
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: SweepGradient(
              startAngle: 0,
              endAngle: 2 * pi,
              transform:
              GradientRotation(_controller.value * 2 * pi), // 🔥 rotate border
              colors:  [
                AppColors.getTextColor2(context),
                AppColors.getTextColor2(context),
                AppColors.getTextColor(context),


              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.getButtonBg(context),
              // gradient: AppColors.premiumGradient,
              borderRadius: BorderRadius.circular(50),

            ),
            child: ElevatedButton.icon(
              onPressed: widget.onPressed,
              icon: Icon(widget.icon, size: 16, color: AppColors.getTextColor(context)),
              label: Text(
                widget.text,
                style:  TextStyle(
                  color: AppColors.getTextColor(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}







class DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double size;
  final String text;
  final bool showText; // 🚀 Added to control visibility

  const DeleteButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.delete_outline,
    this.size = 35.0,
    this.text = "Delete",
    this.showText = false, // 🚀 Default is false (icon only)
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(showText ? 30 : size / 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: showText ? 12 : 0),
        // 🚀 Width is only fixed if it's a circle (icon only)
        width: showText ? null : size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.dangerbgColor,
          // 🚀 Change shape based on text visibility
          borderRadius: BorderRadius.circular(showText ? 30 : size / 2),
          border: Border.all(
            color: AppColors.dangerColor,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.dangerColor,
              size: size * 0.55,
            ),
            // 🚀 Only show text if showText is true
            if (showText) ...[
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: AppColors.dangerColor,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EditButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double size;
  final String? text; // 🚀 Nullable: If null, button is circular

  const EditButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.edit_outlined,
    this.size = 35.0,
    this.text, // 🚀 No default value needed
  });

  @override
  Widget build(BuildContext context) {
    // 🚀 Determine if we are in "Text Mode" or "Icon Mode"
    final bool hasText = text != null && text!.isNotEmpty;

    return InkWell(
      onTap: onPressed,
      // Adaptive radius: Circle for icon, Rounded Rect for text
      borderRadius: BorderRadius.circular(hasText ? 12 : size / 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: size,
        // 🚀 Width is null (auto) if there is text, fixed if it's a circle
        width: hasText ? null : size,
        padding: EdgeInsets.symmetric(horizontal: hasText ? 15 : 0),
        decoration: BoxDecoration(
          color: AppColors.pillbgColor,
          borderRadius: BorderRadius.circular(hasText ? 30 : size / 2),
          border: Border.all(
            color: AppColors.pillColor,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.pillColor,
              size: size * 0.5,
            ),
            if (hasText) ...[
              const SizedBox(width: 8),
              Text(
                text!,
                style: TextStyle(
                  color: AppColors.pillColor,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget? leading;
  final Color? color;        // 🚀 Nullable: if null, it uses default
  final Color? textColor;    // 🚀 Nullable: if null, it uses default
  final double height;
  final double borderRadius;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leading,
    this.color,             // Optional color override
    this.textColor,         // Optional text color override
    this.height = 50,
    this.borderRadius = 50,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🚀 LOGIC: Use provided color, else fallback to Theme Primary, else fallback to Black/White
    final effectiveBgColor = color ?? theme.primaryColor;


    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBgColor,
          foregroundColor: AppColors.getTextColor(context),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 5),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}