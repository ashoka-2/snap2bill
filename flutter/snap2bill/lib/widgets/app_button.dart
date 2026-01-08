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
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 50,
      width: double.infinity, // Usually buttons in login forms take full width
      child: ElevatedButton(

        style: ElevatedButton.styleFrom(
          backgroundColor: isDark?AppColors.buttonColorLight:AppColors.buttonColorDark,
          // FIX FOR BORDER COLOR ERROR
          // If a borderColor is passed, use it; otherwise, no border.
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
          children: [
            // Only show Leading Icon if icon exists AND it is not trailing
            if (!isTrailingIcon && icon != null) ...[
              Icon(icon, color: AppColors.getTextColor2(context)),
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
              Icon(icon, color: textColor),
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
          padding: const EdgeInsets.all(2), // ✅ border thickness
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
                AppColors.getTextColor2(context),
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
                  fontWeight: FontWeight.bold,
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
