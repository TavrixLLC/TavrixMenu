import 'package:clerk_flutter/clerk_flutter.dart';

import 'token_provider.dart';

class ClerkTokenProvider implements TokenProvider {
  ClerkTokenProvider();

  ClerkAuthState? _authState;
  String? _lastToken;

  bool get hasSession =>
      _authState?.session != null && _authState?.user != null;

  void bind(ClerkAuthState authState) {
    _authState = authState;
  }

  @override
  Future<String?> getToken() async {
    final authState = _authState;
    if (authState == null || !hasSession) {
      return null;
    }

    try {
      final token = await authState.sessionToken();
      _lastToken = token.jwt;
      return token.jwt;
    } catch (_) {
      return _lastToken;
    }
  }

  Future<void> signOut() async {
    final authState = _authState;
    _lastToken = null;
    if (authState != null && hasSession) {
      await authState.signOut();
    }
  }
}
