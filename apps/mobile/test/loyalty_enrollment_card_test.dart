import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/loyalty/presentation/widgets/loyalty_enrollment_card.dart';

void main() {
  testWidgets('shows generated customer enrollment link and actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoyaltyEnrollmentCard(
            businessSlug: 'tavrix-cafe',
            customerWebBaseUrl: 'https://menu.example.test',
          ),
        ),
      ),
    );

    expect(find.text('Customer Enrollment Link'), findsOneWidget);
    expect(
      find.text(
        'Ask the customer to scan this QR or open this link to join the loyalty program.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('https://menu.example.test/m/tavrix-cafe/loyalty'),
      findsOneWidget,
    );
    expect(find.text('Copy link'), findsOneWidget);
    expect(find.text('Share link'), findsOneWidget);
  });

  testWidgets('shows friendly missing slug state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoyaltyEnrollmentCard(
            businessSlug: '',
            customerWebBaseUrl: 'https://menu.example.test',
          ),
        ),
      ),
    );

    expect(find.text('Customer Enrollment Link'), findsOneWidget);
    expect(
      find.text(
        'A business slug is required before customers can join from a public loyalty link.',
      ),
      findsOneWidget,
    );
    expect(find.text('Copy link'), findsNothing);
    expect(find.text('Share link'), findsNothing);
  });

  testWidgets('uses public menu origin when configured base URL is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoyaltyEnrollmentCard(
            businessSlug: 'tavrix-cafe',
            customerWebBaseUrl: '',
            publicMenuUrl: 'http://localhost:3001/m/tavrix-cafe',
          ),
        ),
      ),
    );

    expect(
      find.text('http://localhost:3001/m/tavrix-cafe/loyalty'),
      findsOneWidget,
    );
  });

  testWidgets('uses relative enrollment path when no origin is available', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoyaltyEnrollmentCard(
            businessSlug: 'tavrix-cafe',
            customerWebBaseUrl: '',
            publicMenuUrl: '/m/tavrix-cafe',
          ),
        ),
      ),
    );

    expect(find.text('/m/tavrix-cafe/loyalty'), findsOneWidget);
    expect(find.text('Copy link'), findsOneWidget);
    expect(find.text('Share link'), findsOneWidget);
  });
}
