import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/business_header_card.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/role_badge.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../bloc/dashboard_cubit.dart';
import '../bloc/dashboard_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<DashboardCubit>();
      if (cubit.state.status != DashboardStatus.success) {
        cubit.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dashboard',
      actions: [
        IconButton(
          tooltip: 'Sign out',
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await context.read<AuthCubit>().signOut();
            if (context.mounted) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRouteNames.login, (_) => false);
            }
          },
        ),
      ],
      scrollable: true,
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatus.loading ||
              state.status == DashboardStatus.initial) {
            return const LoadingView(message: 'Loading dashboard');
          }

          if (state.status == DashboardStatus.failure) {
            return ErrorView(
              message: state.errorMessage ?? 'Dashboard could not load.',
              onRetry: () => context.read<DashboardCubit>().load(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BusinessHeaderCard(business: state.business),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.user?.fullName ?? 'Business user',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            state.user?.email ??
                                'Signed in for Sprint 1 dev mode',
                          ),
                        ],
                      ),
                    ),
                    RoleBadge(role: state.user?.role ?? 'Staff'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(
                title: 'Quick actions',
                subtitle: 'Business operations for managers and staff.',
              ),
              const SizedBox(height: AppSpacing.md),
              _DashboardActionCard(
                title: 'Manage Menu',
                subtitle: 'Edit categories and menu items.',
                icon: Icons.restaurant_menu,
                routeName: AppRouteNames.menu,
              ),
              const SizedBox(height: AppSpacing.sm),
              _DashboardActionCard(
                title: 'QR Menu',
                subtitle: 'Preview the public menu link concept.',
                icon: Icons.qr_code_2,
                routeName: AppRouteNames.qr,
              ),
              const SizedBox(height: AppSpacing.sm),
              _DashboardActionCard(
                title: 'Subscription',
                subtitle: 'View Tavrix Menu Basic and Pro placeholders.',
                icon: Icons.workspace_premium,
                routeName: AppRouteNames.subscription,
              ),
              const SizedBox(height: AppSpacing.sm),
              _DashboardActionCard(
                title: 'Staff Scanner',
                subtitle: 'Sprint 1 placeholder for staff scanning.',
                icon: Icons.document_scanner_outlined,
                routeName: AppRouteNames.staffScanner,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  const _DashboardActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.routeName,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.of(context).pushNamed(routeName),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(subtitle),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
