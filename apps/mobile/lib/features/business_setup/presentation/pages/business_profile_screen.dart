import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/localization/localized_runtime_message.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../../dashboard/presentation/bloc/dashboard_state.dart';
import '../../../localization/presentation/widgets/app_language_picker.dart';
import '../../domain/entities/business.dart';
import '../bloc/business_setup_cubit.dart';
import '../bloc/business_setup_state.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({
    super.key,
    this.embeddedInWorkspaceShell = false,
  });

  final bool embeddedInWorkspaceShell;

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _nameController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _coverUrlController = TextEditingController();
  String _type = 'cafe';
  String _city = _cityOptions.first;
  String _currency = 'IQD';
  String _language = 'ar';
  bool _hydrated = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<DashboardCubit>();
      if (cubit.state.status == DashboardStatus.initial) {
        cubit.load();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) {
      return;
    }

    final business = context.read<DashboardCubit>().state.business;
    if (business != null) {
      _hydrate(business);
    }
  }

  void _hydrate(Business business) {
    if (_hydrated) {
      return;
    }

    _nameController.text = business.name;
    _city = _normalizedSelectorValue(business.city, _cityOptions);
    _currency = _normalizedSelectorValue(business.currency, _currencyOptions);
    _language = _normalizedSelectorValue(business.language, _languageOptions);
    _logoUrlController.text = business.logoUrl ?? '';
    _coverUrlController.text = business.coverUrl ?? '';
    _type = const ['cafe', 'restaurant', 'shop'].contains(business.type)
        ? business.type
        : 'cafe';
    _hydrated = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _logoUrlController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: BlocConsumer<BusinessSetupCubit, BusinessSetupState>(
        listener: (context, setupState) async {
          if (!_submitted) {
            return;
          }

          if (setupState.status == BusinessSetupStatus.failure) {
            setState(() => _submitted = false);
            return;
          }

          if (setupState.status != BusinessSetupStatus.success) {
            return;
          }

          final business = setupState.business;
          if (business != null) {
            context.read<DashboardCubit>().primeBusiness(business);
            await context.read<AuthCubit>().refreshCurrentUser();
            if (context.mounted) {
              await context.read<DashboardCubit>().load();
            }
          }

          if (!context.mounted) {
            return;
          }

          setState(() => _submitted = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.businessProfileSaved)),
          );
          Navigator.of(context).pop();
        },
        builder: (context, setupState) {
          return BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, dashboardState) {
              if (dashboardState.status == DashboardStatus.initial ||
                  dashboardState.status == DashboardStatus.loading) {
                return AppScaffold(
                  title: context.l10n.businessProfileTitle,
                  embeddedInWorkspaceShell: widget.embeddedInWorkspaceShell,
                  child: LoadingView(
                    message: context.l10n.businessProfileLoading,
                  ),
                );
              }

              final business = dashboardState.business;
              if (business == null) {
                return AppScaffold(
                  title: context.l10n.businessProfileTitle,
                  embeddedInWorkspaceShell: widget.embeddedInWorkspaceShell,
                  child: EmptyState(
                    title: context.l10n.businessProfileMissingTitle,
                    message: context.l10n.businessProfileMissingBody,
                    icon: Icons.storefront,
                  ),
                );
              }

              _hydrate(business);

              final canManageBusiness =
                  dashboardState.permissions?.canManageBusiness ??
                  (dashboardState.effectiveRole == 'OWNER');
              if (!canManageBusiness) {
                return AppScaffold(
                  title: context.l10n.businessProfileTitle,
                  embeddedInWorkspaceShell: widget.embeddedInWorkspaceShell,
                  scrollable: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _AppLanguageSection(),
                      const SizedBox(height: AppSpacing.md),
                      EmptyState(
                        title: context.l10n.businessProfileRestrictedTitle,
                        message: context.l10n.businessProfileRestrictedBody,
                        icon: Icons.lock_outline,
                      ),
                    ],
                  ),
                );
              }

              final isLoading =
                  setupState.status == BusinessSetupStatus.loading &&
                  _submitted;

              return AppScaffold(
                title: context.l10n.businessProfileTitle,
                embeddedInWorkspaceShell: widget.embeddedInWorkspaceShell,
                scrollable: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _AppLanguageSection(),
                    const SizedBox(height: AppSpacing.lg),
                    SectionHeader(
                      title: context.l10n.businessProfileEditTitle,
                      subtitle: context.l10n.businessProfileEditSubtitle,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    _ProfileSectionCard(
                      icon: Icons.storefront_outlined,
                      title: context.l10n.restaurantInfo,
                      subtitle: context.l10n.restaurantInfoSubtitle,
                      children: [
                        AppTextField(
                          label: context.l10n.restaurantName,
                          controller: _nameController,
                          hint: context.l10n.restaurantNameHint,
                        ),
                        SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String>(
                          initialValue: _type,
                          decoration: InputDecoration(
                            labelText: context.l10n.restaurantType,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'cafe',
                              child: Text(context.l10n.restaurantTypeCafe),
                            ),
                            DropdownMenuItem(
                              value: 'restaurant',
                              child: Text(
                                context.l10n.restaurantTypeRestaurant,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'shop',
                              child: Text(context.l10n.restaurantTypeShop),
                            ),
                          ],
                          onChanged: isLoading
                              ? null
                              : (value) => setState(() {
                                  _type = value ?? 'cafe';
                                }),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    _ProfileSectionCard(
                      icon: Icons.tune_outlined,
                      title: context.l10n.locationCurrencyLanguage,
                      subtitle: context.l10n.locationCurrencyLanguageSubtitle,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _city,
                          decoration: InputDecoration(
                            labelText: context.l10n.city,
                          ),
                          items: [
                            for (final city in _selectorOptions(
                              _city,
                              _cityOptions,
                            ))
                              DropdownMenuItem(value: city, child: Text(city)),
                          ],
                          onChanged: isLoading
                              ? null
                              : (value) => setState(() {
                                  _city = value ?? _cityOptions.first;
                                }),
                        ),
                        SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String>(
                          initialValue: _currency,
                          decoration: InputDecoration(
                            labelText: context.l10n.currency,
                          ),
                          items: [
                            for (final currency in _selectorOptions(
                              _currency,
                              _currencyOptions,
                            ))
                              DropdownMenuItem(
                                value: currency,
                                child: Text(_currencyLabel(context, currency)),
                              ),
                          ],
                          onChanged: isLoading
                              ? null
                              : (value) => setState(() {
                                  _currency = value ?? 'IQD';
                                }),
                        ),
                        SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String>(
                          initialValue: _language,
                          decoration: InputDecoration(
                            labelText: context.l10n.menuLanguage,
                          ),
                          items: [
                            for (final language in _selectorOptions(
                              _language,
                              _languageOptions,
                            ))
                              DropdownMenuItem(
                                value: language,
                                child: Text(_languageLabel(context, language)),
                              ),
                          ],
                          onChanged: isLoading
                              ? null
                              : (value) => setState(() {
                                  _language = value ?? 'ar';
                                }),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    _ProfileSectionCard(
                      icon: Icons.image_outlined,
                      title: context.l10n.identityAndPhotos,
                      subtitle: context.l10n.managedPhotosBody,
                      children: [
                        AppTextField(
                          label: context.l10n.optionalLogoLink,
                          hint: context.l10n.optionalImageLinkHint,
                          controller: _logoUrlController,
                          keyboardType: TextInputType.url,
                        ),
                        SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: context.l10n.optionalCoverLink,
                          hint: context.l10n.optionalImageLinkHint,
                          controller: _coverUrlController,
                          keyboardType: TextInputType.url,
                        ),
                      ],
                    ),
                    if (setupState.status == BusinessSetupStatus.failure &&
                        setupState.errorMessage != null &&
                        _submitted) ...[
                      SizedBox(height: AppSpacing.md),
                      ErrorView(
                        message: localizedRuntimeMessage(
                          context.l10n,
                          setupState.errorMessage,
                        ),
                      ),
                    ],
                    SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: isLoading
                          ? context.l10n.savingChanges
                          : context.l10n.saveChanges,
                      icon: Icons.save_outlined,
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() => _submitted = true);
                              context.read<BusinessSetupCubit>().update(
                                id: business.id,
                                name: _nameController.text,
                                type: _type,
                                city: _city,
                                currency: _currency,
                                language: _language,
                                logoUrl: _logoUrlController.text,
                                coverUrl: _coverUrlController.text,
                              );
                            },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AppLanguageSection extends StatelessWidget {
  const _AppLanguageSection();

  @override
  Widget build(BuildContext context) {
    return AppCard(child: const AppLanguagePicker());
  }
}

const _cityOptions = [
  'الموصل',
  'أربيل',
  'دهوك',
  'بغداد',
  'السليمانية',
  'كركوك',
  'البصرة',
  'أخرى',
];

const _currencyOptions = ['IQD', 'USD'];
const _languageOptions = ['ar', 'en'];

String _normalizedSelectorValue(String? value, List<String> defaults) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return defaults.first;
  }
  return trimmed;
}

List<String> _selectorOptions(String current, List<String> defaults) {
  if (defaults.contains(current)) {
    return defaults;
  }
  return [...defaults, current];
}

String _currencyLabel(BuildContext context, String value) {
  return switch (value) {
    'IQD' => context.l10n.currencyIqd,
    'USD' => context.l10n.currencyUsd,
    _ => value,
  };
}

String _languageLabel(BuildContext context, String value) {
  return switch (value) {
    'ar' => context.l10n.languageArabic,
    'en' => context.l10n.languageEnglish,
    _ => value,
  };
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.children = const [],
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(subtitle),
                  ],
                ),
              ),
            ],
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ...children,
          ],
        ],
      ),
    );
  }
}
