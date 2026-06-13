import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';
import 'package:tavrix_menu_mobile/core/auth/dev_token_provider.dart';
import 'package:tavrix_menu_mobile/core/network/api_client.dart';
import 'package:tavrix_menu_mobile/features/loyalty/data/datasources/loyalty_remote_data_source.dart';
import 'package:tavrix_menu_mobile/features/loyalty/domain/entities/loyalty_requests.dart';

void main() {
  test('list memberships sends OpenAPI query parameters', () async {
    final apiClient = _RecordingApiClient(response: <Map<String, dynamic>>[]);
    final dataSource = LoyaltyRemoteDataSourceImpl(apiClient);

    await dataSource.listMemberships(
      businessId: 'bus_123',
      search: ' customer@example.com ',
      status: 'ACTIVE',
      rewardReady: true,
    );

    expect(apiClient.lastGetPath, '/businesses/bus_123/loyalty/memberships');
    expect(apiClient.lastGetQuery, {
      'search': 'customer@example.com',
      'status': 'ACTIVE',
      'rewardReady': 'true',
    });
  });

  test('enroll, add stamps, and redeem send Sprint 5 DTO bodies', () async {
    final apiClient = _RecordingApiClient(response: _enrollResponse());
    final dataSource = LoyaltyRemoteDataSourceImpl(apiClient);

    await dataSource.enrollCustomer(
      businessId: 'bus_123',
      request: const EnrollLoyaltyCustomerRequest(
        phone: '+9647700000000',
        email: 'customer@example.com',
        name: 'Demo Customer',
      ),
    );
    expect(apiClient.lastPostPath, '/businesses/bus_123/loyalty/enroll');
    expect(apiClient.lastPostBody, {
      'phone': '+9647700000000',
      'email': 'customer@example.com',
      'name': 'Demo Customer',
    });

    apiClient.response = _actionResponse(stampCount: 4, rewardReady: false);
    await dataSource.addStamps(
      businessId: 'bus_123',
      membershipId: 'membership_id',
      request: const AddStampsRequest(count: 1, reason: 'Coffee purchase'),
    );
    expect(
      apiClient.lastPostPath,
      '/businesses/bus_123/loyalty/memberships/membership_id/stamps',
    );
    expect(apiClient.lastPostBody, {'count': 1, 'reason': 'Coffee purchase'});

    apiClient.response = _actionResponse(stampCount: 0, rewardReady: false);
    await dataSource.redeemReward(
      businessId: 'bus_123',
      membershipId: 'membership_id',
      request: const RedeemRewardRequest(),
    );
    expect(
      apiClient.lastPostPath,
      '/businesses/bus_123/loyalty/memberships/membership_id/redeem',
    );
    expect(apiClient.lastPostBody, isEmpty);
  });
}

class _RecordingApiClient extends ApiClient {
  _RecordingApiClient({required this.response})
    : super(
        config: const AppConfig(
          apiBaseUrl: 'https://api.example.test',
          customerWebBaseUrl: 'https://menu.example.test',
          devAuthToken: 'dev:user',
          appEnv: 'development',
          enableDevAuth: true,
          clerkPublishableKey: '',
        ),
        tokenProvider: const DevTokenProvider('dev:user'),
      );

  dynamic response;
  String? lastGetPath;
  Map<String, dynamic>? lastGetQuery;
  String? lastPostPath;
  Map<String, dynamic>? lastPostBody;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    lastGetPath = path;
    lastGetQuery = queryParameters;
    return response;
  }

  @override
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    lastPostPath = path;
    lastPostBody = body;
    return response;
  }
}

Map<String, dynamic> _enrollResponse() {
  return {
    'customer': {
      'id': 'customer_id',
      'phone': '+9647700000000',
      'email': 'customer@example.com',
      'name': 'Demo Customer',
    },
    'membership': {
      'id': 'membership_id',
      'businessId': 'bus_123',
      'loyaltyProgramId': 'loyalty_program_id',
      'customerId': 'customer_id',
      'stampCount': 0,
      'rewardReady': false,
      'status': 'ACTIVE',
    },
    'program': {
      'id': 'loyalty_program_id',
      'businessId': 'bus_123',
      'name': 'Tavrix Cafe Stamp Card',
      'stampGoal': 5,
      'rewardName': 'Free coffee',
    },
    'cardState': {
      'stampCount': 0,
      'stampGoal': 5,
      'rewardReady': false,
      'progressPercent': 0,
      'rewardName': 'Free coffee',
      'programName': 'Tavrix Cafe Stamp Card',
    },
  };
}

Map<String, dynamic> _actionResponse({
  required int stampCount,
  required bool rewardReady,
}) {
  return {
    'membership': {
      'id': 'membership_id',
      'stampCount': stampCount,
      'rewardReady': rewardReady,
      'totalStampsEarned': stampCount,
      'totalRewardsRedeemed': stampCount == 0 ? 1 : 0,
    },
    'cardState': {
      'stampCount': stampCount,
      'stampGoal': 5,
      'rewardReady': rewardReady,
      'progressPercent': stampCount * 20,
      'rewardName': 'Free coffee',
      'programName': 'Tavrix Cafe Stamp Card',
    },
  };
}
