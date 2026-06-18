import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';
import 'package:tavrix_menu_mobile/core/auth/dev_token_provider.dart';
import 'package:tavrix_menu_mobile/core/network/api_client.dart';
import 'package:tavrix_menu_mobile/features/staff_scanner/data/datasources/wallet_scan_remote_data_source.dart';

void main() {
  test('wallet scan posts the trimmed token and parses safe result data', () async {
    final apiClient = _RecordingApiClient(response: _walletScanResponse);
    final dataSource = WalletScanRemoteDataSourceImpl(apiClient);

    final result = await dataSource.scan(
      businessId: 'bus_123',
      token: '  test-wallet-token  ',
    );

    expect(
      apiClient.lastPostPath,
      '/businesses/bus_123/loyalty/wallet-scan',
    );
    expect(apiClient.lastPostBody, {'token': 'test-wallet-token'});
    expect(result.customerName, 'Demo Customer');
    expect(result.customerPhone, '+9647700000000');
    expect(result.programName, 'Tavrix Cafe Stamp Card');
    expect(result.stamps, 3);
    expect(result.goal, 10);
    expect(result.progressPercent, 30);
    expect(result.canRedeem, isFalse);
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

  final dynamic response;
  String? lastPostPath;
  Map<String, dynamic>? lastPostBody;

  @override
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    lastPostPath = path;
    lastPostBody = body;
    return response;
  }
}

const _walletScanResponse = <String, dynamic>{
  'membershipId': 'membership_id',
  'customer': {'name': 'Demo Customer', 'phone': '+9647700000000'},
  'program': {
    'name': 'Tavrix Cafe Stamp Card',
    'stampGoal': 10,
    'rewardName': 'Free coffee',
  },
  'progress': {'stamps': 3, 'goal': 10, 'canRedeem': false},
  'walletPass': {'platform': 'GOOGLE_WALLET', 'status': 'ACTIVE'},
};
