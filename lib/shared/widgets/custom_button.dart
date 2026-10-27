import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';

enum CustomButtonVariant { primary, secondary, destructive, teal }

/// Reusable enterprise action button with MediaQuery responsive textsize, sizedbox, container, and padding.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final CustomButtonVariant variant;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = CustomButtonVariant.primary,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, borderSide) = switch (variant) {
      CustomButtonVariant.primary => (AppColors.primary, Colors.white, BorderSide.none),
      CustomButtonVariant.teal => (AppColors.tealAccent, Colors.white, BorderSide.none),
      CustomButtonVariant.destructive => (AppColors.statusDestructive, Colors.white, BorderSide.none),
      CustomButtonVariant.secondary => (
          Colors.white,
          AppColors.primary,
          const BorderSide(color: AppColors.border, width: 1.2),
        ),
    };

    return SizedBox(
      width: width,
      height: Responsive.h(context, height),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.6),
          disabledForegroundColor: fgColor.withValues(alpha: 0.7),
          elevation: 0,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: Responsive.paddingSymmetric(context, horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                width: Responsive.w(context, 22),
                height: Responsive.w(context, 22),
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: Responsive.sp(context, 18), color: fgColor),
                    Responsive.hSpace(context, 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 14.5),
                      fontWeight: FontWeight.w600,
                      color: fgColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
