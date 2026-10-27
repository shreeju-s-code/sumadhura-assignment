import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
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
            color: Colors.white,
            child: Column(
              children: [
                // Search Input Field (by name or 10-digit mobile)
                TextField(
                  controller: _searchController,
                  onChanged: (val) => viewModel.setSearchQuery(val),
                  // 1. TEXTSIZE with MediaQuery
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 14),
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by visitor name or 10-digit mobile...',
                    hintStyle: TextStyle(
                      fontSize: Responsive.sp(context, 13.5),
                      color: AppColors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: Responsive.sp(context, 20),
                      color: AppColors.textSecondary,
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
                    fillColor: AppColors.background,
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

                // Project Filter Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Project: ',
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 12.5),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        DropdownButton<ProjectName?>(
                          value: state.projectFilter,
                          isDense: true,
                          underline: const SizedBox.shrink(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: Responsive.sp(context, 12.5),
                            fontWeight: FontWeight.w600,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text(
                                'All Projects',
                                style: TextStyle(fontSize: Responsive.sp(context, 12.5)),
                              ),
                            ),
                            ...ProjectName.values.map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p.label,
                                  style: TextStyle(fontSize: Responsive.sp(context, 12.5)),
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) => viewModel.setProjectFilter(val),
                        ),
                      ],
                    ),
                    if (state.hasActiveFilter)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          viewModel.resetFilters();
                        },
                        child: Text(
                          'Reset Filters',
                          style: TextStyle(
                            fontSize: Responsive.sp(context, 12),
                            fontWeight: FontWeight.w600,
                            color: AppColors.statusDestructive,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

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
      floatingActionButton: Container(
        height: Responsive.h(context, 48),
        margin: const EdgeInsets.only(bottom: 6),
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
      return const LoadingView(message: 'Loading visitor directory...');
    }

    if (state.errorMessage != null && state.allVisitors.isEmpty) {
      return ErrorView(
        title: 'Failed to load directory',
        message: state.errorMessage!,
        onRetry: () => viewModel.refresh(),
      );
    }

    if (state.filteredVisitors.isEmpty) {
      if (state.hasActiveFilter) {
        return EmptyStateWidget(
          icon: Icons.search_off_rounded,
          title: 'No Matching Visitors',
          message: 'No visitors found matching your search and filter criteria.',
          actionLabel: 'Clear All Filters',
          onAction: () {
            _searchController.clear();
            viewModel.resetFilters();
          },
        );
      }
      return EmptyStateWidget(
        icon: Icons.person_add_disabled_rounded,
        title: 'Visitor Directory Empty',
        message: 'There are currently no registered visitors in the system.',
        actionLabel: 'Register Visitor',
        onAction: () {
          openRegisterVisitorModal(context);
        },
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
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
        width: 1,
      ),
      labelStyle: TextStyle(
        fontSize: Responsive.sp(context, 12),
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? Colors.white : AppColors.textPrimary,
      ),
      padding: Responsive.paddingSymmetric(context, horizontal: 6, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Future<void> _handleCheckIn(Visitor visitor, VisitorListViewModel viewModel) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await viewModel.checkIn(visitor);
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusCheckedIn,
          content: Text('${visitor.name} has been checked in.'),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusDestructive,
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> _handleCheckOut(Visitor visitor, VisitorListViewModel viewModel) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await viewModel.checkOut(visitor);
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('${visitor.name} has checked out.'),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusDestructive,
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> _confirmDelete(Visitor visitor, VisitorListViewModel viewModel) async {
    final messenger = ScaffoldMessenger.of(context);
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
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusDestructive,
            content: Text('Visitor "${visitor.name}" deleted.'),
          ),
        );
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
