enum LoyaltyProgramStatus { draft, validated, published, paused, archived }

/// Blueprint V1 earning catalog. Manual adjustment is deliberately absent:
/// it is a protected administrative operation, not an earning rule.
enum EarningRuleKind {
  visitStamp,
  spendBased,
  itemBased,
  categoryBased,
  completedService,
  hybrid,
  welcomeEvent,
}

/// Blueprint Planned V1 reward catalog. These are presentation contracts only
/// in Phase 1 and do not imply an available reward engine or mutation path.
enum RewardDefinitionKind {
  freeItem,
  freeServiceOrAddOn,
  fixedAmountDiscount,
  percentageDiscount,
  itemOrCategoryDiscount,
  buyXGetY,
  bundleCombo,
  multiMilestone,
  voucher,
  welcomeReward,
}

enum LoyaltyAdministrativeOperationKind { manualAdjustment }

abstract final class ManualAdjustmentPolicyContract {
  static const LoyaltyAdministrativeOperationKind operation =
      LoyaltyAdministrativeOperationKind.manualAdjustment;
  static const bool requiresExplicitPermission = true;
  static const bool requiresReason = true;
  static const bool requiresAuditLog = true;
  static const bool approvalDependsOnPolicy = true;
  static const bool operationallyAvailableInPhase1 = false;
  static const String deferredPhase = 'Secure Operations';
}

class EarningRulePresentationContract {
  const EarningRulePresentationContract({
    required this.id,
    required this.kind,
    required this.summary,
  });

  final String id;
  final EarningRuleKind kind;
  final String summary;
}

class RewardDefinitionPresentationContract {
  const RewardDefinitionPresentationContract({
    required this.id,
    required this.kind,
    required this.summary,
  });

  final String id;
  final RewardDefinitionKind kind;
  final String summary;
}

class LoyaltyProgramPresentationContract {
  const LoyaltyProgramPresentationContract({
    required this.id,
    required this.businessId,
    required this.name,
    required this.status,
    required this.earningRules,
    required this.rewardDefinitions,
    this.operationallyEnabled = true,
    this.startsAt,
    this.endsAt,
  });

  final String id;
  final String businessId;
  final String name;
  final LoyaltyProgramStatus status;
  final List<EarningRulePresentationContract> earningRules;
  final List<RewardDefinitionPresentationContract> rewardDefinitions;
  final bool operationallyEnabled;
  final DateTime? startsAt;
  final DateTime? endsAt;

  bool get isHybridPresentation {
    return earningRules.length > 1 ||
        earningRules.any((rule) => rule.kind == EarningRuleKind.hybrid);
  }

  /// Active is derived, not a parallel lifecycle state.
  bool isOperationallyActiveAt(DateTime now) {
    if (status != LoyaltyProgramStatus.published || !operationallyEnabled) {
      return false;
    }
    if (startsAt != null && now.isBefore(startsAt!)) {
      return false;
    }
    if (endsAt != null && !now.isBefore(endsAt!)) {
      return false;
    }
    return true;
  }
}

/// V1 presents one published program, while keeping list-shaped contracts so
/// future multi-active support does not require a presentation rewrite.
class LoyaltyProgramPortfolioContract {
  const LoyaltyProgramPortfolioContract({required this.programs});

  final List<LoyaltyProgramPresentationContract> programs;

  List<LoyaltyProgramPresentationContract> get publishedPrograms {
    return List.unmodifiable(
      programs.where(
        (program) => program.status == LoyaltyProgramStatus.published,
      ),
    );
  }

  List<LoyaltyProgramPresentationContract> activeProgramsAt(DateTime now) {
    return List.unmodifiable(
      programs.where((program) => program.isOperationallyActiveAt(now)),
    );
  }

  bool get violatesV1SinglePublishedPolicy => publishedPrograms.length > 1;
}

enum SpendRoundingContract { floorPerConfirmedTransaction }

enum RefundLedgerContract { appendLinkedReversingEntry }

abstract final class PointsAndMoneyPolicyContract {
  static const String currency = 'IQD';
  static const int currencyMinorUnitScale = 1;
  static const bool integerPointsOnly = true;
  static const SpendRoundingContract spendRounding =
      SpendRoundingContract.floorPerConfirmedTransaction;
  static const RefundLedgerContract refundHandling =
      RefundLedgerContract.appendLinkedReversingEntry;
  static const bool partialRefundUsesOriginalRule = true;
  static const bool negativeAccountingBalanceAllowed = true;
  static const bool redemptionRequiresSufficientAvailableBalance = true;
  static const bool pointsExpireInV1 = false;
  static const bool futureExpiryIsRetroactiveByDefault = false;
  static const bool refundRequiresIdempotencyActorReasonAndAudit = true;
}
