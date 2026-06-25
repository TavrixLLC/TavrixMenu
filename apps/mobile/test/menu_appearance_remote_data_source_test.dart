import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';
import 'package:tavrix_menu_mobile/core/auth/dev_token_provider.dart';
import 'package:tavrix_menu_mobile/core/network/api_client.dart';
import 'package:tavrix_menu_mobile/features/menu_appearance/data/datasources/menu_appearance_remote_data_source.dart';

void main() {
  test('loads template catalog from GET /menu-templates', () async {
    final apiClient = _RecordingApiClient(
      response: {
        'templates': [
          {
            'id': 'waflo-warm',
            'displayName': 'Waflo Warm',
            'description': 'Default warm template.',
            'bestFor': ['Cafes'],
            'themeTokens': {
              'colors': ['#FF6B4A', '#FFF8F2', '#43A047'],
            },
            'layoutVariant': 'Rounded cards',
          },
        ],
      },
    );
    final dataSource = MenuAppearanceRemoteDataSourceImpl(apiClient);

    final templates = await dataSource.getTemplates();

    expect(apiClient.lastGetPath, '/menu-templates');
    expect(templates.single.id, 'waflo-warm');
    expect(templates.single.previewColors, ['#FF6B4A', '#FFF8F2', '#43A047']);
  });

  test('loads and patches business appearance with template id body', () async {
    final apiClient = _RecordingApiClient(
      response: {
        'appearance': {'businessId': 'bus_123', 'menuTemplateId': 'waflo-warm'},
      },
    );
    final dataSource = MenuAppearanceRemoteDataSourceImpl(apiClient);

    final current = await dataSource.getBusinessAppearance('bus_123');
    expect(apiClient.lastGetPath, '/businesses/bus_123/appearance');
    expect(current.menuTemplateId, 'waflo-warm');

    apiClient.response = {
      'appearance': {
        'businessId': 'bus_123',
        'menuTemplateId': 'minimal-modern',
      },
    };
    final updated = await dataSource.updateBusinessAppearance(
      businessId: 'bus_123',
      menuTemplateId: 'minimal-modern',
    );

    expect(apiClient.lastPatchPath, '/businesses/bus_123/appearance');
    expect(apiClient.lastPatchBody, {'menuTemplateId': 'minimal-modern'});
    expect(updated.menuTemplateId, 'minimal-modern');
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
  String? lastPatchPath;
  Map<String, dynamic>? lastPatchBody;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    lastGetPath = path;
    return response;
  }

  @override
  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    lastPatchPath = path;
    lastPatchBody = body;
    return response;
  }
}
