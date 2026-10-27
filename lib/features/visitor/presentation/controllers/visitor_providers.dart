import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/visitor_api_service.dart';
import '../../data/models/visitor_model.dart';
import '../../data/repositories/visitor_repository.dart';

// ==========================================
// INFRASTRUCTURE & REPOSITORY PROVIDERS
// ==========================================

/// Singleton ApiClient provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Visitor API Service provider
final visitorApiServiceProvider = Provider<IVisitorApiService>((ref) {
  final client = ref.watch(apiClientProvider);
  return VisitorApiService(apiClient: client);
});

/// Visitor Repository provider
final visitorRepositoryProvider = Provider<IVisitorRepository>((ref) {
  final apiService = ref.watch(visitorApiServiceProvider);
  return VisitorRepository(apiService: apiService);
});

// ==========================================
// SEARCH & FILTER CRITERIA PROVIDERS
// ==========================================

/// Active search query (matches visitor name or mobile number)
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Active status filter (All, Registered, Checked In, Checked Out)
final statusFilterProvider = StateProvider<VisitorStatus?>((ref) => null);

/// Active project filter (All, Project A, Project B, Project C)
final projectFilterProvider = StateProvider<ProjectName?>((ref) => null);

// ==========================================
// DASHBOARD METRICS MODEL & PROVIDER
// ==========================================

class DashboardMetrics {
  final int registeredToday;
  final int currentlyCheckedIn;
  final int checkedOutToday;
  final int totalCount;

  const DashboardMetrics({
    required this.registeredToday,
    required this.currentlyCheckedIn,
    required this.checkedOutToday,
    required this.totalCount,
  });

  factory DashboardMetrics.empty() {
    return const DashboardMetrics(
      registeredToday: 0,
      currentlyCheckedIn: 0,
      checkedOutToday: 0,
      totalCount: 0,
    );
  }

  factory DashboardMetrics.fromVisitors(List<Visitor> visitors) {
    int regToday = 0;
    int currCheckedIn = 0;
    int checkedOutToday = 0;

    for (final v in visitors) {
      // Registered today
      if (v.isRegisteredToday) {
        regToday++;
      }
      // Currently checked in (active on site)
      if (v.status == VisitorStatus.checkedIn) {
        currCheckedIn++;
      }
      // Checked out today
      if (v.isCheckedOutToday) {
        checkedOutToday++;
      }
    }

    return DashboardMetrics(
      registeredToday: regToday,
      currentlyCheckedIn: currCheckedIn,
      checkedOutToday: checkedOutToday,
      totalCount: visitors.length,
    );
  }
}

/// Reactive derived provider for Dashboard statistics.
/// Automatically recalculates whenever visitor records are mutated.
final dashboardMetricsProvider = Provider<DashboardMetrics>((ref) {
  final visitorsState = ref.watch(visitorListNotifierProvider);
  return visitorsState.maybeWhen(
    data: (visitors) => DashboardMetrics.fromVisitors(visitors),
    orElse: () => DashboardMetrics.empty(),
  );
});

// ==========================================
// VISITOR LIST STATE NOTIFIER
// ==========================================

class VisitorListNotifier extends StateNotifier<AsyncValue<List<Visitor>>> {
  final IVisitorRepository _repository;

  VisitorListNotifier({required IVisitorRepository repository})
      : _repository = repository,
        super(const AsyncValue.loading()) {
    loadVisitors();
  }

  /// Initial load or pull-to-refresh
  Future<void> loadVisitors({bool isRefresh = false}) async {
    if (!isRefresh && state.hasValue) {
      state = const AsyncValue.loading();
    }
    try {
      final list = await _repository.getVisitors();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Register a new visitor through API and update state
  Future<Visitor> registerVisitor(Visitor visitor) async {
    try {
      final created = await _repository.registerVisitor(visitor);
      state = state.whenData((currentList) => [created, ...currentList]);
      return created;
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing visitor through API and update state
  Future<Visitor> updateVisitor(Visitor visitor) async {
    try {
      final updated = await _repository.updateVisitor(visitor);
      state = state.whenData((currentList) {
        return currentList.map((v) => v.id == updated.id ? updated : v).toList();
      });
      return updated;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a visitor after confirmation
  Future<void> deleteVisitor(String id) async {
    try {
      await _repository.deleteVisitor(id);
      state = state.whenData((currentList) {
        return currentList.where((v) => v.id != id).toList();
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Check-in visitor
  Future<Visitor> checkIn(Visitor visitor) async {
    try {
      final updated = await _repository.checkIn(visitor);
      state = state.whenData((currentList) {
        return currentList.map((v) => v.id == updated.id ? updated : v).toList();
      });
      return updated;
    } catch (e) {
      rethrow;
    }
  }

  /// Check-out visitor
  Future<Visitor> checkOut(Visitor visitor) async {
    try {
      final updated = await _repository.checkOut(visitor);
      state = state.whenData((currentList) {
        return currentList.map((v) => v.id == updated.id ? updated : v).toList();
      });
      return updated;
    } catch (e) {
      rethrow;
    }
  }
}

/// Main Visitor List Provider
final visitorListNotifierProvider =
    StateNotifierProvider<VisitorListNotifier, AsyncValue<List<Visitor>>>((ref) {
  final repo = ref.watch(visitorRepositoryProvider);
  return VisitorListNotifier(repository: repo);
});

// ==========================================
// FILTERED VISITORS COMPUTED PROVIDER
// ==========================================

/// Computed provider that handles search by name/mobile and status/project filters
final filteredVisitorsProvider = Provider<AsyncValue<List<Visitor>>>((ref) {
  final visitorsAsync = ref.watch(visitorListNotifierProvider);
  final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();
  final statusFilter = ref.watch(statusFilterProvider);
  final projectFilter = ref.watch(projectFilterProvider);

  return visitorsAsync.whenData((visitors) {
    return visitors.where((v) {
      // 1. Search Query filter (matches name or 10-digit mobile)
      if (searchQuery.isNotEmpty) {
        final matchesName = v.name.toLowerCase().contains(searchQuery);
        final matchesMobile = v.mobile.contains(searchQuery);
        if (!matchesName && !matchesMobile) return false;
      }

      // 2. Status filter
      if (statusFilter != null && v.status != statusFilter) {
        return false;
      }

      // 3. Project filter
      if (projectFilter != null && v.project != projectFilter) {
        return false;
      }

      return true;
    }).toList();
  });
});

// ==========================================
// INDIVIDUAL VISITOR LOOKUP PROVIDER
// ==========================================

/// Lookup a visitor by ID from the synchronized list or fetch via API
final visitorByIdProvider =
    FutureProvider.family<Visitor?, String>((ref, id) async {
  final listAsync = ref.watch(visitorListNotifierProvider);
  final fromList = listAsync.valueOrNull?.where((v) => v.id == id).firstOrNull;
  if (fromList != null) {
    return fromList;
  }
  // Fallback to repository direct lookup
  final repo = ref.read(visitorRepositoryProvider);
  return await repo.getVisitorById(id);
});
