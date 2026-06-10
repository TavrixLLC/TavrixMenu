import 'token_provider.dart';

class DevTokenProvider implements TokenProvider {
  const DevTokenProvider({required this.enabled});

  final bool enabled;

  @override
  Future<String?> getToken() async {
    if (!enabled) {
      return null;
    }

    const token = String.fromEnvironment('DEV_AUTH_TOKEN');
    return token.isEmpty ? null : token;
  }
}
