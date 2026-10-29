import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/haptic_helper.dart';
import 'dashboard/dashboard_view.dart';
import 'qr_scanner/qr_scanner_view.dart';
import 'visitor_list/visitor_list_view.dart';

/// Main navigation shell hosting a curved floating capsule bottom navigation dock
/// styled in Sumadhura AppBar color (Deep Navy), with terms below each icon
/// (Dashboard, Visitors, Scanner) and responsive haptic interactions.
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
    final appBarColor = isDark ? const Color(0xFF0D1E35) : AppColors.primary;

    return Scaffold(
      backgroundColor: _currentIndex == 2
          ? Colors.black
          : (isDark ? const Color(0xFF0F172A) : AppColors.background),
      resizeToAvoidBottomInset: false,
      extendBody: true, // Extends camera view and scrollable content behind floating dock
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 62,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 14),
          decoration: BoxDecoration(
            // App bar color for bottom navigation bar
            color: appBarColor,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: AppColors.tealAccent.withValues(alpha: 0.28),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.primaryDark).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: AppColors.tealAccent.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildNavItem(
                index: 0,
                label: 'Dashboard',
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard_rounded,
              ),
              _buildNavItem(
                index: 1,
                label: 'Visitors',
                icon: Icons.people_outline_rounded,
                activeIcon: Icons.people_rounded,
              ),
              _buildNavItem(
                index: 2,
                label: 'Scanner',
                icon: Icons.qr_code_scanner_rounded,
                activeIcon: Icons.qr_code_scanner_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (_currentIndex != index) {
              await HapticHelper.heavyVibrate();
              setState(() => _currentIndex = index);
            }
          },
          borderRadius: BorderRadius.circular(36),
          splashColor: AppColors.tealAccent.withValues(alpha: 0.20),
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected
                    ? AppColors.tealAccent
                    : Colors.white.withValues(alpha: 0.60),
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.60),
                  letterSpacing: 0.15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
