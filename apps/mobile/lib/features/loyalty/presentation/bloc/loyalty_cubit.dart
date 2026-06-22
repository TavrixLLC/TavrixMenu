import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../business_setup/domain/entities/business.dart';
import '../../../business_setup/domain/usecases/get_my_business.dart';
import '../../../dashboard/domain/usecases/get_dashboard_summary.dart';
import '../../domain/entities/loyalty_membership.dart';
import '../../domain/entities/loyalty_requests.dart';
import '../../domain/usecases/add_loyalty_stamps.dart';
import '../../domain/usecases/create_loyalty_program.dart';
import '../../domain/usecases/enroll_loyalty_customer.dart';
import '../../domain/usecases/get_active_loyalty_program.dart';
import '../../domain/usecases/get_loyalty_membership.dart';
import '../../domain/usecases/list_loyalty_memberships.dart';
import '../../domain/usecases/list_loyalty_transactions.dart';
import '../../domain/usecases/redeem_loyalty_reward.dart';
import '../../domain/usecases/update_loyalty_program.dart';
import 'loyalty_state.dart';

class LoyaltyCubit extends Cubit<LoyaltyState> {
  LoyaltyCubit({
    required GetMyBusiness getMyBusiness,
    required GetDashboardSummary getDashboardSummary,
    required GetActiveLoyaltyProgram getActiveProgram,
    required CreateLoyaltyProgram createProgram,
    required UpdateLoyaltyProgram updateProgram,
    required EnrollLoyaltyCustomer enrollCustomer,
    required ListLoyaltyMemberships listMemberships,
    required GetLoyaltyMembership getMembership,
    required AddLoyaltyStamps addStamps,
    required RedeemLoyaltyReward redeemReward,
    required ListLoyaltyTransactions listTransactions,
  }) : _getMyBusiness = getMyBusiness,
       _getDashboardSummary = getDashboardSummary,
       _getActiveProgram = getActiveProgram,
       _createProgram = createProgram,
       _updateProgram = updateProgram,
       _enrollCustomer = enrollCustomer,
       _listMemberships = listMemberships,
       _getMembership = getMembership,
       _addStamps = addStamps,
       _redeemReward = redeemReward,
       _listTransactions = listTransactions,
       super(const LoyaltyState.initial());

  final GetMyBusiness _getMyBusiness;
  final GetDashboardSummary _getDashboardSummary;
  final GetActiveLoyaltyProgram _getActiveProgram;
  final CreateLoyaltyProgram _createProgram;
  final UpdateLoyaltyProgram _updateProgram;
  final EnrollLoyaltyCustomer _enrollCustomer;
  final ListLoyaltyMemberships _listMemberships;
  final GetLoyaltyMembership _getMembership;
  final AddLoyaltyStamps _addStamps;
  final RedeemLoyaltyReward _redeemReward;
  final ListLoyaltyTransactions _listTransactions;

  Future<void> load({String search = ''}) async {
    emit(
      state.copyWith(
        status: LoyaltyStatus.loading,
        searchQuery: search,
        isSearching: false,
        isDetailLoading: false,
        isMutating: false,
        clearError: true,
        clearSuccess: true,
        clearSummaryError: true,
      ),
    );

    final businessResult = await _getMyBusiness();
    await businessResult.fold(
      (failure) async => emit(
        LoyaltyState(
          status: LoyaltyStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      ),
      (business) async {
        var resolvedBusiness = business;
        var permissions = business.permissions;
        var role = _roleFromBusiness(business);
        String? summaryErrorMessage;

        if (business.id.trim().isNotEmpty) {
          final summaryResult = await _getDashboardSummary(business.id);
          summaryResult.fold(
            (failure) => summaryErrorMessage = failureMessage(failure),
            (summary) {
              resolvedBusiness = summary.business;
              permissions = summary.permissions;
              role = summary.currentUser.role;
            },
          );
        }

        final programResult = await _getActiveProgram(resolvedBusiness.id);
        await programResult.fold(
          (failure) async {
            if (_isRecoverableProgramLookupFailure(failure)) {
              emit(
                LoyaltyState(
                  status: LoyaltyStatus.success,
                  business: resolvedBusiness,
                  currentRole: role,
                  permissions: permissions,
                  memberships: const [],
                  searchQuery: search,
                  summaryErrorMessage: _joinNotes(
                    summaryErrorMessage,
                    'No active loyalty program is available yet. Owners and managers can set up a stamp card to start daily loyalty operations.',
                  ),
                ),
              );
              return;
            }

            emit(
              LoyaltyState(
                status: LoyaltyStatus.failure,
                business: resolvedBusiness,
                currentRole: role,
                permissions: permissions,
                summaryErrorMessage: summaryErrorMessage,
                errorMessage: failureMessage(failure),
              ),
            );
          },
          (program) async {
            var memberships = const <LoyaltyMembership>[];
            String? membershipErrorMessage;
            if (program != null) {
              final membershipsResult = await _listMemberships(
                businessId: resolvedBusiness.id,
                search: search,
              );
              membershipsResult.fold(
                (failure) => membershipErrorMessage = failureMessage(failure),
                (items) => memberships = items,
              );
            }

            emit(
              LoyaltyState(
                status: LoyaltyStatus.success,
                business: resolvedBusiness,
                currentRole: role,
                permissions: permissions,
                program: program,
                memberships: memberships,
                searchQuery: search,
                summaryErrorMessage: summaryErrorMessage,
                errorMessage: membershipErrorMessage,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> searchMemberships(String search) async {
    final business = state.business;
    if (business == null || business.id.trim().isEmpty) {
      return;
    }
    if (state.program == null) {
      emit(
        state.copyWith(
          status: LoyaltyStatus.success,
          memberships: const [],
          searchQuery: search,
          clearSelectedMembership: true,
          clearTransactions: true,
          clearError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: LoyaltyStatus.success,
        searchQuery: search,
        isSearching: true,
        clearError: true,
      ),
    );
    final result = await _listMemberships(
      businessId: business.id,
      search: search,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LoyaltyStatus.success,
          isSearching: false,
          errorMessage: failureMessage(failure),
        ),
      ),
      (memberships) => emit(
        state.copyWith(
          status: LoyaltyStatus.success,
          memberships: memberships,
          isSearching: false,
          searchQuery: search,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> createProgram(LoyaltyProgramRequest request) async {
    final business = state.business;
    if (business == null) {
      return;
    }
    if (!_ensureCanConfigureProgram()) {
      return;
    }
    final validationMessage = _programValidationMessage(request);
    if (validationMessage != null) {
      _emitOperationFailure(validationMessage);
      return;
    }

    emit(
      state.copyWith(isMutating: true, clearError: true, clearSuccess: true),
    );
    final result = await _createProgram(
      businessId: business.id,
      request: request,
    );
    await result.fold(
      (failure) async => _emitOperationFailure(failureMessage(failure)),
      (program) async {
        emit(
          state.copyWith(
            status: LoyaltyStatus.success,
            program: program,
            isMutating: false,
            successMessage: 'Loyalty program saved.',
            clearError: true,
          ),
        );
        await searchMemberships(state.searchQuery);
      },
    );
  }

  Future<void> updateProgram(LoyaltyProgramRequest request) async {
    final business = state.business;
    final program = state.program;
    if (business == null || program == null) {
      return;
    }
    if (!_ensureCanConfigureProgram()) {
      return;
    }
    final validationMessage = _programValidationMessage(request);
    if (validationMessage != null) {
      _emitOperationFailure(validationMessage);
      return;
    }

    emit(
      state.copyWith(isMutating: true, clearError: true, clearSuccess: true),
    );
    final result = await _updateProgram(
      businessId: business.id,
      programId: program.id,
      request: request,
    );
    result.fold(
      (failure) => _emitOperationFailure(failureMessage(failure)),
      (updatedProgram) => emit(
        state.copyWith(
          status: LoyaltyStatus.success,
          program: updatedProgram,
          isMutating: false,
          successMessage: 'Loyalty program updated.',
          clearError: true,
        ),
      ),
    );
  }

  Future<void> enrollCustomer(EnrollLoyaltyCustomerRequest request) async {
    final business = state.business;
    if (business == null) {
      return;
    }
    if (!_ensureCanUseDailyOperations()) {
      return;
    }
    if (!request.hasRequiredContact) {
      _emitOperationFailure('Enter a phone number or email before enrolling.');
      return;
    }

    emit(
      state.copyWith(isMutating: true, clearError: true, clearSuccess: true),
    );
    final resolvedRequest = EnrollLoyaltyCustomerRequest(
      phone: request.phone,
      email: request.email,
      name: request.name,
      programId: request.programId ?? state.program?.id,
    );
    final result = await _enrollCustomer(
      businessId: business.id,
      request: resolvedRequest,
    );
    await result.fold(
      (failure) async => _emitOperationFailure(failureMessage(failure)),
      (enrollResult) async {
        emit(
          state.copyWith(
            status: LoyaltyStatus.success,
            program: enrollResult.program,
            selectedMembership: enrollResult.membership,
            transactions: enrollResult.membership.transactions,
            isMutating: false,
            successMessage:
                'Customer membership is ready. Existing members keep their stamp progress.',
            clearError: true,
          ),
        );
        await searchMemberships(state.searchQuery);
        await selectMembership(enrollResult.membership.id);
      },
    );
  }

  Future<void> selectMembership(String membershipId) async {
    final business = state.business;
    if (business == null || membershipId.trim().isEmpty) {
      return;
    }
    final preview = state.memberships
        .where((membership) => membership.id == membershipId)
        .firstOrNull;
    emit(
      state.copyWith(
        status: LoyaltyStatus.success,
        selectedMembership: preview,
        isDetailLoading: true,
        clearSelectedMembership: preview == null,
        clearError: true,
      ),
    );

    final membershipResult = await _getMembership(
      businessId: business.id,
      membershipId: membershipId,
    );
    await membershipResult.fold(
      (failure) async => emit(
        state.copyWith(
          status: LoyaltyStatus.success,
          isDetailLoading: false,
          errorMessage: failureMessage(failure),
        ),
      ),
      (membership) async {
        var transactions = membership.transactions;
        String? transactionErrorMessage;
        final transactionResult = await _listTransactions(
          businessId: business.id,
          membershipId: membershipId,
        );
        transactionResult.fold(
          (failure) => transactionErrorMessage = failureMessage(failure),
          (items) => transactions = items,
        );

        emit(
          state.copyWith(
            status: LoyaltyStatus.success,
            selectedMembership: membership.copyWith(transactions: transactions),
            transactions: transactions,
            isDetailLoading: false,
            errorMessage: transactionErrorMessage,
            clearError: transactionErrorMessage == null,
          ),
        );
      },
    );
  }

  Future<void> addStamps({required int count, String? reason}) async {
    final business = state.business;
    final membership = state.selectedMembership;
    if (business == null || membership == null) {
      return;
    }
    if (!_ensureCanUseDailyOperations()) {
      return;
    }
    if (count < 1 || count > 10) {
      _emitOperationFailure('Choose a stamp count from 1 to 10.');
      return;
    }

    emit(
      state.copyWith(isMutating: true, clearError: true, clearSuccess: true),
    );
    final result = await _addStamps(
      businessId: business.id,
      membershipId: membership.id,
      request: AddStampsRequest(count: count, reason: reason),
    );
    await result.fold(
      (failure) async => _emitOperationFailure(failureMessage(failure)),
      (actionResult) async {
        final updated = membership.copyWith(
          stampCount: actionResult.membership.stampCount,
          rewardReady: actionResult.cardState.rewardReady,
          totalStampsEarned: actionResult.membership.totalStampsEarned,
          cardState: actionResult.cardState,
        );
        emit(
          state.copyWith(
            status: LoyaltyStatus.success,
            selectedMembership: updated,
            isMutating: false,
            successMessage: actionResult.cardState.rewardReady
                ? 'Stamp added. Reward is ready to redeem.'
                : 'Stamp added.',
            clearError: true,
          ),
        );
        await _refreshMembershipAfterMutation(updated.id);
      },
    );
  }

  Future<void> redeemReward({String? reason}) async {
    final business = state.business;
    final membership = state.selectedMembership;
    if (business == null || membership == null) {
      return;
    }
    if (!_ensureCanUseDailyOperations()) {
      return;
    }
    if (!membership.effectiveCardState.rewardReady) {
      _emitOperationFailure('This reward is not ready to redeem yet.');
      return;
    }

    emit(
      state.copyWith(isMutating: true, clearError: true, clearSuccess: true),
    );
    final result = await _redeemReward(
      businessId: business.id,
      membershipId: membership.id,
      request: RedeemRewardRequest(reason: reason),
    );
    await result.fold(
      (failure) async => _emitOperationFailure(failureMessage(failure)),
      (actionResult) async {
        final updated = membership.copyWith(
          stampCount: actionResult.membership.stampCount,
          rewardReady: actionResult.cardState.rewardReady,
          totalRewardsRedeemed: actionResult.membership.totalRewardsRedeemed,
          cardState: actionResult.cardState,
        );
        emit(
          state.copyWith(
            status: LoyaltyStatus.success,
            selectedMembership: updated,
            isMutating: false,
            successMessage: 'Reward redeemed. Stamp count reset to 0.',
            clearError: true,
          ),
        );
        await _refreshMembershipAfterMutation(updated.id);
      },
    );
  }

  Future<void> _refreshMembershipAfterMutation(String membershipId) async {
    await selectMembership(membershipId);
    await searchMemberships(state.searchQuery);
  }

  bool _ensureCanConfigureProgram() {
    if (state.canConfigureProgram) {
      return true;
    }

    _emitOperationFailure(
      'Only owners and managers can configure the loyalty program.',
    );
    return false;
  }

  bool _ensureCanUseDailyOperations() {
    if (state.canUseDailyOperations) {
      return true;
    }

    _emitOperationFailure(
      'Your role cannot perform loyalty daily operations for this business.',
    );
    return false;
  }

  String? _programValidationMessage(LoyaltyProgramRequest request) {
    if (request.name.trim().isEmpty) {
      return 'Enter a loyalty program name.';
    }
    if (request.stampGoal < 1 || request.stampGoal > 50) {
      return 'Stamp goal must be from 1 to 50.';
    }
    if (request.rewardName.trim().isEmpty) {
      return 'Enter a reward name.';
    }
    return null;
  }

  void _emitOperationFailure(String message) {
    emit(
      state.copyWith(
        status: LoyaltyStatus.success,
        isSearching: false,
        isDetailLoading: false,
        isMutating: false,
        errorMessage: message,
      ),
    );
  }

  String _roleFromBusiness(Business business) {
    final permissions = business.permissions;
    if (permissions?.canManageBusiness == true) {
      return 'OWNER';
    }
    if (permissions?.canManageMenu == true ||
        permissions?.canManageMembers == true) {
      return 'MANAGER';
    }
    return 'STAFF';
  }

  bool _isRecoverableProgramLookupFailure(Failure failure) {
    return failure is NotFoundFailure || failure is ServerFailure;
  }

  String _joinNotes(String? first, String second) {
    final cleanFirst = first?.trim();
    if (cleanFirst == null || cleanFirst.isEmpty) {
      return second;
    }
    return '$cleanFirst $second';
  }
}
