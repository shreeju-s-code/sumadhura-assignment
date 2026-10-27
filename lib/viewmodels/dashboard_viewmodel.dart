import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/visitor/data/models/visitor_model.dart';
import '../features/visitor/presentation/controllers/visitor_providers.dart';

/// State representation for the Dashboard View.
class DashboardState {
  final DashboardMetrics metrics;
  final List<Visitor> recentVisitors;
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({
    required this.metrics,
    required this.recentVisitors,
    this.isLoading = false,
    this.errorMessage,
  });

  factory DashboardState.initial() => DashboardState(
        metrics: DashboardMetrics.empty(),
        recentVisitors: const [],
        isLoading: true,
      );

  DashboardState copyWith({
    DashboardMetrics? metrics,
    List<Visitor>? recentVisitors,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      metrics: metrics ?? this.metrics,
      recentVisitors: recentVisitors ?? this.recentVisitors,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// ViewModel for Dashboard logic, data aggregation, and actions.
class DashboardViewModel extends StateNotifier<DashboardState> {
  final Ref _ref;

  DashboardViewModel(this._ref) : super(DashboardState.initial()) {
    _init();
  }

  void _init() {
    _ref.listen<AsyncValue<List<Visitor>>>(
      visitorListNotifierProvider,
      (previous, next) {
        next.when(
          data: (visitors) {
            state = state.copyWith(
              metrics: DashboardMetrics.fromVisitors(visitors),
              recentVisitors: visitors.take(5).toList(),
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

  Future<void> refresh() async {
    await _ref.read(visitorListNotifierProvider.notifier).loadVisitors(isRefresh: true);
  }

  Future<void> checkIn(Visitor visitor) async {
    await _ref.read(visitorListNotifierProvider.notifier).checkIn(visitor);
  }

  Future<void> checkOut(Visitor visitor) async {
    await _ref.read(visitorListNotifierProvider.notifier).checkOut(visitor);
  }
}

/// Riverpod provider for DashboardViewModel
final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
  return DashboardViewModel(ref);
});
