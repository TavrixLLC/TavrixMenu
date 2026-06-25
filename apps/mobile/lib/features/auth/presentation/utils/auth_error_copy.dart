import '../../../../core/errors/failures.dart';
import '../../../../core/utils/failure_message.dart';

class AuthErrorCopy {
  const AuthErrorCopy({required this.title, required this.body});

  final String title;
  final String body;
}

const accountNotFoundAuthErrorCopy = AuthErrorCopy(
  title: 'Account not found',
  body:
      'We couldn\'t find an operator account for this email or phone. Ask your business owner to invite you to Waflo.',
);

const genericAuthErrorCopy = AuthErrorCopy(
  title: 'Sign in could not continue',
  body: 'We could not complete sign in. Check your details and try again.',
);

AuthErrorCopy authErrorCopyFromFailure(Failure failure) {
  if (failure is NotFoundFailure) {
    return accountNotFoundAuthErrorCopy;
  }

  return AuthErrorCopy(
    title: 'Sign in could not continue',
    body: failureMessage(failure),
  );
}

AuthErrorCopy authErrorCopyFromClerkError(Object error) {
  final raw = error.toString();
  final normalized = raw.toUpperCase();

  if (_looksLikeAccountNotFound(normalized)) {
    return accountNotFoundAuthErrorCopy;
  }

  return genericAuthErrorCopy;
}

bool _looksLikeAccountNotFound(String normalized) {
  final hasLookupFailure =
      normalized.contains('COULDN\'T FIND YOUR ACCOUNT') ||
      normalized.contains('COULD NOT FIND YOUR ACCOUNT') ||
      normalized.contains('ACCOUNT NOT FOUND') ||
      normalized.contains('USER_NOT_FOUND') ||
      normalized.contains('IDENTIFIER_NOT_FOUND') ||
      normalized.contains('FORM_IDENTIFIER_NOT_FOUND') ||
      normalized.contains('NO ACCOUNT');

  return hasLookupFailure ||
      (normalized.contains('ERROR_RECEIVED_FROM_SERVER') &&
          (normalized.contains('ACCOUNT') ||
              normalized.contains('IDENTIFIER')));
}
