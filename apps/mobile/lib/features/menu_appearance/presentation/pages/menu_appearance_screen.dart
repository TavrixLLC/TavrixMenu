import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/copy/pilot_arabic_copy.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/waflo_button.dart';
import '../../../../shared/widgets/waflo_card.dart';
import '../../../../shared/widgets/waflo_status_badge.dart';
import '../../../business_setup/domain/entities/business.dart';
import '../../domain/entities/menu_template.dart';
import '../bloc/menu_appearance_cubit.dart';
import '../bloc/menu_appearance_state.dart';
import '../utils/menu_template_preview_url.dart';

class MenuAppearanceScreen extends StatefulWidget {
  const MenuAppearanceScreen({required this.customerWebBaseUrl, super.key});

  final String customerWebBaseUrl;

  @override
  State<MenuAppearanceScreen> createState() => _MenuAppearanceScreenState();
}

class _MenuAppearanceScreenState extends State<MenuAppearanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<MenuAppearanceCubit>();
      if (cubit.state.status == MenuAppearanceStatus.initial) {
        cubit.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppScaffold(
        title: PilotArabicCopy.menuAppearanceTitle,
        scrollable: true,
        child: BlocConsumer<MenuAppearanceCubit, MenuAppearanceState>(
          listener: (context, state) {
            final successMessage = state.successMessage;
            if (successMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(successMessage)));
            }
          },
          builder: (context, state) {
            if (state.status == MenuAppearanceStatus.initial ||
                state.status == MenuAppearanceStatus.loading) {
              return const LoadingView(
                message: PilotArabicCopy.menuAppearanceLoading,
              );
            }

            if (state.status == MenuAppearanceStatus.failure) {
              return ErrorView(
                message:
                    state.errorMessage ??
                    PilotArabicCopy.menuAppearanceLoadFailed,
                onRetry: () => context.read<MenuAppearanceCubit>().load(),
              );
            }

            if (!state.hasTemplates) {
              return ErrorView(
                message: PilotArabicCopy.menuAppearanceEmpty,
                onRetry: () => context.read<MenuAppearanceCubit>().load(),
              );
            }

            final business = state.business;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: PilotArabicCopy.publicMenuDesign,
                  subtitle: business == null
                      ? PilotArabicCopy.publicMenuDesignSubtitle
                      : '${PilotArabicCopy.publicMenuDesignSubtitle} (${business.name})',
                ),
                const SizedBox(height: AppSpacing.md),
                _PreviewNotice(business: business),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _InlineNotice(
                    icon: Icons.warning_amber_outlined,
                    color: AppColors.dangerTint,
                    foregroundColor: AppColors.dangerRed,
                    message: state.errorMessage!,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                for (final template in state.templates) ...[
                  Builder(
                    builder: (context) {
                      final canPreview =
                          buildMenuTemplatePreviewUri(
                            business: business,
                            templateId: template.id,
                            customerWebBaseUrl: widget.customerWebBaseUrl,
                          ) !=
                          null;
                      return _TemplateCard(
                        template: template,
                        isCurrent: template.id == state.currentTemplateId,
                        isDraft: template.id == state.draftTemplateId,
                        isSaving: state.isSaving,
                        canPreview: canPreview,
                        onSelect: () => context
                            .read<MenuAppearanceCubit>()
                            .selectTemplate(template.id),
                        onPreview: () =>
                            _openPreview(context, business, template),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                const SizedBox(height: AppSpacing.sm),
                WafloButton(
                  label: state.isSaving
                      ? PilotArabicCopy.savingTemplate
                      : PilotArabicCopy.saveTemplate,
                  icon: Icons.check_circle_outline,
                  isLoading: state.isSaving,
                  onPressed: state.canSave
                      ? () => context.read<MenuAppearanceCubit>().save()
                      : null,
                ),
                if (state.saveForbidden || !state.canManageAppearance) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    PilotArabicCopy.menuAppearancePermission,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openPreview(
    BuildContext context,
    Business? business,
    MenuTemplate template,
  ) async {
    final uri = buildMenuTemplatePreviewUri(
      business: business,
      templateId: template.id,
      customerWebBaseUrl: widget.customerWebBaseUrl,
    );
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(unavailablePreviewMessage)));
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted || launched) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(PilotArabicCopy.previewCouldNotOpen)),
    );
  }
}

class _PreviewNotice extends StatelessWidget {
  const _PreviewNotice({required this.business});

  final Business? business;

  @override
  Widget build(BuildContext context) {
    return WafloCard(
      color: AppColors.warmCream,
      borderColor: AppColors.softBorder,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.palette_outlined, color: AppColors.primaryCoral),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              business == null
                  ? PilotArabicCopy.previewDraftMenu
                  : '${PilotArabicCopy.previewDraftMenu} (${business!.name})',
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.isCurrent,
    required this.isDraft,
    required this.isSaving,
    required this.canPreview,
    required this.onSelect,
    required this.onPreview,
  });

  final MenuTemplate template;
  final bool isCurrent;
  final bool isDraft;
  final bool isSaving;
  final bool canPreview;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final merchantCopy = _merchantTemplateCopy(template);
    final bestForLabels = merchantCopy.bestFor.take(3).toList(growable: false);

    return WafloCard(
      onTap: isSaving ? null : onSelect,
      elevated: isDraft,
      accentColor: isDraft ? AppColors.primaryCoral : null,
      borderColor: isDraft ? AppColors.primaryCoral : AppColors.softBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchantCopy.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      merchantCopy.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (isCurrent)
                const WafloStatusBadge(
                  label: PilotArabicCopy.currentTemplate,
                  icon: Icons.check,
                  color: AppColors.greenTint,
                  foregroundColor: AppColors.freshGreenDark,
                )
              else if (isDraft)
                const WafloStatusBadge(
                  label: PilotArabicCopy.selectedTemplate,
                  icon: Icons.edit_outlined,
                  color: AppColors.coralTint,
                  foregroundColor: AppColors.primaryCoralDark,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _TemplatePreview(
            template: template,
            layoutLabel: merchantCopy.layoutLabel,
          ),
          if (bestForLabels.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final label in bestForLabels)
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth,
                        ),
                        child: _TemplateTraitChip(label: label),
                      ),
                  ],
                );
              },
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: WafloButton(
                  label: PilotArabicCopy.previewAction,
                  icon: Icons.open_in_new,
                  variant: WafloButtonVariant.secondary,
                  onPressed: canPreview ? onPreview : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: WafloButton(
                  label: isDraft
                      ? PilotArabicCopy.selectedTemplate
                      : PilotArabicCopy.selectTemplate,
                  icon: isDraft
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  variant: isDraft
                      ? WafloButtonVariant.success
                      : WafloButtonVariant.ghost,
                  onPressed: isSaving || isDraft ? null : onSelect,
                ),
              ),
            ],
          ),
          if (!canPreview) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              unavailablePreviewMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
          ],
        ],
      ),
    );
  }
}

class _TemplateTraitChip extends StatelessWidget {
  const _TemplateTraitChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.textDark.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          softWrap: true,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _TemplatePreview extends StatelessWidget {
  const _TemplatePreview({required this.template, required this.layoutLabel});

  final MenuTemplate template;
  final String? layoutLabel;

  @override
  Widget build(BuildContext context) {
    final colors = template.previewColors.isEmpty
        ? const ['#FF6B4A', '#FFF8F2', '#43A047']
        : template.previewColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.neutralCanvas,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (final color in colors.take(5)) ...[
                  _Swatch(color: _hexColor(color)),
                  const SizedBox(width: AppSpacing.xs),
                ],
              ],
            ),
            if (layoutLabel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                layoutLabel!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: const SizedBox.square(dimension: 28),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({
    required this.icon,
    required this.color,
    required this.foregroundColor,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final Color foregroundColor;
  final String message;

  @override
  Widget build(BuildContext context) {
    return WafloCard(
      color: color,
      borderColor: foregroundColor.withValues(alpha: 0.16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foregroundColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _MerchantTemplateCopy {
  const _MerchantTemplateCopy({
    required this.title,
    required this.description,
    required this.bestFor,
    this.layoutLabel,
  });

  final String title;
  final String description;
  final List<String> bestFor;
  final String? layoutLabel;
}

const _defaultMerchantTemplateCopy = _MerchantTemplateCopy(
  title: 'شكل منيو جاهز',
  description: 'تصميم واضح يساعد الزبائن يشوفون الأقسام والمنتجات بسهولة.',
  bestFor: ['مطاعم', 'كافيهات', 'منيو واضح'],
  layoutLabel: 'عرض واضح للزبائن',
);

const _merchantTemplateCopyById = <String, _MerchantTemplateCopy>{
  'waflo-warm': _MerchantTemplateCopy(
    title: 'دافئ ومريح',
    description: 'ألوان دافئة تناسب أغلب المطاعم والكافيهات.',
    bestFor: ['مطاعم عامة', 'كافيهات', 'مخابز'],
    layoutLabel: 'بطاقات دافئة',
  ),
  'coffeehouse-premium': _MerchantTemplateCopy(
    title: 'كافيه أنيق',
    description: 'ألوان هادئة مناسبة للقهوة والحلويات.',
    bestFor: ['قهوة مختصة', 'حلويات', 'مخابز'],
    layoutLabel: 'واجهة كافيه',
  ),
  'street-bites': _MerchantTemplateCopy(
    title: 'أكل سريع وحيوي',
    description: 'ألوان قوية تناسب البركر والشاورما والطلبات السريعة.',
    bestFor: ['بركر', 'شاورما', 'طلبات سريعة'],
    layoutLabel: 'واجهة سريعة',
  ),
  'minimal-modern': _MerchantTemplateCopy(
    title: 'بسيط وحديث',
    description: 'مساحات بيضاء ولمسات هادئة لمنيو واضح.',
    bestFor: ['مطاعم هادئة', 'كافيهات حديثة', 'منيو بسيط'],
    layoutLabel: 'قائمة بسيطة',
  ),
  'luxury-dining': _MerchantTemplateCopy(
    title: 'مطعم راقٍ',
    description: 'طابع داكن وأنيق لمطاعم الجلسات الهادئة.',
    bestFor: ['مطاعم راقية', 'فنادق', 'جلسات هادئة'],
    layoutLabel: 'بطاقات أنيقة',
  ),
  'artisan-cafe': _MerchantTemplateCopy(
    title: 'كافيه حرفي',
    description: 'ألوان كريمية وصور بارزة للكافيهات والمخابز.',
    bestFor: ['قهوة مختصة', 'مخابز', 'فطور'],
    layoutLabel: 'بطاقات بالصور',
  ),
  'quick-serve-bold': _MerchantTemplateCopy(
    title: 'خدمة سريعة',
    description: 'تصميم واضح وسريع القراءة للمنيو المختصر.',
    bestFor: ['وجبات سريعة', 'شاورما', 'حلويات'],
    layoutLabel: 'صفوف مختصرة',
  ),
};

_MerchantTemplateCopy _merchantTemplateCopy(MenuTemplate template) {
  final knownCopy = _merchantTemplateCopyById[template.id.trim().toLowerCase()];
  if (knownCopy != null) {
    return knownCopy;
  }

  final title = _safeTemplateTitle(template.displayName);
  final description = _safeTemplateDescription(template.description);
  final bestFor = _safeBestForLabels(template.bestFor);
  final layoutLabel = _safeTemplateLayoutLabel(template.layoutLabel);

  return _MerchantTemplateCopy(
    title: title,
    description: description,
    bestFor: bestFor,
    layoutLabel: layoutLabel,
  );
}

String _safeTemplateTitle(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || _containsInternalTemplateTerm(trimmed)) {
    return _defaultMerchantTemplateCopy.title;
  }
  return trimmed;
}

String _safeTemplateDescription(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || _containsInternalTemplateTerm(trimmed)) {
    return _defaultMerchantTemplateCopy.description;
  }
  return trimmed;
}

List<String> _safeBestForLabels(List<String> values) {
  final labels = _bestForLabels(values)
      .where((label) => !_containsInternalTemplateTerm(label))
      .take(3)
      .toList(growable: false);
  return labels.isEmpty ? _defaultMerchantTemplateCopy.bestFor : labels;
}

String? _safeTemplateLayoutLabel(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return _defaultMerchantTemplateCopy.layoutLabel;
  }
  if (_containsInternalTemplateTerm(trimmed)) {
    return _defaultMerchantTemplateCopy.layoutLabel;
  }
  return trimmed;
}

bool _containsInternalTemplateTerm(String value) {
  final normalized = value.toLowerCase();
  return normalized.contains('api_base_url') ||
      normalized.contains('app_env') ||
      normalized.contains('billing') ||
      normalized.contains('clerk_publishable_key') ||
      normalized.contains('css') ||
      normalized.contains('dev auth') ||
      normalized.contains('enable_dev_auth') ||
      normalized.contains('google sign-in') ||
      normalized.contains('localhost') ||
      normalized.contains('premium') ||
      normalized.contains('previewtemplateid') ||
      normalized.contains('subscription') ||
      normalized.contains('/dev/') ||
      RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)+$').hasMatch(normalized);
}

Iterable<String> _bestForLabels(Iterable<String> values) sync* {
  for (final value in values) {
    final labels = value
        .split(RegExp(r'[,،]'))
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty);
    yield* labels;
  }
}

Color _hexColor(String value) {
  final clean = value.trim().replaceFirst('#', '');
  if (clean.length != 6) {
    return AppColors.primaryCoral;
  }
  final parsed = int.tryParse(clean, radix: 16);
  if (parsed == null) {
    return AppColors.primaryCoral;
  }
  return Color(0xFF000000 | parsed);
}
