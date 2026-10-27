import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sumadhura_visitor/core/network/api_exceptions.dart';
import 'package:sumadhura_visitor/features/visitor/data/datasources/visitor_api_service.dart';
import 'package:sumadhura_visitor/features/visitor/data/models/visitor_model.dart';
import 'package:sumadhura_visitor/features/visitor/data/repositories/visitor_repository.dart';

class MockVisitorApiService extends Mock implements IVisitorApiService {}

void main() {
  late MockVisitorApiService mockApiService;
  late VisitorRepository repository;

  setUp(() {
    mockApiService = MockVisitorApiService();
    repository = VisitorRepository(apiService: mockApiService);
  });

  group('VisitorRepository Business Rules Enforcement', () {
    test('Check-in fails with ValidationApiException if visitor is already checked in', () async {
      final visitor = Visitor(
        id: '10',
        name: 'Ajay Singh',
        mobile: '9876543210',
        purpose: 'Vendor supply',
        status: VisitorStatus.checkedIn,
        createdAt: DateTime.now().toUtc().toIso8601String(),
      );

      expect(
        () => repository.checkIn(visitor),
        throwsA(isA<ValidationApiException>().having(
          (e) => e.message,
          'message',
          contains('already checked in'),
        )),
      );
    });

    test('Check-in fails with ValidationApiException if visit is completed', () async {
      final visitor = Visitor(
        id: '11',
        name: 'Kavita Roy',
        mobile: '9876543210',
        purpose: 'Meeting',
        status: VisitorStatus.checkedOut,
        createdAt: DateTime.now().toUtc().toIso8601String(),
      );

      expect(
        () => repository.checkIn(visitor),
        throwsA(isA<ValidationApiException>().having(
          (e) => e.message,
          'message',
          contains('completed visit cannot be checked in again'),
        )),
      );
    });

    test('Check-out fails with ValidationApiException if visitor has not checked in', () async {
      final visitor = Visitor(
        id: '12',
        name: 'Rohan Gupta',
        mobile: '9876543210',
        purpose: 'Documentation',
        status: VisitorStatus.registered,
        createdAt: DateTime.now().toUtc().toIso8601String(),
      );

      expect(
        () => repository.checkOut(visitor),
        throwsA(isA<ValidationApiException>().having(
          (e) => e.message,
          'message',
          contains('must be checked in before checking out'),
        )),
      );
    });
  });
}
