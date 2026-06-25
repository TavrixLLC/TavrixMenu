import 'package:equatable/equatable.dart';

import '../../../../core/utils/business_role.dart';
import '../../../business_setup/domain/entities/business.dart';
import '../../domain/entities/loyalty_membership.dart';
import '../../domain/entities/loyalty_program.dart';
import '../../domain/entities/loyalty_transaction.dart';

enum LoyaltyStatus { initial, loading, success, failure }

class LoyaltyState extends Equatable {
  const LoyaltyState({
    required this.status,
    this.business,
    this.currentRole = BusinessRole.operator,
    this.permissions,
    this.program,
    this.memberships = const [],
    this.selectedMembership,
    this.transactions = const [],
    this.searchQuery = '',
    this.isSearching = false,
    this.isDetailLoading = false,
    this.isMutating = false,
    this.errorMessage,
    this.successMessage,
    this.summaryErrorMessage,
  });

  const LoyaltyState.initial() : this(status: LoyaltyStatus.initial);

  final LoyaltyStatus status;
  final Business? business;
  final String currentRole;
  final BusinessPermissions? permissions;
  final LoyaltyProgram? program;
  final List<LoyaltyMembership> memberships;
  final LoyaltyMembership? selectedMembership;
  final List<LoyaltyTransaction> transactions;
  final String searchQuery;
  final bool isSearching;
  final bool isDetailLoading;
  final bool isMutating;
  final String? errorMessage;
  final String? successMessage;
  final String? summaryErrorMessage;

  bool get canUseDailyOperations {
    final currentPermissions = permissions;
    if (currentPermissions != null) {
      return currentPermissions.canManageMembers ||
          currentPermissions.canViewMembers;
    }
    final role = currentRole.toUpperCase();
    return role == BusinessRole.owner ||
        role == BusinessRole.manager ||
        role == BusinessRole.staff ||
        !BusinessRole.isKnown(role);
  }

  bool get canConfigureProgram {
    final currentPermissions = permissions;
    if (currentPermissions != null) {
      return currentPermissions.canManageBusiness ||
          currentPermissions.canManageMembers;
    }
    final role = currentRole.toUpperCase();
    if (!BusinessRole.isKnown(role)) {
      return true;
    }
    return role == BusinessRole.owner || role == BusinessRole.manager;
  }

  bool get canViewEnrollmentLink {
    final currentPermissions = permissions;
    if (currentPermissions != null) {
      return currentPermissions.canViewPublicLink ||
          currentPermissions.canViewMembers ||
          currentPermissions.canManageMembers;
    }
    final role = currentRole.toUpperCase();
    return role == BusinessRole.owner ||
        role == BusinessRole.manager ||
        role == BusinessRole.staff ||
        !BusinessRole.isKnown(role);
  }

  LoyaltyState copyWith({
    LoyaltyStatus? status,
    Business? business,
    String? currentRole,
    BusinessPermissions? permissions,
    LoyaltyProgram? program,
    List<LoyaltyMembership>? memberships,
    LoyaltyMembership? selectedMembership,
    List<LoyaltyTransaction>? transactions,
    String? searchQuery,
    bool? isSearching,
    bool? isDetailLoading,
    bool? isMutating,
    String? errorMessage,
    String? successMessage,
    String? summaryErrorMessage,
    bool clearProgram = false,
    bool clearSelectedMembership = false,
    bool clearTransactions = false,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSummaryError = false,
  }) {
    return LoyaltyState(
      status: status ?? this.status,
      business: business ?? this.business,
      currentRole: currentRole ?? this.currentRole,
      permissions: permissions ?? this.permissions,
      program: clearProgram ? null : program ?? this.program,
      memberships: memberships ?? this.memberships,
      selectedMembership: clearSelectedMembership
          ? null
          : selectedMembership ?? this.selectedMembership,
      transactions: clearTransactions
          ? const []
          : transactions ?? this.transactions,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
      summaryErrorMessage: clearSummaryError
          ? null
          : summaryErrorMessage ?? this.summaryErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    business,
    currentRole,
    permissions,
    program,
    memberships,
    selectedMembership,
    transactions,
    searchQuery,
    isSearching,
    isDetailLoading,
    isMutating,
    errorMessage,
    successMessage,
    summaryErrorMessage,
  ];
}
