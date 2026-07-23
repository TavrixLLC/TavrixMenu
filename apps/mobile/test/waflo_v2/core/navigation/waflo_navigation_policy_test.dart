import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/navigation/waflo_destination.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/navigation/waflo_navigation_policy.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/workspace/workspace_models.dart';

import '../../test_fixtures.dart';

void main() {
  test('Owner and Manager receive five capability-backed destinations', () {
    expect(WafloNavigationPolicy.destinationsFor(ownerMembership()), [
      WafloDestination.home,
      WafloDestination.programs,
      WafloDestination.scan,
      WafloDestination.customers,
      WafloDestination.more,
    ]);
    expect(
      WafloNavigationPolicy.destinationsFor(managerMembership()),
      hasLength(5),
    );
  });

  test('Staff receives the focused operational destination set', () {
    final destinations = WafloNavigationPolicy.destinationsFor(
      staffMembership(),
    );
    expect(destinations, [
      WafloDestination.scan,
      WafloDestination.rewards,
      WafloDestination.myActivity,
      WafloDestination.account,
    ]);
    expect(destinations, isNot(contains(WafloDestination.customers)));
    expect(destinations, isNot(contains(WafloDestination.programs)));
    expect(WafloNavigationPolicy.manualCustomerSearchIsScanFallback, isTrue);
    expect(
      WafloNavigationPolicy.initialDestinationFor(staffMembership()),
      WafloDestination.scan,
    );
  });

  test('missing presentation capability omits the destination', () {
    final membership = managerMembership();
    final restricted = managerMembershipWith(
      membership,
      capabilities: const {WafloCapability.viewHome, WafloCapability.viewMore},
    );
    expect(WafloNavigationPolicy.destinationsFor(restricted), [
      WafloDestination.home,
      WafloDestination.more,
    ]);
  });
}

WorkspaceMembershipContract managerMembershipWith(
  WorkspaceMembershipContract source, {
  required Set<WafloCapability> capabilities,
}) {
  return WorkspaceMembershipContract(
    businessId: source.businessId,
    businessDisplayName: source.businessDisplayName,
    role: source.role,
    branchAccess: source.branchAccess,
    capabilities: capabilities,
  );
}
