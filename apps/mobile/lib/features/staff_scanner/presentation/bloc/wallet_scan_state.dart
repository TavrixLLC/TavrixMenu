import 'package:equatable/equatable.dart';

import '../../../business_setup/domain/entities/business.dart';
import '../../domain/entities/wallet_scan_result.dart';

enum WalletScanStatus { initial, loading, ready, scanning, success, failure }

enum StampStatus { idle, stamping, stampSuccess, stampFailure }

class WalletScanState extends Equatable {
  const WalletScanState({
    required this.status,
    this.business,
    this.result,
    this.errorMessage,
    this.stampStatus = StampStatus.idle,
    this.stampErrorMessage,
    this.updatedStamps,
    this.updatedGoal,
  });

  const WalletScanState.initial() : this(status: WalletScanStatus.initial);

  final WalletScanStatus status;
  final Business? business;
  final WalletScanResult? result;
  final String? errorMessage;
  final StampStatus stampStatus;
  final String? stampErrorMessage;

  /// Updated stamp count after a successful add-stamp call.
  final int? updatedStamps;

  /// Updated goal after a successful add-stamp call (goal may change if program updated).
  final int? updatedGoal;

  WalletScanState copyWith({
    WalletScanStatus? status,
    Business? business,
    WalletScanResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
    StampStatus? stampStatus,
    String? stampErrorMessage,
    bool clearStampError = false,
    int? updatedStamps,
    int? updatedGoal,
    bool clearUpdatedStamps = false,
  }) {
    return WalletScanState(
      status: status ?? this.status,
      business: business ?? this.business,
      result: clearResult ? null : result ?? this.result,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      stampStatus: stampStatus ?? this.stampStatus,
      stampErrorMessage: clearStampError
          ? null
          : stampErrorMessage ?? this.stampErrorMessage,
      updatedStamps: clearUpdatedStamps
          ? null
          : updatedStamps ?? this.updatedStamps,
      updatedGoal: clearUpdatedStamps ? null : updatedGoal ?? this.updatedGoal,
    );
  }

  @override
  List<Object?> get props => [
    status,
    business,
    result,
    errorMessage,
    stampStatus,
    stampErrorMessage,
    updatedStamps,
    updatedGoal,
  ];
}
