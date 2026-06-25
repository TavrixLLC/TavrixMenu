import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/current_user.dart';
import '../../../business_setup/domain/entities/business.dart';
import '../../../../core/utils/business_role.dart';
import '../../domain/entities/dashboard_summary.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    required this.status,
    this.user,
    this.business,
    this.summary,
    this.errorMessage,
    this.summaryErrorMessage,
  });

  const DashboardState.initial() : this(status: DashboardStatus.initial);

  final DashboardStatus status;
  final CurrentUser? user;
  final Business? business;
  final DashboardSummary? summary;
  final String? errorMessage;
  final String? summaryErrorMessage;

  BusinessPermissions? get permissions {
    final currentSummary = summary;
    if (currentSummary != null &&
        currentSummary.currentUser.permissionsAvailable) {
      return currentSummary.permissions;
    }
    return business?.permissions;
  }

  String? get backendRole {
    final role = summary?.currentUser.role ?? user?.role;
    return BusinessRole.isKnown(role) ? BusinessRole.normalize(role) : null;
  }

  String get effectiveRole => backendRole ?? BusinessRole.operator;

  String get roleDisplayLabel => BusinessRole.displayLabel(effectiveRole);

  bool get hasKnownRole => backendRole != null;

  DashboardState copyWith({
    DashboardStatus? status,
    CurrentUser? user,
    Business? business,
    DashboardSummary? summary,
    String? errorMessage,
    String? summaryErrorMessage,
    bool clearError = false,
    bool clearSummaryError = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      user: user ?? this.user,
      business: business ?? this.business,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      summaryErrorMessage: clearSummaryError
          ? null
          : summaryErrorMessage ?? this.summaryErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    business,
    summary,
    errorMessage,
    summaryErrorMessage,
  ];
}
