import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../features/visitor/data/models/visitor_model.dart';

/// Pill-style status chip with approved corporate palette colors
/// and MediaQuery responsive textsize, sizedbox, and padding.
class StatusChip extends StatelessWidget {
  final VisitorStatus status;
  final bool isCompact;

  const StatusChip({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (textColor, bgColor, icon) = switch (status) {
      VisitorStatus.registered => (
          AppColors.statusRegistered,
          AppColors.bgRegistered,
          Icons.schedule_rounded,
        ),
      VisitorStatus.checkedIn => (
          AppColors.statusCheckedIn,
          AppColors.bgCheckedIn,
          Icons.check_circle_rounded,
        ),
      VisitorStatus.checkedOut => (
          AppColors.statusCheckedOut,
          AppColors.bgCheckedOut,
          Icons.done_all_rounded,
        ),
    };

    return Container(
      padding: Responsive.paddingSymmetric(
        context,
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: Responsive.sp(context, isCompact ? 12 : 14),
            color: textColor,
          ),
          Responsive.hSpace(context, 5),
          Text(
            status.label,
            style: TextStyle(
              color: textColor,
              fontSize: Responsive.sp(context, isCompact ? 11 : 12),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
