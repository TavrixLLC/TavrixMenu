import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/failure_message.dart';
import '../../domain/usecases/create_business.dart';
import '../../domain/usecases/update_business.dart';
import 'business_setup_state.dart';

class BusinessSetupCubit extends Cubit<BusinessSetupState> {
  BusinessSetupCubit({
    required CreateBusiness createBusiness,
    required UpdateBusiness updateBusiness,
  }) : _createBusiness = createBusiness,
       _updateBusiness = updateBusiness,
       super(const BusinessSetupState.initial());

  final CreateBusiness _createBusiness;
  final UpdateBusiness _updateBusiness;
  int _sessionGeneration = 0;

  void reset() {
    _sessionGeneration++;
    emit(const BusinessSetupState.initial());
  }

  Future<void> submit({
    required String name,
    required String type,
    String? city,
    String currency = 'IQD',
    String language = 'ar',
  }) async {
    final cleanName = name.trim();
    final cleanType = type.trim().isEmpty ? 'cafe' : type.trim();
    final cleanCurrency = currency.trim().isEmpty ? 'IQD' : currency.trim();
    final cleanLanguage = language.trim().isEmpty ? 'ar' : language.trim();

    if (cleanName.isEmpty) {
      emit(
        state.copyWith(
          status: BusinessSetupStatus.failure,
          errorMessage: 'Business name is required.',
        ),
      );
      return;
    }

    final generation = _sessionGeneration;
    emit(state.copyWith(status: BusinessSetupStatus.loading, clearError: true));

    final result = await _createBusiness(
      name: cleanName,
      type: cleanType,
      city: city,
      currency: cleanCurrency,
      language: cleanLanguage,
    );
    if (!_isCurrent(generation)) {
      return;
    }
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

  Future<void> update({
    required String id,
    required String name,
    required String type,
    String? city,
    String currency = 'IQD',
    String language = 'ar',
    String? logoUrl,
    String? coverUrl,
  }) async {
    final cleanName = name.trim();
    final cleanType = type.trim().isEmpty ? 'cafe' : type.trim();
    final cleanCurrency = currency.trim().isEmpty ? 'IQD' : currency.trim();
    final cleanLanguage = language.trim().isEmpty ? 'ar' : language.trim();

    if (id.trim().isEmpty || cleanName.isEmpty) {
      emit(
        state.copyWith(
          status: BusinessSetupStatus.failure,
          errorMessage: 'Business name is required.',
        ),
      );
      return;
    }

    final generation = _sessionGeneration;
    emit(state.copyWith(status: BusinessSetupStatus.loading, clearError: true));

    final result = await _updateBusiness(
      id: id,
      name: cleanName,
      type: cleanType,
      city: city,
      currency: cleanCurrency,
      language: cleanLanguage,
      logoUrl: logoUrl,
      coverUrl: coverUrl,
    );
    if (!_isCurrent(generation)) {
      return;
    }
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

  bool _isCurrent(int generation) {
    return !isClosed && generation == _sessionGeneration;
  }
}
