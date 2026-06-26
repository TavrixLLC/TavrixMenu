import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
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
    return AppScaffold(
      title: 'Menu Appearance',
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
            return const LoadingView(message: 'Loading menu templates');
          }

          if (state.status == MenuAppearanceStatus.failure) {
            return ErrorView(
              message:
                  state.errorMessage ?? 'Menu appearance could not be loaded.',
              onRetry: () => context.read<MenuAppearanceCubit>().load(),
            );
          }

          if (!state.hasTemplates) {
            return ErrorView(
              message:
                  'No public menu templates are available yet. Try again later.',
              onRetry: () => context.read<MenuAppearanceCubit>().load(),
            );
          }

          final business = state.business;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Public menu design',
                subtitle: business == null
                    ? 'Choose how customers see your QR menu.'
                    : 'Choose how customers see ${business.name}.',
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
                label: state.isSaving ? 'Saving template' : 'Save template',
                icon: Icons.check_circle_outline,
                isLoading: state.isSaving,
                onPressed: state.canSave
                    ? () => context.read<MenuAppearanceCubit>().save()
                    : null,
              ),
              if (state.saveForbidden || !state.canManageAppearance) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your workspace permissions do not allow menu design changes.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
                ),
              ],
            ],
          );
        },
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
      const SnackBar(content: Text('Preview could not be opened.')),
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
                  ? 'Preview opens the public QR menu with a draft template. It does not save changes.'
                  : 'Preview opens ${business!.name}\'s public menu with this design without saving changes.',
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
                      template.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(template.description),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (isCurrent)
                const WafloStatusBadge(
                  label: 'Current',
                  icon: Icons.check,
                  color: AppColors.greenTint,
                  foregroundColor: AppColors.freshGreenDark,
                )
              else if (isDraft)
                const WafloStatusBadge(
                  label: 'Selected',
                  icon: Icons.edit_outlined,
                  color: AppColors.coralTint,
                  foregroundColor: AppColors.primaryCoralDark,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _TemplatePreview(template: template),
          if (template.bestFor.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final label in template.bestFor.take(3))
                  WafloStatusBadge(
                    label: label,
                    color: AppColors.surfaceWhite,
                    foregroundColor: AppColors.textDark,
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: WafloButton(
                  label: 'Preview',
                  icon: Icons.open_in_new,
                  variant: WafloButtonVariant.secondary,
                  onPressed: canPreview ? onPreview : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: WafloButton(
                  label: isDraft ? 'Selected' : 'Select',
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

class _TemplatePreview extends StatelessWidget {
  const _TemplatePreview({required this.template});

  final MenuTemplate template;

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
            if (template.layoutLabel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                template.layoutLabel!,
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
