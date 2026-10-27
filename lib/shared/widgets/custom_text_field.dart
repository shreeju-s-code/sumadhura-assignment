import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';

/// Reusable enterprise text field with consistent styling, validation,
/// and MediaQuery-driven responsive textsize, sizedbox, and padding.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final bool readOnly;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. TEXTSIZE with MediaQuery
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(context, 13),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        // 2. SIZEDBOX with MediaQuery
        Responsive.vSpace(context, 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLines: maxLines,
          readOnly: readOnly,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: Responsive.sp(context, 14),
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: Responsive.sp(context, 13.5),
              color: AppColors.textSecondary,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: Responsive.sp(context, 18), color: AppColors.textSecondary)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            // 4. PADDING with MediaQuery
            contentPadding: Responsive.paddingSymmetric(context, horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.tealAccent, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.statusDestructive),
            ),
          ),
        ),
      ],
    );
  }
}
