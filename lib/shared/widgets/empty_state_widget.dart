import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';

/// Clean, responsive empty state view for lists and search results
/// using MediaQuery responsive textsize, sizedbox, container, and padding.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.people_outline_rounded,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: Responsive.paddingSymmetric(context, horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: Responsive.paddingAll(context, 13),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Icon(icon, size: Responsive.sp(context, 34), color: AppColors.textSecondary),
            ),
            Responsive.vSpace(context, 10),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            Responsive.vSpace(context, 6),
            Text(
              message,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: Responsive.sp(context, 12.5),
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              Responsive.vSpace(context, 14),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: Responsive.paddingSymmetric(context, horizontal: 18, vertical: 10),
                ),
                child: Text(
                  actionLabel!,
                  style: TextStyle(fontSize: Responsive.sp(context, 13)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
