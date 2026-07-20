import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/v3/waflo_v3_tokens.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/v3/waflo_bottom_navigation.dart';
import '../../../../shared/widgets/v3/waflo_empty_state.dart';
import '../../../../shared/widgets/v3/waflo_inline_error.dart';
import '../../../../shared/widgets/v3/waflo_primary_button.dart';
import '../../../../shared/widgets/v3/waflo_secondary_button.dart';
import '../../../../shared/widgets/v3/waflo_section_header.dart';
import '../../../../shared/widgets/v3/waflo_shell_v3.dart';
import '../../../../shared/widgets/v3/waflo_skeleton.dart';
import '../../../../shared/widgets/v3/waflo_status_badge.dart';
import '../bloc/dashboard_cubit.dart';
import '../bloc/dashboard_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.embeddedInWorkspaceShell = false,
    this.onDestinationSelected,
    this.onOpenPublicMenu,
  });

  final bool embeddedInWorkspaceShell;
  final ValueChanged<WafloWorkspaceDestination>? onDestinationSelected;
  final VoidCallback? onOpenPublicMenu;

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
    final dashboard = BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) => _DashboardStateView(
        state: state,
        onRetry: () => context.read<DashboardCubit>().load(),
        onDestinationSelected: (destination) {
          final callback = widget.onDestinationSelected;
          if (callback != null) {
            callback(destination);
            return;
          }
          WafloShellV3.maybeControllerOf(
            context,
          )?.selectDestination(destination);
        },
        onOpenPublicMenu: widget.onOpenPublicMenu,
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: widget.embeddedInWorkspaceShell
          ? ColoredBox(
              color: WafloV3Colors.background,
              child: ListView(
                key: const ValueKey('dashboard-v3-scroll-view'),
                padding: const EdgeInsetsDirectional.fromSTEB(
                  WafloV3Spacing.standardPageMargin,
                  WafloV3Spacing.space8,
                  WafloV3Spacing.standardPageMargin,
                  WafloV3Spacing.space24,
                ),
                children: [dashboard],
              ),
            )
          : AppScaffold(title: 'الرئيسية', scrollable: true, child: dashboard),
    );
  }
}

class _DashboardStateView extends StatelessWidget {
  const _DashboardStateView({
    required this.state,
    required this.onRetry,
    required this.onDestinationSelected,
    required this.onOpenPublicMenu,
  });

  final DashboardState state;
  final VoidCallback onRetry;
  final ValueChanged<WafloWorkspaceDestination> onDestinationSelected;
  final VoidCallback? onOpenPublicMenu;

  @override
  Widget build(BuildContext context) {
    if (state.status == DashboardStatus.initial ||
        state.status == DashboardStatus.loading) {
      return const _DashboardLoadingState();
    }

    if (state.status == DashboardStatus.failure) {
      return WafloInlineError(
        key: const ValueKey('dashboard-v3-load-error'),
        title: 'تعذّر تحميل الرئيسية',
        message: state.errorMessage ?? 'حاول مرة ثانية بعد قليل.',
        onRetry: onRetry,
      );
    }

    final summary = state.summary;
    if (summary == null) {
      return WafloInlineError(
        key: const ValueKey('dashboard-v3-summary-error'),
        title: 'تعذّر تحميل تفاصيل المطعم',
        message:
            state.summaryErrorMessage ??
            'لا نعرض أرقاماً تقديرية. أعد المحاولة لعرض البيانات الحقيقية.',
        onRetry: onRetry,
      );
    }

    return Column(
      key: const ValueKey('dashboard-v3-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.summaryErrorMessage != null) ...[
          WafloInlineError(
            title: 'تعذّر تحديث بعض التفاصيل',
            message: state.summaryErrorMessage!,
            onRetry: onRetry,
          ),
          const SizedBox(height: WafloV3Spacing.space16),
        ],
        _ProgressHero(
          state: state,
          onSelectMenu: () =>
              onDestinationSelected(WafloWorkspaceDestination.menu),
          onOpenPublicMenu: onOpenPublicMenu,
        ),
        const SizedBox(height: WafloV3Spacing.space24),
        const WafloSectionHeader(title: 'إجراءات سريعة'),
        const SizedBox(height: WafloV3Spacing.space12),
        _QuickActions(
          state: state,
          onDestinationSelected: onDestinationSelected,
        ),
        const SizedBox(height: WafloV3Spacing.space24),
        const WafloSectionHeader(title: 'لمحة سريعة'),
        const SizedBox(height: WafloV3Spacing.space12),
        _MetricsGrid(state: state),
        const SizedBox(height: WafloV3Spacing.space24),
        const WafloSectionHeader(title: 'النشاط الأخير'),
        const SizedBox(height: WafloV3Spacing.space12),
        const _Surface(
          child: WafloEmptyState(
            key: ValueKey('dashboard-v3-activity-unavailable'),
            icon: Icons.inbox_outlined,
            title: 'النشاط الأخير غير متاح حالياً',
            description: 'سنُظهر النشاط هنا عندما تتوفر بيانات موثوقة للمطعم.',
          ),
        ),
        const SizedBox(height: WafloV3Spacing.space24),
        _LoyaltyPanel(
          enabled: _canAccessLoyalty(state),
          onPressed: () =>
              onDestinationSelected(WafloWorkspaceDestination.loyalty),
        ),
      ],
    );
  }
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({
    required this.state,
    required this.onSelectMenu,
    required this.onOpenPublicMenu,
  });

  final DashboardState state;
  final VoidCallback onSelectMenu;
  final VoidCallback? onOpenPublicMenu;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary!;
    final hasCategories = summary.counts.activeCategories > 0;
    final hasProducts = summary.counts.availableItems > 0;
    final publicMenuReady =
        hasProducts &&
        summary.onboardingHints.hasPublicMenuReady &&
        summary.publicMenu.url.trim().isNotEmpty;
    final completedSteps =
        1 +
        (hasCategories ? 1 : 0) +
        (hasProducts ? 1 : 0) +
        (publicMenuReady ? 1 : 0);
    final canManageMenu = _canManageMenu(state);
    final canOpenMenu = publicMenuReady && onOpenPublicMenu != null;
    final title = !hasCategories
        ? 'ابدأ بأول قسم في منيوك'
        : !hasProducts
        ? 'خلّ منيوك جاهز للزبائن'
        : publicMenuReady
        ? 'منيوك جاهز للمشاركة'
        : 'راجع منيوك قبل مشاركته';
    final description = !hasCategories
        ? 'رتّب المنيو بإضافة قسم حقيقي، وبعدها أضف منتجاتك.'
        : !hasProducts
        ? 'أضف أول منتجاتك حتى تقدر تعرض المنيو وتشاركه مع الزبائن.'
        : publicMenuReady
        ? 'المنتجات والمنيو العام جاهزان. افتح المنيو وراجعه قبل المشاركة.'
        : 'بيانات المنتجات موجودة، لكن المنيو العام غير جاهز للفتح بعد.';

    return _Surface(
      key: const ValueKey('dashboard-v3-progress-hero'),
      warm: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: WafloStatusBadge(
              label: '$completedSteps من 4 خطوات جاهزة',
              status: completedSteps == 4
                  ? WafloStatusKind.active
                  : WafloStatusKind.warning,
            ),
          ),
          const SizedBox(height: WafloV3Spacing.space16),
          Text(
            title,
            key: const ValueKey('dashboard-v3-hero-title'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: WafloV3Colors.primaryText,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: WafloV3Spacing.space8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: WafloV3Colors.primaryText.withValues(alpha: 0.72),
              height: 1.55,
            ),
          ),
          const SizedBox(height: WafloV3Spacing.space20),
          _ProgressSteps(completedSteps: completedSteps),
          const SizedBox(height: WafloV3Spacing.space20),
          WafloPrimaryButton(
            key: const ValueKey('dashboard-v3-primary-menu-action'),
            label: hasCategories ? 'إضافة منتج' : 'إدارة الأقسام',
            onPressed: canManageMenu ? onSelectMenu : null,
          ),
          if (!canManageMenu) ...[
            const SizedBox(height: WafloV3Spacing.space8),
            const _HelperText(text: 'صلاحيتك الحالية لا تسمح بتعديل المنيو.'),
          ],
          const SizedBox(height: WafloV3Spacing.space8),
          WafloSecondaryButton(
            key: const ValueKey('dashboard-v3-open-menu-action'),
            label: 'فتح المنيو',
            onPressed: canOpenMenu ? onOpenPublicMenu : null,
          ),
          if (!canOpenMenu) ...[
            const SizedBox(height: WafloV3Spacing.space8),
            const _HelperText(
              key: ValueKey('dashboard-v3-open-menu-helper'),
              text: 'يتوفر فتح المنيو بعد إضافة منتج وتجهيز الرابط العام.',
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressSteps extends StatelessWidget {
  const _ProgressSteps({required this.completedSteps});

  final int completedSteps;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$completedSteps من 4 خطوات جاهزة',
      excludeSemantics: true,
      child: Row(
        children: List.generate(4, (index) {
          final completed = index < completedSteps;
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: index == 3 ? 0 : WafloV3Spacing.space8,
              ),
              child: Container(
                height: WafloV3Spacing.space8,
                decoration: BoxDecoration(
                  color: completed
                      ? WafloV3Colors.primary
                      : WafloV3Colors.primaryText.withValues(alpha: 0.10),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(WafloV3Radius.pill),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.state,
    required this.onDestinationSelected,
  });

  final DashboardState state;
  final ValueChanged<WafloWorkspaceDestination> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickActionData(
        key: const ValueKey('dashboard-v3-loyalty-action'),
        label: 'إنشاء بطاقة ولاء',
        icon: Icons.loyalty_outlined,
        enabled: _canAccessLoyalty(state),
        helper: _canAccessLoyalty(state) ? null : 'غير متاح لصلاحيتك الحالية',
        onPressed: () =>
            onDestinationSelected(WafloWorkspaceDestination.loyalty),
      ),
      _QuickActionData(
        key: const ValueKey('dashboard-v3-categories-action'),
        label: 'إدارة الأقسام',
        icon: Icons.grid_view_rounded,
        enabled: _canManageMenu(state),
        helper: _canManageMenu(state) ? null : 'تحتاج صلاحية إدارة المنيو',
        onPressed: () => onDestinationSelected(WafloWorkspaceDestination.menu),
      ),
      _QuickActionData(
        key: const ValueKey('dashboard-v3-scanner-action'),
        label: 'مسح بطاقة',
        icon: Icons.qr_code_scanner_rounded,
        enabled: _canScanCustomerWallet(state),
        helper: _canScanCustomerWallet(state)
            ? null
            : 'المسح غير متاح لصلاحيتك الحالية',
        onPressed: () =>
            onDestinationSelected(WafloWorkspaceDestination.scanner),
      ),
      const _QuickActionData(
        key: ValueKey('dashboard-v3-notification-action'),
        label: 'إرسال إشعار',
        icon: Icons.send_outlined,
        enabled: false,
        helper: 'يتفعّل عند توفر إشعارات العملاء',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = WafloV3Spacing.space12;
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: actions
              .map((action) => SizedBox(width: width, child: action.build()))
              .toList(growable: false),
        );
      },
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.key,
    required this.label,
    required this.icon,
    required this.enabled,
    this.helper,
    this.onPressed,
  });

  final Key key;
  final String label;
  final IconData icon;
  final bool enabled;
  final String? helper;
  final VoidCallback? onPressed;

  Widget build() {
    return _QuickActionCard(
      key: key,
      label: label,
      icon: icon,
      enabled: enabled,
      helper: helper,
      onPressed: onPressed,
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.enabled,
    super.key,
    this.helper,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final String? helper;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = enabled
        ? WafloV3Colors.primaryText
        : WafloV3Colors.primaryText.withValues(alpha: 0.42);
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: helper,
      child: Material(
        color: enabled
            ? WafloV3Colors.surface
            : WafloV3Colors.primaryText.withValues(alpha: 0.04),
        borderRadius: const BorderRadius.all(
          Radius.circular(WafloV3Radius.standardCard),
        ),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: const BorderRadius.all(
            Radius.circular(WafloV3Radius.standardCard),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 132),
            child: Padding(
              padding: const EdgeInsets.all(WafloV3Spacing.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: WafloV3Colors.primary.withValues(
                        alpha: enabled ? 0.10 : 0.05,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(WafloV3Spacing.space8),
                      child: Icon(icon, color: foreground),
                    ),
                  ),
                  const SizedBox(height: WafloV3Spacing.space12),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (helper != null) ...[
                    const SizedBox(height: WafloV3Spacing.space4),
                    Text(
                      helper!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: foreground,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final counts = state.summary!.counts;
    final metrics = [
      _MetricData(
        key: const ValueKey('dashboard-v3-products-metric'),
        label: 'المنتجات',
        value: '${counts.availableItems}',
        icon: Icons.shopping_bag_outlined,
      ),
      _MetricData(
        key: const ValueKey('dashboard-v3-categories-metric'),
        label: 'الأقسام',
        value: '${counts.activeCategories}',
        icon: Icons.receipt_long_outlined,
      ),
      const _MetricData(
        key: ValueKey('dashboard-v3-loyalty-metric'),
        label: 'بطاقات الولاء',
        value: 'غير متاح',
        icon: Icons.credit_card_outlined,
        unavailable: true,
      ),
      const _MetricData(
        key: ValueKey('dashboard-v3-customers-metric'),
        label: 'العملاء',
        value: 'غير متاح',
        icon: Icons.groups_outlined,
        unavailable: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = WafloV3Spacing.space12;
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  child: _MetricCard(metric: metric),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.key,
    required this.label,
    required this.value,
    required this.icon,
    this.unavailable = false,
  });

  final Key key;
  final String label;
  final String value;
  final IconData icon;
  final bool unavailable;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _MetricData metric;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      key: metric.key,
      padding: WafloV3Spacing.space16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                metric.icon,
                color: metric.unavailable
                    ? WafloV3Colors.primaryText.withValues(alpha: 0.45)
                    : WafloV3Colors.primary,
              ),
              const SizedBox(width: WafloV3Spacing.space8),
              Expanded(
                child: Text(
                  metric.label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: WafloV3Spacing.space12),
          if (metric.unavailable)
            WafloStatusBadge(
              label: metric.value,
              status: WafloStatusKind.inactive,
            )
          else
            Text(
              metric.value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
        ],
      ),
    );
  }
}

class _LoyaltyPanel extends StatelessWidget {
  const _LoyaltyPanel({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      key: const ValueKey('dashboard-v3-loyalty-panel'),
      warm: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: WafloV3Colors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(WafloV3Spacing.space12),
                  child: Icon(
                    Icons.loyalty_outlined,
                    color: WafloV3Colors.primary,
                  ),
                ),
              ),
              const SizedBox(width: WafloV3Spacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رجّع زبائنك ببرنامج ولاء',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: WafloV3Spacing.space8),
                    Text(
                      'افتح قسم الولاء لإعداد البرنامج أو متابعة بطاقات الزبائن.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: WafloV3Colors.primaryText.withValues(
                          alpha: 0.72,
                        ),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: WafloV3Spacing.space16),
          WafloSecondaryButton(
            key: const ValueKey('dashboard-v3-open-loyalty-action'),
            label: 'فتح الولاء',
            onPressed: enabled ? onPressed : null,
          ),
          if (!enabled) ...[
            const SizedBox(height: WafloV3Spacing.space8),
            const _HelperText(
              text: 'صلاحيتك الحالية لا تسمح بإدارة برنامج الولاء.',
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardLoadingState extends StatelessWidget {
  const _DashboardLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      key: ValueKey('dashboard-v3-loading'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WafloSkeleton(height: 280, radius: WafloV3Radius.largeCard),
        SizedBox(height: WafloV3Spacing.space24),
        WafloSkeleton(width: 140, height: WafloV3Spacing.space24),
        SizedBox(height: WafloV3Spacing.space12),
        WafloSkeleton(height: 132, radius: WafloV3Radius.standardCard),
        SizedBox(height: WafloV3Spacing.space12),
        WafloSkeleton(height: 132, radius: WafloV3Radius.standardCard),
      ],
    );
  }
}

class _HelperText extends StatelessWidget {
  const _HelperText({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: WafloV3Colors.primaryText.withValues(alpha: 0.62),
        height: 1.4,
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({
    required this.child,
    super.key,
    this.warm = false,
    this.padding = WafloV3Spacing.commonCardPadding,
  });

  final Widget child;
  final bool warm;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: warm
            ? Color.alphaBlend(
                WafloV3Colors.accent.withValues(alpha: 0.045),
                WafloV3Colors.surface,
              )
            : WafloV3Colors.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(WafloV3Radius.largeCard),
        ),
        border: Border.all(
          color: warm
              ? WafloV3Colors.primary.withValues(alpha: 0.14)
              : WafloV3Colors.primaryText.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: WafloV3Colors.primaryText.withValues(alpha: 0.045),
            blurRadius: WafloV3Spacing.space16,
            offset: const Offset(0, WafloV3Spacing.space4),
          ),
        ],
      ),
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    );
  }
}

bool _canManageMenu(DashboardState state) {
  return state.permissions?.canManageMenu ?? false;
}

bool _canScanCustomerWallet(DashboardState state) {
  return state.permissions?.canScanCustomerWallet ?? false;
}

bool _canAccessLoyalty(DashboardState state) {
  if (!state.hasKnownRole) {
    return false;
  }
  return state.effectiveRole == 'OWNER' ||
      state.effectiveRole == 'ADMIN' ||
      state.effectiveRole == 'MANAGER';
}
