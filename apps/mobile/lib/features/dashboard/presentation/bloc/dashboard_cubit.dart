import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../auth/domain/entities/current_user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../business_setup/domain/usecases/get_my_business.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required GetCurrentUser getCurrentUser,
    required GetMyBusinesses getMyBusinesses,
  }) : _getCurrentUser = getCurrentUser,
       _getMyBusinesses = getMyBusinesses,
       super(const DashboardState.initial());

  final GetCurrentUser _getCurrentUser;
  final GetMyBusinesses _getMyBusinesses;

  Future<void> load({CurrentUser? currentUser}) async {
    emit(state.copyWith(status: DashboardStatus.loading, clearError: true));

    final user = currentUser ?? await _loadCurrentUser();
    if (user == null) {
      return;
    }

    final businessFromMe = user.activeBusiness;
    if (businessFromMe != null) {
      emit(
        DashboardState(
          status: DashboardStatus.success,
          user: user,
          business: businessFromMe,
        ),
      );
      return;
    }

    final businessesResult = await _getMyBusinesses();
    businessesResult.fold(
      (failure) {
        if (failure is NotFoundFailure) {
          emit(
            DashboardState(
              status: DashboardStatus.needsBusinessSetup,
              user: user,
            ),
          );
          return;
        }

        emit(
          DashboardState(
            status: DashboardStatus.failure,
            user: user,
            errorMessage: failureMessage(failure),
          ),
        );
      },
      (businesses) {
        if (businesses.isEmpty) {
          emit(
            DashboardState(
              status: DashboardStatus.needsBusinessSetup,
              user: user,
            ),
          );
          return;
        }

        emit(
          DashboardState(
            status: DashboardStatus.success,
            user: user,
            business: businesses.first,
          ),
        );
      },
    );
  }

  Future<CurrentUser?> _loadCurrentUser() async {
    final userResult = await _getCurrentUser();
    return userResult.fold((failure) {
      emit(
        DashboardState(
          status: DashboardStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      );
      return null;
    }, (user) => user);
  }
}
