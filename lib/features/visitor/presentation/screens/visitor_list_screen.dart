import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../data/models/visitor_model.dart';
import '../controllers/visitor_providers.dart';
import '../widgets/visitor_card.dart';
import 'visitor_details_screen.dart';
import 'visitor_form_screen.dart';

class VisitorListScreen extends ConsumerStatefulWidget {
  const VisitorListScreen({super.key});

  @override
  ConsumerState<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends ConsumerState<VisitorListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(searchQueryProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredVisitorsProvider);
    final currentStatusFilter = ref.watch(statusFilterProvider);
    final currentProjectFilter = ref.watch(projectFilterProvider);
    final hasActiveFilter = _searchController.text.isNotEmpty ||
        currentStatusFilter != null ||
        currentProjectFilter != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Visitor Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.read(visitorListNotifierProvider.notifier).loadVisitors(isRefresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header container
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            color: Colors.white,
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(searchQueryProvider.notifier).state = val;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by visitor name or 10-digit mobile...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),

                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusFilterChip(label: 'All Status', status: null, selected: currentStatusFilter == null),
                      const SizedBox(width: 6),
                      _buildStatusFilterChip(label: 'Registered', status: VisitorStatus.registered, selected: currentStatusFilter == VisitorStatus.registered),
                      const SizedBox(width: 6),
                      _buildStatusFilterChip(label: 'Checked In', status: VisitorStatus.checkedIn, selected: currentStatusFilter == VisitorStatus.checkedIn),
                      const SizedBox(width: 6),
                      _buildStatusFilterChip(label: 'Checked Out', status: VisitorStatus.checkedOut, selected: currentStatusFilter == VisitorStatus.checkedOut),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Project Filter Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Project: ',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        DropdownButton<ProjectName?>(
                          value: currentProjectFilter,
                          isDense: true,
                          underline: const SizedBox.shrink(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Projects')),
                            ...ProjectName.values.map(
                              (p) => DropdownMenuItem(value: p, child: Text(p.label)),
                            ),
                          ],
                          onChanged: (val) {
                            ref.read(projectFilterProvider.notifier).state = val;
                          },
                        ),
                      ],
                    ),
                    if (hasActiveFilter)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                          ref.read(statusFilterProvider.notifier).state = null;
                          ref.read(projectFilterProvider.notifier).state = null;
                        },
                        child: const Text(
                          'Reset Filters',
                          style: TextStyle(
                            fontSize: 12,
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

          // Visitor List Items
          Expanded(
            child: RefreshIndicator(
              color: AppColors.tealAccent,
              onRefresh: () => ref.read(visitorListNotifierProvider.notifier).loadVisitors(isRefresh: true),
              child: filteredAsync.when(
                loading: () => const LoadingIndicator(message: 'Loading visitor directory...'),
                error: (error, _) => ErrorView(
                  title: 'Failed to load directory',
                  message: error.toString(),
                  onRetry: () => ref.read(visitorListNotifierProvider.notifier).loadVisitors(),
                ),
                data: (visitors) {
                  if (visitors.isEmpty) {
                    if (hasActiveFilter) {
                      return EmptyView(
                        icon: Icons.search_off_rounded,
                        title: 'No Matching Visitors',
                        message: 'No visitors found matching your search and filter criteria.',
                        actionLabel: 'Clear All Filters',
                        onAction: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                          ref.read(statusFilterProvider.notifier).state = null;
                          ref.read(projectFilterProvider.notifier).state = null;
                        },
                      );
                    }
                    return EmptyView(
                      icon: Icons.person_add_disabled_rounded,
                      title: 'Visitor Directory Empty',
                      message: 'There are currently no registered visitors in the system.',
                      actionLabel: 'Register Visitor',
                      onAction: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VisitorFormScreen()),
                        );
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    itemCount: visitors.length,
                    itemBuilder: (context, index) {
                      final visitor = visitors[index];
                      return VisitorCard(
                        visitor: visitor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VisitorDetailsScreen(visitorId: visitor.id),
                            ),
                          );
                        },
                        onCheckIn: visitor.canCheckIn
                            ? () => _handleCheckIn(visitor)
                            : null,
                        onCheckOut: visitor.canCheckOut
                            ? () => _handleCheckOut(visitor)
                            : null,
                        onDelete: () => _confirmDelete(visitor),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Visitor', style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VisitorFormScreen()),
          );
        },
      ),
    );
  }

  Widget _buildStatusFilterChip({
    required String label,
    required VisitorStatus? status,
    required bool selected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (bool isSelected) {
        ref.read(statusFilterProvider.notifier).state = isSelected ? status : null;
      },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
        width: 1,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? Colors.white : AppColors.textPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Future<void> _handleCheckIn(Visitor visitor) async {
    try {
      await ref.read(visitorListNotifierProvider.notifier).checkIn(visitor);
      if (mounted) {
        AppSnackBar.showSuccess(context, '${visitor.name} has been checked in.');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.toString());
      }
    }
  }

  Future<void> _handleCheckOut(Visitor visitor) async {
    try {
      await ref.read(visitorListNotifierProvider.notifier).checkOut(visitor);
      if (mounted) {
        AppSnackBar.showInfo(
          context,
          '${visitor.name} has checked out.',
          icon: Icons.logout_rounded,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.toString());
      }
    }
  }

  Future<void> _confirmDelete(Visitor visitor) async {
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
        await ref.read(visitorListNotifierProvider.notifier).deleteVisitor(visitor.id);
        if (mounted) {
          AppSnackBar.showInfo(
            context,
            'Visitor "${visitor.name}" deleted.',
            icon: Icons.delete_outline_rounded,
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
