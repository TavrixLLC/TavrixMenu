import 'package:clerk_flutter/clerk_flutter.dart';

import 'token_provider.dart';

class ClerkTokenProvider implements TokenProvider {
  ClerkTokenProvider();

  ClerkAuthState? _authState;

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
      return token.jwt;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    final authState = _authState;
    if (authState != null && hasSession) {
      await authState.signOut();
    }
  }
}
