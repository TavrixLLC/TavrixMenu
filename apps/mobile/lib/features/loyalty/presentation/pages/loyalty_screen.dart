import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/localization/localized_runtime_message.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/loyalty_card_state.dart';
import '../../domain/entities/loyalty_customer.dart';
import '../../domain/entities/loyalty_membership.dart';
import '../../domain/entities/loyalty_program.dart';
import '../../domain/entities/loyalty_requests.dart';
import '../../domain/entities/loyalty_transaction.dart';
import '../bloc/loyalty_cubit.dart';
import '../bloc/loyalty_state.dart';
import '../widgets/loyalty_enrollment_card.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({
    super.key,
    this.customerWebBaseUrl = '',
    this.embeddedInWorkspaceShell = false,
  });

  final String customerWebBaseUrl;
  final bool embeddedInWorkspaceShell;

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoyaltyCubit>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.loyaltyTitle,
      embeddedInWorkspaceShell: widget.embeddedInWorkspaceShell,
      scrollable: true,
      child: BlocBuilder<LoyaltyCubit, LoyaltyState>(
        builder: (context, state) {
          if (state.status == LoyaltyStatus.loading ||
              state.status == LoyaltyStatus.initial) {
            return LoadingView(message: context.l10n.loyaltyLoading);
          }

          if (state.status == LoyaltyStatus.failure) {
            return ErrorView(
              message: localizedRuntimeMessage(
                context.l10n,
                state.errorMessage,
                fallback: context.l10n.loyaltyLoadFailed,
              ),
              onRetry: () => context.read<LoyaltyCubit>().load(),
            );
          }

          final business = state.business;
          if (business == null) {
            return EmptyState(
              title: context.l10n.businessProfileMissingTitle,
              message: context.l10n.loyaltySetupNeeded,
              icon: Icons.storefront,
            );
          }

          if (_searchController.text != state.searchQuery) {
            _searchController.text = state.searchQuery;
            _searchController.selection = TextSelection.collapsed(
              offset: _searchController.text.length,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.embeddedInWorkspaceShell) ...[
                SectionHeader(
                  title: business.name,
                  subtitle: context.l10n.loyaltyWorkspaceBody,
                ),
              ],
              if (state.canUseDailyOperations) ...[
                if (!widget.embeddedInWorkspaceShell)
                  SizedBox(height: AppSpacing.md),
                AppButton(
                  label: context.l10n.staffScannerTitle,
                  icon: Icons.document_scanner_outlined,
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRouteNames.walletScan),
                  variant: AppButtonVariant.secondary,
                ),
              ],
              if (state.summaryErrorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                _LoyaltyNotice(
                  title: context.l10n.loyaltyStatusNote,
                  message: localizedRuntimeMessage(
                    context.l10n,
                    state.summaryErrorMessage,
                  ),
                ),
              ],
              if (state.successMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                _LoyaltyNotice(
                  title: context.l10n.genericDone,
                  message: _localizedSuccessMessage(
                    context.l10n,
                    state.successMessage!,
                  ),
                  icon: Icons.check_circle_outline,
                ),
              ],
              if (state.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                ErrorView(
                  message: localizedRuntimeMessage(
                    context.l10n,
                    state.errorMessage,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _ProgramSection(
                state: state,
                onSetup: () => _showProgramDialog(context),
                onEdit: (program) =>
                    _showProgramDialog(context, program: program),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (state.canViewEnrollmentLink &&
                  state.program?.isActive == true)
                LoyaltyEnrollmentCard(
                  businessSlug: business.slug,
                  customerWebBaseUrl: widget.customerWebBaseUrl,
                  publicMenuUrl: business.publicMenuUrl,
                )
              else
                _LoyaltyNotice(
                  title: state.program?.isActive == true
                      ? context.l10n.loyaltyEnrollmentUnavailableTitle
                      : context.l10n.loyaltyInactiveTitle,
                  message: state.program?.isActive == true
                      ? context.l10n.loyaltyEnrollmentUnavailableBody
                      : context.l10n.loyaltyInactiveBody,
                ),
              if (state.program != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _SearchEnrollSection(
                  controller: _searchController,
                  state: state,
                  onSearch: () => context
                      .read<LoyaltyCubit>()
                      .searchMemberships(_searchController.text),
                  onClear: () {
                    _searchController.clear();
                    context.read<LoyaltyCubit>().searchMemberships('');
                  },
                  onEnroll: () => _showEnrollDialog(context),
                ),
                const SizedBox(height: AppSpacing.lg),
                _MembershipResultsSection(state: state),
                const SizedBox(height: AppSpacing.lg),
                _SelectedMembershipSection(
                  state: state,
                  onAddStamp: () => _showAddStampDialog(context),
                  onRedeem: () => _showRedeemDialog(context),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _showProgramDialog(
    BuildContext context, {
    LoyaltyProgram? program,
  }) async {
    final nameController = TextEditingController(text: program?.name ?? '');
    final goalController = TextEditingController(
      text: (program?.stampGoal ?? 5).toString(),
    );
    final rewardController = TextEditingController(
      text: program?.rewardName ?? '',
    );
    final descriptionController = TextEditingController(
      text: program?.description ?? '',
    );
    final rewardDescriptionController = TextEditingController(
      text: program?.rewardDescription ?? '',
    );
    final termsController = TextEditingController(text: program?.terms ?? '');

    try {
      final request = await showDialog<LoyaltyProgramRequest>(
        context: context,
        builder: (dialogContext) {
          String? error;
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  program == null
                      ? context.l10n.setUpLoyaltyProgram
                      : context.l10n.editProgram,
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (error != null) ...[
                        Text(
                          error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: context.l10n.programName,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: goalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.l10n.stampGoal,
                          hintText: '5',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: rewardController,
                        decoration: InputDecoration(
                          labelText: context.l10n.rewardName,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: descriptionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: context.l10n.description,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: rewardDescriptionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: context.l10n.rewardDescription,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: termsController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: context.l10n.terms,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(context.l10n.genericCancel),
                  ),
                  FilledButton(
                    onPressed: () {
                      final goal = int.tryParse(goalController.text.trim());
                      if (nameController.text.trim().isEmpty) {
                        setState(
                          () => error = context.l10n.programNameRequired,
                        );
                        return;
                      }
                      if (goal == null || goal < 1 || goal > 50) {
                        setState(() => error = context.l10n.stampGoalInvalid);
                        return;
                      }
                      if (rewardController.text.trim().isEmpty) {
                        setState(() => error = context.l10n.rewardNameRequired);
                        return;
                      }

                      Navigator.of(dialogContext).pop(
                        LoyaltyProgramRequest(
                          name: nameController.text,
                          stampGoal: goal,
                          rewardName: rewardController.text,
                          description: descriptionController.text,
                          rewardDescription: rewardDescriptionController.text,
                          terms: termsController.text,
                        ),
                      );
                    },
                    child: Text(context.l10n.genericSave),
                  ),
                ],
              );
            },
          );
        },
      );

      if (request == null || !context.mounted) {
        return;
      }
      final cubit = context.read<LoyaltyCubit>();
      if (program == null) {
        await cubit.createProgram(request);
      } else {
        await cubit.updateProgram(request);
      }
    } finally {
      nameController.dispose();
      goalController.dispose();
      rewardController.dispose();
      descriptionController.dispose();
      rewardDescriptionController.dispose();
      termsController.dispose();
    }
  }

  Future<void> _showEnrollDialog(BuildContext context) async {
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final nameController = TextEditingController();

    try {
      final request = await showDialog<EnrollLoyaltyCustomerRequest>(
        context: context,
        builder: (dialogContext) {
          String? error;
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(context.l10n.enrollCustomer),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (error != null) ...[
                        Text(
                          error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: context.l10n.phone,
                          hintText: context.l10n.phoneOrEmailHint,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: context.l10n.email,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: context.l10n.customerName,
                          hintText: context.l10n.customerNameHint,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(context.l10n.genericCancel),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (phoneController.text.trim().isEmpty &&
                          emailController.text.trim().isEmpty) {
                        setState(() => error = context.l10n.contactRequired);
                        return;
                      }

                      Navigator.of(dialogContext).pop(
                        EnrollLoyaltyCustomerRequest(
                          phone: phoneController.text,
                          email: emailController.text,
                          name: nameController.text,
                        ),
                      );
                    },
                    child: Text(context.l10n.enrollCustomer),
                  ),
                ],
              );
            },
          );
        },
      );

      if (request != null && context.mounted) {
        await context.read<LoyaltyCubit>().enrollCustomer(request);
      }
    } finally {
      phoneController.dispose();
      emailController.dispose();
      nameController.dispose();
    }
  }

  Future<void> _showAddStampDialog(BuildContext context) async {
    final reasonController = TextEditingController();
    try {
      final request = await showDialog<AddStampsRequest>(
        context: context,
        builder: (dialogContext) {
          var count = 1;
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(context.l10n.addStampTitle),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: count,
                      decoration: InputDecoration(
                        labelText: context.l10n.count,
                      ),
                      items: [
                        for (var value = 1; value <= 10; value++)
                          DropdownMenuItem(value: value, child: Text('$value')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => count = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        labelText: context.l10n.reason,
                        hintText: context.l10n.stampReasonHint,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(context.l10n.genericCancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(
                      AddStampsRequest(
                        count: count,
                        reason: reasonController.text,
                      ),
                    ),
                    child: Text(context.l10n.addAction),
                  ),
                ],
              );
            },
          );
        },
      );

      if (request != null && context.mounted) {
        await context.read<LoyaltyCubit>().addStamps(
          count: request.count,
          reason: request.reason,
        );
      }
    } finally {
      reasonController.dispose();
    }
  }

  Future<void> _showRedeemDialog(BuildContext context) async {
    final reasonController = TextEditingController();
    try {
      final request = await showDialog<RedeemRewardRequest>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(context.l10n.redeemRewardQuestion),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.redeemConfirmBody),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: context.l10n.reason,
                    hintText: context.l10n.redeemReasonHint,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(context.l10n.genericCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(
                  dialogContext,
                ).pop(RedeemRewardRequest(reason: reasonController.text)),
                child: Text(context.l10n.redeemReward),
              ),
            ],
          );
        },
      );

      if (request != null && context.mounted) {
        await context.read<LoyaltyCubit>().redeemReward(reason: request.reason);
      }
    } finally {
      reasonController.dispose();
    }
  }
}

class _ProgramSection extends StatelessWidget {
  const _ProgramSection({
    required this.state,
    required this.onSetup,
    required this.onEdit,
  });

  final LoyaltyState state;
  final VoidCallback onSetup;
  final ValueChanged<LoyaltyProgram> onEdit;

  @override
  Widget build(BuildContext context) {
    final program = state.program;
    if (program == null) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.loyalty_outlined),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.noActiveLoyaltyProgram,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              state.canConfigureProgram
                  ? context.l10n.loyaltySetupOwnerBody
                  : context.l10n.loyaltySetupStaffBody,
            ),
            if (state.canConfigureProgram) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: context.l10n.setUpStampCard,
                icon: Icons.add_card_outlined,
                onPressed: state.isMutating ? null : onSetup,
              ),
            ],
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.loyalty_outlined),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.programRewardRule(
                        program.stampGoal,
                        program.rewardName,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: program.isActive
                    ? context.l10n.genericActive
                    : context.l10n.genericInactive,
              ),
            ],
          ),
          if ((program.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(program.description!),
          ],
          if ((program.rewardDescription ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(program.rewardDescription!),
          ],
          if ((program.terms ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.termsValue(program.terms!),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (state.canConfigureProgram) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: context.l10n.editProgram,
              icon: Icons.edit_outlined,
              onPressed: state.isMutating ? null : () => onEdit(program),
              variant: AppButtonVariant.secondary,
            ),
          ],
          if (!state.canConfigureProgram) ...[
            const SizedBox(height: AppSpacing.md),
            _LoyaltyNotice(
              title: context.l10n.viewOnlyProgramAccess,
              message: context.l10n.viewOnlyProgramBody,
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchEnrollSection extends StatelessWidget {
  const _SearchEnrollSection({
    required this.controller,
    required this.state,
    required this.onSearch,
    required this.onClear,
    required this.onEnroll,
  });

  final TextEditingController controller;
  final LoyaltyState state;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final VoidCallback onEnroll;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.customerLookup,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            decoration: InputDecoration(
              labelText: context.l10n.searchMembers,
              suffixIcon: IconButton(
                tooltip: context.l10n.genericSearch,
                icon: const Icon(Icons.search),
                onPressed: state.isSearching ? null : onSearch,
              ),
            ),
          ),
          if (state.isSearching) ...[
            const SizedBox(height: AppSpacing.md),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(
                label: context.l10n.genericSearch,
                icon: Icons.search,
                onPressed: state.isSearching ? null : onSearch,
                expand: false,
              ),
              AppButton(
                label: context.l10n.genericShowAll,
                icon: Icons.list_alt,
                onPressed: state.isSearching ? null : onClear,
                variant: AppButtonVariant.secondary,
                expand: false,
              ),
              AppButton(
                label: context.l10n.enrollCustomer,
                icon: Icons.person_add_alt_1,
                onPressed: state.isMutating ? null : onEnroll,
                variant: AppButtonVariant.secondary,
                expand: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MembershipResultsSection extends StatelessWidget {
  const _MembershipResultsSection({required this.state});

  final LoyaltyState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: context.l10n.memberships,
          subtitle: context.l10n.membershipHelp,
        ),
        const SizedBox(height: AppSpacing.md),
        if (state.memberships.isEmpty)
          EmptyState(
            title: state.searchQuery.trim().isEmpty
                ? context.l10n.noLoyaltyMembers
                : context.l10n.noMembershipMatches,
            message: state.searchQuery.trim().isEmpty
                ? context.l10n.noLoyaltyMembersBody
                : context.l10n.noMembershipMatchesBody,
            icon: Icons.people_outline,
          )
        else
          Column(
            children: [
              for (final membership in state.memberships) ...[
                _MembershipResultCard(
                  membership: membership,
                  selected: membership.id == state.selectedMembership?.id,
                  onTap: () => context.read<LoyaltyCubit>().selectMembership(
                    membership.id,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
      ],
    );
  }
}

class _MembershipResultCard extends StatelessWidget {
  const _MembershipResultCard({
    required this.membership,
    required this.selected,
    required this.onTap,
  });

  final LoyaltyMembership membership;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final customer = membership.customer;
    final cardState = membership.effectiveCardState;
    return AppCard(
      onTap: onTap,
      color: selected ? AppColors.greenLight : AppColors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person_outline),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer?.displayName ?? context.l10n.loyaltyCustomer,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(_contactLine(context.l10n, customer)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.cardStampProgress(
                    cardState.stampCount,
                    cardState.stampGoal,
                    cardState.rewardName,
                  ),
                ),
              ],
            ),
          ),
          if (cardState.rewardReady)
            StatusBadge(
              label: context.l10n.rewardReady,
              color: AppColors.warning,
              foregroundColor: AppColors.textBlack,
            ),
        ],
      ),
    );
  }
}

class _SelectedMembershipSection extends StatelessWidget {
  const _SelectedMembershipSection({
    required this.state,
    required this.onAddStamp,
    required this.onRedeem,
  });

  final LoyaltyState state;
  final VoidCallback onAddStamp;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final membership = state.selectedMembership;
    if (membership == null) {
      return EmptyState(
        title: context.l10n.selectMembership,
        message: context.l10n.selectMembershipBody,
        icon: Icons.credit_card,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.isDetailLoading) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
        ],
        _CardStateCard(membership: membership),
        const SizedBox(height: AppSpacing.md),
        _MembershipActionsCard(
          membership: membership,
          isMutating: state.isMutating,
          onAddStamp: onAddStamp,
          onRedeem: onRedeem,
        ),
        const SizedBox(height: AppSpacing.lg),
        _TransactionsSection(transactions: state.transactions),
      ],
    );
  }
}

class _CardStateCard extends StatelessWidget {
  const _CardStateCard({required this.membership});

  final LoyaltyMembership membership;

  @override
  Widget build(BuildContext context) {
    final customer = membership.customer;
    final cardState = membership.effectiveCardState;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.card_membership_outlined),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer?.displayName ?? context.l10n.loyaltyCustomer,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(_contactLine(context.l10n, customer)),
                  ],
                ),
              ),
              if (cardState.rewardReady)
                StatusBadge(
                  label: context.l10n.genericReady,
                  color: AppColors.warning,
                  foregroundColor: AppColors.textBlack,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(cardState.programName),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.cardStampCount(
              cardState.stampCount,
              cardState.stampGoal,
            ),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(value: cardState.progressRatio),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.progressTowardReward(
              cardState.progressPercent,
              cardState.rewardName,
            ),
          ),
          if (cardState.rewardReady) ...[
            const SizedBox(height: AppSpacing.md),
            _RewardReadyBanner(cardState: cardState),
          ],
        ],
      ),
    );
  }
}

class _RewardReadyBanner extends StatelessWidget {
  const _RewardReadyBanner({required this.cardState});

  final LoyaltyCardState cardState;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.redeem_outlined),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                context.l10n.rewardReadyMessage(cardState.rewardName),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MembershipActionsCard extends StatelessWidget {
  const _MembershipActionsCard({
    required this.membership,
    required this.isMutating,
    required this.onAddStamp,
    required this.onRedeem,
  });

  final LoyaltyMembership membership;
  final bool isMutating;
  final VoidCallback onAddStamp;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final cardState = membership.effectiveCardState;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.actions,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(
                label: context.l10n.addStampTitle,
                icon: Icons.add_circle_outline,
                onPressed: isMutating ? null : onAddStamp,
                expand: false,
              ),
              if (cardState.rewardReady)
                AppButton(
                  label: context.l10n.redeemReward,
                  icon: Icons.redeem,
                  onPressed: isMutating ? null : onRedeem,
                  variant: AppButtonVariant.danger,
                  expand: false,
                ),
            ],
          ),
          if (!cardState.rewardReady) ...[
            const SizedBox(height: AppSpacing.md),
            Text(context.l10n.redeemAvailableAt(cardState.stampGoal)),
          ],
          if (isMutating) ...[
            const SizedBox(height: AppSpacing.md),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

class _TransactionsSection extends StatelessWidget {
  const _TransactionsSection({required this.transactions});

  final List<LoyaltyTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: context.l10n.recentTransactions),
        const SizedBox(height: AppSpacing.md),
        if (transactions.isEmpty)
          EmptyState(
            title: context.l10n.noTransactionsTitle,
            message: context.l10n.noTransactionsBody,
            icon: Icons.receipt_long_outlined,
          )
        else
          Column(
            children: [
              for (final transaction in transactions.take(8)) ...[
                _TransactionCard(transaction: transaction),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final LoyaltyTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_transactionIcon(transaction.type)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _transactionLabel(context.l10n, transaction.type),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(_formatStampDelta(context.l10n, transaction.stampsDelta)),
                if ((transaction.reason ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(transaction.reason!),
                ],
                if ((transaction.createdAt ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatDate(transaction.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoyaltyNotice extends StatelessWidget {
  const _LoyaltyNotice({
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
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

String _localizedSuccessMessage(
  AppLocalizations localizations,
  String message,
) {
  final normalized = message.trim().toLowerCase();
  if (normalized.contains('program saved')) {
    return localizations.loyaltyProgramSaved;
  }
  if (normalized.contains('program updated')) {
    return localizations.loyaltyProgramUpdated;
  }
  if (normalized.contains('stamp')) {
    return localizations.stampSuccess;
  }
  return localizations.loyaltyOperationCompleted;
}

String _contactLine(AppLocalizations localizations, LoyaltyCustomer? customer) {
  if (customer == null) {
    return localizations.noCustomerContact;
  }

  final parts = [
    customer.phone,
    customer.email,
  ].where((value) => value != null && value.trim().isNotEmpty).cast<String>();
  final line = parts.join(' • ');
  return line.isEmpty ? localizations.noCustomerContact : line;
}

String _transactionLabel(AppLocalizations localizations, String type) {
  return switch (type.toUpperCase()) {
    'STAMP_ADDED' => localizations.stampAddedTransaction,
    'REWARD_REDEEMED' => localizations.rewardRedeemedTransaction,
    'ADJUSTMENT' => localizations.adjustmentTransaction,
    'VOID' => localizations.voidTransaction,
    _ => localizations.unknownTransaction,
  };
}

IconData _transactionIcon(String type) {
  return switch (type.toUpperCase()) {
    'STAMP_ADDED' => Icons.add_circle_outline,
    'REWARD_REDEEMED' => Icons.redeem_outlined,
    'ADJUSTMENT' => Icons.tune_outlined,
    'VOID' => Icons.block_outlined,
    _ => Icons.receipt_long_outlined,
  };
}

String _formatStampDelta(AppLocalizations localizations, int delta) {
  if (delta > 0) {
    return localizations.positiveStampDelta(delta);
  }
  if (delta < 0) {
    return localizations.negativeStampDelta(delta);
  }
  return localizations.noStampChange;
}

String _formatDate(String? value) {
  final raw = value?.trim();
  if (raw == null || raw.isEmpty) {
    return '';
  }

  final date = DateTime.tryParse(raw);
  if (date == null) {
    return raw;
  }

  final local = date.toLocal();
  return '${local.year}-${_two(local.month)}-${_two(local.day)} '
      '${_two(local.hour)}:${_two(local.minute)}';
}

String _two(int value) => value.toString().padLeft(2, '0');
