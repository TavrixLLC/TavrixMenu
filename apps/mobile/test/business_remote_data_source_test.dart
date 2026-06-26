import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';
import 'package:tavrix_menu_mobile/core/auth/dev_token_provider.dart';
import 'package:tavrix_menu_mobile/core/network/api_client.dart';
import 'package:tavrix_menu_mobile/features/business_setup/data/datasources/business_remote_data_source.dart';

void main() {
  test('create business posts Sprint 12 owner workspace body', () async {
    final apiClient = _RecordingApiClient(
      response: {
        'appContext': {
          'business': {
            'id': 'bus_123',
            'name': 'Tavrix Cafe',
            'slug': 'tavrix-cafe',
            'type': 'cafe',
            'city': 'Baghdad',
            'currency': 'IQD',
            'language': 'ar',
          },
          'publicMenu': {'url': 'https://menu.example.test/m/tavrix-cafe'},
          'currentMembership': {'role': 'OWNER'},
        },
      },
    );
    final dataSource = BusinessRemoteDataSourceImpl(apiClient);

    final business = await dataSource.createBusiness(
      name: 'Tavrix Cafe',
      type: 'cafe',
      city: 'Baghdad',
      currency: 'IQD',
      language: 'ar',
    );

    expect(apiClient.lastPostPath, '/businesses');
    expect(apiClient.lastPostBody, {
      'name': 'Tavrix Cafe',
      'type': 'cafe',
      'city': 'Baghdad',
      'currency': 'IQD',
      'language': 'ar',
    });
    expect(apiClient.getCalls, 0);
    expect(business.id, 'bus_123');
    expect(business.publicMenuUrl, 'https://menu.example.test/m/tavrix-cafe');
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
  String? lastPostPath;
  Map<String, dynamic>? lastPostBody;
  int getCalls = 0;

  @override
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    lastPostPath = path;
    lastPostBody = body;
    return response;
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    getCalls += 1;
    return response;
  }
}
