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
  int _sessionGeneration = 0;

  void reset() {
    _sessionGeneration++;
    emit(const DashboardState.initial());
  }

  void primeBusiness(Business business) {
    emit(DashboardState(status: DashboardStatus.success, business: business));
  }

  Future<void> load() async {
    final generation = _sessionGeneration;
    emit(
      state.copyWith(
        status: DashboardStatus.loading,
        clearError: true,
        clearSummaryError: true,
      ),
    );

    final userResult = await _getCurrentUser();
    if (!_isCurrent(generation)) {
      return;
    }
    await userResult.fold(
      (failure) async => _emitIfCurrent(
        generation,
        DashboardState(
          status: DashboardStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      ),
      (user) async {
        final businessResult = await _getMyBusiness();
        if (!_isCurrent(generation)) {
          return;
        }
        await businessResult.fold(
          (failure) async => _emitIfCurrent(
            generation,
            DashboardState(
              status: DashboardStatus.failure,
              user: user,
              errorMessage: failureMessage(failure),
            ),
          ),
          (business) => _loadSummary(
            generation: generation,
            user: user,
            business: business,
          ),
        );
      },
    );
  }

  Future<void> refreshSummary(String businessId) async {
    if (businessId.trim().isEmpty) {
      return;
    }

    final generation = _sessionGeneration;
    final result = await _getDashboardSummary(businessId);
    if (!_isCurrent(generation)) {
      return;
    }
    result.fold(
      (failure) => _emitIfCurrent(
        generation,
        state.copyWith(
          status: DashboardStatus.success,
          summaryErrorMessage: failureMessage(failure),
        ),
      ),
      (summary) => _emitIfCurrent(
        generation,
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
    required int generation,
    required CurrentUser user,
    required Business business,
  }) async {
    if (business.id.trim().isEmpty) {
      _emitIfCurrent(
        generation,
        DashboardState(
          status: DashboardStatus.success,
          user: user,
          business: business,
        ),
      );
      return;
    }

    final summaryResult = await _getDashboardSummary(business.id);
    if (!_isCurrent(generation)) {
      return;
    }
    summaryResult.fold(
      (failure) => _emitIfCurrent(
        generation,
        DashboardState(
          status: DashboardStatus.success,
          user: user,
          business: business,
          summaryErrorMessage: failureMessage(failure),
        ),
      ),
      (summary) => _emitIfCurrent(
        generation,
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

  bool _isCurrent(int generation) {
    return !isClosed && generation == _sessionGeneration;
  }

  void _emitIfCurrent(int generation, DashboardState nextState) {
    if (_isCurrent(generation)) {
      emit(nextState);
    }
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
