import 'package:equatable/equatable.dart';

import '../../domain/entities/current_user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.user,
    this.errorTitle,
    this.errorMessage,
  });

  const AuthState.initial() : this(status: AuthStatus.initial);

  final AuthStatus status;
  final CurrentUser? user;
  final String? errorTitle;
  final String? errorMessage;

  bool get shouldOpenDashboard => user?.hasBusiness ?? false;

  AuthState copyWith({
    AuthStatus? status,
    CurrentUser? user,
    String? errorTitle,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorTitle: clearError ? null : errorTitle ?? this.errorTitle,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorTitle, errorMessage];
}
