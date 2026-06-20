import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/failure_message.dart';
import '../../../business_setup/domain/usecases/get_my_business.dart';
import '../../domain/usecases/scan_wallet_pass.dart';
import 'wallet_scan_state.dart';

class WalletScanCubit extends Cubit<WalletScanState> {
  WalletScanCubit({
    required GetMyBusiness getMyBusiness,
    required ScanWalletPass scanWalletPass,
  }) : _getMyBusiness = getMyBusiness,
       _scanWalletPass = scanWalletPass,
       super(const WalletScanState.initial());

  final GetMyBusiness _getMyBusiness;
  final ScanWalletPass _scanWalletPass;

  Future<void> load() async {
    if (state.business != null) {
      emit(
        state.copyWith(
          status: WalletScanStatus.ready,
          clearResult: true,
          clearError: true,
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
}
