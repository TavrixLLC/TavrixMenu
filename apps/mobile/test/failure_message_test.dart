import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/errors/failures.dart';
import 'package:tavrix_menu_mobile/core/utils/failure_message.dart';

void main() {
  test('technical backend enums are not shown to users', () {
    final message = failureMessage(
      const ValidationFailure('ERROR_RECEIVED_FROM_SERVER'),
    );

    expect(message, 'Please check the form values.');
    expect(message, isNot(contains('ERROR_RECEIVED_FROM_SERVER')));
  });

  test('friendly validation messages remain visible', () {
    expect(
      failureMessage(const ValidationFailure('Business name is required.')),
      'Business name is required.',
    );
  });
}
