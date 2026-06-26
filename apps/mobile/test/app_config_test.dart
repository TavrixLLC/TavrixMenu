import 'package:flutter_test/flutter_test.dart';
import 'package:tavrix_menu_mobile/app/config/app_config.dart';

void main() {
  test('auth config status names missing keys without values', () {
    const config = AppConfig(
      apiBaseUrl: '',
      customerWebBaseUrl: '',
      devAuthToken: '',
      appEnv: 'development',
      enableDevAuth: false,
      clerkPublishableKey: '',
    );

    expect(config.hasOperatorAuthConfig, isFalse);
    expect(config.sanitizedAuthConfigStatus, {
      'status': 'missing',
      'missingKeys': [
        'API_BASE_URL',
        'CLERK_PUBLISHABLE_KEY',
        'CUSTOMER_WEB_BASE_URL',
      ],
    });
  });

  test('auth config status is configured when QA keys exist', () {
    const config = AppConfig(
      apiBaseUrl: 'https://api.example.test',
      customerWebBaseUrl: 'https://menu.example.test',
      devAuthToken: '',
      appEnv: 'production',
      enableDevAuth: false,
      clerkPublishableKey: 'pk_test_placeholder',
    );

    expect(config.hasOperatorAuthConfig, isTrue);
    expect(config.sanitizedAuthConfigStatus, {
      'status': 'configured',
      'missingKeys': <String>[],
    });
    expect(config.sanitizedAuthConfigStatus.toString(), isNot(contains('pk_')));
    expect(
      config.sanitizedAuthConfigStatus.toString(),
      isNot(contains('https://')),
    );
  });
}
