import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/current_user.dart';
import '../../../business_setup/domain/entities/business.dart';
import '../../../business_setup/domain/entities/business_app_context.dart';

enum DashboardStatus { initial, loading, success, noBusiness, failure }

class DashboardState extends Equatable {
  const DashboardState({
    required this.status,
    this.user,
    this.business,
    this.appContext,
    this.errorMessage,
  });

  const DashboardState.initial() : this(status: DashboardStatus.initial);

  final DashboardStatus status;
  final CurrentUser? user;
  final Business? business;
  final BusinessAppContext? appContext;
  final String? errorMessage;

  DashboardState copyWith({
    DashboardStatus? status,
    CurrentUser? user,
    Business? business,
    BusinessAppContext? appContext,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      user: user ?? this.user,
      business: business ?? this.business,
      appContext: appContext ?? this.appContext,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, business, appContext, errorMessage];
}
