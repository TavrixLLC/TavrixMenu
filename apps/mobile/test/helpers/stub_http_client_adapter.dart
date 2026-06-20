import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';
import 'package:tavrix_menu_mobile/core/auth/token_provider.dart';
import 'package:tavrix_menu_mobile/core/network/api_client.dart';

class StubHttpClientAdapter implements HttpClientAdapter {
  StubHttpClientAdapter({required this.statusCode, required this.data});

  final int statusCode;
  final dynamic data;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(data),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiClient buildTestApiClient(StubHttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
  dio.httpClientAdapter = adapter;
  return ApiClient(
    config: const AppConfig(
      apiBaseUrl: 'https://api.example.test',
      customerWebBaseUrl: '',
      devAuthToken: '',
      appEnv: 'test',
      enableDevAuth: false,
      clerkPublishableKey: '',
    ),
    tokenProvider: const _TestTokenProvider(),
    dio: dio,
  );
}

class _TestTokenProvider implements TokenProvider {
  const _TestTokenProvider();

  @override
  Future<String?> getToken() async => 'test-session-token';
}
