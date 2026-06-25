import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/auth_session_controller.dart';
import '../../domain/usecases/get_current_user.dart';
import '../utils/auth_error_copy.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required GetCurrentUser getCurrentUser,
    required AuthSessionController authSessionController,
  }) : _authSessionController = authSessionController,
       _getCurrentUser = getCurrentUser,
       super(const AuthState.initial());

  final GetCurrentUser _getCurrentUser;
  final AuthSessionController _authSessionController;

  Future<void> restoreSession() async {
    if (!_authSessionController.canUseClerkAuth ||
        !_authSessionController.hasClerkSession) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }

    await signInWithClerk();
  }

  Future<void> signInWithClerk() async {
    if (!_authSessionController.canUseClerkAuth) {
      emit(
        const AuthState(
          status: AuthStatus.failure,
          errorTitle: 'Sign in unavailable',
          errorMessage: 'Clerk is not configured for this build.',
        ),
      );
      return;
    }

    _authSessionController.useClerk();
    await _loadCurrentUser();
  }

  Future<void> signInDevMode() async {
    if (!_authSessionController.canUseDevAuth) {
      emit(
        const AuthState(
          status: AuthStatus.failure,
          errorTitle: 'Sign in unavailable',
          errorMessage: 'Development login is disabled for this build.',
        ),
      );
      return;
    }

    _authSessionController.useDevelopment();
    await _loadCurrentUser();
  }

  Future<void> refreshCurrentUser() {
    return _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final result = await _getCurrentUser();
    result.fold((failure) {
      final copy = authErrorCopyFromFailure(failure);
      emit(
        AuthState(
          status: AuthStatus.failure,
          errorTitle: copy.title,
          errorMessage: copy.body,
        ),
      );
    }, (user) => emit(AuthState(status: AuthStatus.authenticated, user: user)));
  }

  Future<void> signOut() async {
    await _authSessionController.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
