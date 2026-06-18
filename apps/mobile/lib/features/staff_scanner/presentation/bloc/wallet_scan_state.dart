import 'package:equatable/equatable.dart';

import '../../../business_setup/domain/entities/business.dart';
import '../../domain/entities/wallet_scan_result.dart';

enum WalletScanStatus { initial, loading, ready, scanning, success, failure }

class WalletScanState extends Equatable {
  const WalletScanState({
    required this.status,
    this.business,
    this.result,
    this.errorMessage,
  });

  const WalletScanState.initial() : this(status: WalletScanStatus.initial);

  final WalletScanStatus status;
  final Business? business;
  final WalletScanResult? result;
  final String? errorMessage;

  WalletScanState copyWith({
    WalletScanStatus? status,
    Business? business,
    WalletScanResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return WalletScanState(
      status: status ?? this.status,
      business: business ?? this.business,
      result: clearResult ? null : result ?? this.result,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, business, result, errorMessage];
}
