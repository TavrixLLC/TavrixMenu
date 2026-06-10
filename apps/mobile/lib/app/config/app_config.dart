import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.clerkPublishableKey,
    required this.devFallbackEnabled,
  });

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      apiBaseUrl: String.fromEnvironment('API_BASE_URL'),
      clerkPublishableKey: String.fromEnvironment('CLERK_PUBLISHABLE_KEY'),
      devFallbackEnabled:
          !kReleaseMode &&
          bool.fromEnvironment(
            'TAVRIX_ENABLE_DEV_FALLBACK',
            defaultValue: true,
          ),
    );
  }

  final String apiBaseUrl;
  final String clerkPublishableKey;
  final bool devFallbackEnabled;

  bool get hasApiBaseUrl => apiBaseUrl.trim().isNotEmpty;

  String get normalizedApiBaseUrl {
    final trimmed = apiBaseUrl.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
