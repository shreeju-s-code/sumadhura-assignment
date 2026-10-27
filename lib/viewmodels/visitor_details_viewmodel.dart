import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/visitor/data/models/visitor_model.dart';
import '../features/visitor/presentation/controllers/visitor_providers.dart';

class VisitorDetailsState {
  final Visitor? visitor;
  final bool isLoading;
  final bool isActionRunning;
  final String? errorMessage;

  const VisitorDetailsState({
    this.visitor,
    this.isLoading = false,
    this.isActionRunning = false,
    this.errorMessage,
  });

  VisitorDetailsState copyWith({
    Visitor? visitor,
    bool? isLoading,
    bool? isActionRunning,
    String? errorMessage,
  }) {
    return VisitorDetailsState(
      visitor: visitor ?? this.visitor,
      isLoading: isLoading ?? this.isLoading,
      isActionRunning: isActionRunning ?? this.isActionRunning,
      errorMessage: errorMessage,
    );
  }
}

class VisitorDetailsViewModel extends StateNotifier<VisitorDetailsState> {
  final Ref _ref;
  final String visitorId;

  VisitorDetailsViewModel(this._ref, this.visitorId)
      : super(const VisitorDetailsState(isLoading: true)) {
    _init();
  }

  void _init() {
    _ref.listen<AsyncValue<List<Visitor>>>(
      visitorListNotifierProvider,
      (previous, next) {
        next.when(
          data: (visitors) {
            final match = visitors.where((v) => v.id == visitorId).firstOrNull;
            state = state.copyWith(
              visitor: match,
              isLoading: false,
              errorMessage: match == null ? 'Visitor not found' : null,
            );
          },
          loading: () {
            state = state.copyWith(isLoading: true);
          },
          error: (err, _) {
            state = state.copyWith(isLoading: false, errorMessage: err.toString());
          },
        );
      },
      fireImmediately: true,
    );
  }

  Future<void> checkIn() async {
    final current = state.visitor;
    if (current == null) return;
    state = state.copyWith(isActionRunning: true, errorMessage: null);
    try {
      await _ref.read(visitorListNotifierProvider.notifier).checkIn(current);
      state = state.copyWith(isActionRunning: false);
    } catch (e) {
      state = state.copyWith(isActionRunning: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> checkOut() async {
    final current = state.visitor;
    if (current == null) return;
    state = state.copyWith(isActionRunning: true, errorMessage: null);
    try {
      await _ref.read(visitorListNotifierProvider.notifier).checkOut(current);
      state = state.copyWith(isActionRunning: false);
    } catch (e) {
      state = state.copyWith(isActionRunning: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> delete() async {
    state = state.copyWith(isActionRunning: true, errorMessage: null);
    try {
      await _ref.read(visitorListNotifierProvider.notifier).deleteVisitor(visitorId);
      state = state.copyWith(isActionRunning: false);
    } catch (e) {
      state = state.copyWith(isActionRunning: false, errorMessage: e.toString());
      rethrow;
    }
  }
}

final visitorDetailsViewModelProvider =
    StateNotifierProvider.family<VisitorDetailsViewModel, VisitorDetailsState, String>(
        (ref, visitorId) {
  return VisitorDetailsViewModel(ref, visitorId);
});
