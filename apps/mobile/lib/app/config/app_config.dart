import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.customerWebBaseUrl,
    required this.devAuthToken,
    required this.appEnv,
    required this.enableDevAuth,
    required this.clerkPublishableKey,
    this.googleClientId = '',
    this.googleServerClientId = '',
  });

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      apiBaseUrl: String.fromEnvironment('API_BASE_URL'),
      customerWebBaseUrl: String.fromEnvironment('CUSTOMER_WEB_BASE_URL'),
      devAuthToken: String.fromEnvironment('DEV_AUTH_TOKEN'),
      appEnv: String.fromEnvironment('APP_ENV', defaultValue: 'production'),
      enableDevAuth: bool.fromEnvironment(
        'ENABLE_DEV_AUTH',
        defaultValue: false,
      ),
      clerkPublishableKey: String.fromEnvironment('CLERK_PUBLISHABLE_KEY'),
      googleClientId: String.fromEnvironment('GOOGLE_CLIENT_ID'),
      googleServerClientId: String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID'),
    );
  }

  final String apiBaseUrl;
  final String customerWebBaseUrl;
  final String devAuthToken;
  final String appEnv;
  final bool enableDevAuth;
  final String clerkPublishableKey;
  final String googleClientId;
  final String googleServerClientId;

  bool get hasApiBaseUrl => apiBaseUrl.trim().isNotEmpty;

  bool get hasClerkPublishableKey => clerkPublishableKey.trim().isNotEmpty;

  bool get hasGoogleNativeClientConfig =>
      googleClientId.trim().isNotEmpty ||
      googleServerClientId.trim().isNotEmpty;

  bool get isDevelopment => appEnv.trim().toLowerCase() == 'development';

  bool get isProduction => appEnv.trim().toLowerCase() == 'production';

  bool get isDevAuthEnabled => !kReleaseMode && isDevelopment && enableDevAuth;

  String get normalizedApiBaseUrl {
    final trimmed = apiBaseUrl.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  String get normalizedCustomerWebBaseUrl {
    final trimmed = customerWebBaseUrl.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  String? get normalizedGoogleClientId {
    final trimmed = googleClientId.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? get normalizedGoogleServerClientId {
    final trimmed = googleServerClientId.trim().isNotEmpty
        ? googleServerClientId.trim()
        : googleClientId.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
