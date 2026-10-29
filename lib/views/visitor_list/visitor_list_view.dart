import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/haptic_helper.dart';
import '../../core/utils/responsive.dart';
import '../../features/visitor/data/models/visitor_model.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_view.dart';
import '../../viewmodels/visitor_list_viewmodel.dart';
import '../visitor_details/visitor_details_view.dart';
import '../visitor_form/visitor_form_view.dart';
import '../../features/visitor/presentation/widgets/visitor_card.dart';

class VisitorListView extends ConsumerStatefulWidget {
  const VisitorListView({super.key});

  @override
  ConsumerState<VisitorListView> createState() => _VisitorListViewState();
}

class _VisitorListViewState extends ConsumerState<VisitorListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(visitorListViewModelProvider).searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visitorListViewModelProvider);
    final viewModel = ref.read(visitorListViewModelProvider.notifier);
    final isSmallScreen = Responsive.screenWidth(context) < 360;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              'Visitor Directory',
              style: TextStyle(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 3. CONTAINER: Search & Filter header container with Responsive padding
          Container(
            padding: Responsive.paddingLTRB(
              context,
              isSmallScreen ? 12 : 16,
              14,
              isSmallScreen ? 12 : 16,
              10,
            ),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: Column(
              children: [
                // Search Input Field (by name or 10-digit mobile)
                TextField(
                  controller: _searchController,
                  onChanged: (val) => viewModel.setSearchQuery(val),
                  // 1. TEXTSIZE with MediaQuery
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 14),
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by visitor name or 10-digit mobile...',
                    hintStyle: TextStyle(
                      fontSize: Responsive.sp(context, 13.5),
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: Responsive.sp(context, 20),
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, size: Responsive.sp(context, 20)),
                            onPressed: () {
                              _searchController.clear();
                              viewModel.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
                    // 4. PADDING with MediaQuery
                    contentPadding: Responsive.paddingSymmetric(context, horizontal: 14, vertical: 12),
                  ),
                ),
                // 2. SIZEDBOX with MediaQuery
                Responsive.vSpace(context, 10),

                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusFilterChip(
                        label: 'All Status',
                        selected: state.statusFilter == null,
                        onSelected: () => viewModel.setStatusFilter(null),
                      ),
                      Responsive.hSpace(context, 6),
                      _buildStatusFilterChip(
                        label: 'Registered',
                        selected: state.statusFilter == VisitorStatus.registered,
                        onSelected: () => viewModel.setStatusFilter(
                          state.statusFilter == VisitorStatus.registered ? null : VisitorStatus.registered,
                        ),
                      ),
                      Responsive.hSpace(context, 6),
                      _buildStatusFilterChip(
                        label: 'Checked In',
                        selected: state.statusFilter == VisitorStatus.checkedIn,
                        onSelected: () => viewModel.setStatusFilter(
                          state.statusFilter == VisitorStatus.checkedIn ? null : VisitorStatus.checkedIn,
                        ),
                      ),
                      Responsive.hSpace(context, 6),
                      _buildStatusFilterChip(
                        label: 'Checked Out',
                        selected: state.statusFilter == VisitorStatus.checkedOut,
                        onSelected: () => viewModel.setStatusFilter(
                          state.statusFilter == VisitorStatus.checkedOut ? null : VisitorStatus.checkedOut,
                        ),
                      ),
                    ],
                  ),
                ),
                Responsive.vSpace(context, 8),

                // Project Filter & Total Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PopupMenuButton<ProjectName?>(
                      position: PopupMenuPosition.under,
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isDark ? const Color(0xFF334155) : AppColors.border, width: 1),
                      ),
                      onSelected: (val) {
                        viewModel.setProjectFilter(val);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<ProjectName?>(
                          value: null,
                          child: Text(
                            'All Projects',
                            style: TextStyle(
                              fontSize: Responsive.sp(context, 12.5),
                              fontWeight: state.projectFilter == null ? FontWeight.w700 : FontWeight.w500,
                              color: state.projectFilter == null ? AppColors.tealAccent : (isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary),
                            ),
                          ),
                        ),
                        ...ProjectName.values.map(
                          (p) => PopupMenuItem<ProjectName?>(
                            value: p,
                            child: Text(
                              p.label,
                              style: TextStyle(
                                fontSize: Responsive.sp(context, 12.5),
                                fontWeight: state.projectFilter == p ? FontWeight.w700 : FontWeight.w500,
                                color: state.projectFilter == p ? AppColors.tealAccent : (isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary),
                              ),
                            ),
                          ),
                        ),
                      ],
                      child: Container(
                        padding: Responsive.paddingSymmetric(context, horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : AppColors.border, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Project: ',
                              style: TextStyle(
                                fontSize: Responsive.sp(context, 12),
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              state.projectFilter?.label ?? 'All Projects',
                              style: TextStyle(
                                fontSize: Responsive.sp(context, 12),
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.tealAccent : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down, size: Responsive.sp(context, 18), color: isDark ? AppColors.tealAccent : AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'Total : ${state.filteredVisitors.length}',
                      style: TextStyle(
                        fontSize: Responsive.sp(context, 12.5),
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.tealAccent : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: isDark ? const Color(0xFF334155) : AppColors.border),

          // Scrollable visitor list with heavy vibration on pull-to-refresh
          Expanded(
            child: RefreshIndicator(
              color: AppColors.tealAccent,
              onRefresh: () async {
                // 4. Heavy vibrate when user swipes down to refresh
                await HapticHelper.heavyVibrate();
                await viewModel.refresh();
              },
              child: _buildListContent(state, viewModel),
            ),
          ),
        ],
      ),
      floatingActionButton: MediaQuery.viewInsetsOf(context).bottom > 0
          ? null
          : Container(
              height: Responsive.h(context, 48),
              margin: const EdgeInsets.only(bottom: 115),
              child: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          highlightElevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.tealAccent, width: 1.2),
          ),
          icon: Icon(Icons.person_add_rounded, size: Responsive.sp(context, 19)),
          label: Text(
            'New Visitor',
            style: TextStyle(
              fontSize: Responsive.sp(context, 13.5),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          onPressed: () {
            // 2. Slow transferring pop-up
            openRegisterVisitorModal(context);
          },
        ),
      ),
    );
  }

  Widget _buildListContent(VisitorListState state, VisitorListViewModel viewModel) {
    if (state.isLoading && state.allVisitors.isEmpty) {
      return const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: LoadingView(message: 'Loading visitor directory...'),
        ),
      );
    }

    if (state.errorMessage != null && state.allVisitors.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: ErrorView(
            title: 'Failed to load directory',
            message: state.errorMessage!,
            onRetry: () => viewModel.refresh(),
          ),
        ),
      );
    }

    if (state.filteredVisitors.isEmpty) {
      if (state.hasActiveFilter) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: EmptyStateWidget(
              icon: Icons.search_off_rounded,
              title: 'No Matching Visitors',
              message: 'No visitors found matching your search and filter criteria.',
              actionLabel: 'Clear All Filters',
              onAction: () {
                _searchController.clear();
                viewModel.resetFilters();
              },
            ),
          ),
        );
      }
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: EmptyStateWidget(
            icon: Icons.person_add_disabled_rounded,
            title: 'Visitor Directory Empty',
            message: 'There are currently no registered visitors in the system.',
            actionLabel: 'Register Visitor',
            onAction: () {
              openRegisterVisitorModal(context);
            },
          ),
        ),
      );
    }

    final isSmallScreen = Responsive.screenWidth(context) < 360;

    return ListView.builder(
      padding: Responsive.paddingSymmetric(
        context,
        horizontal: isSmallScreen ? 12 : 16,
        vertical: 14,
      ),
      itemCount: state.filteredVisitors.length,
      itemBuilder: (context, index) {
        final visitor = state.filteredVisitors[index];
        return VisitorCard(
          visitor: visitor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VisitorDetailsView(visitorId: visitor.id),
              ),
            );
          },
          onCheckIn: visitor.canCheckIn ? () => _handleCheckIn(visitor, viewModel) : null,
          onCheckOut: visitor.canCheckOut ? () => _handleCheckOut(visitor, viewModel) : null,
          onDelete: () => _confirmDelete(visitor, viewModel),
        );
      },
    );
  }

  Widget _buildStatusFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) async {
        await HapticHelper.heavyVibrate();
        onSelected();
      },
      selectedColor: isDark ? AppColors.tealAccent : AppColors.primary,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      side: BorderSide(
        color: selected
            ? (isDark ? AppColors.tealAccent : AppColors.primary)
            : (isDark ? const Color(0xFF334155) : AppColors.border),
        width: 1,
      ),
      labelStyle: TextStyle(
        fontSize: Responsive.sp(context, 12),
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? Colors.white : (isDark ? const Color(0xFFCBD5E1) : AppColors.textPrimary),
      ),
      padding: Responsive.paddingSymmetric(context, horizontal: 6, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Future<void> _handleCheckIn(Visitor visitor, VisitorListViewModel viewModel) async {
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

    if (confirmed != true || !mounted) return;

    try {
      await viewModel.checkIn(visitor);
      await HapticHelper.heavyVibrate();
      if (mounted) {
        AppSnackBar.showSuccess(context, '${visitor.name} has been checked in.');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.toString());
      }
    }
  }

  Future<void> _handleCheckOut(Visitor visitor, VisitorListViewModel viewModel) async {
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

    if (confirmed != true || !mounted) return;

    try {
      await viewModel.checkOut(visitor);
      await HapticHelper.heavyVibrate();
      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          '${visitor.name} has checked out.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.toString());
      }
    }
  }

  Future<void> _confirmDelete(Visitor visitor, VisitorListViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.w700)),
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
        await viewModel.deleteVisitor(visitor.id);
        if (mounted) {
          AppSnackBar.showSuccess(
            context,
            'Visitor "${visitor.name}" deleted.',
          );
        }
      } catch (e) {
        if (mounted) {
          AppSnackBar.showError(context, 'Failed to delete visitor: $e');
        }
      }
    }
  }
}
