import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/app_locale_controller.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/theme/v3/waflo_v3_tokens.dart';

class AppLanguagePicker extends StatelessWidget {
  const AppLanguagePicker({super.key, this.showHelp = true});

  final bool showHelp;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppLocaleController?>();
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return BlocBuilder<AppLocaleController, AppLocaleState>(
      bloc: controller,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.appLanguage,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (showHelp) ...[
              const SizedBox(height: WafloV3Spacing.space4),
              Text(
                context.l10n.appLanguageHelp,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: WafloV3Spacing.space12),
            ...AppLocale.values.map(
              (locale) => Padding(
                padding: const EdgeInsetsDirectional.only(
                  bottom: WafloV3Spacing.space8,
                ),
                child: _LanguageChoice(
                  locale: locale,
                  selected: state.locale == locale,
                  enabled: !state.isSaving,
                  onSelected: () =>
                      context.read<AppLocaleController>().select(locale),
                ),
              ),
            ),
            if (state.persistenceFailed)
              Text(
                context.l10n.languageSaveFailed,
                key: const ValueKey('app-language-persistence-error'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: WafloV3Colors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LanguageChoice extends StatelessWidget {
  const _LanguageChoice({
    required this.locale,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final AppLocale locale;
  final bool selected;
  final bool enabled;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: locale.nativeName,
      child: Material(
        color: selected
            ? WafloV3Colors.primary.withValues(alpha: 0.08)
            : WafloV3Colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WafloV3Radius.standardCard),
          side: BorderSide(
            color: selected
                ? WafloV3Colors.primary
                : WafloV3Colors.primaryText.withValues(alpha: 0.12),
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: enabled ? onSelected : null,
          borderRadius: BorderRadius.circular(WafloV3Radius.standardCard),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: WafloV3Spacing.minimumTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: WafloV3Spacing.space16,
                vertical: WafloV3Spacing.space12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      locale.nativeName,
                      textDirection: locale.textDirection,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: WafloV3Spacing.space8),
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected
                        ? WafloV3Colors.primary
                        : WafloV3Colors.primaryText.withValues(alpha: 0.45),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
