import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/business_role.dart';
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
import '../../domain/entities/business.dart';
import '../bloc/business_setup_cubit.dart';
import '../bloc/business_setup_state.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _currencyController = TextEditingController();
  final _languageController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _coverUrlController = TextEditingController();
  String _type = 'cafe';
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
    _cityController.text = business.city ?? '';
    _currencyController.text = business.currency;
    _languageController.text = business.language;
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
    _cityController.dispose();
    _currencyController.dispose();
    _languageController.dispose();
    _logoUrlController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BusinessSetupCubit, BusinessSetupState>(
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
          const SnackBar(content: Text('Business profile updated')),
        );
        Navigator.of(context).pop();
      },
      builder: (context, setupState) {
        return BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, dashboardState) {
            if (dashboardState.status == DashboardStatus.initial ||
                dashboardState.status == DashboardStatus.loading) {
              return const AppScaffold(
                title: 'Business profile',
                child: LoadingView(message: 'Loading business profile'),
              );
            }

            final business = dashboardState.business;
            if (business == null) {
              return const AppScaffold(
                title: 'Business profile',
                child: EmptyState(
                  title: 'Business setup needed',
                  message: 'Create a business before editing its profile.',
                  icon: Icons.storefront,
                ),
              );
            }

            _hydrate(business);

            final canManageBusiness =
                dashboardState.permissions?.canManageBusiness ??
                (dashboardState.effectiveRole == BusinessRole.owner ||
                    dashboardState.effectiveRole == BusinessRole.admin);
            if (!canManageBusiness) {
              return const AppScaffold(
                title: 'Business profile',
                child: EmptyState(
                  title: 'Restricted access',
                  message:
                      'Your business permissions do not allow profile edits.',
                  icon: Icons.lock_outline,
                ),
              );
            }

            final isLoading =
                setupState.status == BusinessSetupStatus.loading && _submitted;

            return AppScaffold(
              title: 'Business profile',
              scrollable: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Edit business profile',
                    subtitle:
                        'These fields power the owner dashboard and public menu.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
                            DropdownMenuItem(
                              value: 'cafe',
                              child: Text('Cafe'),
                            ),
                            DropdownMenuItem(
                              value: 'restaurant',
                              child: Text('Restaurant'),
                            ),
                            DropdownMenuItem(
                              value: 'shop',
                              child: Text('Shop'),
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
                        AppTextField(
                          label: 'Currency',
                          controller: _currencyController,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Language',
                          controller: _languageController,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Logo URL',
                          controller: _logoUrlController,
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Cover URL',
                          controller: _coverUrlController,
                          keyboardType: TextInputType.url,
                        ),
                      ],
                    ),
                  ),
                  if (setupState.status == BusinessSetupStatus.failure &&
                      setupState.errorMessage != null &&
                      _submitted) ...[
                    const SizedBox(height: AppSpacing.md),
                    ErrorView(message: setupState.errorMessage!),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: isLoading ? 'Saving' : 'Save profile',
                    icon: Icons.save_outlined,
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() => _submitted = true);
                            context.read<BusinessSetupCubit>().update(
                              id: business.id,
                              name: _nameController.text,
                              type: _type,
                              city: _cityController.text,
                              currency: _currencyController.text,
                              language: _languageController.text,
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
    );
  }
}
