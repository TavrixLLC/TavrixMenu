import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/business_header_card.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/role_badge.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/waflo_action_tile.dart';
import '../../../../shared/widgets/waflo_metric_card.dart';
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
    unawaited(context.read<DashboardCubit>().load());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Waflo Workspace',
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
            return const LoadingView(message: 'Loading Waflo Workspace');
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
              BusinessHeaderCard(
                business: state.business,
                role: state.roleDisplayLabel,
              ),
              if (state.summaryErrorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                _InlineNotice(
                  title: 'Latest counts did not load',
                  message:
                      'You can keep using this business workspace. Pull to refresh later or try again from the dashboard.',
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _AccessCard(state: state),
              const SizedBox(height: AppSpacing.lg),
              _DashboardActionCard(
                title: 'Scan customer wallet',
                subtitle:
                    'Find the customer card, confirm progress, and add a stamp.',
                icon: Icons.qr_code_scanner,
                routeName: AppRouteNames.walletScan,
                accentColor: AppColors.primaryCoral,
                badge: 'Ready',
              ),
              if (state.summary != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _DashboardSummarySection(state: state),
              ],
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(
                title: 'Quick actions',
                subtitle: 'Choose the next job for this business.',
              ),
              const SizedBox(height: AppSpacing.md),
              _DashboardActionCard(
                enabled: _canManageMenu(state),
                title: 'Menu Appearance',
                subtitle: _canManageMenu(state)
                    ? 'Choose the public menu template customers see.'
                    : 'Only an owner or manager can save menu design changes.',
                icon: Icons.palette_outlined,
                routeName: AppRouteNames.menuAppearance,
                accentColor: AppColors.primaryCoral,
              ),
              const SizedBox(height: AppSpacing.sm),
              _DashboardActionCard(
                enabled: _canManageMenu(state),
                title: 'Menu tools',
                subtitle: _canManageMenu(state)
                    ? 'Edit categories and menu items.'
                    : 'Only an owner or manager can edit the menu.',
                icon: Icons.restaurant_menu,
                routeName: AppRouteNames.menu,
                accentColor: AppColors.freshGreen,
              ),
              const SizedBox(height: AppSpacing.sm),
              _DashboardActionCard(
                title: 'Loyalty tools',
                subtitle: 'Enroll customers, add stamps, and redeem rewards.',
                icon: Icons.loyalty_outlined,
                routeName: AppRouteNames.loyalty,
                accentColor: AppColors.freshGreen,
              ),
              const SizedBox(height: AppSpacing.sm),
              _DashboardActionCard(
                enabled: _canViewPublicLink(state),
                title: 'Public menu link',
                subtitle: _canViewPublicLink(state)
                    ? 'Copy the public menu URL for table displays.'
                    : 'Ask an owner for access to the public menu link.',
                icon: Icons.qr_code_2,
                routeName: AppRouteNames.qr,
                accentColor: AppColors.primaryCoral,
              ),
              const SizedBox(height: AppSpacing.sm),
              _DashboardActionCard(
                enabled: _canManageBusiness(state),
                title: 'Business Workspace',
                subtitle: _canManageBusiness(state)
                    ? 'Update name, type, city, language, and media URLs.'
                    : 'Only an owner or manager can edit this profile.',
                icon: Icons.storefront,
                routeName: AppRouteNames.businessProfile,
                accentColor: AppColors.rewardGold,
              ),
              const SizedBox(height: AppSpacing.sm),
              _DashboardActionCard(
                title: 'Subscription',
                subtitle: 'Review plan status and premium workspace access.',
                icon: Icons.workspace_premium,
                routeName: AppRouteNames.subscription,
                accentColor: AppColors.rewardGold,
              ),
            ],
          );
        },
      ),
    );
  }
}

bool _canManageBusiness(DashboardState state) {
  final permissions = state.permissions;
  if (permissions != null) {
    return permissions.canManageBusiness;
  }
  if (!state.hasKnownRole) {
    return true;
  }
  return state.effectiveRole == 'OWNER' ||
      state.effectiveRole == 'ADMIN' ||
      state.effectiveRole == 'MANAGER';
}

bool _canManageMenu(DashboardState state) {
  final permissions = state.permissions;
  if (permissions != null) {
    return permissions.canManageMenu;
  }
  if (!state.hasKnownRole) {
    return true;
  }
  return state.effectiveRole == 'OWNER' ||
      state.effectiveRole == 'ADMIN' ||
      state.effectiveRole == 'MANAGER';
}

bool _canViewPublicLink(DashboardState state) {
  return state.permissions?.canViewPublicLink ?? true;
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final fullName = state.user?.fullName.trim() ?? '';
    final businessName = state.business?.name.trim() ?? 'this business';
    final title = fullName.isNotEmpty ? fullName : 'Your access';
    final subtitle = _roleGuidance(state, businessName);

    return AppCard(
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: AppColors.primaryCoral,
          ),
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
          const SizedBox(width: AppSpacing.md),
          RoleBadge(role: state.roleDisplayLabel),
        ],
      ),
    );
  }

  String _roleGuidance(DashboardState state, String businessName) {
    return switch (state.effectiveRole) {
      'OWNER' =>
        'Owner access for $businessName. You can manage setup, menu, loyalty, and business tools.',
      'ADMIN' =>
        'Admin access for $businessName. You can manage setup, menu, loyalty, and business tools.',
      'MANAGER' =>
        'Manager access for $businessName. You can help run menu and loyalty operations.',
      'STAFF' =>
        'Business tools access for $businessName. Your main job is scanning customer wallets.',
      _ =>
        'Workspace access for $businessName. Ask the owner if an action is unavailable.',
    };
  }
}

class _DashboardSummarySection extends StatelessWidget {
  const _DashboardSummarySection({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary!;
    final hint = _hintText(summary.onboardingHints.recommendedNextStep);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.dashboard_customize_outlined),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Workspace',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Live menu readiness at a glance.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = AppSpacing.sm;
                  final tileWidth = (constraints.maxWidth - gap) / 2;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      _WorkflowMetricTile(
                        width: tileWidth,
                        label: 'Active categories',
                        value: summary.counts.activeCategories,
                        icon: Icons.category_outlined,
                      ),
                      _WorkflowMetricTile(
                        width: tileWidth,
                        label: 'Available items',
                        value: summary.counts.availableItems,
                        icon: Icons.restaurant_menu,
                      ),
                      _WorkflowMetricTile(
                        width: tileWidth,
                        label: 'Archived categories',
                        value: summary.counts.inactiveCategories,
                        icon: Icons.archive_outlined,
                      ),
                      _WorkflowMetricTile(
                        width: tileWidth,
                        label: 'Unavailable items',
                        value: summary.counts.unavailableItems,
                        icon: Icons.visibility_off_outlined,
                      ),
                    ],
                  );
                },
              ),
              if (summary.permissions.canViewMembers ||
                  summary.permissions.canManageMembers) ...[
                const SizedBox(height: AppSpacing.sm),
                _WorkflowMemberRow(value: summary.counts.activeMembers),
              ],
              const SizedBox(height: AppSpacing.md),
              _WorkflowNextStep(message: hint),
            ],
          ),
        ),
      ],
    );
  }

  String _hintText(String? step) {
    return switch (step) {
      'CREATE_CATEGORY' =>
        'Add your first category so the public menu has structure.',
      'CREATE_ITEM' => 'Add an item to make the menu useful for customers.',
      'SHARE_PUBLIC_MENU' =>
        'Your menu is ready. Copy the public link from QR Menu.',
      'OPEN_DASHBOARD' => 'Review your dashboard and keep building the menu.',
      _ => 'Keep your menu profile, categories, and public link up to date.',
    };
  }
}

class _WorkflowMetricTile extends StatelessWidget {
  const _WorkflowMetricTile({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
  });

  final double width;
  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: WafloMetricCard(
        label: label,
        value: '$value',
        icon: icon,
        accentColor: value == 0 ? AppColors.mutedText : AppColors.primaryCoral,
      ),
    );
  }
}

class _WorkflowMemberRow extends StatelessWidget {
  const _WorkflowMemberRow({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.greenTint,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.groups_outlined, color: AppColors.freshGreenDark),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Active members',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '$value',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.houseGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkflowNextStep extends StatelessWidget {
  const _WorkflowNextStep({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.softBorder),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColors.primaryCoral),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended next step',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.primaryCoral),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(message),
              ],
            ),
          ),
        ],
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
    this.enabled = true,
    this.accentColor = AppColors.primaryCoral,
    this.badge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String routeName;
  final bool enabled;
  final Color accentColor;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return WafloActionTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      enabled: enabled,
      accentColor: accentColor,
      badge: badge,
      onTap: enabled ? () => Navigator.of(context).pushNamed(routeName) : null,
    );
  }
}
