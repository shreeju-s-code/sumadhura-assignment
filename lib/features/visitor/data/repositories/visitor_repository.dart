import '../../../../core/network/api_exceptions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../datasources/visitor_api_service.dart';
import '../models/visitor_model.dart';

abstract class IVisitorRepository {
  Future<List<Visitor>> getVisitors();
  Future<Visitor> getVisitorById(String id);
  Future<Visitor> registerVisitor(Visitor visitor);
  Future<Visitor> updateVisitor(Visitor visitor);
  Future<void> deleteVisitor(String id);
  Future<Visitor> checkIn(Visitor visitor);
  Future<Visitor> checkOut(Visitor visitor);
}

/// Repository managing visitor data operations and business rule validations
/// at the data boundary.
class VisitorRepository implements IVisitorRepository {
  final IVisitorApiService _apiService;

  // In-memory fallback cache populated dynamically from real API operations
  static final List<Visitor> _mockFallbackStore = [];

  VisitorRepository({required IVisitorApiService apiService})
      : _apiService = apiService;

  @override
  Future<List<Visitor>> getVisitors() async {
    try {
      final remoteList = await _apiService.getVisitors();
      _syncStore(remoteList);
      return remoteList;
    } catch (e) {
      // Return cached list if available during temporary network issues
      if (_mockFallbackStore.isNotEmpty) {
        return List.unmodifiable(_mockFallbackStore);
      }
      rethrow;
    }
  }

  @override
  Future<Visitor> getVisitorById(String id) async {
    try {
      return await _apiService.getVisitorById(id);
    } catch (e) {
      // Check in fallback cache
      final matched = _mockFallbackStore.where((v) => v.id == id);
      if (matched.isNotEmpty) {
        return matched.first;
      }
      if (e is ApiException) rethrow;
      throw const NotFoundException('Visitor with the provided ID does not exist.');
    }
  }

  @override
  Future<Visitor> registerVisitor(Visitor visitor) async {
    try {
      final created = await _apiService.createVisitor(visitor);
      _mockFallbackStore.insert(0, created);
      return created;
    } catch (e) {
      // Fallback local persistence if remote mock is unreachable
      final generatedId = (DateTime.now().millisecondsSinceEpoch % 100000).toString();
      final localCreated = visitor.copyWith(id: generatedId);
      _mockFallbackStore.insert(0, localCreated);
      return localCreated;
    }
  }

  @override
  Future<Visitor> updateVisitor(Visitor visitor) async {
    try {
      final updated = await _apiService.updateVisitor(visitor);
      final index = _mockFallbackStore.indexWhere((v) => v.id == visitor.id);
      if (index != -1) {
        _mockFallbackStore[index] = updated;
      }
      return updated;
    } catch (e) {
      final index = _mockFallbackStore.indexWhere((v) => v.id == visitor.id);
      if (index != -1) {
        _mockFallbackStore[index] = visitor;
        return visitor;
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteVisitor(String id) async {
    try {
      await _apiService.deleteVisitor(id);
    } finally {
      _mockFallbackStore.removeWhere((v) => v.id == id);
    }
  }

  @override
  Future<Visitor> checkIn(Visitor visitor) async {
    // Enforce Business Rule: Check-in is permitted only for Registered visitors
    if (!visitor.canCheckIn) {
      if (visitor.status == VisitorStatus.checkedIn) {
        throw const ValidationApiException('Visitor is already checked in.');
      } else if (visitor.status == VisitorStatus.checkedOut) {
        throw const ValidationApiException('A completed visit cannot be checked in again.');
      }
      throw const ValidationApiException('Check-in is permitted only for Registered visitors.');
    }

    final nowIso = DateFormatter.nowIso();
    try {
      final updated = await _apiService.checkInVisitor(visitor.id, nowIso);
      _updateLocalStore(updated);
      return updated;
    } catch (e) {
      final localUpdated = visitor.copyWith(
        status: VisitorStatus.checkedIn,
        checkInTime: nowIso,
      );
      _updateLocalStore(localUpdated);
      return localUpdated;
    }
  }

  @override
  Future<Visitor> checkOut(Visitor visitor) async {
    // Enforce Business Rule: Check-out is permitted only for Checked In visitors
    if (!visitor.canCheckOut) {
      if (visitor.status == VisitorStatus.registered) {
        throw const ValidationApiException('Visitor must be checked in before checking out.');
      } else if (visitor.status == VisitorStatus.checkedOut) {
        throw const ValidationApiException('Visitor has already checked out.');
      }
      throw const ValidationApiException('Check-out is permitted only for Checked In visitors.');
    }

    final nowIso = DateFormatter.nowIso();
    try {
      final updated = await _apiService.checkOutVisitor(visitor.id, nowIso);
      _updateLocalStore(updated);
      return updated;
    } catch (e) {
      final localUpdated = visitor.copyWith(
        status: VisitorStatus.checkedOut,
        checkOutTime: nowIso,
      );
      _updateLocalStore(localUpdated);
      return localUpdated;
    }
  }

  void _syncStore(List<Visitor> remoteList) {
    _mockFallbackStore.clear();
    _mockFallbackStore.addAll(remoteList);
  }

  void _updateLocalStore(Visitor visitor) {
    final idx = _mockFallbackStore.indexWhere((v) => v.id == visitor.id);
    if (idx != -1) {
      _mockFallbackStore[idx] = visitor;
    } else {
      _mockFallbackStore.add(visitor);
    }
  }
}
