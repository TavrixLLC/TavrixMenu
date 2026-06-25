import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/auth/presentation/utils/auth_error_copy.dart';
import 'package:tavrix_menu_mobile/shared/widgets/error_view.dart';

void main() {
  test('unknown account Clerk error maps to operator account copy', () {
    final copy = authErrorCopyFromClerkError(
      'Couldn\'t find your account. (ERROR_RECEIVED_FROM_SERVER)',
    );

    expect(copy.title, 'Account not found');
    expect(
      copy.body,
      'We couldn\'t find an operator account for this email or phone. Ask your business owner to invite you to Waflo.',
    );
    expect(copy.body, isNot(contains('ERROR_RECEIVED_FROM_SERVER')));
  });

  test('generic Clerk errors do not expose raw technical enums', () {
    final copy = authErrorCopyFromClerkError(
      'ClerkError(ERROR_FORM_CODE_INCORRECT)',
    );

    expect(copy.title, 'Sign in could not continue');
    expect(copy.body, isNot(contains('ERROR_FORM_CODE_INCORRECT')));
    expect(copy.body, isNot(contains('ClerkError')));
  });

  testWidgets('account-not-found error view renders friendly copy only', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ErrorView(
            title: 'Account not found',
            message:
                'We couldn\'t find an operator account for this email or phone. Ask your business owner to invite you to Waflo.',
          ),
        ),
      ),
    );

    expect(find.text('Account not found'), findsOneWidget);
    expect(find.textContaining('operator account'), findsOneWidget);
    expect(find.textContaining('ERROR_RECEIVED_FROM_SERVER'), findsNothing);
  });
}
