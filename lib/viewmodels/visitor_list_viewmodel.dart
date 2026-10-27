import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/visitor/data/models/visitor_model.dart';
import '../features/visitor/presentation/controllers/visitor_providers.dart';

/// State representation for the Visitor List View.
class VisitorListState {
  final List<Visitor> allVisitors;
  final List<Visitor> filteredVisitors;
  final String searchQuery;
  final VisitorStatus? statusFilter;
  final ProjectName? projectFilter;
  final bool isLoading;
  final String? errorMessage;

  const VisitorListState({
    required this.allVisitors,
    required this.filteredVisitors,
    this.searchQuery = '',
    this.statusFilter,
    this.projectFilter,
    this.isLoading = false,
    this.errorMessage,
  });

  factory VisitorListState.initial() => const VisitorListState(
        allVisitors: [],
        filteredVisitors: [],
        isLoading: true,
      );

  bool get hasActiveFilter =>
      searchQuery.isNotEmpty || statusFilter != null || projectFilter != null;

  VisitorListState copyWith({
    List<Visitor>? allVisitors,
    List<Visitor>? filteredVisitors,
    String? searchQuery,
    VisitorStatus? statusFilter,
    bool clearStatusFilter = false,
    ProjectName? projectFilter,
    bool clearProjectFilter = false,
    bool? isLoading,
    String? errorMessage,
  }) {
    return VisitorListState(
      allVisitors: allVisitors ?? this.allVisitors,
      filteredVisitors: filteredVisitors ?? this.filteredVisitors,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      projectFilter: clearProjectFilter ? null : (projectFilter ?? this.projectFilter),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// ViewModel for Visitor List screen.
class VisitorListViewModel extends StateNotifier<VisitorListState> {
  final Ref _ref;

  VisitorListViewModel(this._ref) : super(VisitorListState.initial()) {
    _init();
  }

  void _init() {
    _ref.listen<AsyncValue<List<Visitor>>>(
      visitorListNotifierProvider,
      (previous, next) {
        next.when(
          data: (visitors) {
            state = state.copyWith(
              allVisitors: visitors,
              filteredVisitors: _applyFilters(
                visitors,
                state.searchQuery,
                state.statusFilter,
                state.projectFilter,
              ),
              isLoading: false,
              errorMessage: null,
            );
          },
          loading: () {
            state = state.copyWith(isLoading: true, errorMessage: null);
          },
          error: (error, _) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: error.toString(),
            );
          },
        );
      },
      fireImmediately: true,
    );
  }

  void setSearchQuery(String query) {
    final filtered = _applyFilters(
      state.allVisitors,
      query,
      state.statusFilter,
      state.projectFilter,
    );
    state = state.copyWith(searchQuery: query, filteredVisitors: filtered);
  }

  void setStatusFilter(VisitorStatus? status) {
    final filtered = _applyFilters(
      state.allVisitors,
      state.searchQuery,
      status,
      state.projectFilter,
    );
    state = state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
      filteredVisitors: filtered,
    );
  }

  void setProjectFilter(ProjectName? project) {
    final filtered = _applyFilters(
      state.allVisitors,
      state.searchQuery,
      state.statusFilter,
      project,
    );
    state = state.copyWith(
      projectFilter: project,
      clearProjectFilter: project == null,
      filteredVisitors: filtered,
    );
  }

  void resetFilters() {
    state = state.copyWith(
      searchQuery: '',
      clearStatusFilter: true,
      clearProjectFilter: true,
      filteredVisitors: state.allVisitors,
    );
  }

  Future<void> refresh() async {
    await _ref.read(visitorListNotifierProvider.notifier).loadVisitors(isRefresh: true);
  }

  Future<void> checkIn(Visitor visitor) async {
    await _ref.read(visitorListNotifierProvider.notifier).checkIn(visitor);
  }

  Future<void> checkOut(Visitor visitor) async {
    await _ref.read(visitorListNotifierProvider.notifier).checkOut(visitor);
  }

  Future<void> deleteVisitor(String id) async {
    await _ref.read(visitorListNotifierProvider.notifier).deleteVisitor(id);
  }

  List<Visitor> _applyFilters(
    List<Visitor> list,
    String query,
    VisitorStatus? status,
    ProjectName? project,
  ) {
    final cleanQuery = query.trim().toLowerCase();
    return list.where((v) {
      if (cleanQuery.isNotEmpty) {
        final matchesName = v.name.toLowerCase().contains(cleanQuery);
        final matchesMobile = v.mobile.contains(cleanQuery);
        if (!matchesName && !matchesMobile) return false;
      }
      if (status != null && v.status != status) {
        return false;
      }
      if (project != null && v.project != project) {
        return false;
      }
      return true;
    }).toList();
  }
}

/// Riverpod provider for VisitorListViewModel
final visitorListViewModelProvider =
    StateNotifierProvider<VisitorListViewModel, VisitorListState>((ref) {
  return VisitorListViewModel(ref);
});
