import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/app.dart';

void main() {
  testWidgets('shows business login and opens dashboard in dev mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TavrixMenuApp());
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('Tavrix Menu'), findsOneWidget);
    expect(find.text('Business user login'), findsOneWidget);
    expect(
      find.textContaining('Customers browse menus through customer-web'),
      findsOneWidget,
    );

    await tester.tap(find.text('Continue in dev mode'));
    await tester.pumpAndSettle();

    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Manage Menu'), findsOneWidget);
  });
}
