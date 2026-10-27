import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/visitor/data/models/visitor_model.dart';
import '../features/visitor/presentation/controllers/visitor_providers.dart';

class QrScannerState {
  final bool isProcessing;
  final Visitor? identifiedVisitor;
  final String? errorMessage;

  const QrScannerState({
    this.isProcessing = false,
    this.identifiedVisitor,
    this.errorMessage,
  });

  QrScannerState copyWith({
    bool? isProcessing,
    Visitor? identifiedVisitor,
    bool clearVisitor = false,
    String? errorMessage,
  }) {
    return QrScannerState(
      isProcessing: isProcessing ?? this.isProcessing,
      identifiedVisitor: clearVisitor ? null : (identifiedVisitor ?? this.identifiedVisitor),
      errorMessage: errorMessage,
    );
  }
}

class QrScannerViewModel extends StateNotifier<QrScannerState> {
  final Ref _ref;

  QrScannerViewModel(this._ref) : super(const QrScannerState());

  Future<Visitor?> processScannedId(String visitorId) async {
    if (state.isProcessing) return null; // Debounce guard

    state = state.copyWith(isProcessing: true, errorMessage: null, clearVisitor: true);
    try {
      final repo = _ref.read(visitorRepositoryProvider);
      final visitor = await repo.getVisitorById(visitorId);
      state = state.copyWith(
        isProcessing: false,
        identifiedVisitor: visitor,
        errorMessage: null,
      );
      return visitor;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
        clearVisitor: true,
      );
      rethrow;
    }
  }

  Future<void> checkInScannedVisitor() async {
    final visitor = state.identifiedVisitor;
    if (visitor == null) return;
    try {
      final updated = await _ref
          .read(visitorListNotifierProvider.notifier)
          .checkIn(visitor);
      state = state.copyWith(identifiedVisitor: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> checkOutScannedVisitor() async {
    final visitor = state.identifiedVisitor;
    if (visitor == null) return;
    try {
      final updated = await _ref
          .read(visitorListNotifierProvider.notifier)
          .checkOut(visitor);
      state = state.copyWith(identifiedVisitor: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  void reset() {
    state = const QrScannerState();
  }
}

final qrScannerViewModelProvider =
    StateNotifierProvider<QrScannerViewModel, QrScannerState>((ref) {
  return QrScannerViewModel(ref);
});
