import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/visitor_model.dart';

/// Reusable Visitor card with MediaQuery-driven responsive textsize, sizedbox, container, and padding.
class VisitorCard extends StatelessWidget {
  final Visitor visitor;
  final VoidCallback onTap;
  final VoidCallback? onCheckIn;
  final VoidCallback? onCheckOut;
  final VoidCallback? onDelete;

  const VisitorCard({
    super.key,
    required this.visitor,
    required this.onTap,
    this.onCheckIn,
    this.onCheckOut,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(context, 12)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: Responsive.paddingAll(context, 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Name + Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: Responsive.w(context, 20),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                      child: Text(
                        visitor.name.isNotEmpty ? visitor.name[0].toUpperCase() : 'V',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: Responsive.sp(context, 16),
                        ),
                      ),
                    ),
                    Responsive.hSpace(context, 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visitor.name,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: Responsive.sp(context, 15),
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Responsive.vSpace(context, 2),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: Responsive.sp(context, 13),
                                color: AppColors.textSecondary,
                              ),
                              Responsive.hSpace(context, 4),
                              Text(
                                visitor.mobile,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: Responsive.sp(context, 13),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: visitor.status, isCompact: true),
                  ],
                ),

                Responsive.vSpace(context, 10),
                const Divider(height: 1, color: AppColors.border),
                Responsive.vSpace(context, 10),

                // Purpose & Tags
                Row(
                  children: [
                    Container(
                      padding: Responsive.paddingSymmetric(context, horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        visitor.project.label,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: Responsive.sp(context, 11.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Responsive.hSpace(context, 6),
                    Container(
                      padding: Responsive.paddingSymmetric(context, horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.tealLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        visitor.visitorType.label,
                        style: TextStyle(
                          color: AppColors.tealAccent,
                          fontSize: Responsive.sp(context, 11.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                Responsive.vSpace(context, 8),

                // Purpose line
                Text(
                  visitor.purpose,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: Responsive.sp(context, 13),
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                Responsive.vSpace(context, 10),

                // Bottom row: Timestamp + Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Created: ${DateFormatter.formatDate(visitor.createdAt)}',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: Responsive.sp(context, 11.5),
                      ),
                    ),
                    Row(
                      children: [
                        if (visitor.canCheckIn && onCheckIn != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: SizedBox(
                              height: Responsive.h(context, 32),
                              child: ElevatedButton.icon(
                                onPressed: onCheckIn,
                                icon: Icon(Icons.login_rounded, size: Responsive.sp(context, 14)),
                                label: Text(
                                  'Check In',
                                  style: TextStyle(fontSize: Responsive.sp(context, 12)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.tealAccent,
                                  foregroundColor: Colors.white,
                                  padding: Responsive.paddingSymmetric(context, horizontal: 10),
                                ),
                              ),
                            ),
                          ),
                        if (visitor.canCheckOut && onCheckOut != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: SizedBox(
                              height: Responsive.h(context, 32),
                              child: ElevatedButton.icon(
                                onPressed: onCheckOut,
                                icon: Icon(Icons.logout_rounded, size: Responsive.sp(context, 14)),
                                label: Text(
                                  'Check Out',
                                  style: TextStyle(fontSize: Responsive.sp(context, 12)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: Responsive.paddingSymmetric(context, horizontal: 10),
                                ),
                              ),
                            ),
                          ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: Responsive.sp(context, 13),
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
