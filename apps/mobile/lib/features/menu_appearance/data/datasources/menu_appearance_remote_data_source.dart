import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/response_parser.dart';
import '../models/business_appearance_model.dart';
import '../models/menu_template_model.dart';

abstract class MenuAppearanceRemoteDataSource {
  bool get canCallBackend;

  Future<List<MenuTemplateModel>> getTemplates();

  Future<BusinessAppearanceModel> getBusinessAppearance(String businessId);

  Future<BusinessAppearanceModel> updateBusinessAppearance({
    required String businessId,
    required String menuTemplateId,
  });
}

class MenuAppearanceRemoteDataSourceImpl
    implements MenuAppearanceRemoteDataSource {
  const MenuAppearanceRemoteDataSourceImpl(this.apiClient);

  final ApiClient apiClient;

  @override
  bool get canCallBackend => apiClient.canCallBackend;

  @override
  Future<List<MenuTemplateModel>> getTemplates() async {
    final data = await apiClient.get('/menu-templates');
    final list = _toObjectList(data, context: 'menu templates response');

    try {
      return list.map(MenuTemplateModel.fromJson).toList(growable: false);
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw const ServerException('Invalid menu templates response.');
    }
  }

  @override
  Future<BusinessAppearanceModel> getBusinessAppearance(
    String businessId,
  ) async {
    final data = await apiClient.get(
      '/businesses/${Uri.encodeComponent(businessId)}/appearance',
    );
    return _parseAppearance(
      data,
      businessId: businessId,
      context: 'business appearance response',
    );
  }

  @override
  Future<BusinessAppearanceModel> updateBusinessAppearance({
    required String businessId,
    required String menuTemplateId,
  }) async {
    final data = await apiClient.patch(
      '/businesses/${Uri.encodeComponent(businessId)}/appearance',
      body: {'menuTemplateId': menuTemplateId},
    );
    return _parseAppearance(
      data,
      businessId: businessId,
      context: 'update business appearance response',
    );
  }

  BusinessAppearanceModel _parseAppearance(
    dynamic data, {
    required String businessId,
    required String context,
  }) {
    final json = asJsonObject(data, context: context);

    try {
      return BusinessAppearanceModel.fromJson(json, businessId: businessId);
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
      final nestedList = json['templates'] ?? json['data'] ?? json['items'];
      return asJsonObjectList(nestedList, context: context);
    }

    return asJsonObjectList(data, context: context);
  }
}
