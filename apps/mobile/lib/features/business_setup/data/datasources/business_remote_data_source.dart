import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/response_parser.dart';
import '../models/business_model.dart';

abstract class BusinessRemoteDataSource {
  bool get canCallBackend;

  Future<List<BusinessModel>> getMyBusinesses();

  Future<BusinessModel> createBusiness({
    required String name,
    required String type,
    String? city,
    String currency = 'IQD',
    String language = 'ar',
  });

  Future<BusinessModel> updateBusiness({
    required String id,
    required String name,
    required String type,
    String? city,
    String currency = 'IQD',
    String language = 'ar',
  });
}

class BusinessRemoteDataSourceImpl implements BusinessRemoteDataSource {
  const BusinessRemoteDataSourceImpl(this.apiClient);

  final ApiClient apiClient;

  @override
  bool get canCallBackend => apiClient.canCallBackend;

  @override
  Future<List<BusinessModel>> getMyBusinesses() async {
    final data = await apiClient.get('/businesses/me');
    return _parseBusinesses(data, context: 'current businesses response');
  }

  @override
  Future<BusinessModel> createBusiness({
    required String name,
    required String type,
    String? city,
    String currency = 'IQD',
    String language = 'ar',
  }) async {
    final data = await apiClient.post(
      '/businesses',
      body: {
        'name': name,
        'type': type,
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
        'currency': currency,
        'language': language,
      },
    );
    return _parseBusiness(data, context: 'create business response');
  }

  @override
  Future<BusinessModel> updateBusiness({
    required String id,
    required String name,
    required String type,
    String? city,
    String currency = 'IQD',
    String language = 'ar',
  }) async {
    final data = await apiClient.patch(
      '/businesses/$id',
      body: {
        'name': name,
        'type': type,
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
        'currency': currency,
        'language': language,
      },
    );
    return _parseBusiness(data, context: 'update business response');
  }

  List<BusinessModel> _parseBusinesses(
    dynamic data, {
    required String context,
  }) {
    final list = _toBusinessList(data, context: context);

    try {
      return list.map(BusinessModel.fromJson).toList();
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw ServerException('Invalid $context.');
    }
  }

  BusinessModel _parseBusiness(dynamic data, {required String context}) {
    final json = asNestedJsonObject(
      data,
      context: context,
      keys: const ['data', 'business'],
    );

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

  List<Map<String, dynamic>> _toBusinessList(
    dynamic data, {
    required String context,
  }) {
    if (data is Map) {
      final json = asJsonObject(data, context: context);
      final nested =
          json['data'] ??
          json['businesses'] ??
          json['items'] ??
          json['results'];

      if (nested is Map) {
        final nestedJson = asJsonObject(nested, context: context);
        final nestedList =
            nestedJson['businesses'] ??
            nestedJson['items'] ??
            nestedJson['results'];
        if (nestedList != null) {
          return asJsonObjectList(nestedList, context: context);
        }
        return [nestedJson];
      }

      if (nested != null) {
        return asJsonObjectList(nested, context: context);
      }

      return [json];
    }

    return asJsonObjectList(data, context: context);
  }
}
