import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/response_parser.dart';
import '../models/business_model.dart';

abstract class BusinessRemoteDataSource {
  bool get canCallBackend;

  Future<BusinessModel> getMyBusiness();

  Future<BusinessModel> createBusiness({
    required String name,
    required String slug,
  });

  Future<BusinessModel> updateBusiness({
    required String id,
    required String name,
    required String slug,
  });
}

class BusinessRemoteDataSourceImpl implements BusinessRemoteDataSource {
  const BusinessRemoteDataSourceImpl(this.apiClient);

  final ApiClient apiClient;

  @override
  bool get canCallBackend => apiClient.canCallBackend;

  @override
  Future<BusinessModel> getMyBusiness() async {
    final data = await apiClient.get('/businesses/me');
    return _parseBusiness(data, context: 'current business response');
  }

  @override
  Future<BusinessModel> createBusiness({
    required String name,
    required String slug,
  }) async {
    final data = await apiClient.post(
      '/businesses',
      body: {'name': name, 'slug': slug},
    );
    return _parseBusiness(data, context: 'create business response');
  }

  @override
  Future<BusinessModel> updateBusiness({
    required String id,
    required String name,
    required String slug,
  }) async {
    final data = await apiClient.patch(
      '/businesses/$id',
      body: {'name': name, 'slug': slug},
    );
    return _parseBusiness(data, context: 'update business response');
  }

  BusinessModel _parseBusiness(dynamic data, {required String context}) {
    final json = asJsonObject(data, context: context);

    try {
      return BusinessModel.fromJson(json);
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw ServerException('Invalid $context.');
    }
  }
}
