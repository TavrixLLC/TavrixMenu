import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/wallet_scan_result.dart';

abstract class WalletScanRepository {
  Future<Either<Failure, WalletScanResult>> scan({
    required String businessId,
    required String token,
  });
}
