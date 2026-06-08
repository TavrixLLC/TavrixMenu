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
import '../../../dashboard/presentation/bloc/dashboard_cubit.dart';
import '../bloc/business_setup_cubit.dart';
import '../bloc/business_setup_state.dart';

class BusinessSetupScreen extends StatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> {
  final _nameController = TextEditingController(text: 'Tavrix Demo Cafe');
  final _slugController = TextEditingController(text: 'tavrix-demo-cafe');

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BusinessSetupCubit, BusinessSetupState>(
      listener: (context, state) {
        if (state.status == BusinessSetupStatus.success) {
          context.read<DashboardCubit>().load();
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
                    'This profile powers the business dashboard and public menu URL.',
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Business name',
                      controller: _nameController,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Public slug',
                      controller: _slugController,
                      hint: 'my-cafe',
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
                label: isLoading ? 'Saving' : 'Save business',
                icon: Icons.storefront,
                onPressed: isLoading
                    ? null
                    : () => context.read<BusinessSetupCubit>().submit(
                        name: _nameController.text,
                        slug: _slugController.text,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
