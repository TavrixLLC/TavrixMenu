import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';
import 'package:tavrix_menu_mobile/core/auth/dev_token_provider.dart';
import 'package:tavrix_menu_mobile/core/network/api_client.dart';
import 'package:tavrix_menu_mobile/features/menu/data/datasources/menu_remote_data_source.dart';
import 'package:tavrix_menu_mobile/features/menu/domain/entities/reorder_menu_record.dart';

void main() {
  test(
    'category and item lists pass includeInactive query only when requested',
    () async {
      final apiClient = _RecordingApiClient(response: <Map<String, dynamic>>[]);
      final dataSource = MenuRemoteDataSourceImpl(apiClient);

      await dataSource.getCategories('bus_123', includeInactive: true);
      expect(apiClient.lastGetPath, '/businesses/bus_123/categories');
      expect(apiClient.lastGetQuery, {'includeInactive': true});

      await dataSource.getItems('bus_123');
      expect(apiClient.lastGetPath, '/businesses/bus_123/items');
      expect(apiClient.lastGetQuery, isNull);
    },
  );

  test('restore category and item send minimal Sprint 4 DTO bodies', () async {
    final apiClient = _RecordingApiClient(
      response: {
        'id': 'cat_123',
        'businessId': 'bus_123',
        'nameAr': 'Drinks',
        'sortOrder': 0,
        'isActive': true,
      },
    );
    final dataSource = MenuRemoteDataSourceImpl(apiClient);

    await dataSource.restoreCategory('cat_123');
    expect(apiClient.lastPatchPath, '/categories/cat_123');
    expect(apiClient.lastPatchBody, {'isActive': true});

    apiClient.response = {
      'id': 'item_123',
      'businessId': 'bus_123',
      'categoryId': 'cat_123',
      'nameAr': 'Coffee',
      'descriptionAr': null,
      'price': '3000',
      'isAvailable': true,
      'sortOrder': 0,
    };

    await dataSource.restoreItem('item_123');
    expect(apiClient.lastPatchPath, '/items/item_123');
    expect(apiClient.lastPatchBody, {'isAvailable': true});
  });

  test('reorder endpoints send orders wrapper with id and sortOrder', () async {
    final apiClient = _RecordingApiClient(response: <Map<String, dynamic>>[]);
    final dataSource = MenuRemoteDataSourceImpl(apiClient);
    const orders = [
      ReorderMenuRecord(id: 'cat_123', sortOrder: 0),
      ReorderMenuRecord(id: 'cat_456', sortOrder: 1),
    ];

    await dataSource.reorderCategories(businessId: 'bus_123', orders: orders);
    expect(apiClient.lastPatchPath, '/businesses/bus_123/categories/reorder');
    expect(apiClient.lastPatchBody, {
      'orders': [
        {'id': 'cat_123', 'sortOrder': 0},
        {'id': 'cat_456', 'sortOrder': 1},
      ],
    });

    await dataSource.reorderItems(businessId: 'bus_123', orders: orders);
    expect(apiClient.lastPatchPath, '/businesses/bus_123/items/reorder');
    expect(apiClient.lastPatchBody, {
      'orders': [
        {'id': 'cat_123', 'sortOrder': 0},
        {'id': 'cat_456', 'sortOrder': 1},
      ],
    });
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
  String? lastPatchPath;
  Map<String, dynamic>? lastPatchBody;

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
  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    lastPatchPath = path;
    lastPatchBody = body;
    return response;
  }
}
