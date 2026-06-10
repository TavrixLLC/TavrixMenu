import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/failure_message.dart';
import '../../domain/usecases/create_business.dart';
import 'business_setup_state.dart';

class BusinessSetupCubit extends Cubit<BusinessSetupState> {
  BusinessSetupCubit({required CreateBusiness createBusiness})
    : _createBusiness = createBusiness,
      super(const BusinessSetupState.initial());

  final CreateBusiness _createBusiness;

  Future<void> submit({
    required String name,
    required String type,
    String? city,
  }) async {
    final cleanName = name.trim();
    final cleanType = type.trim().isEmpty ? 'cafe' : type.trim();
    final cleanCity = city?.trim();

    if (cleanName.isEmpty) {
      emit(
        state.copyWith(
          status: BusinessSetupStatus.failure,
          errorMessage: 'Business name is required.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: BusinessSetupStatus.loading, clearError: true));

    final result = await _createBusiness(
      name: cleanName,
      type: cleanType,
      city: cleanCity == null || cleanCity.isEmpty ? null : cleanCity,
      currency: 'IQD',
      language: 'ar',
    );
    result.fold(
      (failure) => emit(
        BusinessSetupState(
          status: BusinessSetupStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      ),
      (business) => emit(
        BusinessSetupState(
          status: BusinessSetupStatus.success,
          business: business,
        ),
      ),
    );
  }
}
