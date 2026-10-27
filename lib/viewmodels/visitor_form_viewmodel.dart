import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/visitor/data/models/visitor_model.dart';
import '../features/visitor/presentation/controllers/visitor_providers.dart';

class VisitorFormState {
  final bool isSubmitting;
  final String? errorMessage;

  const VisitorFormState({
    this.isSubmitting = false,
    this.errorMessage,
  });

  VisitorFormState copyWith({
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return VisitorFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class VisitorFormViewModel extends StateNotifier<VisitorFormState> {
  final Ref _ref;

  VisitorFormViewModel(this._ref) : super(const VisitorFormState());

  Future<Visitor?> registerVisitor(Visitor visitor) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final created = await _ref
          .read(visitorListNotifierProvider.notifier)
          .registerVisitor(visitor);
      state = state.copyWith(isSubmitting: false);
      return created;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<Visitor?> updateVisitor(Visitor visitor) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final updated = await _ref
          .read(visitorListNotifierProvider.notifier)
          .updateVisitor(visitor);
      state = state.copyWith(isSubmitting: false);
      return updated;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      rethrow;
    }
  }
}

final visitorFormViewModelProvider =
    StateNotifierProvider<VisitorFormViewModel, VisitorFormState>((ref) {
  return VisitorFormViewModel(ref);
});
