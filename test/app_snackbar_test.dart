import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sumadhura_visitor/core/utils/app_snackbar.dart';

void main() {
  group('AppSnackBar Tests', () {
    testWidgets('AppSnackBar showSuccess displays floating curved SnackBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AppSnackBar.showSuccess(context, 'Operation successful'),
                child: const Text('Show Success'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Success'));
      await tester.pump();

      expect(find.text('Operation successful'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      final snackBarFinder = find.byType(SnackBar);
      expect(snackBarFinder, findsOneWidget);
      final SnackBar snackBar = tester.widget(snackBarFinder);
      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.shape, isA<RoundedRectangleBorder>());
      expect(snackBar.backgroundColor, AppSnackBar.successGreen);
    });

    testWidgets('AppSnackBar showError displays floating curved SnackBar with error styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AppSnackBar.showError(context, 'Operation failed'),
                child: const Text('Show Error'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pump();

      expect(find.text('Operation failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

      final snackBarFinder = find.byType(SnackBar);
      expect(snackBarFinder, findsOneWidget);
      final SnackBar snackBar = tester.widget(snackBarFinder);
      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.shape, isA<RoundedRectangleBorder>());
      expect(snackBar.backgroundColor, AppSnackBar.failedRed);
    });
  });
}

