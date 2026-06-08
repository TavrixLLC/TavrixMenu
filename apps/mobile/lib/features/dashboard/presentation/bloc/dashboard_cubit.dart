import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/failure_message.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../business_setup/domain/usecases/get_my_business.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required GetCurrentUser getCurrentUser,
    required GetMyBusiness getMyBusiness,
  }) : _getCurrentUser = getCurrentUser,
       _getMyBusiness = getMyBusiness,
       super(const DashboardState.initial());

  final GetCurrentUser _getCurrentUser;
  final GetMyBusiness _getMyBusiness;

  Future<void> load() async {
    emit(state.copyWith(status: DashboardStatus.loading, clearError: true));

    final userResult = await _getCurrentUser();
    await userResult.fold(
      (failure) async => emit(
        DashboardState(
          status: DashboardStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      ),
      (user) async {
        final businessResult = await _getMyBusiness();
        businessResult.fold(
          (failure) => emit(
            DashboardState(
              status: DashboardStatus.failure,
              user: user,
              errorMessage: failureMessage(failure),
            ),
          ),
          (business) => emit(
            DashboardState(
              status: DashboardStatus.success,
              user: user,
              business: business,
            ),
          ),
        );
      },
    );
  }
}
