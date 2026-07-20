import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/copy/pilot_arabic_copy.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/business_header_card.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/role_badge.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/waflo_action_tile.dart';
import '../../../../shared/widgets/waflo_metric_card.dart';
import '../../../../shared/widgets/v2/waflo_shell_v2.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../bloc/dashboard_cubit.dart';
import '../bloc/dashboard_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.embeddedInWorkspaceShell = false});

  final bool embeddedInWorkspaceShell;

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppScaffold(
        title: PilotArabicCopy.dashboardTitle,
        embeddedInWorkspaceShell: widget.embeddedInWorkspaceShell,
        actions: widget.embeddedInWorkspaceShell
            ? null
            : [_buildSignOutAction(context)],
        scrollable: true,
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state.status == DashboardStatus.loading ||
                state.status == DashboardStatus.initial) {
              return const LoadingView(
                message: PilotArabicCopy.dashboardLoading,
              );
            }

            if (state.status == DashboardStatus.failure) {
              return ErrorView(
                message:
                    state.errorMessage ?? PilotArabicCopy.dashboardLoadFailed,
                onRetry: () => context.read<DashboardCubit>().load(),
              );
            }

            final isStaff = state.effectiveRole == 'STAFF';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.embeddedInWorkspaceShell) ...[
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _buildSignOutAction(context),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ] else
                  BusinessHeaderCard(
                    business: state.business,
                    role: state.workspaceRoleDisplayLabel,
                  ),
                if (state.summaryErrorMessage != null) ...[
                  if (!widget.embeddedInWorkspaceShell)
                    const SizedBox(height: AppSpacing.md),
                  _InlineNotice(
                    title: PilotArabicCopy.latestCountsFailed,
                    message: PilotArabicCopy.latestCountsRetry,
                  ),
                ],
                if (!widget.embeddedInWorkspaceShell ||
                    state.summaryErrorMessage != null)
                  const SizedBox(height: AppSpacing.lg),
                _AccessCard(state: state),
                if (!isStaff) ...[
                  const SizedBox(height: AppSpacing.lg),
                  const _ManagedSetupCard(),
                ],
                if (isStaff) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _DashboardActionCard(
                    key: const ValueKey('dashboardWalletScanAction'),
                    enabled: _canScanCustomerWallet(state),
                    title: PilotArabicCopy.staffCashier,
                    subtitle: _canScanCustomerWallet(state)
                        ? PilotArabicCopy.scannerSubtitle
                        : PilotArabicCopy.scanDisabled,
                    icon: Icons.qr_code_scanner,
                    routeName: AppRouteNames.walletScan,
                    accentColor: AppColors.primaryCoral,
                    badge: PilotArabicCopy.readyBadge,
                  ),
                ],
                if (state.summary != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _DashboardSummarySection(state: state),
                ],
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: isStaff
                      ? PilotArabicCopy.staffCashier
                      : PilotArabicCopy.guidedSetupTitle,
                  subtitle: isStaff
                      ? PilotArabicCopy.scannerSubtitle
                      : PilotArabicCopy.guidedSetupSubtitle,
                ),
                const SizedBox(height: AppSpacing.md),
                _DashboardActionCard(
                  enabled: _canManageBusiness(state),
                  title: PilotArabicCopy.businessInfo,
                  subtitle: _canManageBusiness(state)
                      ? PilotArabicCopy.businessWorkspaceSubtitle
                      : PilotArabicCopy.businessWorkspaceDenied,
                  icon: Icons.storefront,
                  routeName: AppRouteNames.businessProfile,
                  accentColor: AppColors.rewardGold,
                ),
                const SizedBox(height: AppSpacing.sm),
                _DashboardActionCard(
                  enabled: _canManageMenu(state),
                  title: PilotArabicCopy.menuProducts,
                  subtitle: _canManageMenu(state)
                      ? PilotArabicCopy.menuToolsSubtitle
                      : PilotArabicCopy.menuToolsDenied,
                  icon: Icons.restaurant_menu,
                  routeName: AppRouteNames.menu,
                  accentColor: AppColors.freshGreen,
                ),
                const SizedBox(height: AppSpacing.sm),
                _DashboardActionCard(
                  enabled: _canViewPublicLink(state),
                  title: PilotArabicCopy.publicQrMenu,
                  subtitle: _canViewPublicLink(state)
                      ? PilotArabicCopy.publicLinkSubtitle
                      : PilotArabicCopy.publicLinkDenied,
                  icon: Icons.qr_code_2,
                  routeName: AppRouteNames.qr,
                  accentColor: AppColors.primaryCoral,
                ),
                const SizedBox(height: AppSpacing.sm),
                _DashboardActionCard(
                  title: PilotArabicCopy.loyaltyCard,
                  subtitle: PilotArabicCopy.loyaltyToolsSubtitle,
                  icon: Icons.loyalty_outlined,
                  routeName: AppRouteNames.loyalty,
                  accentColor: AppColors.freshGreen,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (!isStaff) ...[
                  _DashboardActionCard(
                    key: const ValueKey('dashboardWalletScanAction'),
                    enabled: _canScanCustomerWallet(state),
                    title: PilotArabicCopy.staffCashier,
                    subtitle: _canScanCustomerWallet(state)
                        ? PilotArabicCopy.scannerSubtitle
                        : PilotArabicCopy.scanDisabled,
                    icon: Icons.qr_code_scanner,
                    routeName: AppRouteNames.walletScan,
                    accentColor: AppColors.primaryCoral,
                    badge: PilotArabicCopy.readyBadge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                _DashboardActionCard(
                  enabled: _canManageAppearance(state),
                  title: PilotArabicCopy.menuAppearance,
                  subtitle: _canManageAppearance(state)
                      ? PilotArabicCopy.menuAppearanceSubtitle
                      : PilotArabicCopy.menuAppearanceDenied,
                  icon: Icons.palette_outlined,
                  routeName: AppRouteNames.menuAppearance,
                  accentColor: AppColors.primaryCoral,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSignOutAction(BuildContext context) {
    return IconButton(
      tooltip: PilotArabicCopy.signOut,
      icon: const Icon(Icons.logout),
      onPressed: () async {
        await context.read<AuthCubit>().signOut();
        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRouteNames.login, (_) => false);
        }
      },
    );
  }
}

bool _canManageAppearance(DashboardState state) {
  final permissions = state.permissions;
  if (permissions != null) {
    return permissions.canManageAppearance;
  }
  if (!state.hasKnownRole) {
    return true;
  }
  return state.effectiveRole == 'OWNER' ||
      state.effectiveRole == 'ADMIN' ||
      state.effectiveRole == 'MANAGER';
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

bool _canScanCustomerWallet(DashboardState state) {
  return state.permissions?.canScanCustomerWallet ?? true;
}

class _ManagedSetupCard extends StatelessWidget {
  const _ManagedSetupCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.handshake_outlined, color: AppColors.primaryCoral),
          const SizedBox(height: AppSpacing.sm),
          Text(
            PilotArabicCopy.guidedSetupTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(PilotArabicCopy.managedSetupBody),
        ],
      ),
    );
  }
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
          RoleBadge(role: state.workspaceRoleDisplayLabel),
        ],
      ),
    );
  }

  String _roleGuidance(DashboardState state, String businessName) {
    return switch (state.effectiveRole) {
      'OWNER' => '${PilotArabicCopy.ownerAccess} ($businessName)',
      'ADMIN' => '${PilotArabicCopy.ownerAccess} ($businessName)',
      'MANAGER' => '${PilotArabicCopy.managerAccess} ($businessName)',
      'STAFF' => '${PilotArabicCopy.staffAccess} ($businessName)',
      _ => '${PilotArabicCopy.unknownAccess} ($businessName)',
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
    final needsMenuSetup =
        summary.counts.activeCategories == 0 ||
        summary.counts.availableItems == 0;

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
                          PilotArabicCopy.guidedSetupTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          PilotArabicCopy.guidedSetupSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (needsMenuSetup) ...[
                _MenuSetupPrompt(summary: summary),
                const SizedBox(height: AppSpacing.md),
              ],
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
                        label: PilotArabicCopy.activeCategories,
                        value: summary.counts.activeCategories,
                        icon: Icons.category_outlined,
                      ),
                      _WorkflowMetricTile(
                        width: tileWidth,
                        label: PilotArabicCopy.availableItems,
                        value: summary.counts.availableItems,
                        icon: Icons.restaurant_menu,
                      ),
                      _WorkflowMetricTile(
                        width: tileWidth,
                        label: PilotArabicCopy.inactiveCategories,
                        value: summary.counts.inactiveCategories,
                        icon: Icons.archive_outlined,
                      ),
                      _WorkflowMetricTile(
                        width: tileWidth,
                        label: PilotArabicCopy.unavailableItems,
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
      'CREATE_CATEGORY' => 'ابدأ بإضافة أول قسم حتى يصير المنيو مرتباً.',
      'CREATE_ITEM' => 'أضف أول منتج حتى يصير المنيو مفيداً للزبائن.',
      'SHARE_PUBLIC_MENU' =>
        'المنيو جاهز. افتح رابط QR والمنيو العام وشاركه عند الحاجة.',
      'OPEN_DASHBOARD' => 'راجع الخطوات وكمل تجهيز المطعم.',
      _ => 'حافظ على معلومات المطعم والمنيو ورابط QR محدثة.',
    };
  }
}

class _MenuSetupPrompt extends StatelessWidget {
  const _MenuSetupPrompt({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.goldTint,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_outlined,
                  color: AppColors.rewardGold,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    PilotArabicCopy.guidedSetupTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(PilotArabicCopy.guidedSetupSubtitle),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                const _SetupStep(
                  label: PilotArabicCopy.businessInfo,
                  completed: true,
                ),
                _SetupStep(
                  label: PilotArabicCopy.addCategories,
                  completed: summary.counts.activeCategories > 0,
                ),
                _SetupStep(
                  label: PilotArabicCopy.addItems,
                  completed: summary.counts.availableItems > 0,
                ),
                _SetupStep(
                  label: PilotArabicCopy.shareQr,
                  completed: summary.publicMenu.url.trim().isNotEmpty,
                ),
                const _SetupStep(label: PilotArabicCopy.enableLoyalty),
                const _SetupStep(label: PilotArabicCopy.prepareCashier),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupStep extends StatelessWidget {
  const _SetupStep({required this.label, this.completed = false});

  final String label;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              completed ? Icons.check_circle_outline : Icons.radio_button_off,
              size: 16,
              color: completed
                  ? AppColors.freshGreenDark
                  : AppColors.primaryCoral,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
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
                PilotArabicCopy.activeMembers,
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
                    PilotArabicCopy.nextStepTitle,
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
    super.key,
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
      onTap: enabled
          ? () {
              final shell = WafloShellV2.of(context);
              if (shell != null) {
                if (routeName == AppRouteNames.menu) {
                  shell.setTab(1);
                } else if (routeName == AppRouteNames.loyalty) {
                  shell.setTab(2);
                } else if (routeName == AppRouteNames.walletScan) {
                  shell.setTab(3);
                } else if (routeName == AppRouteNames.businessProfile) {
                  shell.setTab(4);
                } else {
                  Navigator.of(context).pushNamed(routeName);
                }
              } else {
                Navigator.of(context).pushNamed(routeName);
              }
            }
          : null,
    );
  }
}
