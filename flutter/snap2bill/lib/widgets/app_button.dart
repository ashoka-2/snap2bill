//
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import '../theme/colors.dart';
//
// class AppButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   final Color color;
//   final Color textColor;
//   final IconData? icon;
//   final bool isTrailingIcon;
//
//   // New properties
//   final bool isLoading;
//   final Color? borderColor;
//   final double height;
//
//   const AppButton({
//     super.key,
//     required this.text,
//     required this.onPressed,
//     this.icon,
//     this.color = Colors.white,
//     this.textColor = Colors.white,
//     this.isTrailingIcon = false,
//     this.isLoading = false,
//     this.borderColor,
//     this.height = 50.0,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: height,
//       width: double.infinity,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           // ✅ Tummhara original Style Logic
//           backgroundColor: AppColors.getButtonColor(context),
//           side: borderColor != null ? BorderSide(color: borderColor!) : null,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(50), // ✅ Radius 50 hi rakha hai
//           ),
//         ),
//         onPressed: isLoading ? null : onPressed,
//         child: isLoading
//             ? const SizedBox(
//           height: 24,
//           width: 24,
//           child: CircularProgressIndicator(
//             color: Colors.white,
//             strokeWidth: 2.5,
//           ),
//         )
//         // 🚀 CHANGE START: Sirf yahan FittedBox lagaya hai
//             : FittedBox(
//           fit: BoxFit.scaleDown, // Text bada hua to shrink karega
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center, // Center align fix
//             mainAxisSize: MainAxisSize.min, // Content ko chipka ke rakhega
//             children: [
//               if (!isTrailingIcon && icon != null) ...[
//                 Icon(icon, color: AppColors.getTextColor2(context), size: 20),
//                 const SizedBox(width: 10),
//               ],
//
//               Text(
//                 text,
//                 style: TextStyle(
//                   color: AppColors.getTextColor2(context),
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//
//               if (isTrailingIcon && icon != null) ...[
//                 const SizedBox(width: 10),
//                 Icon(icon, color: AppColors.getTextColor2(context)),
//               ],
//             ],
//           ),
//         ),
//         // 🚀 CHANGE END
//       ),
//     );
//   }
// }
//
// // class CartButton extends StatefulWidget {
// //   final String text;
// //   final IconData icon;
// //   final VoidCallback onPressed;
// //
// //   const CartButton({
// //     super.key,
// //     required this.text,
// //     required this.icon,
// //     required this.onPressed,
// //   });
// //
// //   @override
// //   State<CartButton> createState() => _CartButtonState();
// // }
// //
// // class _CartButtonState extends State<CartButton>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _controller;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _controller =
// //     AnimationController(vsync: this, duration: const Duration(seconds: 4))
// //       ..repeat();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return AnimatedBuilder(
// //       animation: _controller,
// //       builder: (_, __) {
// //         return Container(
// //           padding: const EdgeInsets.all(2.5), // ✅ border thickness
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(50),
// //             gradient: SweepGradient(
// //               startAngle: 0,
// //               endAngle: 2 * pi,
// //               transform:
// //               GradientRotation(_controller.value * 2 * pi), // 🔥 rotate border
// //               colors:  [
// //                 AppColors.getTextColor2(context),
// //                 AppColors.getTextColor2(context),
// //                 AppColors.getTextColor(context),
// //                 AppColors.getTextColor(context),
// //
// //
// //
// //               ],
// //             ),
// //           ),
// //           child: Container(
// //             decoration: BoxDecoration(
// //               color: AppColors.getButtonBg(context),
// //               // gradient: AppColors.premiumGradient,
// //               borderRadius: BorderRadius.circular(50),
// //
// //             ),
// //             child: ElevatedButton.icon(
// //               onPressed: widget.onPressed,
// //               icon: Icon(widget.icon, size: 16, color: AppColors.getTextColor(context)),
// //               label: Text(
// //                 widget.text,
// //                 style:  TextStyle(
// //                   color: AppColors.getTextColor(context),
// //                   fontSize: 12,
// //                   fontWeight: FontWeight.w900,
// //                 ),
// //               ),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.transparent,
// //                 shadowColor: Colors.transparent,
// //                 elevation: 0,
// //                 padding:
// //                 const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(50),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }
// //
// //
//
//
// class CartButton extends StatefulWidget {
//   final String text;
//   final IconData icon;
//   final VoidCallback onPressed;
//
//   const CartButton({
//     super.key,
//     required this.text,
//     required this.icon,
//     required this.onPressed,
//   });
//
//   @override
//   State<CartButton> createState() => _CartButtonState();
// }
//
// class _CartButtonState extends State<CartButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   bool _isPressed = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 3),
//     )..repeat();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final textColor = AppColors.getTextColor(context);
//     final buttonBg = AppColors.getButtonBg(context);
//     final primaryColor = Theme.of(context).primaryColor;
//
//     return GestureDetector(
//       onTapDown: (_) => setState(() => _isPressed = true),
//       onTapUp: (_) {
//         setState(() => _isPressed = false);
//         widget.onPressed();
//       },
//       onTapCancel: () => setState(() => _isPressed = false),
//       child: AnimatedScale(
//         scale: _isPressed ? 0.95 : 1.0,
//         duration: const Duration(milliseconds: 100),
//         curve: Curves.easeInOut,
//         child: AnimatedBuilder(
//           animation: _controller,
//           builder: (_, __) {
//             return Container(
//               height: 40, // Fixed Height
//               width: double.infinity, // Full width le lega parent ke hisaab se
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(50),
//                 boxShadow: [
//                   BoxShadow(
//                     color: primaryColor.withValues(alpha:0.2),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // 1. ROTATING BORDER
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(50),
//                       gradient: SweepGradient(
//                         startAngle: 0,
//                         endAngle: 2 * pi,
//                         transform: GradientRotation(_controller.value * 2 * pi),
//                         colors: [
//                           Colors.transparent,
//                           primaryColor.withValues(alpha:0.5),
//                           primaryColor,
//                           Colors.white,
//                           primaryColor,
//                           primaryColor.withValues(alpha:0.5),
//                           Colors.transparent,
//                         ],
//                         stops: const [0.0, 0.3, 0.45, 0.5, 0.55, 0.7, 1.0],
//                       ),
//                     ),
//                   ),
//
//                   // 2. INNER BACKGROUND
//                   Container(
//                     margin: const EdgeInsets.all(2.0),
//                     decoration: BoxDecoration(
//                       color: buttonBg,
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                   ),
//
//                   // 3. TEXT & ICON (WITH FITTED BOX 🚀)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     child: FittedBox(
//                       fit: BoxFit.scaleDown, // 🚀 Text bada hua to chota ho jayega
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                               widget.icon,
//                               size: 16,
//                               color: textColor
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             widget.text.toUpperCase(),
//                             style: TextStyle(
//                               color: textColor,
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
//
//
// class DeleteButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   final IconData icon;
//   final double size;
//   final String text;
//   final bool showText; // 🚀 Added to control visibility
//
//   const DeleteButton({
//     super.key,
//     required this.onPressed,
//     this.icon = Icons.delete_outline,
//     this.size = 35.0,
//     this.text = "Delete",
//     this.showText = false, // 🚀 Default is false (icon only)
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onPressed,
//       borderRadius: BorderRadius.circular(showText ? 30 : size / 2),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: EdgeInsets.symmetric(horizontal: showText ? 12 : 0),
//         // 🚀 Width is only fixed if it's a circle (icon only)
//         width: showText ? null : size,
//         height: size,
//         decoration: BoxDecoration(
//           color: AppColors.dangerbgColor,
//           // 🚀 Change shape based on text visibility
//           borderRadius: BorderRadius.circular(showText ? 30 : size / 2),
//           border: Border.all(
//             color: AppColors.dangerColor,
//             width: 1.2,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: AppColors.dangerColor,
//               size: size * 0.55,
//             ),
//             // 🚀 Only show text if showText is true
//             if (showText) ...[
//               const SizedBox(width: 8),
//               Text(
//                 text,
//                 style: TextStyle(
//                   color: AppColors.dangerColor,
//                   fontWeight: FontWeight.bold,
//                   fontSize: size * 0.4,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class EditButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   final IconData icon;
//   final double size;
//   final String? text; // 🚀 Nullable: If null, button is circular
//
//   const EditButton({
//     super.key,
//     required this.onPressed,
//     this.icon = Icons.edit_outlined,
//     this.size = 35.0,
//     this.text, // 🚀 No default value needed
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // 🚀 Determine if we are in "Text Mode" or "Icon Mode"
//     final bool hasText = text != null && text!.isNotEmpty;
//
//     return InkWell(
//       onTap: onPressed,
//       // Adaptive radius: Circle for icon, Rounded Rect for text
//       borderRadius: BorderRadius.circular(hasText ? 12 : size / 2),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         height: size,
//         // 🚀 Width is null (auto) if there is text, fixed if it's a circle
//         width: hasText ? null : size,
//         padding: EdgeInsets.symmetric(horizontal: hasText ? 15 : 0),
//         decoration: BoxDecoration(
//           color: AppColors.pillbgColor,
//           borderRadius: BorderRadius.circular(hasText ? 30 : size / 2),
//           border: Border.all(
//             color: AppColors.pillColor,
//             width: 1.2,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: AppColors.pillColor,
//               size: size * 0.5,
//             ),
//             if (hasText) ...[
//               const SizedBox(width: 8),
//               Text(
//                 text!,
//                 style: TextStyle(
//                   color: AppColors.pillColor,
//                   fontWeight: FontWeight.bold,
//                   fontSize: size * 0.4,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class SecondaryButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   final Widget? leading;
//   final Color? color;
//   final Color? textColor;
//   final double height;
//   final double borderRadius;
//
//   const SecondaryButton({
//     super.key,
//     required this.text,
//     required this.onPressed,
//     this.leading,
//     this.color,
//     this.textColor,
//     this.height = 50,
//     this.borderRadius = 50,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Logic: Use provided color, else fallback to Primary
//     final effectiveBgColor = color ?? AppColors.getPrimaryColor(context);
//
//     return SizedBox(
//       height: height,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           side: BorderSide(
//             color: AppColors.getBorderColor(context).withValues(alpha: 0.5),
//             width: 1,
//           ),
//           backgroundColor: effectiveBgColor,
//           foregroundColor: AppColors.getTextColor(context),
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(borderRadius),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 10), // Thoda padding diya safety ke liye
//         ),
//         // 🚀 FIX: Added FittedBox here
//         child: FittedBox(
//           fit: BoxFit.scaleDown,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (leading != null) ...[
//                 leading!,
//                 const SizedBox(width: 5),
//               ],
//               Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.WhiteColor, // Aapka original color
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/colors.dart';

// ==========================================================
// 1. APP BUTTON (Smart Icon Detection)
// ==========================================================
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Nullable for disabled state
  final Color color;
  final Color textColor;
  final dynamic icon; // Can be IconData or HugeIconData
  final bool isTrailingIcon;
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
    this.isLoading = false,
    this.borderColor,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.getButtonColor(context),
          side: borderColor != null ? BorderSide(color: borderColor!) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isTrailingIcon && icon != null) ...[
                _buildIcon(context, icon, 20),
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
              if (isTrailingIcon && icon != null) ...[
                const SizedBox(width: 10),
                _buildIcon(context, icon, 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 🚀 HELPER: Decides whether to render Icon or HugeIcon
  Widget _buildIcon(BuildContext context, dynamic iconData, double size) {
    if (iconData is IconData) {
      return Icon(iconData, color: AppColors.getTextColor2(context), size: size);
    } else {
      return HugeIcon(
          icon: iconData, color: AppColors.getTextColor2(context), size: size);
    }
  }
}

// ==========================================================
// 2. CART BUTTON (Smart Icon Detection)
// ==========================================================
class CartButton extends StatefulWidget {
  final String text;
  final dynamic icon;
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
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getTextColor(context);
    final buttonBg = AppColors.getButtonBg(context);
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha:0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating Border
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: SweepGradient(
                        startAngle: 0,
                        endAngle: 2 * pi,
                        transform: GradientRotation(_controller.value * 2 * pi),
                        colors: [
                          Colors.transparent,
                          primaryColor.withValues(alpha:0.5),
                          primaryColor,
                          Colors.white,
                          primaryColor,
                          primaryColor.withValues(alpha:0.5),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.45, 0.5, 0.55, 0.7, 1.0],
                      ),
                    ),
                  ),
                  // Inner Background
                  Container(
                    margin: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: buttonBg,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  // Text & Icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildIcon(widget.icon, textColor, 16),
                          const SizedBox(width: 8),
                          Text(
                            widget.text.toUpperCase(),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIcon(dynamic iconData, Color color, double size) {
    if (iconData is IconData) {
      return Icon(iconData, color: color, size: size);
    } else {
      return HugeIcon(icon: iconData, color: color, size: size);
    }
  }
}

// ==========================================================
// 3. DELETE BUTTON (Smart Icon Detection)
// ==========================================================
class DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;
  final dynamic icon;
  final double size;
  final String text;
  final bool showText;

  const DeleteButton({
    super.key,
    required this.onPressed,
    this.icon = HugeIcons.strokeRoundedDelete02,
    this.size = 35.0,
    this.text = "Delete",
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(showText ? 30 : size / 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: showText ? 12 : 0),
        width: showText ? null : size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.dangerbgColor,
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
            _buildIcon(icon, AppColors.dangerColor, size * 0.55),
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

  Widget _buildIcon(dynamic iconData, Color color, double size) {
    if (iconData is IconData) {
      return Icon(iconData, color: color, size: size);
    } else {
      return HugeIcon(icon: iconData, color: color, size: size);
    }
  }
}

// ==========================================================
// 4. EDIT BUTTON (Smart Icon Detection)
// ==========================================================
class EditButton extends StatelessWidget {
  final VoidCallback onPressed;
  final dynamic icon;
  final double size;
  final String? text;

  const EditButton({
    super.key,
    required this.onPressed,
    this.icon = HugeIcons.strokeRoundedEdit02,
    this.size = 35.0,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasText = text != null && text!.isNotEmpty;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(hasText ? 12 : size / 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: size,
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
            _buildIcon(icon, AppColors.pillColor, size * 0.5),
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

  Widget _buildIcon(dynamic iconData, Color color, double size) {
    if (iconData is IconData) {
      return Icon(iconData, color: color, size: size);
    } else {
      return HugeIcon(icon: iconData, color: color, size: size);
    }
  }
}

// ==========================================================
// 5. SECONDARY BUTTON (Already supports Widgets)
// ==========================================================
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget? leading;
  final Color? color;
  final Color? textColor;
  final double height;
  final double borderRadius;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leading,
    this.color,
    this.textColor,
    this.height = 50,
    this.borderRadius = 50,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = color ?? AppColors.getPrimaryColor(context);

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          side: BorderSide(
            color: AppColors.getBorderColor(context).withValues(alpha: 0.5),
            width: 1,
          ),
          backgroundColor: effectiveBgColor,
          foregroundColor: AppColors.getTextColor(context),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
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
                  color: AppColors.WhiteColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}