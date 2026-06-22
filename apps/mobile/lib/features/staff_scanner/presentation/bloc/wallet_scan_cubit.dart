import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<void> load() async {
    if (state.business != null) {
      emit(
        state.copyWith(
          status: WalletScanStatus.ready,
          clearResult: true,
          clearError: true,
          stampStatus: StampStatus.idle,
          clearStampError: true,
          clearUpdatedStamps: true,
        ),
      );
      return;
    }

    emit(state.copyWith(status: WalletScanStatus.loading, clearError: true));
    final result = await _getMyBusiness();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: WalletScanStatus.failure,
          errorMessage: failureMessage(failure),
        ),
      ),
      (business) => emit(
        state.copyWith(
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
          errorMessage: 'Enter a wallet QR token.',
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
          errorMessage: 'Business access is not ready. Please try again.',
          clearResult: true,
        ),
      );
      return false;
    }

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
      businessId: business.id,
      token: cleanToken,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: WalletScanStatus.failure,
            errorMessage: failureMessage(failure),
          ),
        );
        return false;
      },
      (scanResult) {
        emit(
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

    emit(
      state.copyWith(stampStatus: StampStatus.stamping, clearStampError: true),
    );

    final stampResult = await _addLoyaltyStamps(
      businessId: business.id,
      membershipId: result.membershipId,
      request: const AddStampsRequest(count: 1),
    );

    stampResult.fold(
      (failure) {
        emit(
          state.copyWith(
            stampStatus: StampStatus.stampFailure,
            stampErrorMessage: failureMessage(failure),
          ),
        );
      },
      (actionResult) {
        emit(
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
}
