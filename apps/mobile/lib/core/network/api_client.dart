import 'package:dio/dio.dart';

import '../../app/config/app_config.dart';
import '../auth/token_provider.dart';
import '../errors/exceptions.dart';

class ApiClient {
  ApiClient({
    required AppConfig config,
    required TokenProvider tokenProvider,
    Dio? dio,
  }) : _config = config,
       _tokenProvider = tokenProvider,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: config.normalizedApiBaseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 15),
               headers: const {'Accept': 'application/json'},
             ),
           );

  final AppConfig _config;
  final TokenProvider _tokenProvider;
  final Dio _dio;

  bool get canCallBackend => _config.hasApiBaseUrl;

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _send('GET', path, queryParameters: queryParameters);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) {
    return _send('POST', path, body: body);
  }

  Future<dynamic> postWithValidationStatusCodes(
    String path, {
    Map<String, dynamic>? body,
    required Set<int> validationStatusCodes,
  }) {
    return _send(
      'POST',
      path,
      body: body,
      validationStatusCodes: validationStatusCodes,
    );
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) {
    return _send('PATCH', path, body: body);
  }

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Set<int> validationStatusCodes = const {422},
  }) async {
    if (!canCallBackend) {
      throw const ServerException('Service is not available right now.');
    }

    final token = await _tokenProvider.getToken();
    final options = Options(
      method: method,
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    try {
      final response = await _dio.request<dynamic>(
        path,
        data: body,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        throw const TimeoutException();
      }

      if (error.type == DioExceptionType.connectionError) {
        throw const OfflineException();
      }

      final statusCode = error.response?.statusCode;
      if (statusCode == 401) {
        throw const UnauthorizedException();
      }
      if (statusCode == 403) {
        throw const ForbiddenException();
      }
      if (statusCode == 404) {
        throw const NotFoundException();
      }
      if (statusCode == 409) {
        throw ConflictException(_responseMessage(error.response?.data));
      }
      if (validationStatusCodes.contains(statusCode)) {
        throw ValidationException(
          _responseMessage(error.response?.data) ?? 'Validation failed.',
        );
      }

      throw ServerException(
        error.response?.data.toString() ??
            error.message ??
            'API request failed.',
      );
    }
  }
}

String? _responseMessage(dynamic data) {
  if (data is Map) {
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    if (message is List) {
      final messages = message
          .whereType<String>()
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList();
      if (messages.isNotEmpty) {
        return messages.join(' ');
      }
    }
  }

  if (data is String && data.trim().isNotEmpty) {
    return data.trim();
  }
  return null;
}
