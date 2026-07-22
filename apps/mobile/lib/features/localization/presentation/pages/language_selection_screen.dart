import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/app_locale_controller.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/theme/v3/waflo_v3_tokens.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  AppLocale? _selectedLocale;

  @override
  Widget build(BuildContext context) {
    final localeState = context.watch<AppLocaleController>().state;
    final deviceLocale = View.of(context).platformDispatcher.locale;
    final suggestion = AppLocale.suggestedFromDevice(deviceLocale);

    return Scaffold(
      backgroundColor: WafloV3Colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(WafloV3Spacing.standardPageMargin),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: WafloV3Colors.surface,
                  borderRadius: BorderRadius.circular(WafloV3Radius.largeCard),
                  border: Border.all(
                    color: WafloV3Colors.primaryText.withValues(alpha: 0.08),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(WafloV3Spacing.space24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Waflo',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: WafloV3Colors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: WafloV3Spacing.space20),
                      Text(
                        context.l10n.languageSelectionTitle,
                        key: const ValueKey('language-selection-title'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: WafloV3Spacing.space8),
                      Text(
                        context.l10n.languageSelectionBody,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: WafloV3Spacing.space24),
                      ...AppLocale.values.map(
                        (locale) => Padding(
                          padding: const EdgeInsetsDirectional.only(
                            bottom: WafloV3Spacing.space12,
                          ),
                          child: _FirstLaunchLanguageChoice(
                            locale: locale,
                            isSelected: _selectedLocale == locale,
                            isSuggested:
                                suggestion == locale &&
                                _selectedLocale != locale,
                            onPressed: () =>
                                setState(() => _selectedLocale = locale),
                          ),
                        ),
                      ),
                      if (localeState.persistenceFailed) ...[
                        Text(
                          context.l10n.languageSaveFailed,
                          key: const ValueKey(
                            'language-selection-persistence-error',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: WafloV3Colors.error,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: WafloV3Spacing.space12),
                      ],
                      FilledButton(
                        key: const ValueKey('language-selection-continue'),
                        onPressed:
                            _selectedLocale == null || localeState.isSaving
                            ? null
                            : () => context.read<AppLocaleController>().select(
                                _selectedLocale!,
                              ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(
                            WafloV3Spacing.minimumTouchTarget,
                          ),
                          backgroundColor: WafloV3Colors.primary,
                        ),
                        child: localeState.isSaving
                            ? const SizedBox.square(
                                dimension: WafloV3Spacing.space20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: WafloV3Colors.surface,
                                ),
                              )
                            : Text(context.l10n.languageContinue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FirstLaunchLanguageChoice extends StatelessWidget {
  const _FirstLaunchLanguageChoice({
    required this.locale,
    required this.isSelected,
    required this.isSuggested,
    required this.onPressed,
  });

  final AppLocale locale;
  final bool isSelected;
  final bool isSuggested;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: locale.nativeName,
      child: Material(
        color: isSelected
            ? WafloV3Colors.primary.withValues(alpha: 0.08)
            : WafloV3Colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WafloV3Radius.standardCard),
          side: BorderSide(
            color: isSelected
                ? WafloV3Colors.primary
                : WafloV3Colors.primaryText.withValues(alpha: 0.14),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(WafloV3Radius.standardCard),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (isSuggested) ...[
                    Text(
                      context.l10n.languageSuggested,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: WafloV3Colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: WafloV3Spacing.space8),
                  ],
                  Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? WafloV3Colors.primary
                        : WafloV3Colors.primaryText.withValues(alpha: 0.4),
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
