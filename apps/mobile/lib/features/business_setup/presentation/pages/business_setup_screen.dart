import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/constants/app_spacing.dart';
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
  final _cityController = TextEditingController();
  String _type = 'cafe';
  String _currency = 'IQD';
  String _language = 'ar';

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Business setup saved')));
          Navigator.of(context).pushReplacementNamed(AppRouteNames.dashboard);
        }
      },
      builder: (context, state) {
        final isLoading = state.status == BusinessSetupStatus.loading;

        return AppScaffold(
          title: 'Business setup',
          scrollable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Create your business profile',
                subtitle:
                    'Start with the details customers will recognize on your public menu.',
              ),
              const SizedBox(height: AppSpacing.lg),
              const AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.visibility_outlined),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'After saving, your dashboard opens and Waflo prepares a public QR menu for this business.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Business name',
                      controller: _nameController,
                      hint: 'Royal Cup',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: const InputDecoration(
                        labelText: 'Business type',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'cafe', child: Text('Cafe')),
                        DropdownMenuItem(
                          value: 'restaurant',
                          child: Text('Restaurant'),
                        ),
                        DropdownMenuItem(
                          value: 'shop',
                          child: Text('Retail shop'),
                        ),
                      ],
                      onChanged: isLoading
                          ? null
                          : (value) => setState(() {
                              _type = value ?? 'cafe';
                            }),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'City',
                      controller: _cityController,
                      hint: 'Baghdad',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _currency,
                      decoration: const InputDecoration(
                        labelText: 'Menu currency',
                        helperText: 'Used for prices customers see.',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'IQD',
                          child: Text('Iraqi dinar (IQD)'),
                        ),
                        DropdownMenuItem(
                          value: 'USD',
                          child: Text('US dollar (USD)'),
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
                        labelText: 'Default menu language',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'ar',
                          child: Text('Arabic / Kurdish ready'),
                        ),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: isLoading
                          ? null
                          : (value) => setState(() {
                              _language = value ?? 'ar';
                            }),
                    ),
                  ],
                ),
              ),
              if (state.status == BusinessSetupStatus.failure &&
                  state.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                ErrorView(message: state.errorMessage!),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: isLoading ? 'Creating business' : 'Create business',
                icon: Icons.storefront,
                onPressed: isLoading
                    ? null
                    : () => context.read<BusinessSetupCubit>().submit(
                        name: _nameController.text,
                        type: _type,
                        city: _cityController.text,
                        currency: _currency,
                        language: _language,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
