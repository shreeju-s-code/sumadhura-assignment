import 'package:flutter_test/flutter_test.dart';
import 'package:sumadhura_visitor/features/visitor/data/models/visitor_model.dart';
import 'package:sumadhura_visitor/features/visitor/presentation/controllers/visitor_providers.dart';

void main() {
  group('Dashboard Metrics Calculation Tests', () {
    test('Calculates registered today, currently checked in, and checked out today accurately', () {
      final now = DateTime.now();
      final todayIso = now.toUtc().toIso8601String();
      final yesterdayIso = now.subtract(const Duration(days: 1)).toUtc().toIso8601String();

      final visitors = [
        // Visitor 1: Registered today
        Visitor(
          id: '1',
          name: 'Person 1',
          mobile: '9876543210',
          purpose: 'Meeting',
          status: VisitorStatus.registered,
          createdAt: todayIso,
        ),
        // Visitor 2: Registered yesterday, checked in today
        Visitor(
          id: '2',
          name: 'Person 2',
          mobile: '9876543211',
          purpose: 'Delivery',
          status: VisitorStatus.checkedIn,
          createdAt: yesterdayIso,
          checkInTime: todayIso,
        ),
        // Visitor 3: Registered today, currently checked in
        Visitor(
          id: '3',
          name: 'Person 3',
          mobile: '9876543212',
          purpose: 'Audit',
          status: VisitorStatus.checkedIn,
          createdAt: todayIso,
          checkInTime: todayIso,
        ),
        // Visitor 4: Checked out today
        Visitor(
          id: '4',
          name: 'Person 4',
          mobile: '9876543213',
          purpose: 'Consultation',
          status: VisitorStatus.checkedOut,
          createdAt: todayIso,
          checkInTime: todayIso,
          checkOutTime: todayIso,
        ),
      ];

      final metrics = DashboardMetrics.fromVisitors(visitors);

      // Registered today: visitors 1, 3, 4
      expect(metrics.registeredToday, 3);
      // Currently checked in: visitors 2, 3
      expect(metrics.currentlyCheckedIn, 2);
      // Checked out today: visitor 4
      expect(metrics.checkedOutToday, 1);
      expect(metrics.totalCount, 4);
    });
  });
}
