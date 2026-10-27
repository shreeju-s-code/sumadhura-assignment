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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: Colors.white,
        elevation: 4,
        indicatorColor: AppColors.tealLight,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
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
            label: 'Visitors',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_rounded),
            selectedIcon: Icon(Icons.qr_code_scanner, color: AppColors.primary),
            label: 'Scan',
          ),
        ],
      ),
    );
  }
}
