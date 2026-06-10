import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.clerkPublishableKey,
    required this.customerWebBaseUrl,
    required this.appEnv,
    required this.enableDevAuth,
    required this.enableDevFallback,
  });

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      apiBaseUrl: String.fromEnvironment('API_BASE_URL'),
      clerkPublishableKey: String.fromEnvironment('CLERK_PUBLISHABLE_KEY'),
      customerWebBaseUrl: String.fromEnvironment(
        'CUSTOMER_WEB_BASE_URL',
        defaultValue: 'https://menu.tavrix.com',
      ),
      appEnv: String.fromEnvironment('APP_ENV', defaultValue: 'development'),
      enableDevAuth: bool.fromEnvironment(
        'ENABLE_DEV_AUTH',
        defaultValue: true,
      ),
      enableDevFallback: bool.fromEnvironment(
        'TAVRIX_ENABLE_DEV_FALLBACK',
        defaultValue: true,
      ),
    );
  }

  final String apiBaseUrl;
  final String clerkPublishableKey;
  final String customerWebBaseUrl;
  final String appEnv;
  final bool enableDevAuth;
  final bool enableDevFallback;

  bool get hasApiBaseUrl => apiBaseUrl.trim().isNotEmpty;

  bool get isDevelopment => appEnv.trim().toLowerCase() == 'development';

  bool get devAuthEnabled => isDevelopment && enableDevAuth && !kReleaseMode;

  bool get devFallbackEnabled => devAuthEnabled && enableDevFallback;

  String get normalizedApiBaseUrl {
    final trimmed = apiBaseUrl.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  String get normalizedCustomerWebBaseUrl {
    final trimmed = customerWebBaseUrl.trim();
    if (trimmed.isEmpty) {
      return 'https://menu.tavrix.com';
    }
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  String customerMenuUrl(String slug) {
    final cleanSlug = slug.trim();
    final pathSlug = cleanSlug.isEmpty ? 'your-business' : cleanSlug;
    return '$normalizedCustomerWebBaseUrl/m/$pathSlug';
  }
}
