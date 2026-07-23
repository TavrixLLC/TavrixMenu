import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/waflo_v2/features/card_studio/domain/campaign_event.dart';
import 'package:tavrix_menu_mobile/waflo_v2/features/card_studio/domain/card_design.dart';
import 'package:tavrix_menu_mobile/waflo_v2/features/card_studio/domain/card_design_validator.dart';
import 'package:tavrix_menu_mobile/waflo_v2/features/card_studio/domain/theme_assignment.dart';
import 'package:tavrix_menu_mobile/waflo_v2/features/card_studio/domain/visual_theme.dart';
import 'package:tavrix_menu_mobile/waflo_v2/shared/models/customer_identity_contract.dart';
import 'package:tavrix_menu_mobile/waflo_v2/shared/models/loyalty_policy_contract.dart';

import '../../../test_fixtures.dart';

void main() {
  test('approved Waflo design passes contrast and presentation validation', () {
    final result = CardDesignValidator.validate(
      design: reviewCardDesign(),
      providers: reviewProviderCapabilities,
    );
    expect(result.passesSafetyChecks, isTrue);
    expect(
      result.issues.where(
        (issue) => issue.severity == CardDesignValidationSeverity.error,
      ),
      isEmpty,
    );
  });

  test(
    'five card colors are independent and every surface resolves contrast',
    () {
      final design = reviewCardDesign();
      expect({
        design.primaryColor,
        design.secondaryColor,
        design.accentColor,
        design.backgroundColor,
        design.textColor,
      }, hasLength(5));
      final coral = CardDesignValidator.foregroundForSurface(
        design.accentColor,
        preferred: design.textColor,
      );
      expect(coral.foreground, HexColorValue('#241916'));
      expect(coral.ratio, greaterThanOrEqualTo(4.5));
      expect(coral.usesPreferredForeground, isTrue);
    },
  );

  test('unsafe text contrast blocks publish', () {
    final safe = reviewCardDesign();
    final unsafe = CardDesignDraft(
      id: safe.id,
      businessId: safe.businessId,
      programId: safe.programId,
      revision: safe.revision,
      status: safe.status,
      businessDisplayName: safe.businessDisplayName,
      programDisplayName: safe.programDisplayName,
      primaryColor: safe.primaryColor,
      secondaryColor: safe.secondaryColor,
      accentColor: safe.accentColor,
      backgroundColor: HexColorValue('#FFFFFF'),
      textColor: HexColorValue('#FF6B4A'),
      cardShape: safe.cardShape,
      stampShape: safe.stampShape,
      stampIcon: safe.stampIcon,
      rewardIcon: safe.rewardIcon,
      copy: safe.copy,
      logo: safe.logo,
      cover: safe.cover,
      rewardMedia: safe.rewardMedia,
    );
    final result = CardDesignValidator.validate(
      design: unsafe,
      providers: reviewProviderCapabilities,
    );
    expect(result.passesSafetyChecks, isFalse);
    expect(result.issues.map((issue) => issue.code), contains('text_contrast'));
  });

  test('local-only media cannot be treated as a confirmed upload', () {
    final safe = reviewCardDesign();
    final localOnly = CardDesignDraft(
      id: safe.id,
      businessId: safe.businessId,
      programId: safe.programId,
      revision: safe.revision,
      status: safe.status,
      businessDisplayName: safe.businessDisplayName,
      programDisplayName: safe.programDisplayName,
      primaryColor: safe.primaryColor,
      secondaryColor: safe.secondaryColor,
      accentColor: safe.accentColor,
      backgroundColor: safe.backgroundColor,
      textColor: safe.textColor,
      cardShape: safe.cardShape,
      stampShape: safe.stampShape,
      stampIcon: safe.stampIcon,
      rewardIcon: safe.rewardIcon,
      copy: safe.copy,
      logo: const CardMediaReference(
        state: CardMediaState.localPreview,
        localReviewLabel: 'local test file',
      ),
      cover: safe.cover,
      rewardMedia: safe.rewardMedia,
    );
    final result = CardDesignValidator.validate(
      design: localOnly,
      providers: reviewProviderCapabilities,
    );
    expect(
      result.issues.map((issue) => issue.code),
      contains('media_not_confirmed'),
    );
  });

  test('card shape, copy, stamp icon, and reward icon are explicit', () {
    final design = reviewCardDesign();
    expect(design.cardShape, CardVisualShape.softRectangle);
    expect(design.stampIcon, CardVisualIcon.coffee);
    expect(design.rewardIcon, CardVisualIcon.gift);
    expect(design.copy.isComplete, isTrue);
    expect(
      const CardDesignCopy(
        joinHeadline: '',
        joinBody: 'Body',
        rewardLabel: 'Reward',
      ).isComplete,
      isFalse,
    );
  });

  test(
    'VisualTheme validates window and falls back to base design explicitly',
    () {
      final theme = VisualThemeContract(
        id: 'theme-review',
        businessId: 'business-review-a',
        name: 'Ramadan review',
        occasion: VisualThemeOccasion.ramadan,
        status: VisualThemeStatus.draft,
        timezone: 'Asia/Baghdad',
        startAt: DateTime.utc(2027, 2, 1),
        endAt: DateTime.utc(2027, 3, 1),
        fallbackCardDesignRevisionId: 'design-revision-base',
        overrides: VisualThemeOverrides(primaryColor: HexColorValue('#AE3115')),
      );
      final fallback = ResolvedDesignReference.fallback(theme);
      expect(theme.hasValidWindow, isTrue);
      expect(fallback.origin, ResolvedDesignOrigin.baseDesign);
      expect(fallback.designRevisionId, 'design-revision-base');
      expect(fallback.visualThemeId, isNull);
    },
  );

  test('invalid theme interval is rejected by contract state', () {
    final theme = VisualThemeContract(
      id: 'theme-review',
      businessId: 'business-review-a',
      name: 'Invalid review',
      occasion: VisualThemeOccasion.custom,
      status: VisualThemeStatus.draft,
      timezone: 'Asia/Baghdad',
      startAt: DateTime.utc(2027, 3, 1),
      endAt: DateTime.utc(2027, 2, 1),
      fallbackCardDesignRevisionId: 'design-revision-base',
      overrides: const VisualThemeOverrides(),
    );
    expect(theme.hasValidWindow, isFalse);
  });

  test(
    'Campaign and Theme assignment are separate business-scoped contracts',
    () {
      const campaign = CampaignEventContract(
        id: 'campaign-review',
        businessId: 'business-review-a',
        name: 'Occasion review',
        status: CampaignEventStatus.draft,
        visualThemeId: 'theme-review',
      );
      final assignment = VisualThemeAssignmentContract(
        businessId: campaign.businessId,
        visualThemeId: campaign.visualThemeId!,
        programIds: ['program-review-a', 'program-review-b'],
      );
      expect(assignment.isValid, isTrue);
      expect(assignment.programIds, hasLength(2));
    },
  );

  test(
    'V1 portfolio flags more than one published program without changing shape',
    () {
      const rule = EarningRulePresentationContract(
        id: 'rule',
        kind: EarningRuleKind.visitStamp,
        summary: 'fixture',
      );
      const reward = RewardDefinitionPresentationContract(
        id: 'reward',
        kind: RewardDefinitionKind.voucher,
        summary: 'fixture',
      );
      const portfolio = LoyaltyProgramPortfolioContract(
        programs: [
          LoyaltyProgramPresentationContract(
            id: 'a',
            businessId: 'business-review-a',
            name: 'A',
            status: LoyaltyProgramStatus.published,
            earningRules: [rule],
            rewardDefinitions: [reward],
          ),
          LoyaltyProgramPresentationContract(
            id: 'b',
            businessId: 'business-review-a',
            name: 'B',
            status: LoyaltyProgramStatus.published,
            earningRules: [rule],
            rewardDefinitions: [reward],
          ),
        ],
      );
      expect(portfolio.violatesV1SinglePublishedPolicy, isTrue);
      expect(portfolio.programs, hasLength(2));
    },
  );

  test('Blueprint V1 earning and reward catalogs are explicit contracts', () {
    expect(EarningRuleKind.values, [
      EarningRuleKind.visitStamp,
      EarningRuleKind.spendBased,
      EarningRuleKind.itemBased,
      EarningRuleKind.categoryBased,
      EarningRuleKind.completedService,
      EarningRuleKind.hybrid,
      EarningRuleKind.welcomeEvent,
    ]);
    expect(RewardDefinitionKind.values, [
      RewardDefinitionKind.freeItem,
      RewardDefinitionKind.freeServiceOrAddOn,
      RewardDefinitionKind.fixedAmountDiscount,
      RewardDefinitionKind.percentageDiscount,
      RewardDefinitionKind.itemOrCategoryDiscount,
      RewardDefinitionKind.buyXGetY,
      RewardDefinitionKind.bundleCombo,
      RewardDefinitionKind.multiMilestone,
      RewardDefinitionKind.voucher,
      RewardDefinitionKind.welcomeReward,
    ]);
    expect(
      ManualAdjustmentPolicyContract.operationallyAvailableInPhase1,
      isFalse,
    );
    expect(ManualAdjustmentPolicyContract.requiresExplicitPermission, isTrue);
    expect(ManualAdjustmentPolicyContract.requiresReason, isTrue);
    expect(ManualAdjustmentPolicyContract.requiresAuditLog, isTrue);
  });

  test('Active is derived from Published and operational time conditions', () {
    final start = DateTime.utc(2027, 1, 1);
    final end = DateTime.utc(2027, 2, 1);
    final published = LoyaltyProgramPresentationContract(
      id: 'program',
      businessId: 'business-review-a',
      name: 'Program',
      status: LoyaltyProgramStatus.published,
      earningRules: const [],
      rewardDefinitions: const [],
      startsAt: start,
      endsAt: end,
    );
    expect(
      published.isOperationallyActiveAt(DateTime.utc(2027, 1, 15)),
      isTrue,
    );
    expect(
      published.isOperationallyActiveAt(DateTime.utc(2026, 12, 31)),
      isFalse,
    );
    expect(published.isOperationallyActiveAt(end), isFalse);

    final paused = LoyaltyProgramPresentationContract(
      id: 'paused',
      businessId: 'business-review-a',
      name: 'Paused',
      status: LoyaltyProgramStatus.paused,
      earningRules: const [],
      rewardDefinitions: const [],
    );
    expect(paused.isOperationallyActiveAt(DateTime.utc(2027, 1, 15)), isFalse);
    expect(LoyaltyProgramStatus.values, [
      LoyaltyProgramStatus.draft,
      LoyaltyProgramStatus.validated,
      LoyaltyProgramStatus.published,
      LoyaltyProgramStatus.paused,
      LoyaltyProgramStatus.archived,
    ]);
  });

  test(
    'approved identity, IQD, points, refund, and expiry assumptions are explicit',
    () {
      expect(CustomerIdentityPolicyContract.uniquenessIsBusinessScoped, isTrue);
      expect(
        CustomerIdentityPolicyContract.verificationMethod,
        CustomerVerificationMethod.otp,
      );
      expect(
        CustomerIdentityPolicyContract.crossBusinessTransferAllowed,
        isFalse,
      );
      expect(PointsAndMoneyPolicyContract.currency, 'IQD');
      expect(PointsAndMoneyPolicyContract.currencyMinorUnitScale, 1);
      expect(PointsAndMoneyPolicyContract.integerPointsOnly, isTrue);
      expect(
        PointsAndMoneyPolicyContract.spendRounding,
        SpendRoundingContract.floorPerConfirmedTransaction,
      );
      expect(
        PointsAndMoneyPolicyContract.refundHandling,
        RefundLedgerContract.appendLinkedReversingEntry,
      );
      expect(PointsAndMoneyPolicyContract.pointsExpireInV1, isFalse);
    },
  );

  test('theme contracts contain no loyalty value mutation dependency', () {
    final source = [
      'lib/waflo_v2/features/card_studio/domain/visual_theme.dart',
      'lib/waflo_v2/features/card_studio/domain/campaign_event.dart',
      'lib/waflo_v2/features/card_studio/domain/theme_assignment.dart',
    ].map((path) => File(path).readAsStringSync()).join('\n');
    expect(source, isNot(contains('LoyaltyLedger')));
    expect(source, isNot(contains('RewardEntitlement')));
    expect(source, isNot(contains('Redemption')));
    expect(source, isNot(contains('mutation')));
  });
}
