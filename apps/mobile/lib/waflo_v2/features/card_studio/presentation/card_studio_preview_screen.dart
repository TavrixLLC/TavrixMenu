import 'package:flutter/material.dart';

import '../../../core/localization/waflo_v2_strings.dart';
import '../../../core/theme/waflo_spacing.dart';
import '../../../shared/components/waflo_buttons.dart';
import '../../../shared/components/waflo_info_banner.dart';
import '../../../shared/components/waflo_section_card.dart';
import '../../../shared/components/waflo_status_chip.dart';
import '../domain/card_design.dart';
import '../domain/card_design_validator.dart';
import '../domain/provider_preview.dart';
import 'components/card_customization_summary.dart';
import 'components/card_design_preview.dart';
import 'components/color_preview_field.dart';
import 'components/join_and_poster_preview.dart';
import 'components/provider_preview_panel.dart';
import 'components/studio_step_rail.dart';

class CardStudioPreviewScreen extends StatefulWidget {
  const CardStudioPreviewScreen({
    required this.design,
    required this.providerCapabilities,
    super.key,
    this.initialStep = 0,
  }) : assert(initialStep >= 0 && initialStep < 8);

  final CardDesignDraft design;
  final List<ProviderPreviewCapability> providerCapabilities;
  final int initialStep;

  @override
  State<CardStudioPreviewScreen> createState() =>
      _CardStudioPreviewScreenState();
}

class _CardStudioPreviewScreenState extends State<CardStudioPreviewScreen> {
  final ScrollController _bodyController = ScrollController();
  late int _selectedStep;

  @override
  void initState() {
    super.initState();
    _selectedStep = widget.initialStep;
  }

  @override
  void didUpdateWidget(CardStudioPreviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStep != widget.initialStep) {
      _selectedStep = widget.initialStep;
    }
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  void _selectStep(int index) {
    if (index == _selectedStep || index < 0 || index >= 8) return;
    setState(() => _selectedStep = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_bodyController.hasClients) return;
      final reduceMotion =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (reduceMotion) {
        _bodyController.jumpTo(0);
        return;
      }
      _bodyController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.wafloV2;
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    final labels = [
      strings.brand,
      strings.colors,
      strings.earningVisual,
      strings.rewards,
      strings.joinPage,
      strings.poster,
      strings.wallet,
      strings.review,
    ];
    final validation = CardDesignValidator.validate(
      design: widget.design,
      providers: widget.providerCapabilities,
    );
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: Navigator.of(context).canPop(),
        toolbarHeight: largeText ? 112 : null,
        title: Text(
          strings.cardStudio,
          maxLines: largeText ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        controller: _bodyController,
        padding: const EdgeInsetsDirectional.all(WafloSpacing.screenInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WafloInfoBanner(
              title: strings.previewOnly,
              body: strings.cardStudioBody,
              tone: WafloBannerTone.information,
            ),
            const SizedBox(height: WafloSpacing.x4),
            StudioStepRail(
              labels: labels,
              selectedIndex: _selectedStep,
              onSelected: _selectStep,
            ),
            const SizedBox(height: WafloSpacing.x4),
            AnimatedSwitcher(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _stepContent(strings, validation),
            ),
            const SizedBox(height: WafloSpacing.x5),
            _StepActions(
              currentStep: _selectedStep,
              totalSteps: labels.length,
              previousLabel: strings.previousStep,
              nextLabel: strings.nextStep,
              onPrevious: _selectedStep > 0
                  ? () => _selectStep(_selectedStep - 1)
                  : null,
              onNext: _selectedStep < labels.length - 1
                  ? () => _selectStep(_selectedStep + 1)
                  : null,
            ),
            const SizedBox(height: WafloSpacing.x4),
          ],
        ),
      ),
    );
  }

  Widget _stepContent(
    WafloV2Strings strings,
    CardDesignValidationResult validation,
  ) {
    return switch (_selectedStep) {
      0 => CardBrandSummary(design: widget.design),
      1 => WafloSectionCard(
        key: const ValueKey('waflo-studio-section-1'),
        title: strings.colors,
        leading: Icons.color_lens_outlined,
        trailing: WafloStatusChip(
          label: validation.passesSafetyChecks
              ? strings.accessibleContrast
              : strings.inaccessibleContrast,
          tone: validation.passesSafetyChecks
              ? WafloStatusTone.success
              : WafloStatusTone.error,
          icon: validation.passesSafetyChecks
              ? Icons.check_rounded
              : Icons.warning_amber_rounded,
        ),
        child: Column(
          children: [
            ColorPreviewField(
              label: strings.primaryColor,
              color: widget.design.primaryColor,
            ),
            const SizedBox(height: WafloSpacing.x2),
            ColorPreviewField(
              label: strings.secondaryColor,
              color: widget.design.secondaryColor,
            ),
            const SizedBox(height: WafloSpacing.x2),
            ColorPreviewField(
              label: strings.accentColor,
              color: widget.design.accentColor,
            ),
            const SizedBox(height: WafloSpacing.x2),
            ColorPreviewField(
              label: strings.backgroundColor,
              color: widget.design.backgroundColor,
            ),
            const SizedBox(height: WafloSpacing.x2),
            ColorPreviewField(
              label: strings.textColor,
              color: widget.design.textColor,
            ),
          ],
        ),
      ),
      2 => CardEarningVisualSummary(design: widget.design),
      3 => CardRewardsSummary(design: widget.design),
      4 => _PreviewSection(
        key: const ValueKey('waflo-studio-section-4'),
        title: strings.joinPage,
        icon: Icons.person_add_alt_1_outlined,
        badge: strings.fieldPreviewOnly,
        child: JoinPagePreview(design: widget.design),
      ),
      5 => _PreviewSection(
        key: const ValueKey('waflo-studio-section-5'),
        title: strings.poster,
        icon: Icons.print_outlined,
        child: const QrPosterPreview(),
      ),
      6 => _WalletStep(
        key: const ValueKey('waflo-studio-section-6'),
        design: widget.design,
        capabilities: widget.providerCapabilities,
      ),
      _ => _ReviewStep(
        key: const ValueKey('waflo-studio-section-7'),
        design: widget.design,
      ),
    };
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
    required this.title,
    required this.icon,
    required this.child,
    super.key,
    this.badge,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: WafloSpacing.x2),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            if (badge != null) ...[
              const SizedBox(width: WafloSpacing.x2),
              Flexible(
                child: WafloStatusChip(
                  label: badge!,
                  tone: WafloStatusTone.information,
                  icon: Icons.lock_outline_rounded,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: WafloSpacing.x3),
        child,
      ],
    );
  }
}

class _WalletStep extends StatelessWidget {
  const _WalletStep({
    required this.design,
    required this.capabilities,
    super.key,
  });

  final CardDesignDraft design;
  final List<ProviderPreviewCapability> capabilities;

  @override
  Widget build(BuildContext context) {
    final strings = context.wafloV2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(strings.wallet, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: WafloSpacing.x3),
        for (final capability in capabilities) ...[
          ProviderPreviewPanel(design: design, capability: capability),
          const SizedBox(height: WafloSpacing.x3),
        ],
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.design, super.key});

  final CardDesignDraft design;

  @override
  Widget build(BuildContext context) {
    final strings = context.wafloV2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(strings.baseDesign, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: WafloSpacing.x2),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: WafloStatusChip(
            label: strings.exactWafloPreview,
            tone: WafloStatusTone.information,
            icon: Icons.palette_outlined,
          ),
        ),
        const SizedBox(height: WafloSpacing.x3),
        CardDesignPreview(design: design),
        const SizedBox(height: WafloSpacing.x4),
        WafloInfoBanner(
          title: strings.seasonalDeferred,
          body: strings.seasonalDeferredBody,
          tone: WafloBannerTone.warning,
        ),
        const SizedBox(height: WafloSpacing.x4),
        WafloPrimaryButton(
          label: strings.publishingDisabled,
          onPressed: null,
          disabledReason: strings.publishingDisabledBody,
        ),
      ],
    );
  }
}

class _StepActions extends StatelessWidget {
  const _StepActions({
    required this.currentStep,
    required this.totalSteps,
    required this.previousLabel,
    required this.nextLabel,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentStep;
  final int totalSteps;
  final String previousLabel;
  final String nextLabel;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (currentStep > 0)
          Expanded(
            child: WafloSecondaryButton(
              key: const ValueKey('waflo-studio-previous'),
              label: previousLabel,
              onPressed: onPrevious,
              leading: Icons.arrow_back_rounded,
            ),
          ),
        if (currentStep > 0 && currentStep < totalSteps - 1)
          const SizedBox(width: WafloSpacing.x3),
        if (currentStep < totalSteps - 1)
          Expanded(
            child: WafloPrimaryButton(
              key: const ValueKey('waflo-studio-next'),
              label: nextLabel,
              onPressed: onNext,
              leading: Icons.arrow_forward_rounded,
            ),
          ),
      ],
    );
  }
}
