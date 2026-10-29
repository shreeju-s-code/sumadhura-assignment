import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/haptic_helper.dart';
import '../../core/utils/responsive.dart';
import '../../features/visitor/data/models/visitor_model.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/dashboard_stat_card.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_view.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../qr_scanner/qr_scanner_view.dart';
import '../visitor_details/visitor_details_view.dart';
import '../visitor_form/visitor_form_view.dart';
import '../visitor_list/visitor_list_view.dart';
import '../../features/visitor/presentation/widgets/visitor_card.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);
    final viewModel = ref.read(dashboardViewModelProvider.notifier);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallScreen = screenWidth < 360;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: AppBar(
        toolbarHeight: Responsive.h(context, 76),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.tealAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'Sumadhura Properties',
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 11),
                    fontWeight: FontWeight.w700,
                    color: AppColors.tealAccent,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              'Visitor Management Desk',
              style: TextStyle(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Container(
                key: ValueKey<bool>(isDark),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.tealAccent.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? const Color(0xFFFBBF24) : Colors.white,
                  size: 20,
                ),
              ),
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () async {
              await HapticHelper.heavyVibrate();
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.tealAccent,
        onRefresh: () async {
          await HapticHelper.heavyVibrate();
          await viewModel.refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            isSmallScreen ? 12.0 : 16.0,
            16.0,
            isSmallScreen ? 12.0 : 16.0,
            118.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Summary greeting with Responsive textsize
              Text(
                'Today\'s Overview',
                style: TextStyle(
                  fontSize: Responsive.sp(context, 17),
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFFF1F5F9)
                      : AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              Responsive.vSpace(context, 12),

              // Three Mandatory Visitor Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: DashboardStatCard(
                      title: 'Registered',
                      count: state.metrics.registeredToday,
                      subtitle: 'Total Today',
                      icon: Icons.assignment_ind_outlined,
                      accentColor: AppColors.statusRegistered,
                      bgColor: AppColors.bgRegistered,
                    ),
                  ),
                  Responsive.hSpace(context, 10),
                  Expanded(
                    child: DashboardStatCard(
                      title: 'Checked In',
                      count: state.metrics.currentlyCheckedIn,
                      subtitle: 'On-Premises',
                      icon: Icons.check_circle_outline_rounded,
                      accentColor: AppColors.statusCheckedIn,
                      bgColor: AppColors.bgCheckedIn,
                    ),
                  ),
                  Responsive.hSpace(context, 10),
                  Expanded(
                    child: DashboardStatCard(
                      title: 'Checked Out',
                      count: state.metrics.checkedOutToday,
                      subtitle: 'Departed Today',
                      icon: Icons.logout_rounded,
                      accentColor: AppColors.statusCheckedOut,
                      bgColor: AppColors.bgCheckedOut,
                    ),
                  ),
                ],
              ),

              Responsive.vSpace(context, 20),

              // Action shortcuts row with Responsive Container height
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Register Visitor',
                      icon: Icons.person_add_alt_1_rounded,
                      variant: CustomButtonVariant.primary,
                      height: Responsive.h(context, 48),
                      onPressed: () {
                        openRegisterVisitorModal(context);
                      },
                    ),
                  ),
                  Responsive.hSpace(context, 10),
                  Expanded(
                    child: CustomButton(
                      label: 'Scan QR Code',
                      icon: Icons.qr_code_scanner_rounded,
                      variant: CustomButtonVariant.teal,
                      height: Responsive.h(context, 48),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QrScannerView(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              Responsive.vSpace(context, 26),

              // Recent Visitors section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Visitors',
                    style: TextStyle(
                      fontSize: Responsive.sp(context, 16.5),
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFFF1F5F9)
                          : AppColors.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VisitorListView(),
                        ),
                      );
                    },
                    icon: Text(
                      'View All',
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 13.5),
                        fontWeight: FontWeight.w600,
                        color: AppColors.tealAccent,
                      ),
                    ),
                    label: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: AppColors.tealAccent,
                    ),
                  ),
                ],
              ),
              Responsive.vSpace(context, 8),

              // Dynamic content: Loading, Error, Empty, or List
              if (state.isLoading && state.recentVisitors.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: LoadingView(message: 'Loading visitor statistics...'),
                )
              else if (state.errorMessage != null &&
                  state.recentVisitors.isEmpty)
                ErrorView(
                  title: 'Unable to load dashboard',
                  message: state.errorMessage!,
                  onRetry: () => viewModel.refresh(),
                )
              else if (state.recentVisitors.isEmpty)
                EmptyStateWidget(
                  icon: Icons.group_off_rounded,
                  title: 'No Visitors Registered',
                  message:
                      'Register a visitor or scan a QR pass to start recording visits.',
                  actionLabel: 'Register First Visitor',
                  onAction: () {
                    openRegisterVisitorModal(context);
                  },
                )
              else
                Column(
                  children: state.recentVisitors.map((v) {
                    return VisitorCard(
                      visitor: v,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VisitorDetailsView(visitorId: v.id),
                          ),
                        );
                      },
                      onCheckIn: v.canCheckIn
                          ? () => _handleCheckIn(context, viewModel, v)
                          : null,
                      onCheckOut: v.canCheckOut
                          ? () => _handleCheckOut(context, viewModel, v)
                          : null,
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCheckIn(
    BuildContext context,
    DashboardViewModel vm,
    Visitor visitor,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Confirm Check In',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
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
      await vm.checkIn(visitor);
      await HapticHelper.heavyVibrate();
      if (context.mounted) {
        AppSnackBar.showSuccess(
          context,
          '${visitor.name} successfully checked in.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, e.toString());
      }
    }
  }

  Future<void> _handleCheckOut(
    BuildContext context,
    DashboardViewModel vm,
    Visitor visitor,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Confirm Check Out',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
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
      await vm.checkOut(visitor);
      await HapticHelper.heavyVibrate();
      if (context.mounted) {
        AppSnackBar.showSuccess(
          context,
          '${visitor.name} successfully checked out.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, e.toString());
      }
    }
  }
}
