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
import '../../../../shared/widgets/status_badge.dart';
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
      context.read<DashboardCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dashboard',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<DashboardCubit>().load(),
        ),
      ],
      scrollable: true,
      child: BlocConsumer<DashboardCubit, DashboardState>(
        listener: (context, state) {
          if (state.status == DashboardStatus.noBusiness) {
            Navigator.of(
              context,
            ).pushReplacementNamed(AppRouteNames.businessSetup);
          }
        },
        builder: (context, state) {
          if (state.status == DashboardStatus.loading ||
              state.status == DashboardStatus.initial) {
            return const LoadingView(message: 'Loading dashboard');
          }

          if (state.status == DashboardStatus.noBusiness) {
            return const LoadingView(message: 'Opening business setup');
          }

          if (state.status == DashboardStatus.failure) {
            return ErrorView(
              message: state.errorMessage ?? 'Dashboard could not load.',
              onRetry: () => context.read<DashboardCubit>().load(),
            );
          }

          final permissions = state.appContext?.permissions;
          final membership = state.appContext?.currentMembership;
          final canManageMenu = permissions?.canManageMenu ?? true;
          final canViewPublicLink = permissions?.canViewPublicLink ?? true;

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
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(
                      label: 'Slug',
                      value: state.business?.slug ?? 'Not configured',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _DetailRow(
                      label: 'Type',
                      value: state.business?.type ?? 'cafe',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _DetailRow(
                      label: 'Role',
                      value:
                          membership?.role ??
                          ((state.business?.role.isEmpty ?? true)
                              ? 'OWNER'
                              : state.business!.role),
                    ),
                    if (membership != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _DetailRow(
                        label: 'Member',
                        value: membership.isActive ? 'Active' : 'Inactive',
                      ),
                    ],
                    if (permissions != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          if (permissions.canManageBusiness)
                            const StatusBadge(label: 'Manage business'),
                          if (permissions.canManageMenu)
                            const StatusBadge(label: 'Manage menu'),
                          if (permissions.canViewPublicLink)
                            const StatusBadge(label: 'Public link'),
                          if (permissions.canViewMembers)
                            const StatusBadge(label: 'View members'),
                        ],
                      ),
                    ],
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
                enabled: canManageMenu,
              ),
              const SizedBox(height: AppSpacing.sm),
              _DashboardActionCard(
                title: 'QR Menu',
                subtitle: 'Preview the public menu link concept.',
                icon: Icons.qr_code_2,
                routeName: AppRouteNames.qr,
                enabled: canViewPublicLink,
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  const _DashboardActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.routeName,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String routeName;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: enabled ? () => Navigator.of(context).pushNamed(routeName) : null,
      child: Row(
        children: [
          Icon(icon, color: enabled ? null : Theme.of(context).disabledColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: enabled ? null : Theme.of(context).disabledColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(subtitle),
              ],
            ),
          ),
          Icon(
            enabled ? Icons.chevron_right : Icons.lock_outline,
            color: enabled ? null : Theme.of(context).disabledColor,
          ),
        ],
      ),
    );
  }
}
