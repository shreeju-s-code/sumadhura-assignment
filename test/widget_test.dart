import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sumadhura_visitor/main.dart';

void main() {
  testWidgets('App renders Dashboard with title and metrics', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SumadhuraVisitorApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sumadhura Properties'), findsOneWidget);
    expect(find.text('Visitor Management Desk'), findsOneWidget);
    expect(find.text('Today\'s Overview'), findsOneWidget);
    expect(find.text('Registered'), findsWidgets);
    expect(find.text('Checked In'), findsWidgets);
    expect(find.text('Checked Out'), findsWidgets);
  });
}
