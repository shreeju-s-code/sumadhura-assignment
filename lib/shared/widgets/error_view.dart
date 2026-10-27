import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';

/// Reusable error presentation widget with retry action and
/// MediaQuery responsive textsize, sizedbox, container, and padding.
class ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryText;

  const ErrorView({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
    this.retryText = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: Responsive.paddingSymmetric(context, horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: Responsive.paddingAll(context, 16),
              decoration: const BoxDecoration(
                color: AppColors.bgDestructive,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: Responsive.sp(context, 38),
                color: AppColors.statusDestructive,
              ),
            ),
            Responsive.vSpace(context, 16),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: Responsive.sp(context, 17),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            Responsive.vSpace(context, 8),
            Text(
              message,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: Responsive.sp(context, 14),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              Responsive.vSpace(context, 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh_rounded, size: Responsive.sp(context, 18)),
                label: Text(
                  retryText,
                  style: TextStyle(fontSize: Responsive.sp(context, 13.5)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: Responsive.paddingSymmetric(context, horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
