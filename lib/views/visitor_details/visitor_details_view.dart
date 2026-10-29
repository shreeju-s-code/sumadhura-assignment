import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive.dart';
import '../../features/visitor/data/models/visitor_model.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_view.dart';
import '../../shared/widgets/status_chip.dart';
import '../../viewmodels/visitor_details_viewmodel.dart';
import '../visitor_form/visitor_form_view.dart';

class VisitorDetailsView extends ConsumerWidget {
  final String visitorId;

  const VisitorDetailsView({super.key, required this.visitorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(visitorDetailsViewModelProvider(visitorId));
    final viewModel = ref.read(visitorDetailsViewModelProvider(visitorId).notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Visitor Pass & Profile'),
        actions: [
          if (state.visitor != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Visitor',
              onPressed: () {
                openEditVisitorModal(context, state.visitor!);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70),
              tooltip: 'Delete Visitor',
              onPressed: () => _confirmDelete(context, state.visitor!, viewModel),
            ),
          ],
        ],
      ),
      body: _buildBody(context, state, viewModel),
    );
  }

  Widget _buildBody(
    BuildContext context,
    VisitorDetailsState state,
    VisitorDetailsViewModel viewModel,
  ) {
    if (state.isLoading) {
      return const LoadingView(message: 'Loading visitor record...');
    }

    if (state.visitor == null || state.errorMessage != null) {
      return ErrorView(
        title: 'Visitor Record Not Found',
        message: state.errorMessage ?? 'No visitor found with ID #$visitorId.',
        retryText: 'Return to Directory',
        onRetry: () => Navigator.pop(context),
      );
    }

    final visitor = state.visitor!;

    return SingleChildScrollView(
      // 4. PADDING with MediaQuery
      padding: Responsive.paddingAll(context, 16.0),
      child: Column(
        children: [
          // Security Pass Card with Generated QR Code
          _buildPassCard(context, visitor),
          // 2. SIZEDBOX with MediaQuery
          Responsive.vSpace(context, 16),

          // Visitor Details Card
          _buildInfoCard(context, visitor),
          Responsive.vSpace(context, 16),

          // Lifecycle & Timestamps Card
          _buildAuditCard(context, visitor),
          Responsive.vSpace(context, 24),

          // Check-in / Check-out Action Button
          _buildActionButton(context, visitor, state, viewModel),
        ],
      ),
    );
  }

  Widget _buildPassCard(BuildContext context, Visitor visitor) {
    // 3. CONTAINER / Sizing with MediaQuery
    final qrDimension = Responsive.qrCodeSize(context);

    return Container(
      width: double.infinity,
      padding: Responsive.paddingSymmetric(context, horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TEXTSIZE with MediaQuery
                  Text(
                    'SECURITY PASS',
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 11),
                      fontWeight: FontWeight.w700,
                      color: AppColors.tealAccent,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Responsive.vSpace(context, 2),
                  Text(
                    'PASS ID: #${visitor.id}',
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 16),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              StatusChip(status: visitor.status),
            ],
          ),

          Responsive.vSpace(context, 18),
          const Divider(color: AppColors.border),
          Responsive.vSpace(context, 18),

          // QR Code Display generated from visitor ID with MediaQuery-derived size
          Container(
            padding: Responsive.paddingAll(context, 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: QrImageView(
              data: visitor.id,
              version: QrVersions.auto,
              size: qrDimension,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.primary,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.primary,
              ),
            ),
          ),

          Responsive.vSpace(context, 14),
          Text(
            'Scan this QR at the gate to record entry and exit',
            style: TextStyle(
              fontSize: Responsive.sp(context, 12),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Visitor visitor) {
    return Container(
      width: double.infinity,
      padding: Responsive.paddingAll(context, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visitor Information',
            style: TextStyle(
              fontSize: Responsive.sp(context, 15),
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Responsive.vSpace(context, 14),

          _buildRow(context, Icons.person_rounded, 'Full Name', visitor.name),
          _buildRow(context, Icons.phone_rounded, 'Mobile Number', visitor.mobile),
          _buildRow(
            context,
            Icons.email_rounded,
            'Email Address',
            visitor.email?.isNotEmpty == true ? visitor.email! : 'Not provided',
          ),
          _buildRow(context, Icons.business_rounded, 'Project Location', visitor.project.label),
          _buildRow(context, Icons.badge_rounded, 'Visitor Classification', visitor.visitorType.label),
          _buildRow(context, Icons.assignment_rounded, 'Purpose of Visit', visitor.purpose),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(context, 12.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: Responsive.sp(context, 18), color: AppColors.tealAccent),
          Responsive.hSpace(context, 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 11.5),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Responsive.vSpace(context, 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 14),
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditCard(BuildContext context, Visitor visitor) {
    return Container(
      width: double.infinity,
      padding: Responsive.paddingAll(context, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visit Lifecycle & Timestamps',
            style: TextStyle(
              fontSize: Responsive.sp(context, 15),
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Responsive.vSpace(context, 14),

          _buildTimelineStep(
            context: context,
            title: 'Registered',
            timestamp: DateFormatter.formatDateTime(visitor.createdAt),
            isDone: true,
            icon: Icons.app_registration_rounded,
            color: AppColors.statusRegistered,
          ),
          _buildTimelineStep(
            context: context,
            title: 'Checked In',
            timestamp: visitor.checkInTime != null
                ? DateFormatter.formatDateTime(visitor.checkInTime)
                : 'Pending arrival',
            isDone: visitor.checkInTime != null,
            icon: Icons.login_rounded,
            color: AppColors.statusCheckedIn,
          ),
          _buildTimelineStep(
            context: context,
            title: 'Checked Out',
            timestamp: visitor.checkOutTime != null
                ? DateFormatter.formatDateTime(visitor.checkOutTime)
                : (visitor.status == VisitorStatus.checkedIn
                    ? 'Currently on site'
                    : 'Pending check-in'),
            isDone: visitor.checkOutTime != null,
            icon: Icons.logout_rounded,
            color: AppColors.statusCheckedOut,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required BuildContext context,
    required String title,
    required String timestamp,
    required bool isDone,
    required IconData icon,
    required Color color,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: Responsive.paddingAll(context, 5),
              decoration: BoxDecoration(
                color: isDone ? color : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: Responsive.sp(context, 14), color: Colors.white),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: Responsive.h(context, 32),
                color: isDone ? color.withValues(alpha: 0.4) : AppColors.border,
              ),
          ],
        ),
        Responsive.hSpace(context, 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 13.5),
                    fontWeight: FontWeight.w700,
                    color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 12),
                    color: isDone ? AppColors.textSecondary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    Visitor visitor,
    VisitorDetailsState state,
    VisitorDetailsViewModel viewModel,
  ) {
    if (visitor.canCheckIn) {
      return CustomButton(
        label: 'Check In Visitor',
        icon: Icons.login_rounded,
        variant: CustomButtonVariant.teal,
        isLoading: state.isActionRunning,
        onPressed: () => _handleCheckIn(context, visitor, viewModel),
        width: double.infinity,
      );
    } else if (visitor.canCheckOut) {
      return CustomButton(
        label: 'Check Out Visitor',
        icon: Icons.logout_rounded,
        variant: CustomButtonVariant.primary,
        isLoading: state.isActionRunning,
        onPressed: () => _handleCheckOut(context, visitor, viewModel),
        width: double.infinity,
      );
    } else {
      // Completed visit rule: Cannot be checked in again
      return Container(
        width: double.infinity,
        padding: Responsive.paddingAll(context, 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.statusCheckedOut, size: Responsive.sp(context, 18)),
            Responsive.hSpace(context, 8),
            Text(
              'Visit completed. Record is archived.',
              style: TextStyle(
                color: AppColors.statusCheckedOut,
                fontSize: Responsive.sp(context, 13.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handleCheckIn(
    BuildContext context,
    Visitor visitor,
    VisitorDetailsViewModel viewModel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Check In', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to check in "${visitor.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tealAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Check In'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await viewModel.checkIn();
      if (context.mounted) {
        AppSnackBar.showSuccess(context, '${visitor.name} has been successfully checked in.');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, e.toString());
      }
    }
  }

  Future<void> _handleCheckOut(
    BuildContext context,
    Visitor visitor,
    VisitorDetailsViewModel viewModel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Check Out', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to check out "${visitor.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Check Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await viewModel.checkOut();
      if (context.mounted) {
        AppSnackBar.showSuccess(
          context,
          '${visitor.name} has been checked out.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, e.toString());
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Visitor visitor,
    VisitorDetailsViewModel viewModel,
  ) async {
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Visitor', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to permanently delete the record for "${visitor.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDestructive),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await viewModel.delete();
        if (context.mounted) {
          AppSnackBar.showSuccess(
            context,
            'Visitor "${visitor.name}" deleted.',
          );
        }
        navigator.pop();
      } catch (e) {
        if (context.mounted) {
          AppSnackBar.showError(context, 'Failed to delete visitor: $e');
        }
      }
    }
  }
}
