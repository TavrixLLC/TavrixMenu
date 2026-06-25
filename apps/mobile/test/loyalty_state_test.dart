import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/loyalty/presentation/bloc/loyalty_state.dart';

void main() {
  test(
    'OWNER ADMIN and MANAGER can configure while STAFF can run daily operations',
    () {
      const owner = LoyaltyState(
        status: LoyaltyStatus.success,
        currentRole: 'OWNER',
      );
      const admin = LoyaltyState(
        status: LoyaltyStatus.success,
        currentRole: 'ADMIN',
      );
      const manager = LoyaltyState(
        status: LoyaltyStatus.success,
        currentRole: 'MANAGER',
      );
      const staff = LoyaltyState(
        status: LoyaltyStatus.success,
        currentRole: 'STAFF',
      );

      expect(owner.canConfigureProgram, isTrue);
      expect(admin.canConfigureProgram, isTrue);
      expect(manager.canConfigureProgram, isTrue);
      expect(staff.canConfigureProgram, isFalse);
      expect(staff.canUseDailyOperations, isTrue);
      expect(owner.canViewEnrollmentLink, isTrue);
      expect(admin.canViewEnrollmentLink, isTrue);
      expect(manager.canViewEnrollmentLink, isTrue);
      expect(staff.canViewEnrollmentLink, isTrue);
    },
  );

  test(
    'missing role remains operational until backend permissions are known',
    () {
      const state = LoyaltyState(
        status: LoyaltyStatus.success,
        currentRole: 'BUSINESS_OPERATOR',
      );

      expect(state.canViewEnrollmentLink, isTrue);
      expect(state.canUseDailyOperations, isTrue);
      expect(state.canConfigureProgram, isTrue);
    },
  );
}
