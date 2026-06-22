import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/run_safe.dart';
import '../../domain/entities/wallet_scan_result.dart';
import '../../domain/repositories/wallet_scan_repository.dart';
import '../datasources/wallet_scan_remote_data_source.dart';

class WalletScanRepositoryImpl implements WalletScanRepository {
  const WalletScanRepositoryImpl({
    required WalletScanRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  final WalletScanRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, WalletScanResult>> scan({
    required String businessId,
    required String token,
  }) {
    return runSafe(() async {
      final model = await _remoteDataSource.scan(
        businessId: businessId,
        token: token,
      );
      return model.toEntity();
    }, _networkInfo);
  }
}
