import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/response_parser.dart';
import '../../domain/entities/loyalty_requests.dart';
import '../models/loyalty_action_result_model.dart';
import '../models/loyalty_enroll_result_model.dart';
import '../models/loyalty_membership_model.dart';
import '../models/loyalty_program_model.dart';
import '../models/loyalty_stamp_presets_model.dart';
import '../models/loyalty_stamp_style_model.dart';
import '../models/loyalty_transaction_model.dart';

abstract class LoyaltyRemoteDataSource {
  bool get canCallBackend;

  Future<LoyaltyProgramModel?> getActiveProgram(String businessId);

  Future<LoyaltyStampPresetsModel> getStampPresets();

  Future<LoyaltyStampStyleModel?> getStampStyle(String businessId);

  Future<LoyaltyStampStyleModel> updateStampStyle({
    required String businessId,
    required UpdateLoyaltyStampStyleRequest request,
  });

  Future<LoyaltyProgramModel> createProgram({
    required String businessId,
    required LoyaltyProgramRequest request,
  });

  Future<LoyaltyProgramModel> updateProgram({
    required String businessId,
    required String programId,
    required LoyaltyProgramRequest request,
  });

  Future<LoyaltyEnrollResultModel> enrollCustomer({
    required String businessId,
    required EnrollLoyaltyCustomerRequest request,
  });

  Future<List<LoyaltyMembershipModel>> listMemberships({
    required String businessId,
    String? search,
    String? status,
    bool? rewardReady,
  });

  Future<LoyaltyMembershipModel> getMembership({
    required String businessId,
    required String membershipId,
  });

  Future<LoyaltyActionResultModel> addStamps({
    required String businessId,
    required String membershipId,
    required AddStampsRequest request,
  });

  Future<LoyaltyActionResultModel> redeemReward({
    required String businessId,
    required String membershipId,
    required RedeemRewardRequest request,
  });

  Future<List<LoyaltyTransactionModel>> listTransactions({
    required String businessId,
    required String membershipId,
  });
}

class LoyaltyRemoteDataSourceImpl implements LoyaltyRemoteDataSource {
  const LoyaltyRemoteDataSourceImpl(this.apiClient);

  final ApiClient apiClient;

  @override
  bool get canCallBackend => apiClient.canCallBackend;

  @override
  Future<LoyaltyProgramModel?> getActiveProgram(String businessId) async {
    final data = await apiClient.get('/businesses/$businessId/loyalty/program');
    return _parseProgramOrNull(
      data,
      context: 'active loyalty program response',
    );
  }

  @override
  Future<LoyaltyStampPresetsModel> getStampPresets() async {
    final data = await apiClient.get('/loyalty/stamp-presets');
    return _parseStampPresets(data);
  }

  @override
  Future<LoyaltyStampStyleModel?> getStampStyle(String businessId) async {
    final data = await apiClient.get(
      '/businesses/$businessId/loyalty/stamp-style',
    );
    return _parseStampStyleOrNull(
      data,
      context: 'loyalty stamp style response',
    );
  }

  @override
  Future<LoyaltyStampStyleModel> updateStampStyle({
    required String businessId,
    required UpdateLoyaltyStampStyleRequest request,
  }) async {
    final data = await apiClient.patch(
      '/businesses/$businessId/loyalty/stamp-style',
      body: request.toJson(),
    );
    return _parseStampStyle(data, context: 'update loyalty stamp style');
  }

  @override
  Future<LoyaltyProgramModel> createProgram({
    required String businessId,
    required LoyaltyProgramRequest request,
  }) async {
    final data = await apiClient.post(
      '/businesses/$businessId/loyalty/program',
      body: request.toJson(),
    );
    return _parseProgram(data, context: 'create loyalty program response');
  }

  @override
  Future<LoyaltyProgramModel> updateProgram({
    required String businessId,
    required String programId,
    required LoyaltyProgramRequest request,
  }) async {
    final data = await apiClient.patch(
      '/businesses/$businessId/loyalty/program/$programId',
      body: request.toJson(),
    );
    return _parseProgram(data, context: 'update loyalty program response');
  }

  @override
  Future<LoyaltyEnrollResultModel> enrollCustomer({
    required String businessId,
    required EnrollLoyaltyCustomerRequest request,
  }) async {
    final data = await apiClient.post(
      '/businesses/$businessId/loyalty/enroll',
      body: request.toJson(),
    );
    return _parseEnrollResult(data);
  }

  @override
  Future<List<LoyaltyMembershipModel>> listMemberships({
    required String businessId,
    String? search,
    String? status,
    bool? rewardReady,
  }) async {
    final query = <String, dynamic>{};
    final cleanSearch = search?.trim();
    final cleanStatus = status?.trim();
    if (cleanSearch != null && cleanSearch.isNotEmpty) {
      query['search'] = cleanSearch;
    }
    if (cleanStatus != null && cleanStatus.isNotEmpty) {
      query['status'] = cleanStatus;
    }
    if (rewardReady != null) {
      query['rewardReady'] = rewardReady.toString();
    }

    final data = await apiClient.get(
      '/businesses/$businessId/loyalty/memberships',
      queryParameters: query.isEmpty ? null : query,
    );
    return _parseMemberships(data);
  }

  @override
  Future<LoyaltyMembershipModel> getMembership({
    required String businessId,
    required String membershipId,
  }) async {
    final data = await apiClient.get(
      '/businesses/$businessId/loyalty/memberships/$membershipId',
    );
    return _parseMembership(data, context: 'loyalty membership response');
  }

  @override
  Future<LoyaltyActionResultModel> addStamps({
    required String businessId,
    required String membershipId,
    required AddStampsRequest request,
  }) async {
    final data = await apiClient.post(
      '/businesses/$businessId/loyalty/memberships/$membershipId/stamps',
      body: request.toJson(),
    );
    return _parseActionResult(data, context: 'add stamps response');
  }

  @override
  Future<LoyaltyActionResultModel> redeemReward({
    required String businessId,
    required String membershipId,
    required RedeemRewardRequest request,
  }) async {
    final data = await apiClient.post(
      '/businesses/$businessId/loyalty/memberships/$membershipId/redeem',
      body: request.toJson(),
    );
    return _parseActionResult(data, context: 'redeem reward response');
  }

  @override
  Future<List<LoyaltyTransactionModel>> listTransactions({
    required String businessId,
    required String membershipId,
  }) async {
    final data = await apiClient.get(
      '/businesses/$businessId/loyalty/memberships/$membershipId/transactions',
    );
    return _parseTransactions(data);
  }

  LoyaltyProgramModel? _parseProgramOrNull(
    dynamic data, {
    required String context,
  }) {
    if (data == null) {
      return null;
    }

    if (data is Map) {
      final json = asJsonObject(data, context: context);
      if (json.isEmpty) {
        return null;
      }
      if (json.containsKey('data') && json['data'] == null) {
        return null;
      }
      if (json['data'] is Map) {
        return _parseProgram(json['data'], context: context);
      }
      if (json['program'] is Map) {
        return _parseProgram(json['program'], context: context);
      }
    }

    return _parseProgram(data, context: context);
  }

  LoyaltyProgramModel _parseProgram(dynamic data, {required String context}) {
    final json = asJsonObject(data, context: context);

    try {
      return LoyaltyProgramModel.fromJson(json);
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw ServerException('Invalid $context.');
    }
  }

  LoyaltyStampPresetsModel _parseStampPresets(dynamic data) {
    final json = _toObject(data, context: 'loyalty stamp presets response');

    try {
      return LoyaltyStampPresetsModel.fromJson(json);
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw const ServerException('Invalid loyalty stamp presets response.');
    }
  }

  LoyaltyStampStyleModel? _parseStampStyleOrNull(
    dynamic data, {
    required String context,
  }) {
    if (data == null) {
      return null;
    }

    if (data is Map) {
      final json = asJsonObject(data, context: context);
      if (json.isEmpty) {
        return null;
      }
      if (json.containsKey('data') && json['data'] == null) {
        return null;
      }
    }

    return _parseStampStyle(data, context: context);
  }

  LoyaltyStampStyleModel _parseStampStyle(
    dynamic data, {
    required String context,
  }) {
    final json = _toObject(data, context: context);

    try {
      return LoyaltyStampStyleModel.fromJson(json);
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw ServerException('Invalid $context.');
    }
  }

  LoyaltyEnrollResultModel _parseEnrollResult(dynamic data) {
    final json = asJsonObject(
      data,
      context: 'enroll loyalty customer response',
    );

    try {
      return LoyaltyEnrollResultModel.fromJson(json);
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw const ServerException('Invalid enroll loyalty customer response.');
    }
  }

  List<LoyaltyMembershipModel> _parseMemberships(dynamic data) {
    final list = _toObjectList(data, context: 'loyalty memberships response');

    try {
      return list.map(LoyaltyMembershipModel.fromJson).toList();
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw const ServerException('Invalid loyalty memberships response.');
    }
  }

  LoyaltyMembershipModel _parseMembership(
    dynamic data, {
    required String context,
  }) {
    final json = asJsonObject(data, context: context);

    try {
      return LoyaltyMembershipModel.fromJson(json);
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw ServerException('Invalid $context.');
    }
  }

  LoyaltyActionResultModel _parseActionResult(
    dynamic data, {
    required String context,
  }) {
    final json = asJsonObject(data, context: context);

    try {
      return LoyaltyActionResultModel.fromJson(json);
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw ServerException('Invalid $context.');
    }
  }

  List<LoyaltyTransactionModel> _parseTransactions(dynamic data) {
    final list = _toObjectList(data, context: 'loyalty transactions response');

    try {
      return list.map(LoyaltyTransactionModel.fromJson).toList();
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (_) {
      throw const ServerException('Invalid loyalty transactions response.');
    }
  }

  List<Map<String, dynamic>> _toObjectList(
    dynamic data, {
    required String context,
  }) {
    if (data is Map) {
      final json = asJsonObject(data, context: context);
      final nestedList = json['data'] ?? json['items'] ?? json['memberships'];
      return asJsonObjectList(nestedList, context: context);
    }

    return asJsonObjectList(data, context: context);
  }

  Map<String, dynamic> _toObject(dynamic data, {required String context}) {
    if (data is Map) {
      final json = asJsonObject(data, context: context);
      final nested = json['data'] ?? json['style'] ?? json['stampStyle'];
      if (nested is Map) {
        return asJsonObject(nested, context: context);
      }
      return json;
    }

    return asJsonObject(data, context: context);
  }
}
