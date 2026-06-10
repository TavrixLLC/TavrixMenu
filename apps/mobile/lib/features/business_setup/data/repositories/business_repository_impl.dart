import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/run_safe.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/business_app_context.dart';
import '../../domain/entities/public_link.dart';
import '../../domain/repositories/business_repository.dart';
import '../datasources/business_remote_data_source.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  BusinessRepositoryImpl({
    required BusinessRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    required bool devFallbackEnabled,
    required String customerWebBaseUrl,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo,
       _devFallbackEnabled = devFallbackEnabled,
       _customerWebBaseUrl = customerWebBaseUrl;

  final BusinessRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final bool _devFallbackEnabled;
  final String _customerWebBaseUrl;
  Business _devBusiness = const Business(
    id: 'dev-business',
    name: 'Tavrix Cafe',
    slug: 'tavrix-cafe',
    type: 'cafe',
    role: 'OWNER',
    publicMenuUrl: '',
    currency: 'IQD',
    language: 'ar',
  );

  @override
  Future<Either<Failure, Business?>> getMyBusiness() {
    return runSafe(() async {
      if (!_remoteDataSource.canCallBackend && _devFallbackEnabled) {
        return _devBusiness;
      }

      final model = await _remoteDataSource.getMyBusiness();
      return model?.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, BusinessAppContext>> getBusinessAppContext(
    String businessId,
  ) {
    return runSafe(() async {
      if (!_remoteDataSource.canCallBackend && _devFallbackEnabled) {
        return BusinessAppContext(
          business: _devBusiness,
          currentMembership: const BusinessMembership(
            id: 'dev-membership',
            role: 'OWNER',
            isActive: true,
          ),
          permissions: const BusinessPermissions.all(),
          publicMenu: _devPublicLink(_devBusiness),
        );
      }

      final model = await _remoteDataSource.getBusinessAppContext(businessId);
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, PublicLink>> getPublicLink(String businessId) {
    return runSafe(() async {
      if (!_remoteDataSource.canCallBackend && _devFallbackEnabled) {
        return _devPublicLink(_devBusiness);
      }

      final model = await _remoteDataSource.getPublicLink(businessId);
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, Business>> createBusiness({
    required String name,
    required String type,
    required String currency,
    required String language,
    String? city,
  }) async {
    return runSafe(() async {
      if (!_remoteDataSource.canCallBackend && _devFallbackEnabled) {
        final slug = name
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
            .replaceAll(RegExp(r'^-|-$'), '');
        _devBusiness = Business(
          id: 'dev-business',
          name: name,
          slug: slug.isEmpty ? 'tavrix-cafe' : slug,
          type: type,
          role: 'OWNER',
          publicMenuUrl: '',
          city: city,
          currency: currency,
          language: language,
        );
        return _devBusiness;
      }

      final model = await _remoteDataSource.createBusiness(
        name: name,
        type: type,
        city: city,
        currency: currency,
        language: language,
      );
      return model.toEntity();
    }, _networkInfo);
  }

  @override
  Future<Either<Failure, Business>> updateBusiness({
    required String id,
    required String name,
    required String type,
    required String currency,
    required String language,
    String? city,
  }) async {
    return runSafe(() async {
      if (!_remoteDataSource.canCallBackend && _devFallbackEnabled) {
        final slug = name
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
            .replaceAll(RegExp(r'^-|-$'), '');
        _devBusiness = Business(
          id: id,
          name: name,
          slug: slug.isEmpty ? _devBusiness.slug : slug,
          type: type,
          role: _devBusiness.role,
          publicMenuUrl: '',
          city: city,
          currency: currency,
          language: language,
        );
        return _devBusiness;
      }

      final model = await _remoteDataSource.updateBusiness(
        id: id,
        name: name,
        type: type,
        city: city,
        currency: currency,
        language: language,
      );
      return model.toEntity();
    }, _networkInfo);
  }

  PublicLink _devPublicLink(Business business) {
    final baseUrl = _customerWebBaseUrl.endsWith('/')
        ? _customerWebBaseUrl.substring(0, _customerWebBaseUrl.length - 1)
        : _customerWebBaseUrl;
    final path = '/m/${business.slug}';
    final url = '$baseUrl$path';
    return PublicLink(
      businessId: business.id,
      slug: business.slug,
      publicMenuPath: path,
      publicMenuUrl: url,
      qrPayload: url,
    );
  }
}
