import '../workspace/workspace_models.dart';
import 'waflo_destination.dart';

/// Role-aware presentation policy. It never replaces server authorization.
abstract final class WafloNavigationPolicy {
  static List<WafloDestination> destinationsFor(
    WorkspaceMembershipContract membership,
  ) {
    final candidates = switch (membership.role) {
      WafloMembershipRole.owner || WafloMembershipRole.manager => const [
        WafloDestination.home,
        WafloDestination.programs,
        WafloDestination.scan,
        WafloDestination.customers,
        WafloDestination.more,
      ],
      WafloMembershipRole.staff => const [
        WafloDestination.scan,
        WafloDestination.rewards,
        WafloDestination.myActivity,
        WafloDestination.account,
      ],
    };

    return List.unmodifiable(
      candidates.where((destination) => _canView(membership, destination)),
    );
  }

  static bool _canView(
    WorkspaceMembershipContract membership,
    WafloDestination destination,
  ) {
    final requiredCapability = switch (destination) {
      WafloDestination.home => WafloCapability.viewHome,
      WafloDestination.programs => WafloCapability.viewPrograms,
      WafloDestination.scan => WafloCapability.useScanner,
      WafloDestination.customers => WafloCapability.viewCustomers,
      WafloDestination.rewards => WafloCapability.viewRewards,
      WafloDestination.myActivity => WafloCapability.viewOwnActivity,
      WafloDestination.account => WafloCapability.viewAccount,
      WafloDestination.more => WafloCapability.viewMore,
    };
    return membership.can(requiredCapability);
  }

  static WafloDestination initialDestinationFor(
    WorkspaceMembershipContract membership,
  ) {
    final destinations = destinationsFor(membership);
    if (destinations.isEmpty) {
      return WafloDestination.more;
    }
    if (membership.role == WafloMembershipRole.staff &&
        destinations.contains(WafloDestination.scan)) {
      return WafloDestination.scan;
    }
    for (final preferred in const [
      WafloDestination.home,
      WafloDestination.scan,
      WafloDestination.customers,
      WafloDestination.account,
      WafloDestination.more,
    ]) {
      if (destinations.contains(preferred)) {
        return preferred;
      }
    }
    return WafloDestination.more;
  }

  /// Manual lookup is a Scan fallback, never a top-level Staff destination.
  static const bool manualCustomerSearchIsScanFallback = true;
}
