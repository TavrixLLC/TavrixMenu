import 'package:clerk_flutter/clerk_flutter.dart';

import '../../app/config/app_config.dart';
import 'clerk_token_provider.dart';
import 'dev_token_provider.dart';
import 'token_provider.dart';

enum AuthTokenSource { none, clerk, development }

class AuthSessionController implements TokenProvider {
  AuthSessionController({
    required AppConfig config,
    required ClerkTokenProvider clerkTokenProvider,
    required DevTokenProvider devTokenProvider,
  }) : _config = config,
       _clerkTokenProvider = clerkTokenProvider,
       _devTokenProvider = devTokenProvider;

  final AppConfig _config;
  final ClerkTokenProvider _clerkTokenProvider;
  final DevTokenProvider _devTokenProvider;

  AuthTokenSource _source = AuthTokenSource.none;

  bool get canUseDevAuth => _config.isDevAuthEnabled;

  bool get canUseClerkAuth => _config.hasClerkPublishableKey;

  bool get hasClerkSession => _clerkTokenProvider.hasSession;

  AuthTokenSource get source => _source;

  void bindClerkAuthState(ClerkAuthState authState) {
    _clerkTokenProvider.bind(authState);
  }

  void useClerk() {
    _source = AuthTokenSource.clerk;
  }

  void useDevelopment() {
    _source = AuthTokenSource.development;
  }

  @override
  Future<String?> getToken() {
    return switch (_source) {
      AuthTokenSource.clerk => _clerkTokenProvider.getToken(),
      AuthTokenSource.development => _devTokenProvider.getToken(),
      AuthTokenSource.none => Future<String?>.value(),
    };
  }

  Future<void> signOut() async {
    final shouldSignOutClerk = _source == AuthTokenSource.clerk;
    _source = AuthTokenSource.none;
    if (shouldSignOutClerk) {
      await _clerkTokenProvider.signOut();
    }
  }
}
