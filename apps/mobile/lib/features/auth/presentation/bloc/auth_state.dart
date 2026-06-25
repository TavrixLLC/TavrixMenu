import 'package:equatable/equatable.dart';

import '../../domain/entities/current_user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  const AuthState({required this.status, this.user, this.errorMessage});

  const AuthState.initial() : this(status: AuthStatus.initial);

  final AuthStatus status;
  final CurrentUser? user;
  final String? errorMessage;

  bool get shouldOpenDashboard => user?.hasBusiness ?? false;

  AuthState copyWith({
    AuthStatus? status,
    CurrentUser? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
