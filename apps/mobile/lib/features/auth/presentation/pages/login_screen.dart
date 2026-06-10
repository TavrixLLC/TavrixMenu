import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../../dashboard/presentation/bloc/dashboard_state.dart';
import '../../domain/entities/current_user.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated && state.user != null) {
          _completeBackendBoot(context, state.user!);
        }
      },
      builder: (context, state) {
        final isBusy =
            state.status == AuthStatus.loading ||
            state.status == AuthStatus.authenticated;

        return AppScaffold(
          scrollable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.houseGreen,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tavrix Menu',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Business user login',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.greenLight,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'For owners, managers, and staff. Customers do not use this Flutter app.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const AppCard(
                child: Text(
                  'Customers browse menus through customer-web. Customer ordering, cart, checkout, profile, and order history are outside this business app.',
                ),
              ),
              if (state.status == AuthStatus.failure &&
                  state.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                ErrorView(message: state.errorMessage!),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: isBusy ? 'Loading workspace' : 'Continue in dev mode',
                icon: Icons.login,
                onPressed: isBusy
                    ? null
                    : () => context.read<AuthCubit>().signInDevMode(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _completeBackendBoot(
    BuildContext context,
    CurrentUser user,
  ) async {
    final dashboardCubit = context.read<DashboardCubit>();
    await dashboardCubit.load(currentUser: user);

    if (!context.mounted) {
      return;
    }

    final dashboardState = dashboardCubit.state;
    switch (dashboardState.status) {
      case DashboardStatus.success:
        Navigator.of(context).pushReplacementNamed(AppRouteNames.dashboard);
        return;
      case DashboardStatus.needsBusinessSetup:
        Navigator.of(context).pushReplacementNamed(AppRouteNames.businessSetup);
        return;
      case DashboardStatus.failure:
        context.read<AuthCubit>().showBusinessAppError(
          dashboardState.errorMessage ?? 'Business workspace could not load.',
        );
        return;
      case DashboardStatus.initial:
      case DashboardStatus.loading:
        break;
    }
  }
}
