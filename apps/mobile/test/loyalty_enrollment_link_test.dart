import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_enrollment_link.dart';

void main() {
  group('LoyaltyEnrollmentLink', () {
    test(
      'builds absolute enrollment URL from configured customer web base URL',
      () {
        final url = LoyaltyEnrollmentLink.build(
          businessSlug: 'tavrix-cafe',
          customerWebBaseUrl: 'https://menu.example.test/',
        );

        expect(url, 'https://menu.example.test/m/tavrix-cafe/loyalty');
      },
    );

    test(
      'uses public menu URL origin when customer web base URL is missing',
      () {
        final url = LoyaltyEnrollmentLink.build(
          businessSlug: 'tavrix-cafe',
          customerWebBaseUrl: '',
          publicMenuUrl: 'http://localhost:3001/m/tavrix-cafe',
        );

        expect(url, 'http://localhost:3001/m/tavrix-cafe/loyalty');
      },
    );

    test(
      'falls back to relative enrollment path when no origin is available',
      () {
        final url = LoyaltyEnrollmentLink.build(
          businessSlug: 'tavrix-cafe',
          customerWebBaseUrl: '',
          publicMenuUrl: '/m/tavrix-cafe',
        );

        expect(url, '/m/tavrix-cafe/loyalty');
      },
    );

    test('returns null when business slug is missing', () {
      final url = LoyaltyEnrollmentLink.build(
        businessSlug: ' ',
        customerWebBaseUrl: 'https://menu.example.test',
      );

      expect(url, isNull);
    });
  });
}
