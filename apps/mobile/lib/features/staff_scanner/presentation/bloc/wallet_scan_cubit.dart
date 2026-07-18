import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/copy/pilot_arabic_copy.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../business_setup/domain/usecases/get_my_business.dart';
import '../../../loyalty/domain/entities/loyalty_requests.dart';
import '../../../loyalty/domain/usecases/add_loyalty_stamps.dart';
import '../../domain/usecases/scan_wallet_pass.dart';
import 'wallet_scan_state.dart';

class WalletScanCubit extends Cubit<WalletScanState> {
  WalletScanCubit({
    required GetMyBusiness getMyBusiness,
    required ScanWalletPass scanWalletPass,
    required AddLoyaltyStamps addLoyaltyStamps,
  }) : _getMyBusiness = getMyBusiness,
       _scanWalletPass = scanWalletPass,
       _addLoyaltyStamps = addLoyaltyStamps,
       super(const WalletScanState.initial());

  final GetMyBusiness _getMyBusiness;
  final ScanWalletPass _scanWalletPass;
  final AddLoyaltyStamps _addLoyaltyStamps;
  int _sessionGeneration = 0;

  void reset() {
    _sessionGeneration++;
    emit(const WalletScanState.initial());
  }

  Future<void> load() async {
    final generation = _sessionGeneration;
    emit(const WalletScanState(status: WalletScanStatus.loading));
    final result = await _getMyBusiness();
    if (!_isCurrent(generation)) {
      return;
    }
    result.fold(
      (failure) => _emitIfCurrent(
        generation,
        const WalletScanState.initial().copyWith(
          status: WalletScanStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      ),
      (business) => _emitIfCurrent(
        generation,
        const WalletScanState.initial().copyWith(
          status: WalletScanStatus.ready,
          business: business,
          clearError: true,
        ),
      ),
    );
  }

  Future<bool> scan(String token) async {
    if (state.status == WalletScanStatus.scanning) {
      return false;
    }

    final cleanToken = token.trim();
    if (cleanToken.isEmpty) {
      emit(
        state.copyWith(
          status: WalletScanStatus.failure,
          errorMessage: PilotArabicCopy.loyaltyQrRequired,
          clearResult: true,
        ),
      );
      return false;
    }

    final business = state.business;
    if (business == null) {
      emit(
        state.copyWith(
          status: WalletScanStatus.failure,
          errorMessage: PilotArabicCopy.businessWorkspaceNotReady,
          clearResult: true,
        ),
      );
      return false;
    }

    final generation = _sessionGeneration;
    final businessId = business.id;
    emit(
      state.copyWith(
        status: WalletScanStatus.scanning,
        clearError: true,
        clearResult: true,
        stampStatus: StampStatus.idle,
        clearStampError: true,
        clearUpdatedStamps: true,
      ),
    );
    final result = await _scanWalletPass(
      businessId: businessId,
      token: cleanToken,
    );
    if (!_isCurrentBusiness(generation, businessId)) {
      return false;
    }

    return result.fold(
      (failure) {
        _emitIfCurrent(
          generation,
          state.copyWith(
            status: WalletScanStatus.failure,
            errorMessage: failureMessage(failure),
          ),
        );
        return false;
      },
      (scanResult) {
        _emitIfCurrent(
          generation,
          state.copyWith(
            status: WalletScanStatus.success,
            result: scanResult,
            clearError: true,
          ),
        );
        return true;
      },
    );
  }

  /// Adds one stamp to the membership obtained from the scan result.
  /// Guards against duplicate calls while stamping is in progress.
  Future<void> addStamp() async {
    if (state.stampStatus == StampStatus.stamping) {
      return;
    }

    final business = state.business;
    final result = state.result;
    if (business == null || result == null) {
      return;
    }

    final generation = _sessionGeneration;
    final businessId = business.id;
    emit(
      state.copyWith(stampStatus: StampStatus.stamping, clearStampError: true),
    );

    final stampResult = await _addLoyaltyStamps(
      businessId: businessId,
      membershipId: result.membershipId,
      request: const AddStampsRequest(count: 1),
    );
    if (!_isCurrentBusiness(generation, businessId)) {
      return;
    }

    stampResult.fold(
      (failure) {
        _emitIfCurrent(
          generation,
          state.copyWith(
            stampStatus: StampStatus.stampFailure,
            stampErrorMessage: failureMessage(failure),
          ),
        );
      },
      (actionResult) {
        _emitIfCurrent(
          generation,
          state.copyWith(
            stampStatus: StampStatus.stampSuccess,
            clearStampError: true,
            updatedStamps: actionResult.cardState.stampCount,
            updatedGoal: actionResult.cardState.stampGoal,
          ),
        );
      },
    );
  }

  bool _isCurrent(int generation) {
    return !isClosed && generation == _sessionGeneration;
  }

  bool _isCurrentBusiness(int generation, String businessId) {
    return _isCurrent(generation) && state.business?.id == businessId;
  }

  void _emitIfCurrent(int generation, WalletScanState nextState) {
    if (_isCurrent(generation)) {
      emit(nextState);
    }
  }
}
