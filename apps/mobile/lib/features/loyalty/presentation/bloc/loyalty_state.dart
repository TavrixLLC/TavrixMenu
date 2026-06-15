import 'package:equatable/equatable.dart';

import '../../../business_setup/domain/entities/business.dart';
import '../../domain/entities/loyalty_membership.dart';
import '../../domain/entities/loyalty_program.dart';
import '../../domain/entities/loyalty_stamp_style.dart';
import '../../domain/entities/loyalty_transaction.dart';

enum LoyaltyStatus { initial, loading, success, failure }

class LoyaltyState extends Equatable {
  const LoyaltyState({
    required this.status,
    this.business,
    this.currentRole = 'STAFF',
    this.permissions,
    this.program,
    this.stampPresets,
    this.stampStyle,
    this.memberships = const [],
    this.selectedMembership,
    this.transactions = const [],
    this.searchQuery = '',
    this.isSearching = false,
    this.isDetailLoading = false,
    this.isMutating = false,
    this.isLoadingStampPresets = false,
    this.isLoadingStampStyle = false,
    this.isSavingStampStyle = false,
    this.stampStyleSaveSuccess = false,
    this.errorMessage,
    this.successMessage,
    this.summaryErrorMessage,
    this.stampStyleError,
  });

  const LoyaltyState.initial() : this(status: LoyaltyStatus.initial);

  final LoyaltyStatus status;
  final Business? business;
  final String currentRole;
  final BusinessPermissions? permissions;
  final LoyaltyProgram? program;
  final LoyaltyStampPresets? stampPresets;
  final LoyaltyStampStyle? stampStyle;
  final List<LoyaltyMembership> memberships;
  final LoyaltyMembership? selectedMembership;
  final List<LoyaltyTransaction> transactions;
  final String searchQuery;
  final bool isSearching;
  final bool isDetailLoading;
  final bool isMutating;
  final bool isLoadingStampPresets;
  final bool isLoadingStampStyle;
  final bool isSavingStampStyle;
  final bool stampStyleSaveSuccess;
  final String? errorMessage;
  final String? successMessage;
  final String? summaryErrorMessage;
  final String? stampStyleError;

  bool get canUseDailyOperations {
    final role = currentRole.toUpperCase();
    return role == 'OWNER' || role == 'MANAGER' || role == 'STAFF';
  }

  bool get canConfigureProgram {
    final role = currentRole.toUpperCase();
    return role == 'OWNER' || role == 'MANAGER';
  }

  bool get canConfigureStampStyle => canConfigureProgram;

  bool get canViewEnrollmentLink {
    final role = currentRole.toUpperCase();
    return role == 'OWNER' || role == 'MANAGER' || role == 'STAFF';
  }

  LoyaltyState copyWith({
    LoyaltyStatus? status,
    Business? business,
    String? currentRole,
    BusinessPermissions? permissions,
    LoyaltyProgram? program,
    LoyaltyStampPresets? stampPresets,
    LoyaltyStampStyle? stampStyle,
    List<LoyaltyMembership>? memberships,
    LoyaltyMembership? selectedMembership,
    List<LoyaltyTransaction>? transactions,
    String? searchQuery,
    bool? isSearching,
    bool? isDetailLoading,
    bool? isMutating,
    bool? isLoadingStampPresets,
    bool? isLoadingStampStyle,
    bool? isSavingStampStyle,
    bool? stampStyleSaveSuccess,
    String? errorMessage,
    String? successMessage,
    String? summaryErrorMessage,
    String? stampStyleError,
    bool clearProgram = false,
    bool clearStampPresets = false,
    bool clearStampStyle = false,
    bool clearSelectedMembership = false,
    bool clearTransactions = false,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSummaryError = false,
    bool clearStampStyleError = false,
    bool clearStampStyleSaveSuccess = false,
  }) {
    return LoyaltyState(
      status: status ?? this.status,
      business: business ?? this.business,
      currentRole: currentRole ?? this.currentRole,
      permissions: permissions ?? this.permissions,
      program: clearProgram ? null : program ?? this.program,
      stampPresets: clearStampPresets
          ? null
          : stampPresets ?? this.stampPresets,
      stampStyle: clearStampStyle ? null : stampStyle ?? this.stampStyle,
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
      isLoadingStampPresets:
          isLoadingStampPresets ?? this.isLoadingStampPresets,
      isLoadingStampStyle: isLoadingStampStyle ?? this.isLoadingStampStyle,
      isSavingStampStyle: isSavingStampStyle ?? this.isSavingStampStyle,
      stampStyleSaveSuccess: clearStampStyleSaveSuccess
          ? false
          : stampStyleSaveSuccess ?? this.stampStyleSaveSuccess,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
      summaryErrorMessage: clearSummaryError
          ? null
          : summaryErrorMessage ?? this.summaryErrorMessage,
      stampStyleError: clearStampStyleError
          ? null
          : stampStyleError ?? this.stampStyleError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    business,
    currentRole,
    permissions,
    program,
    stampPresets,
    stampStyle,
    memberships,
    selectedMembership,
    transactions,
    searchQuery,
    isSearching,
    isDetailLoading,
    isMutating,
    isLoadingStampPresets,
    isLoadingStampStyle,
    isSavingStampStyle,
    stampStyleSaveSuccess,
    errorMessage,
    successMessage,
    summaryErrorMessage,
    stampStyleError,
  ];
}
