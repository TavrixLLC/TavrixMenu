import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/failure_message.dart';
import '../../domain/usecases/get_current_user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required GetCurrentUser getCurrentUser})
    : _getCurrentUser = getCurrentUser,
      super(const AuthState.initial());

  final GetCurrentUser _getCurrentUser;

  Future<void> signInDevMode() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final result = await _getCurrentUser();
    result.fold(
      (failure) => emit(
        AuthState(
          status: AuthStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      ),
      (user) => emit(AuthState(status: AuthStatus.authenticated, user: user)),
    );
  }

  void signOut() {
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
