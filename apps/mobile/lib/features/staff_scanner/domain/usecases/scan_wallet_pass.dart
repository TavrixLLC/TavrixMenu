import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/wallet_scan_result.dart';
import '../repositories/wallet_scan_repository.dart';

class ScanWalletPass {
  const ScanWalletPass(this._repository);

  final WalletScanRepository _repository;

  Future<Either<Failure, WalletScanResult>> call({
    required String businessId,
    required String token,
  }) {
    return _repository.scan(businessId: businessId, token: token);
  }
}
