import 'package:flutter/material.dart';
import 'package:tavrix_menu_mobile/waflo_v2/app/waflo_v2_app_shell.dart';
import 'package:tavrix_menu_mobile/waflo_v2/app/waflo_v2_foundation_app.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/localization/waflo_v2_strings.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/navigation/waflo_destination.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/state/waflo_view_state.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/theme/waflo_colors.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/theme/waflo_spacing.dart';
import 'package:tavrix_menu_mobile/waflo_v2/core/workspace/workspace_models.dart';
import 'package:tavrix_menu_mobile/waflo_v2/features/card_studio/domain/provider_preview.dart';
import 'package:tavrix_menu_mobile/waflo_v2/features/card_studio/presentation/card_studio_preview_screen.dart';
import 'package:tavrix_menu_mobile/waflo_v2/features/card_studio/presentation/components/provider_preview_panel.dart';
import 'package:tavrix_menu_mobile/waflo_v2/features/home/presentation/waflo_foundation_overview.dart';
import 'package:tavrix_menu_mobile/waflo_v2/shared/components/waflo_info_banner.dart';
import 'package:tavrix_menu_mobile/waflo_v2/shared/components/waflo_section_card.dart';
import 'package:tavrix_menu_mobile/waflo_v2/shared/components/waflo_state_view.dart';

import '../test_fixtures.dart';

/// Browser-only visual review target. It is never imported by the production
/// bootstrap and contains fixture data only.
enum WafloVisualReviewScenario {
  ownerArabic('owner-ar'),
  staffSorani('staff-ckb'),
  managerEnglish('manager-en'),
  stateGalleryArabic('states-ar'),
  studioArabic('studio-ar'),
  walletSorani('wallet-ckb'),
  studioEnglish('studio-en'),
  accessibilitySmallArabic('accessibility-ar'),
  providerComparisonEnglish('comparison-en');

  const WafloVisualReviewScenario(this.queryValue);

  final String queryValue;
}

void main() {
  final requested = Uri.base.queryParameters['view'];
  final scenario = WafloVisualReviewScenario.values.firstWhere(
    (candidate) => candidate.queryValue == requested,
    orElse: () => WafloVisualReviewScenario.ownerArabic,
  );
  runApp(buildVisualReviewApp(scenario));
}

Widget buildVisualReviewApp(WafloVisualReviewScenario scenario) {
  final locale = switch (scenario) {
    WafloVisualReviewScenario.staffSorani ||
    WafloVisualReviewScenario.walletSorani => const Locale('ckb'),
    WafloVisualReviewScenario.managerEnglish ||
    WafloVisualReviewScenario.studioEnglish ||
    WafloVisualReviewScenario.providerComparisonEnglish => const Locale('en'),
    _ => const Locale('ar'),
  };

  final home = switch (scenario) {
    WafloVisualReviewScenario.ownerArabic => _shell(ownerWorkspace()),
    WafloVisualReviewScenario.staffSorani => _shell(staffWorkspace()),
    WafloVisualReviewScenario.managerEnglish => _shell(
      _managerEnglishWorkspace(),
    ),
    WafloVisualReviewScenario.stateGalleryArabic => const _StateGallery(),
    WafloVisualReviewScenario.studioArabic => CardStudioPreviewScreen(
      design: reviewCardDesign(),
      providerCapabilities: reviewProviderCapabilities,
      initialStep: 1,
    ),
    WafloVisualReviewScenario.walletSorani => const _WalletGallery(),
    WafloVisualReviewScenario.studioEnglish => CardStudioPreviewScreen(
      design: reviewCardDesign(
        businessDisplayName: 'Dijla Café',
        programDisplayName: 'Visit rewards',
        joinHeadline: 'Join Visit rewards',
        joinBody: 'Collect visits and unlock your reward.',
        rewardLabel: 'Visit reward',
      ),
      providerCapabilities: reviewProviderCapabilities,
    ),
    WafloVisualReviewScenario.accessibilitySmallArabic =>
      const _SmallAccessibilityReview(),
    WafloVisualReviewScenario.providerComparisonEnglish =>
      const _ProviderComparisonGallery(),
  };

  return WafloV2FoundationApp(locale: locale, home: home);
}

class _SmallAccessibilityReview extends StatelessWidget {
  const _SmallAccessibilityReview();

  @override
  Widget build(BuildContext context) {
    final parentMedia = MediaQuery.of(context);
    return ColoredBox(
      color: WafloColors.canvas,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 360,
          height: parentMedia.size.height,
          child: MediaQuery(
            data: parentMedia.copyWith(
              size: Size(360, parentMedia.size.height),
              textScaler: const TextScaler.linear(1.6),
            ),
            child: CardStudioPreviewScreen(
              design: reviewCardDesign(),
              providerCapabilities: reviewProviderCapabilities,
              initialStep: 2,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _shell(ActiveWorkspaceContract workspace) {
  return WafloV2AppShell(
    workspace: workspace,
    destinationBuilder: (context, destination) {
      if (workspace.membership.role == WafloMembershipRole.staff &&
          destination == WafloDestination.scan) {
        return const _StaffScanReviewSurface();
      }
      if (destination == WafloDestination.home) {
        return WafloFoundationOverview(workspace: workspace);
      }
      return Padding(
        padding: const EdgeInsetsDirectional.all(WafloSpacing.screenInset),
        child: WafloStateView(
          state: const WafloViewState(kind: WafloViewStateKind.disabled),
        ),
      );
    },
  );
}

class _StaffScanReviewSurface extends StatelessWidget {
  const _StaffScanReviewSurface();

  @override
  Widget build(BuildContext context) {
    final strings = context.wafloV2;
    return ListView(
      padding: const EdgeInsetsDirectional.all(WafloSpacing.screenInset),
      children: [
        Text(strings.scan, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: WafloSpacing.x3),
        WafloSectionCard(
          child: SizedBox(
            height: 210,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, size: 48),
                  const SizedBox(height: WafloSpacing.x3),
                  Text(
                    strings.disabledTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: WafloSpacing.x1),
                  Text(
                    strings.disabledBody,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: WafloSpacing.x3),
        WafloInfoBanner(
          title: strings.manualCustomerSearch,
          body: strings.manualCustomerSearchBody,
          tone: WafloBannerTone.information,
        ),
      ],
    );
  }
}

class _StateGallery extends StatelessWidget {
  const _StateGallery();

  @override
  Widget build(BuildContext context) {
    const states = [
      WafloViewStateKind.loading,
      WafloViewStateKind.empty,
      WafloViewStateKind.error,
      WafloViewStateKind.offline,
      WafloViewStateKind.forbidden,
      WafloViewStateKind.disabled,
      WafloViewStateKind.stale,
      WafloViewStateKind.confirmed,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('حالات واجهة Waflo V2')),
      body: GridView.builder(
        padding: const EdgeInsetsDirectional.all(WafloSpacing.screenInset),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: WafloSpacing.x3,
          mainAxisSpacing: WafloSpacing.x3,
          mainAxisExtent: 285,
        ),
        itemCount: states.length,
        itemBuilder: (context, index) => WafloStateView(
          state: WafloViewState(kind: states[index]),
          compact: true,
        ),
      ),
    );
  }
}

ActiveWorkspaceContract _managerEnglishWorkspace() {
  const branches = [
    BranchSummaryContract(id: 'branch-karrada', displayName: 'Karrada branch'),
    BranchSummaryContract(id: 'branch-mansour', displayName: 'Mansour branch'),
  ];
  return ActiveWorkspaceContract(
    membership: managerMembership(),
    visibleBranches: branches,
    activeBranch: branches[1],
  );
}

class _WalletGallery extends StatelessWidget {
  const _WalletGallery();

  @override
  Widget build(BuildContext context) {
    final design = reviewCardDesign(
      businessDisplayName: 'کافێی دیجله',
      programDisplayName: 'خەڵاتی سەردان',
      joinHeadline: 'بەشداری خەڵاتی سەردان بکە',
      joinBody: 'سەردان کۆبکەرەوە و خەڵاتەکەت بەدەستبهێنە.',
      rewardLabel: 'خەڵاتی سەردان',
    );
    final localizedCapabilities = reviewProviderCapabilities
        .map(
          (capability) => ProviderPreviewCapability(
            provider: capability.provider,
            isAvailable: capability.isAvailable,
            isDeterministicPreview: capability.isDeterministicPreview,
            isRealDeviceVerified: capability.isRealDeviceVerified,
            limitations: const ['لەسەر ئامێری ڕاستەقینە پشتڕاست نەکراوەتەوە'],
          ),
        )
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: const Text('پێشبینینی Wallet')),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(WafloSpacing.screenInset),
        children: [
          const WafloInfoBanner(
            title: 'پێشبینینی ناوخۆیی تەنها',
            body:
                'ئەمە پشتڕاستکردنەوەی Apple Wallet یان Google Wallet لەسەر ئامێری ڕاستەقینە نییە.',
            tone: WafloBannerTone.warning,
          ),
          const SizedBox(height: WafloSpacing.x4),
          for (final capability in localizedCapabilities) ...[
            ProviderPreviewPanel(design: design, capability: capability),
            const SizedBox(height: WafloSpacing.x3),
          ],
        ],
      ),
    );
  }
}

class _ProviderComparisonGallery extends StatelessWidget {
  const _ProviderComparisonGallery();

  @override
  Widget build(BuildContext context) {
    final design = reviewCardDesign(
      businessDisplayName: 'Dijla Café',
      programDisplayName: 'Visit rewards',
      joinHeadline: 'Join Visit rewards',
      joinBody: 'Collect visits and unlock your reward.',
      rewardLabel: 'Visit reward',
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Waflo / Apple / Google')),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(WafloSpacing.screenInset),
        children: [
          const WafloInfoBanner(
            title: 'Preview fidelity comparison',
            body:
                'Waflo is deterministic. Apple and Google are structural platform approximations and are not real-device verification.',
            tone: WafloBannerTone.warning,
          ),
          const SizedBox(height: WafloSpacing.x4),
          for (final capability in reviewProviderCapabilities) ...[
            ProviderPreviewPanel(design: design, capability: capability),
            const SizedBox(height: WafloSpacing.x3),
          ],
        ],
      ),
    );
  }
}
