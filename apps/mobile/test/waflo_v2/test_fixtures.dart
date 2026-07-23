import 'package:flutter/material.dart';
import 'package:tavrix_menu_mobile/waflo_v2/app/waflo_v2_foundation_app.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/workspace/workspace_models.dart';
import 'package:tavrix_menu_mobile/waflo_v2/features/card_studio/domain/card_design.dart';
import 'package:tavrix_menu_mobile/waflo_v2/features/card_studio/domain/provider_preview.dart';

WorkspaceMembershipContract ownerMembership() {
  return WorkspaceMembershipContract(
    businessId: 'business-review-a',
    businessDisplayName: 'مقهى دجلة',
    role: WafloMembershipRole.owner,
    branchAccess: const BranchAccessScope.all(),
    capabilities: WafloCapability.values.toSet(),
  );
}

WorkspaceMembershipContract managerMembership() {
  return WorkspaceMembershipContract(
    businessId: 'business-review-a',
    businessDisplayName: 'Dijla Café',
    role: WafloMembershipRole.manager,
    branchAccess: BranchAccessScope.selected([
      'branch-karrada',
      'branch-mansour',
    ]),
    capabilities: WafloCapability.values.toSet(),
  );
}

WorkspaceMembershipContract staffMembership() {
  return WorkspaceMembershipContract(
    businessId: 'business-review-a',
    businessDisplayName: 'کافێی دیجله',
    role: WafloMembershipRole.staff,
    branchAccess: BranchAccessScope.selected(['branch-karrada']),
    capabilities: const {
      WafloCapability.useScanner,
      WafloCapability.viewRewards,
      WafloCapability.viewOwnActivity,
      WafloCapability.viewAccount,
    },
  );
}

const reviewBranches = <BranchSummaryContract>[
  BranchSummaryContract(id: 'branch-karrada', displayName: 'فرع الكرادة'),
  BranchSummaryContract(id: 'branch-mansour', displayName: 'فرع المنصور'),
  BranchSummaryContract(id: 'branch-basra', displayName: 'فرع البصرة'),
];

ActiveWorkspaceContract ownerWorkspace() {
  return ActiveWorkspaceContract(
    membership: ownerMembership(),
    visibleBranches: reviewBranches,
    activeBranch: reviewBranches[0],
  );
}

ActiveWorkspaceContract managerWorkspace() {
  return ActiveWorkspaceContract(
    membership: managerMembership(),
    visibleBranches: reviewBranches.take(2).toList(growable: false),
    activeBranch: reviewBranches[1],
  );
}

ActiveWorkspaceContract staffWorkspace() {
  return ActiveWorkspaceContract(
    membership: staffMembership(),
    visibleBranches: [reviewBranches[0]],
    activeBranch: reviewBranches[0],
  );
}

CardDesignDraft reviewCardDesign({
  String businessDisplayName = 'مقهى دجلة',
  String programDisplayName = 'مكافآت الزيارة',
  String joinHeadline = 'انضم إلى مكافآت الزيارة',
  String joinBody = 'اجمع زياراتك واستبدل مكافأتك.',
  String rewardLabel = 'مكافأة الزيارة',
}) {
  return CardDesignDraft(
    id: 'design-review-1',
    businessId: 'business-review-a',
    programId: 'program-review-a',
    revision: 1,
    status: CardDesignStatus.draft,
    businessDisplayName: businessDisplayName,
    programDisplayName: programDisplayName,
    primaryColor: HexColorValue('#AE3115'),
    secondaryColor: HexColorValue('#7D2311'),
    accentColor: HexColorValue('#FF6B4A'),
    backgroundColor: HexColorValue('#F7F9FF'),
    textColor: HexColorValue('#241916'),
    cardShape: CardVisualShape.softRectangle,
    stampShape: StampVisualShape.roundedSquare,
    stampIcon: CardVisualIcon.coffee,
    rewardIcon: CardVisualIcon.gift,
    copy: CardDesignCopy(
      joinHeadline: joinHeadline,
      joinBody: joinBody,
      rewardLabel: rewardLabel,
    ),
    logo: const CardMediaReference(state: CardMediaState.empty),
    cover: const CardMediaReference(state: CardMediaState.empty),
    rewardMedia: const CardMediaReference(state: CardMediaState.empty),
  );
}

const reviewProviderCapabilities = <ProviderPreviewCapability>[
  ProviderPreviewCapability(
    provider: CardPreviewProvider.web,
    isAvailable: true,
    isDeterministicPreview: true,
    isRealDeviceVerified: false,
    limitations: ['Review fixture only'],
  ),
  ProviderPreviewCapability(
    provider: CardPreviewProvider.appleWallet,
    isAvailable: true,
    isDeterministicPreview: false,
    isRealDeviceVerified: false,
    limitations: ['Provider rendering may differ'],
  ),
  ProviderPreviewCapability(
    provider: CardPreviewProvider.googleWallet,
    isAvailable: true,
    isDeterministicPreview: false,
    isRealDeviceVerified: false,
    limitations: ['Provider rendering may differ'],
  ),
];

Widget foundationHarness({
  required Widget home,
  Locale locale = const Locale('ar'),
}) {
  return WafloV2FoundationApp(locale: locale, home: home);
}
