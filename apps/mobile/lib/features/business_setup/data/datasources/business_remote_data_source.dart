import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/response_parser.dart';
import '../models/business_app_context_model.dart';
import '../models/business_model.dart';
import '../models/public_link_model.dart';

abstract class BusinessRemoteDataSource {
  bool get canCallBackend;

  Future<BusinessModel?> getMyBusiness();

  Future<BusinessAppContextModel> getBusinessAppContext(String businessId);

  Future<PublicLinkModel> getPublicLink(String businessId);

  Future<BusinessModel> createBusiness({
    required String name,
    required String type,
    required String currency,
    required String language,
    String? city,
  });

  Future<BusinessModel> updateBusiness({
    required String id,
    required String name,
    required String type,
    required String currency,
    required String language,
    String? city,
  });
}

class BusinessRemoteDataSourceImpl implements BusinessRemoteDataSource {
  const BusinessRemoteDataSourceImpl(this.apiClient);

  final ApiClient apiClient;

  @override
  bool get canCallBackend => apiClient.canCallBackend;

  @override
  Future<BusinessModel?> getMyBusiness() async {
    final data = await apiClient.get('/businesses/me');
    return _parseFirstBusiness(data, context: 'current business response');
  }

  @override
  Future<BusinessAppContextModel> getBusinessAppContext(
    String businessId,
  ) async {
    final data = await apiClient.get('/businesses/$businessId/app-context');
    return BusinessAppContextModel.fromResponse(data);
  }

  @override
  Future<PublicLinkModel> getPublicLink(String businessId) async {
    final data = await apiClient.get('/businesses/$businessId/public-link');
    return PublicLinkModel.fromResponse(data);
  }

  @override
  Future<BusinessModel> createBusiness({
    required String name,
    required String type,
    required String currency,
    required String language,
    String? city,
  }) async {
    final data = await apiClient.post(
      '/businesses',
      body: _businessBody(
        name: name,
        type: type,
        city: city,
        currency: currency,
        language: language,
      ),
    );
    return _parseBusiness(data, context: 'create business response');
  }

  @override
  Future<BusinessModel> updateBusiness({
    required String id,
    required String name,
    required String type,
    required String currency,
    required String language,
    String? city,
  }) async {
    final data = await apiClient.patch(
      '/businesses/$id',
      body: _businessBody(
        name: name,
        type: type,
        city: city,
        currency: currency,
        language: language,
      ),
    );
    return _parseBusiness(data, context: 'update business response');
  }

  Map<String, dynamic> _businessBody({
    required String name,
    required String type,
    required String currency,
    required String language,
    String? city,
  }) {
    return {
      'name': name,
      'type': type,
      if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
      'currency': currency,
      'language': language,
    };
  }

  BusinessModel? _parseFirstBusiness(dynamic data, {required String context}) {
    try {
      if (data is List || data is Iterable) {
        final list = asJsonObjectList(data, context: context);
        if (list.isEmpty) {
          return null;
        }
        return BusinessModel.fromJson(list.first);
      }

      final json = asJsonObject(data, context: context);
      final nestedBusinesses = json['businesses'] ?? json['data'];
      if (nestedBusinesses is List || nestedBusinesses is Iterable) {
        final list = asJsonObjectList(nestedBusinesses, context: context);
        if (list.isEmpty) {
          return null;
        }
        return BusinessModel.fromJson(list.first);
      }

      final nestedBusiness = json['business'];
      if (nestedBusiness != null) {
        return BusinessModel.fromJson(
          asJsonObject(nestedBusiness, context: '$context business'),
        );
      }

      return BusinessModel.fromJson(json);
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw ServerException('Invalid $context.');
    }
  }

  BusinessModel _parseBusiness(dynamic data, {required String context}) {
    final json = asJsonObject(data, context: context);
    final nested = json['data'] ?? json['business'];
    final businessJson = nested == null
        ? json
        : asJsonObject(nested, context: '$context business');

    try {
      return BusinessModel.fromJson(businessJson);
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw ServerException('Invalid $context.');
    }
  }
}
