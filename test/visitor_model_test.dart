import 'package:flutter_test/flutter_test.dart';
import 'package:sumadhura_visitor/features/visitor/data/models/visitor_model.dart';

void main() {
  group('Visitor Model & Business Logic Rules Tests', () {
    test('New visitor starts with Registered status', () {
      final visitor = Visitor(
        id: '1',
        name: 'Rahul Sharma',
        mobile: '9876543210',
        purpose: 'Flat inspection',
        createdAt: DateTime.now().toUtc().toIso8601String(),
      );

      expect(visitor.status, VisitorStatus.registered);
      expect(visitor.canCheckIn, isTrue);
      expect(visitor.canCheckOut, isFalse);
      expect(visitor.isCompleted, isFalse);
    });

    test('Checked In visitor allows check-out but not check-in', () {
      final visitor = Visitor(
        id: '2',
        name: 'Sunil Rao',
        mobile: '9123456789',
        purpose: 'Delivery',
        status: VisitorStatus.checkedIn,
        createdAt: DateTime.now().toUtc().toIso8601String(),
        checkInTime: DateTime.now().toUtc().toIso8601String(),
      );

      expect(visitor.canCheckIn, isFalse);
      expect(visitor.canCheckOut, isTrue);
      expect(visitor.isCompleted, isFalse);
    });

    test('Completed visitor cannot be checked in or checked out again', () {
      final visitor = Visitor(
        id: '3',
        name: 'Meera Iyer',
        mobile: '9988776655',
        purpose: 'Client meeting',
        status: VisitorStatus.checkedOut,
        createdAt: DateTime.now().toUtc().toIso8601String(),
        checkInTime: DateTime.now().subtract(const Duration(hours: 2)).toUtc().toIso8601String(),
        checkOutTime: DateTime.now().toUtc().toIso8601String(),
      );

      expect(visitor.canCheckIn, isFalse);
      expect(visitor.canCheckOut, isFalse);
      expect(visitor.isCompleted, isTrue);
    });

    test('JSON serialization and deserialization roundtrip', () {
      const original = Visitor(
        id: '42',
        name: 'Anita Desai',
        mobile: '9811223344',
        email: 'anita@example.com',
        visitorType: VisitorType.vendor,
        project: ProjectName.projectB,
        purpose: 'Plumbing supplies delivery',
        status: VisitorStatus.registered,
        createdAt: '2026-10-27T10:00:00Z',
      );

      final json = original.toJson();
      expect(json['id'], '42');
      expect(json['name'], 'Anita Desai');
      expect(json['mobile'], '9811223344');
      expect(json['email'], 'anita@example.com');
      expect(json['visitor_type'], 'Vendor');
      expect(json['project'], 'Project B');
      expect(json['status'], 'Registered');

      final parsed = Visitor.fromJson(json);
      expect(parsed.id, original.id);
      expect(parsed.name, original.name);
      expect(parsed.visitorType, VisitorType.vendor);
      expect(parsed.project, ProjectName.projectB);
      expect(parsed.status, VisitorStatus.registered);
    });
  });
}
