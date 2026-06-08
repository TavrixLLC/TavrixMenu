import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/current_user.dart';
import '../../../business_setup/domain/entities/business.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    required this.status,
    this.user,
    this.business,
    this.errorMessage,
  });

  const DashboardState.initial() : this(status: DashboardStatus.initial);

  final DashboardStatus status;
  final CurrentUser? user;
  final Business? business;
  final String? errorMessage;

  DashboardState copyWith({
    DashboardStatus? status,
    CurrentUser? user,
    Business? business,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      user: user ?? this.user,
      business: business ?? this.business,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, business, errorMessage];
}
