import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/run_safe.dart';
import '../../domain/entities/business.dart';
import '../../domain/repositories/business_repository.dart';
import '../datasources/business_remote_data_source.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  BusinessRepositoryImpl({
    required BusinessRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    required bool devFallbackEnabled,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo,
       _devFallbackEnabled = devFallbackEnabled;

  final BusinessRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final bool _devFallbackEnabled;
  Business _devBusiness = const Business(
    id: 'dev-business',
    name: 'Tavrix Demo Cafe',
    slug: 'tavrix-demo-cafe',
    publicMenuUrl: 'https://menu.tavrix.com/tavrix-demo-cafe',
  );

  @override
  Future<Either<Failure, Business>> getMyBusiness() {
    return runSafe(() async {
      if (!_remoteDataSource.canCallBackend && _devFallbackEnabled) {
        return _devBusiness;
      }

      final model = await _remoteDataSource.getMyBusiness();
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, Business>> createBusiness({
    required String name,
    required String slug,
  }) async {
    return runSafe(() async {
      if (!_remoteDataSource.canCallBackend && _devFallbackEnabled) {
        _devBusiness = Business(
          id: 'dev-business',
          name: name,
          slug: slug,
          publicMenuUrl: 'https://menu.tavrix.com/$slug',
        );
        return _devBusiness;
      }

      final model = await _remoteDataSource.createBusiness(
        name: name,
        slug: slug,
      );
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, Business>> updateBusiness({
    required String id,
    required String name,
    required String slug,
  }) async {
    return runSafe(() async {
      if (!_remoteDataSource.canCallBackend && _devFallbackEnabled) {
        _devBusiness = Business(
          id: id,
          name: name,
          slug: slug,
          publicMenuUrl: 'https://menu.tavrix.com/$slug',
        );
        return _devBusiness;
      }

      final model = await _remoteDataSource.updateBusiness(
        id: id,
        name: name,
        slug: slug,
      );
      return model.toEntity();
    }, _networkInfo);
  }
}
