import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/visitor_model.dart';

/// Abstract contract for Visitor API operations.
abstract class IVisitorApiService {
  Future<List<Visitor>> getVisitors();
  Future<Visitor> getVisitorById(String id);
  Future<Visitor> createVisitor(Visitor visitor);
  Future<Visitor> updateVisitor(Visitor visitor);
  Future<void> deleteVisitor(String id);
  Future<Visitor> checkInVisitor(String id, String timestamp);
  Future<Visitor> checkOutVisitor(String id, String timestamp);
}

/// Concrete REST implementation using [ApiClient] (Dio).
class VisitorApiService implements IVisitorApiService {
  final ApiClient _apiClient;

  VisitorApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<Visitor>> getVisitors() async {
    try {
      final data = await _apiClient.get(ApiEndpoints.visitors);
      if (data is List) {
        return data.map((item) => Visitor.fromJson(Map<String, dynamic>.from(item))).toList();
      }
      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnexpectedApiException('Failed to parse visitor list response: $e');
    }
  }

  @override
  Future<Visitor> getVisitorById(String id) async {
    try {
      final data = await _apiClient.get(ApiEndpoints.visitorById(id));
      if (data is Map) {
        return Visitor.fromJson(Map<String, dynamic>.from(data));
      }
      throw const NotFoundException('Visitor record could not be parsed.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnexpectedApiException('Failed to retrieve visitor: $e');
    }
  }

  @override
  Future<Visitor> createVisitor(Visitor visitor) async {
    try {
      final payload = visitor.toCreatePayload();
      final data = await _apiClient.post(ApiEndpoints.visitors, data: payload);
      if (data is Map) {
        return Visitor.fromJson(Map<String, dynamic>.from(data));
      }
      throw const UnexpectedApiException('Invalid server response when creating visitor.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnexpectedApiException('Failed to create visitor: $e');
    }
  }

  @override
  Future<Visitor> updateVisitor(Visitor visitor) async {
    try {
      final payload = visitor.toJson();
      final data = await _apiClient.put(ApiEndpoints.visitorById(visitor.id), data: payload);
      if (data is Map) {
        return Visitor.fromJson(Map<String, dynamic>.from(data));
      }
      return visitor;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnexpectedApiException('Failed to update visitor: $e');
    }
  }

  @override
  Future<void> deleteVisitor(String id) async {
    try {
      await _apiClient.delete(ApiEndpoints.visitorById(id));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnexpectedApiException('Failed to delete visitor: $e');
    }
  }

  @override
  Future<Visitor> checkInVisitor(String id, String timestamp) async {
    try {
      final payload = {
        'status': VisitorStatus.checkedIn.toJson(),
        'check_in_time': timestamp,
      };
      final data = await _apiClient.put(ApiEndpoints.checkIn(id), data: payload);
      if (data is Map) {
        return Visitor.fromJson(Map<String, dynamic>.from(data));
      }
      throw const UnexpectedApiException('Invalid server response during check-in.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnexpectedApiException('Failed to check in visitor: $e');
    }
  }

  @override
  Future<Visitor> checkOutVisitor(String id, String timestamp) async {
    try {
      final payload = {
        'status': VisitorStatus.checkedOut.toJson(),
        'check_out_time': timestamp,
      };
      final data = await _apiClient.put(ApiEndpoints.checkOut(id), data: payload);
      if (data is Map) {
        return Visitor.fromJson(Map<String, dynamic>.from(data));
      }
      throw const UnexpectedApiException('Invalid server response during check-out.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnexpectedApiException('Failed to check out visitor: $e');
    }
  }
}
