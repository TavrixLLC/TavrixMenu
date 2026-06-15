import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({required this.config, super.key});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          final routeName = state.shouldOpenDashboard
              ? AppRouteNames.dashboard
              : AppRouteNames.businessSetup;
          Navigator.of(context).pushReplacementNamed(routeName);
        }
      },
      builder: (context, state) {
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
              if (config.hasClerkPublishableKey)
                _ClerkSignInPanel(authStatus: state.status)
              else
                const AppCard(
                  child: Text(
                    'Set CLERK_PUBLISHABLE_KEY to enable owner sign in and sign up.',
                  ),
                ),
              if (config.isDevAuthEnabled) ...[
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: state.status == AuthStatus.loading
                      ? 'Preparing'
                      : 'Continue in dev mode',
                  icon: Icons.login,
                  variant: AppButtonVariant.secondary,
                  onPressed: state.status == AuthStatus.loading
                      ? null
                      : () => context.read<AuthCubit>().signInDevMode(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ClerkSignInPanel extends StatelessWidget {
  const _ClerkSignInPanel({required this.authStatus});

  final AuthStatus authStatus;

  @override
  Widget build(BuildContext context) {
    return ClerkAuthBuilder(
      signedOutBuilder: (context, authState) => const ClerkAuthentication(),
      signedInBuilder: (context, authState) {
        if (authStatus == AuthStatus.initial ||
            authStatus == AuthStatus.unauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<AuthCubit>().signInWithClerk();
            }
          });
        }

        if (authStatus == AuthStatus.failure) {
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('You are signed in with Clerk.'),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Retry workspace check',
                  icon: Icons.refresh,
                  onPressed: () => context.read<AuthCubit>().signInWithClerk(),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Sign out',
                  icon: Icons.logout,
                  variant: AppButtonVariant.ghost,
                  onPressed: () => context.read<AuthCubit>().signOut(),
                ),
              ],
            ),
          );
        }

        return const LoadingView(message: 'Checking your business access');
      },
    );
  }
}
