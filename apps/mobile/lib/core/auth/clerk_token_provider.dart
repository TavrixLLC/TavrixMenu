import 'token_provider.dart';

class ClerkTokenProvider implements TokenProvider {
  const ClerkTokenProvider();

  @override
  Future<String?> getToken() async {
    // Clerk Flutter integration will provide the business-user token here later.
    return null;
  }
}
