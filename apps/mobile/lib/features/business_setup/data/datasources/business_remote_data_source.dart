import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/response_parser.dart';
import '../models/business_model.dart';

abstract class BusinessRemoteDataSource {
  bool get canCallBackend;

  Future<BusinessModel> getMyBusiness();

  Future<BusinessModel> createBusiness({
    required String name,
    required String type,
    String? city,
    required String currency,
    required String language,
  });

  Future<BusinessModel> updateBusiness({
    required String id,
    required String name,
    required String type,
    String? city,
    required String currency,
    required String language,
    String? logoUrl,
    String? coverUrl,
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
    final businesses = _parseBusinesses(
      data,
      context: 'current businesses response',
    );
    if (businesses.isEmpty) {
      throw const NotFoundException();
    }
    if (businesses.length > 1) {
      throw const ValidationException(
        'Select one workspace before continuing.',
      );
    }

    final business = businesses.single;
    if (business.id.trim().isEmpty) {
      return business;
    }

    return getAppContext(business.id);
  }

  Future<BusinessModel> getAppContext(String businessId) async {
    final data = await apiClient.get('/businesses/$businessId/app-context');
    return _parseBusiness(data, context: 'business app context response');
  }

  @override
  Future<BusinessModel> createBusiness({
    required String name,
    required String type,
    String? city,
    required String currency,
    required String language,
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
    final business = _parseBusiness(data, context: 'create business response');
    if (_hasAppContext(data) || business.id.trim().isEmpty) {
      return business;
    }

    return getAppContext(business.id);
  }

  @override
  Future<BusinessModel> updateBusiness({
    required String id,
    required String name,
    required String type,
    String? city,
    required String currency,
    required String language,
    String? logoUrl,
    String? coverUrl,
  }) async {
    await apiClient.patch(
      '/businesses/$id',
      body: {
        'name': name,
        'type': type,
        'city': _nullableTrim(city),
        'currency': currency,
        'language': language,
        'logoUrl': _nullableTrim(logoUrl),
        'coverUrl': _nullableTrim(coverUrl),
      },
    );
    return getAppContext(id);
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

  List<BusinessModel> _parseBusinesses(
    dynamic data, {
    required String context,
  }) {
    final list = _toObjectList(data, context: context);

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

  List<Map<String, dynamic>> _toObjectList(
    dynamic data, {
    required String context,
  }) {
    if (data is Map) {
      final json = asJsonObject(data, context: context);
      final nestedList = json['data'] ?? json['businesses'];
      return asJsonObjectList(nestedList, context: context);
    }

    return asJsonObjectList(data, context: context);
  }

  bool _hasAppContext(dynamic data) {
    if (data is! Map) {
      return false;
    }

    final json = asJsonObject(data, context: 'create business response');
    return json['appContext'] != null || json['app_context'] != null;
  }
}

String? _nullableTrim(String? value) {
  if (value == null) {
    return null;
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
