import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../qr_scanner/presentation/screens/qr_scanner_screen.dart';
import '../../../visitor/data/models/visitor_model.dart';
import '../../../visitor/presentation/controllers/visitor_providers.dart';
import '../../../visitor/presentation/screens/visitor_details_screen.dart';
import '../../../visitor/presentation/screens/visitor_form_screen.dart';
import '../../../visitor/presentation/screens/visitor_list_screen.dart';
import '../../../visitor/presentation/widgets/visitor_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardMetricsProvider);
    final visitorsAsync = ref.watch(visitorListNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sumadhura Properties',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Visitor Management Desk',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
            tooltip: 'Scan Visitor QR',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrScannerScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Data',
            onPressed: () => ref.read(visitorListNotifierProvider.notifier).loadVisitors(isRefresh: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.tealAccent,
        onRefresh: () => ref.read(visitorListNotifierProvider.notifier).loadVisitors(isRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Summary greeting
              const Text(
                'Today\'s Overview',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),

              // Metric Cards Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Registered',
                      count: metrics.registeredToday,
                      subtitle: 'Today',
                      icon: Icons.assignment_ind_outlined,
                      accentColor: AppColors.statusRegistered,
                      bgColor: AppColors.bgRegistered,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Checked In',
                      count: metrics.currentlyCheckedIn,
                      subtitle: 'On-Premises',
                      icon: Icons.check_circle_outline_rounded,
                      accentColor: AppColors.statusCheckedIn,
                      bgColor: AppColors.bgCheckedIn,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Checked Out',
                      count: metrics.checkedOutToday,
                      subtitle: 'Departed',
                      icon: Icons.logout_rounded,
                      accentColor: AppColors.statusCheckedOut,
                      bgColor: AppColors.bgCheckedOut,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Action shortcuts banner
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      context: context,
                      title: 'Register Visitor',
                      subtitle: 'New gate entry',
                      icon: Icons.person_add_alt_1_rounded,
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VisitorFormScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionTile(
                      context: context,
                      title: 'Scan QR Code',
                      subtitle: 'Camera check-in',
                      icon: Icons.qr_code_scanner_rounded,
                      color: AppColors.tealAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QrScannerScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Visitors section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Visitors',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VisitorListScreen(),
                        ),
                      );
                    },
                    icon: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13.5,
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
              const SizedBox(height: 8),

              // Recent Visitors list
              visitorsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: LoadingIndicator(message: 'Loading visitors...'),
                ),
                error: (error, _) => ErrorView(
                  title: 'Unable to load visitors',
                  message: error.toString(),
                  onRetry: () => ref.read(visitorListNotifierProvider.notifier).loadVisitors(),
                ),
                data: (visitors) {
                  if (visitors.isEmpty) {
                    return EmptyView(
                      icon: Icons.group_off_rounded,
                      title: 'No Visitors Registered',
                      message: 'Register a visitor or scan a QR pass to get started.',
                      actionLabel: 'Register First Visitor',
                      onAction: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VisitorFormScreen()),
                        );
                      },
                    );
                  }

                  final recentVisitors = visitors.take(5).toList();

                  return Column(
                    children: recentVisitors.map((v) {
                      return VisitorCard(
                        visitor: v,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VisitorDetailsScreen(visitorId: v.id),
                            ),
                          );
                        },
                        onCheckIn: v.canCheckIn
                            ? () => _handleCheckIn(context, ref, v)
                            : null,
                        onCheckOut: v.canCheckOut
                            ? () => _handleCheckOut(context, ref, v)
                            : null,
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: Colors.white,
        elevation: 4,
        indicatorColor: AppColors.tealLight,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VisitorListScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QrScannerScreen()),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded, color: AppColors.primary),
            label: 'Directory',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_rounded),
            selectedIcon: Icon(Icons.qr_code_scanner, color: AppColors.primary),
            label: 'Scan QR',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleCheckIn(BuildContext context, WidgetRef ref, Visitor visitor) async {
    try {
      await ref.read(visitorListNotifierProvider.notifier).checkIn(visitor);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusCheckedIn,
            content: Text('${visitor.name} successfully checked in.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusDestructive,
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  Future<void> _handleCheckOut(BuildContext context, WidgetRef ref, Visitor visitor) async {
    try {
      await ref.read(visitorListNotifierProvider.notifier).checkOut(visitor);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('${visitor.name} successfully checked out.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusDestructive,
            content: Text(e.toString()),
          ),
        );
      }
    }
  }
}
