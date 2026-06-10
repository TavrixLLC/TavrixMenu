import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/failure_message.dart';
import '../../../auth/domain/entities/current_user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../business_setup/domain/entities/business.dart';
import '../../../business_setup/domain/usecases/get_business_app_context.dart';
import '../../../business_setup/domain/usecases/get_my_business.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required GetCurrentUser getCurrentUser,
    required GetMyBusiness getMyBusiness,
    required GetBusinessAppContext getBusinessAppContext,
  }) : _getCurrentUser = getCurrentUser,
       _getMyBusiness = getMyBusiness,
       _getBusinessAppContext = getBusinessAppContext,
       super(const DashboardState.initial());

  final GetCurrentUser _getCurrentUser;
  final GetMyBusiness _getMyBusiness;
  final GetBusinessAppContext _getBusinessAppContext;

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
        final businessFromMe = user.businesses.isEmpty
            ? null
            : user.businesses.first;
        if (businessFromMe != null) {
          await _emitBusinessDashboard(user: user, business: businessFromMe);
          return;
        }

        final businessResult = await _getMyBusiness();
        await businessResult.fold(
          (failure) async => emit(
            DashboardState(
              status: DashboardStatus.failure,
              user: user,
              errorMessage: failureMessage(failure),
            ),
          ),
          (business) async {
            if (business == null) {
              emit(
                DashboardState(status: DashboardStatus.noBusiness, user: user),
              );
              return;
            }

            await _emitBusinessDashboard(user: user, business: business);
          },
        );
      },
    );
  }

  Future<void> _emitBusinessDashboard({
    required CurrentUser user,
    required Business business,
  }) async {
    final contextResult = await _getBusinessAppContext(business.id);
    contextResult.fold(
      (_) => emit(
        DashboardState(
          status: DashboardStatus.success,
          user: user,
          business: business,
        ),
      ),
      (appContext) => emit(
        DashboardState(
          status: DashboardStatus.success,
          user: user,
          business: appContext.business,
          appContext: appContext,
        ),
      ),
    );
  }
}
