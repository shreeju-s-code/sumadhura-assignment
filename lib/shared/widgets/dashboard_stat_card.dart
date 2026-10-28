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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : AppColors.surface;
    final cardBorder = isDark ? const Color(0xFF334155) : AppColors.border;
    final primaryTextColor = isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final iconBg = isDark ? accentColor.withValues(alpha: 0.18) : bgColor;

    return Container(
      // Responsive padding using MediaQuery
      padding: Responsive.paddingSymmetric(context, horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
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
                    color: iconBg,
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
                    color: primaryTextColor,
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
                color: primaryTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Responsive subtitle text size
            Text(
              subtitle,
              style: TextStyle(
                fontSize: Responsive.sp(context, 10.5),
                color: secondaryTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
