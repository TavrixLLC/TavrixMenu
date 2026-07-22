import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/localization/localized_runtime_message.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../dashboard/presentation/bloc/dashboard_cubit.dart';
import '../bloc/business_setup_cubit.dart';
import '../bloc/business_setup_state.dart';

class BusinessSetupScreen extends StatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> {
  final _nameController = TextEditingController();
  String _type = 'cafe';
  String _city = _cityOptions.first;
  String _currency = 'IQD';
  String _language = 'ar';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BusinessSetupCubit, BusinessSetupState>(
      listener: (context, state) async {
        if (state.status == BusinessSetupStatus.success) {
          await context.read<AuthCubit>().refreshCurrentUser();
          if (!context.mounted) return;
          final business = state.business;
          if (business != null) {
            context.read<DashboardCubit>().primeBusiness(business);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.businessSetupSaved)),
          );
          Navigator.of(context).pushReplacementNamed(AppRouteNames.dashboard);
        }
      },
      builder: (context, state) {
        final isLoading = state.status == BusinessSetupStatus.loading;

        return Directionality(
          textDirection: Directionality.of(context),
          child: AppScaffold(
            title: context.l10n.businessSetupTitle,
            scrollable: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: context.l10n.businessSetupTitle,
                  subtitle: context.l10n.businessSetupSubtitle,
                ),
                SizedBox(height: AppSpacing.lg),
                _SetupSectionCard(
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
                          child: Text(context.l10n.restaurantTypeRestaurant),
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
                _SetupSectionCard(
                  icon: Icons.image_outlined,
                  title: context.l10n.identityAndPhotos,
                  subtitle: context.l10n.managedPhotosBody,
                ),
                SizedBox(height: AppSpacing.md),
                _SetupSectionCard(
                  icon: Icons.tune_outlined,
                  title: context.l10n.locationCurrencyLanguage,
                  subtitle: context.l10n.locationCurrencyLanguageSubtitle,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _city,
                      decoration: InputDecoration(labelText: context.l10n.city),
                      items: [
                        for (final city in _cityOptions)
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
                        DropdownMenuItem(
                          value: 'IQD',
                          child: Text(context.l10n.currencyIqd),
                        ),
                        DropdownMenuItem(
                          value: 'USD',
                          child: Text(context.l10n.currencyUsd),
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
                        DropdownMenuItem(
                          value: 'ar',
                          child: Text(context.l10n.languageArabic),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(context.l10n.languageEnglish),
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
                _SetupSectionCard(
                  icon: Icons.location_on_outlined,
                  title: context.l10n.contactAndAddress,
                  subtitle: context.l10n.contactAndAddressBody,
                ),
                if (state.status == BusinessSetupStatus.failure &&
                    state.errorMessage != null) ...[
                  SizedBox(height: AppSpacing.md),
                  ErrorView(
                    message: localizedRuntimeMessage(
                      context.l10n,
                      state.errorMessage,
                    ),
                  ),
                ],
                SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: isLoading
                      ? context.l10n.businessCreateLoading
                      : context.l10n.businessCreateAction,
                  icon: Icons.storefront,
                  onPressed: isLoading
                      ? null
                      : () => context.read<BusinessSetupCubit>().submit(
                          name: _nameController.text,
                          type: _type,
                          city: _city,
                          currency: _currency,
                          language: _language,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

class _SetupSectionCard extends StatelessWidget {
  const _SetupSectionCard({
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
