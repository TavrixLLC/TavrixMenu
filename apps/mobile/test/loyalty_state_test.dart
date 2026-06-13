import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/features/loyalty/presentation/bloc/loyalty_state.dart';

void main() {
  test(
    'OWNER and MANAGER can configure while STAFF can run daily operations',
    () {
      const owner = LoyaltyState(
        status: LoyaltyStatus.success,
        currentRole: 'OWNER',
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
      expect(manager.canConfigureProgram, isTrue);
      expect(staff.canConfigureProgram, isFalse);
      expect(staff.canUseDailyOperations, isTrue);
    },
  );
}
