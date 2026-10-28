import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'dashboard/dashboard_view.dart';
import 'qr_scanner/qr_scanner_view.dart';
import 'visitor_list/visitor_list_view.dart';

/// Main navigation shell hosting Bottom Navigation: Dashboard, Visitors, and Scan.
class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _views = const [
    DashboardView(),
    VisitorListView(),
    QrScannerView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 4,
        indicatorColor: isDark ? AppColors.tealAccent.withValues(alpha: 0.25) : AppColors.tealLight,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: isDark ? const Color(0xFF94A3B8) : null),
            selectedIcon: Icon(Icons.dashboard_rounded, color: isDark ? AppColors.tealAccent : AppColors.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded, color: isDark ? const Color(0xFF94A3B8) : null),
            selectedIcon: Icon(Icons.people_rounded, color: isDark ? AppColors.tealAccent : AppColors.primary),
            label: 'Visitors',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_rounded, color: isDark ? const Color(0xFF94A3B8) : null),
            selectedIcon: Icon(Icons.qr_code_scanner, color: isDark ? AppColors.tealAccent : AppColors.primary),
            label: 'Scan',
          ),
        ],
      ),
    );
  }
}
