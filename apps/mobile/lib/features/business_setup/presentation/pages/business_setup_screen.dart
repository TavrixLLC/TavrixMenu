import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/copy/pilot_arabic_copy.dart';
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
            const SnackBar(content: Text(PilotArabicCopy.businessSetupSaved)),
          );
          Navigator.of(context).pushReplacementNamed(AppRouteNames.dashboard);
        }
      },
      builder: (context, state) {
        final isLoading = state.status == BusinessSetupStatus.loading;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: AppScaffold(
            title: PilotArabicCopy.businessSetupTitle,
            scrollable: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: PilotArabicCopy.businessSetupTitle,
                  subtitle: PilotArabicCopy.businessSetupSubtitle,
                ),
                const SizedBox(height: AppSpacing.lg),
                _SetupSectionCard(
                  icon: Icons.storefront_outlined,
                  title: PilotArabicCopy.restaurantInfo,
                  subtitle: PilotArabicCopy.restaurantInfoSubtitle,
                  children: [
                    AppTextField(
                      label: PilotArabicCopy.restaurantName,
                      controller: _nameController,
                      hint: PilotArabicCopy.restaurantNameHint,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: const InputDecoration(
                        labelText: PilotArabicCopy.restaurantType,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'cafe',
                          child: Text(PilotArabicCopy.restaurantTypeCafe),
                        ),
                        DropdownMenuItem(
                          value: 'restaurant',
                          child: Text(PilotArabicCopy.restaurantTypeRestaurant),
                        ),
                        DropdownMenuItem(
                          value: 'shop',
                          child: Text(PilotArabicCopy.restaurantTypeShop),
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
                const SizedBox(height: AppSpacing.md),
                const _SetupSectionCard(
                  icon: Icons.image_outlined,
                  title: PilotArabicCopy.identityAndPhotos,
                  subtitle: PilotArabicCopy.managedPhotosBody,
                ),
                const SizedBox(height: AppSpacing.md),
                _SetupSectionCard(
                  icon: Icons.tune_outlined,
                  title: PilotArabicCopy.locationCurrencyLanguage,
                  subtitle: PilotArabicCopy.locationCurrencyLanguageSubtitle,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _city,
                      decoration: const InputDecoration(
                        labelText: PilotArabicCopy.city,
                      ),
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
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _currency,
                      decoration: const InputDecoration(
                        labelText: PilotArabicCopy.currency,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'IQD',
                          child: Text(PilotArabicCopy.currencyIqd),
                        ),
                        DropdownMenuItem(
                          value: 'USD',
                          child: Text(PilotArabicCopy.currencyUsd),
                        ),
                      ],
                      onChanged: isLoading
                          ? null
                          : (value) => setState(() {
                              _currency = value ?? 'IQD';
                            }),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _language,
                      decoration: const InputDecoration(
                        labelText: PilotArabicCopy.language,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'ar',
                          child: Text(PilotArabicCopy.languageArabic),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(PilotArabicCopy.languageEnglish),
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
                const SizedBox(height: AppSpacing.md),
                const _SetupSectionCard(
                  icon: Icons.location_on_outlined,
                  title: PilotArabicCopy.contactAndAddress,
                  subtitle: PilotArabicCopy.contactAndAddressBody,
                ),
                if (state.status == BusinessSetupStatus.failure &&
                    state.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  ErrorView(message: state.errorMessage!),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: isLoading
                      ? PilotArabicCopy.businessCreateLoading
                      : PilotArabicCopy.businessCreateAction,
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
