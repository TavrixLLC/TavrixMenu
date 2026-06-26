import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/core/utils/business_role.dart';

void main() {
  test('role labels never default to staff', () {
    expect(BusinessRole.displayLabel('OWNER'), 'Owner');
    expect(BusinessRole.displayLabel('ADMIN'), 'Admin');
    expect(BusinessRole.displayLabel('MANAGER'), 'Manager');
    expect(BusinessRole.displayLabel(null), 'Business Operator');
    expect(BusinessRole.displayLabel('BUSINESS_OWNER'), 'Business Operator');

    expect(BusinessRole.displayLabel('OWNER'), isNot('Staff'));
    expect(BusinessRole.displayLabel('ADMIN'), isNot('Staff'));
    expect(BusinessRole.displayLabel('MANAGER'), isNot('Staff'));
    expect(BusinessRole.displayLabel(null), isNot('Staff'));
  });

  test('staff label requires explicit staff role', () {
    expect(BusinessRole.displayLabel('STAFF'), 'Staff');
  });
}
