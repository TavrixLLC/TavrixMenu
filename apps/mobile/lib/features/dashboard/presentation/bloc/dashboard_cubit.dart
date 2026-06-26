import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/failure_message.dart';
import '../../../auth/domain/entities/current_user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../../business_setup/domain/entities/business.dart';
import '../../../business_setup/domain/usecases/get_my_business.dart';
import '../../domain/usecases/get_dashboard_summary.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required GetCurrentUser getCurrentUser,
    required GetMyBusiness getMyBusiness,
    required GetDashboardSummary getDashboardSummary,
  }) : _getCurrentUser = getCurrentUser,
       _getMyBusiness = getMyBusiness,
       _getDashboardSummary = getDashboardSummary,
       super(const DashboardState.initial());

  final GetCurrentUser _getCurrentUser;
  final GetMyBusiness _getMyBusiness;
  final GetDashboardSummary _getDashboardSummary;

  void reset() {
    emit(const DashboardState.initial());
  }

  void primeBusiness(Business business) {
    emit(DashboardState(status: DashboardStatus.success, business: business));
  }

  Future<void> load() async {
    emit(
      state.copyWith(
        status: DashboardStatus.loading,
        clearError: true,
        clearSummaryError: true,
      ),
    );

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
        await businessResult.fold(
          (failure) async => emit(
            DashboardState(
              status: DashboardStatus.failure,
              user: user,
              errorMessage: failureMessage(failure),
            ),
          ),
          (business) => _loadSummary(user: user, business: business),
        );
      },
    );
  }

  Future<void> refreshSummary(String businessId) async {
    if (businessId.trim().isEmpty) {
      return;
    }

    final result = await _getDashboardSummary(businessId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DashboardStatus.success,
          summaryErrorMessage: failureMessage(failure),
        ),
      ),
      (summary) => emit(
        state.copyWith(
          status: DashboardStatus.success,
          business: summary.business,
          summary: summary,
          clearSummaryError: true,
        ),
      ),
    );
  }

  Future<void> _loadSummary({
    required CurrentUser user,
    required Business business,
  }) async {
    if (business.id.trim().isEmpty) {
      emit(
        DashboardState(
          status: DashboardStatus.success,
          user: user,
          business: business,
        ),
      );
      return;
    }

    final summaryResult = await _getDashboardSummary(business.id);
    summaryResult.fold(
      (failure) => emit(
        DashboardState(
          status: DashboardStatus.success,
          user: user,
          business: business,
          summaryErrorMessage: failureMessage(failure),
        ),
      ),
      (summary) => emit(
        DashboardState(
          status: DashboardStatus.success,
          user: user,
          business: _mergeBusinessContext(
            appContextBusiness: business,
            summaryBusiness: summary.business,
          ),
          summary: summary,
        ),
      ),
    );
  }
}

Business _mergeBusinessContext({
  required Business appContextBusiness,
  required Business summaryBusiness,
}) {
  if ((summaryBusiness.role?.trim().isNotEmpty ?? false) ||
      (appContextBusiness.role?.trim().isEmpty ?? true)) {
    return summaryBusiness;
  }

  return Business(
    id: summaryBusiness.id,
    name: summaryBusiness.name,
    slug: summaryBusiness.slug,
    publicMenuUrl: summaryBusiness.publicMenuUrl,
    type: summaryBusiness.type,
    city: summaryBusiness.city,
    currency: summaryBusiness.currency,
    language: summaryBusiness.language,
    logoUrl: summaryBusiness.logoUrl,
    coverUrl: summaryBusiness.coverUrl,
    status: summaryBusiness.status,
    role: appContextBusiness.role,
    permissions: summaryBusiness.permissions ?? appContextBusiness.permissions,
  );
}
