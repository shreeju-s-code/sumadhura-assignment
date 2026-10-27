import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/visitor_model.dart';
import '../controllers/visitor_providers.dart';
import 'visitor_form_screen.dart';

class VisitorDetailsScreen extends ConsumerStatefulWidget {
  final String visitorId;

  const VisitorDetailsScreen({super.key, required this.visitorId});

  @override
  ConsumerState<VisitorDetailsScreen> createState() => _VisitorDetailsScreenState();
}

class _VisitorDetailsScreenState extends ConsumerState<VisitorDetailsScreen> {
  bool _isProcessingAction = false;

  @override
  Widget build(BuildContext context) {
    // Watch list for reactive updates
    final listAsync = ref.watch(visitorListNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Visitor Pass & Details'),
        actions: [
          // Edit button
          listAsync.maybeWhen(
            data: (visitors) {
              final visitor = visitors.where((v) => v.id == widget.visitorId).firstOrNull;
              if (visitor == null) return const SizedBox.shrink();
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit Visitor',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VisitorFormScreen(existingVisitor: visitor),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70),
                    tooltip: 'Delete Visitor',
                    onPressed: () => _confirmDelete(visitor),
                  ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: listAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading visitor record...'),
        error: (error, _) => ErrorView(
          title: 'Unable to load visitor',
          message: error.toString(),
          onRetry: () => ref.read(visitorListNotifierProvider.notifier).loadVisitors(),
        ),
        data: (visitors) {
          final visitor = visitors.where((v) => v.id == widget.visitorId).firstOrNull;

          if (visitor == null) {
            return ErrorView(
              title: 'Visitor Not Found',
              message: 'No visitor record found with ID #${widget.visitorId}.',
              retryText: 'Back to Directory',
              onRetry: () => Navigator.pop(context),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Digital QR Code Pass Card
                _buildQrPassCard(visitor),
                const SizedBox(height: 16),

                // Visitor Details Card
                _buildDetailsCard(visitor),
                const SizedBox(height: 16),

                // Lifecycle & Timestamp Audit Trail Card
                _buildAuditTrailCard(visitor),
                const SizedBox(height: 24),

                // Action Buttons (Check-In / Check-Out)
                _buildActionButtons(visitor),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQrPassCard(Visitor visitor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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
          // Header of pass
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SECURITY PASS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tealAccent,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'PASS ID: #${visitor.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              StatusBadge(status: visitor.status),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(color: AppColors.border),
          const SizedBox(height: 18),

          // QR Code Graphic (Generated using server-assigned ID)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: QrImageView(
              data: visitor.id,
              version: QrVersions.auto,
              size: 190.0,
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

          const SizedBox(height: 14),
          const Text(
            'Present this QR at the gate scanner to Check In or Check Out',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Visitor visitor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visitor Information',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),

          _buildDetailRow(Icons.person_rounded, 'Full Name', visitor.name),
          _buildDetailRow(Icons.phone_rounded, 'Mobile Number', visitor.mobile),
          _buildDetailRow(
            Icons.email_rounded,
            'Email Address',
            visitor.email?.isNotEmpty == true ? visitor.email! : 'Not provided',
          ),
          _buildDetailRow(Icons.business_rounded, 'Project Location', visitor.project.label),
          _buildDetailRow(Icons.badge_rounded, 'Visitor Classification', visitor.visitorType.label),
          _buildDetailRow(Icons.assignment_rounded, 'Purpose of Visit', visitor.purpose),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.tealAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
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

  Widget _buildAuditTrailCard(Visitor visitor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visit Lifecycle Audit',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),

          _buildTimelineStep(
            title: 'Registered',
            timestamp: DateFormatter.formatDateTime(visitor.createdAt),
            isDone: true,
            icon: Icons.app_registration_rounded,
            color: AppColors.statusRegistered,
          ),
          _buildTimelineStep(
            title: 'Checked In',
            timestamp: visitor.checkInTime != null
                ? DateFormatter.formatDateTime(visitor.checkInTime)
                : 'Pending arrival',
            isDone: visitor.checkInTime != null,
            icon: Icons.login_rounded,
            color: AppColors.statusCheckedIn,
          ),
          _buildTimelineStep(
            title: 'Checked Out',
            timestamp: visitor.checkOutTime != null
                ? DateFormatter.formatDateTime(visitor.checkOutTime)
                : (visitor.status == VisitorStatus.checkedIn ? 'Currently on site' : 'Pending check-in'),
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
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isDone ? color : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: Colors.white),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isDone ? color.withValues(alpha: 0.4) : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildActionButtons(Visitor visitor) {
    if (visitor.canCheckIn) {
      return AppButton(
        label: 'Check In Visitor',
        icon: Icons.login_rounded,
        variant: ButtonVariant.teal,
        isLoading: _isProcessingAction,
        onPressed: () => _handleCheckIn(visitor),
        width: double.infinity,
      );
    } else if (visitor.canCheckOut) {
      return AppButton(
        label: 'Check Out Visitor',
        icon: Icons.logout_rounded,
        variant: ButtonVariant.primary,
        isLoading: _isProcessingAction,
        onPressed: () => _handleCheckOut(visitor),
        width: double.infinity,
      );
    } else {
      // Completed visit rule: Cannot be checked in again
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.statusCheckedOut, size: 18),
            SizedBox(width: 8),
            Text(
              'Visit completed. Record is archived.',
              style: TextStyle(
                color: AppColors.statusCheckedOut,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handleCheckIn(Visitor visitor) async {
    setState(() => _isProcessingAction = true);
    try {
      await ref.read(visitorListNotifierProvider.notifier).checkIn(visitor);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusCheckedIn,
            content: Text('${visitor.name} has been successfully checked in.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusDestructive,
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingAction = false);
    }
  }

  Future<void> _handleCheckOut(Visitor visitor) async {
    setState(() => _isProcessingAction = true);
    try {
      await ref.read(visitorListNotifierProvider.notifier).checkOut(visitor);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('${visitor.name} has been checked out.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusDestructive,
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingAction = false);
    }
  }

  Future<void> _confirmDelete(Visitor visitor) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Visitor', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to permanently delete visitor record for "${visitor.name}"?'),
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

    if (confirmed == true && mounted) {
      try {
        await ref.read(visitorListNotifierProvider.notifier).deleteVisitor(visitor.id);
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusDestructive,
            content: Text('Visitor "${visitor.name}" deleted.'),
          ),
        );
        navigator.pop(); // Return back to list
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusDestructive,
            content: Text('Failed to delete visitor: $e'),
          ),
        );
      }
    }
  }
}
