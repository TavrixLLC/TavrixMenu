import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/auth/presentation/utils/auth_error_copy.dart';
import 'package:tavrix_menu_mobile/shared/widgets/error_view.dart';

void main() {
  test('invalid OTP Clerk error maps to invalid code copy', () {
    final copy = authErrorCopyFromClerkError(
      'ClerkError(ERROR_FORM_CODE_INCORRECT)',
    );

    expect(copy.title, 'Invalid code');
    expect(copy.body, 'Check the code and try again.');
    expect(copy.body, isNot(contains('ERROR_FORM_CODE_INCORRECT')));
  });

  test('unknown business account error maps to support copy', () {
    final copy = authErrorCopyFromClerkError(
      'Couldn\'t find your account. (ERROR_RECEIVED_FROM_SERVER)',
    );

    expect(copy.title, 'Business account not found');
    expect(
      copy.body,
      'This mobile app is for Waflo business accounts. Contact Waflo support to activate your business workspace.',
    );
    expect(copy.body, isNot(contains('ERROR_RECEIVED_FROM_SERVER')));
  });

  test('generic server errors do not expose raw technical enums', () {
    final copy = authErrorCopyFromClerkError(
      'ClerkError(ERROR_RECEIVED_FROM_SERVER)',
    );

    expect(copy.title, 'Something went wrong');
    expect(
      copy.body,
      'We couldn\'t complete sign-in right now. Please try again.',
    );
    expect(copy.body, isNot(contains('ERROR_RECEIVED_FROM_SERVER')));
    expect(copy.body, isNot(contains('ClerkError')));
  });

  testWidgets('business account error view renders friendly copy only', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorView(
            title: 'Business account not found',
            message:
                'This mobile app is for Waflo business accounts. Contact Waflo support to activate your business workspace.',
          ),
        ),
      ),
    );

    expect(find.text('Business account not found'), findsOneWidget);
    expect(find.textContaining('business workspace'), findsOneWidget);
    expect(find.textContaining('ERROR_RECEIVED_FROM_SERVER'), findsNothing);
  });

  testWidgets('invalid OTP copy renders without technical enum', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorView(
            title: 'Invalid code',
            message: 'Check the code and try again.',
          ),
        ),
      ),
    );

    expect(find.text('Invalid code'), findsOneWidget);
    expect(find.text('Check the code and try again.'), findsOneWidget);
    expect(find.textContaining('ERROR_FORM_CODE_INCORRECT'), findsNothing);
  });
}
