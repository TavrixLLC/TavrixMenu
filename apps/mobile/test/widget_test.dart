import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/app.dart';

void main() {
  testWidgets('shows the Tavrix Menu login placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(const TavrixMenuApp());

    expect(find.text('Tavrix Menu'), findsOneWidget);
    expect(find.text('Business user login'), findsOneWidget);
  });
}
