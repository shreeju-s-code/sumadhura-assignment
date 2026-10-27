import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';

/// Clean, branded loading view with optional progress text and
/// MediaQuery responsive textsize, sizedbox, container, and padding.
class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: Responsive.paddingAll(context, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: Responsive.w(context, 38),
              height: Responsive.w(context, 38),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.tealAccent),
                strokeWidth: 3.2,
              ),
            ),
            if (message != null) ...[
              Responsive.vSpace(context, 16),
              Text(
                message!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: Responsive.sp(context, 14),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
