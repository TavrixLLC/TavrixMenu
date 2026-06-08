import 'token_provider.dart';

class DevTokenProvider implements TokenProvider {
  const DevTokenProvider();

  @override
  Future<String?> getToken() async {
    const token = String.fromEnvironment('DEV_AUTH_TOKEN');
    return token.isEmpty ? null : token;
  }
}
