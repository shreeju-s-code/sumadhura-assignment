import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';

/// Stat card for the Dashboard metrics row utilizing MediaQuery responsive dimensions.
class DashboardStatCard extends StatelessWidget {
  final String title;
  final int count;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Responsive padding using MediaQuery
      padding: Responsive.paddingSymmetric(context, horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Responsive icon container
                Container(
                  padding: Responsive.paddingAll(context, 6),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: Responsive.sp(context, 16), color: accentColor),
                ),
                // Responsive count text size
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 20),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            // Responsive vertical spacing
            Responsive.vSpace(context, 8),
            // Responsive title text size
            Text(
              title,
              style: TextStyle(
                fontSize: Responsive.sp(context, 12),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Responsive subtitle text size
            Text(
              subtitle,
              style: TextStyle(
                fontSize: Responsive.sp(context, 10.5),
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
