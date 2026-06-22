import 'token_provider.dart';

class DevTokenProvider implements TokenProvider {
  const DevTokenProvider(this.token);

  final String token;

  @override
  Future<String?> getToken() async {
    final cleanToken = token.trim();
    return cleanToken.isEmpty ? null : cleanToken;
  }
}
