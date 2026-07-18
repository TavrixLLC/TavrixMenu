import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';
import 'package:tavrix_menu_mobile/core/auth/dev_token_provider.dart';
import 'package:tavrix_menu_mobile/core/errors/exceptions.dart';
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

  test(
    'get my business returns not found when response has zero businesses',
    () {
      final apiClient = _RecordingApiClient(response: const []);
      final dataSource = BusinessRemoteDataSourceImpl(apiClient);

      expect(dataSource.getMyBusiness, throwsA(isA<NotFoundException>()));
    },
  );

  test('get my business loads app context for exactly one business', () async {
    final apiClient = _RecordingApiClient(
      response: null,
      getResponses: [
        [
          {
            'id': 'business-a',
            'name': 'Business A',
            'slug': 'business-a',
            'type': 'cafe',
            'currency': 'IQD',
            'language': 'ar',
            'status': 'ACTIVE',
            'role': 'OWNER',
          },
        ],
        {
          'appContext': {
            'business': {
              'id': 'business-a',
              'name': 'Business A',
              'slug': 'business-a',
              'type': 'cafe',
              'currency': 'IQD',
              'language': 'ar',
            },
            'publicMenu': {'url': 'https://menu.example.test/m/business-a'},
            'currentMembership': {'role': 'OWNER'},
          },
        },
      ],
    );
    final dataSource = BusinessRemoteDataSourceImpl(apiClient);

    final business = await dataSource.getMyBusiness();

    expect(apiClient.getPaths, [
      '/businesses/me',
      '/businesses/business-a/app-context',
    ]);
    expect(business.id, 'business-a');
    expect(business.name, 'Business A');
  });

  test('get my business fails closed for multiple businesses', () {
    final apiClient = _RecordingApiClient(
      response: [
        {
          'id': 'business-a',
          'name': 'Business A',
          'slug': 'business-a',
          'type': 'cafe',
          'currency': 'IQD',
          'language': 'ar',
          'status': 'ACTIVE',
          'role': 'OWNER',
        },
        {
          'id': 'business-b',
          'name': 'Business B',
          'slug': 'business-b',
          'type': 'cafe',
          'currency': 'IQD',
          'language': 'ar',
          'status': 'ACTIVE',
          'role': 'OWNER',
        },
      ],
    );
    final dataSource = BusinessRemoteDataSourceImpl(apiClient);

    expect(dataSource.getMyBusiness, throwsA(isA<ValidationException>()));
  });
}

class _RecordingApiClient extends ApiClient {
  _RecordingApiClient({required this.response, List<dynamic>? getResponses})
    : getResponses = List<dynamic>.of(getResponses ?? const []),
      super(
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
  final List<dynamic> getResponses;
  String? lastPostPath;
  Map<String, dynamic>? lastPostBody;
  int getCalls = 0;
  final List<String> getPaths = [];

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
    getPaths.add(path);
    if (getResponses.isNotEmpty) {
      return getResponses.removeAt(0);
    }
    return response;
  }
}
