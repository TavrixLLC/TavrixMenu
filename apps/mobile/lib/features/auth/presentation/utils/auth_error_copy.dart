import '../../../../core/errors/failures.dart';
import '../../../../core/utils/failure_message.dart';

class AuthErrorCopy {
  const AuthErrorCopy({required this.title, required this.body});

  final String title;
  final String body;
}

const businessAccountNotFoundCopy = AuthErrorCopy(
  title: 'Business account not found',
  body:
      'This mobile app is for Waflo business accounts. Contact Waflo support to activate your business workspace.',
);

const invalidOtpCopy = AuthErrorCopy(
  title: 'Invalid code',
  body: 'Check the code and try again.',
);

const technicalSignInErrorCopy = AuthErrorCopy(
  title: 'Something went wrong',
  body: 'We couldn\'t complete sign-in right now. Please try again.',
);

AuthErrorCopy authErrorCopyFromFailure(Failure failure) {
  if (failure is NotFoundFailure || failure is ForbiddenFailure) {
    return businessAccountNotFoundCopy;
  }

  if (failure is UnauthorizedFailure) {
    return const AuthErrorCopy(
      title: 'Sign in expired',
      body: 'Please sign in again to continue.',
    );
  }

  if (failure is OfflineFailure || failure is TimeoutFailure) {
    return AuthErrorCopy(
      title: 'Connection problem',
      body: failureMessage(failure),
    );
  }

  return technicalSignInErrorCopy;
}

AuthErrorCopy authErrorCopyFromClerkError(Object error) {
  final normalized = error.toString().toUpperCase();

  if (_looksLikeInvalidOtp(normalized)) {
    return invalidOtpCopy;
  }

  if (_looksLikeAccountNotFound(normalized)) {
    return businessAccountNotFoundCopy;
  }

  return technicalSignInErrorCopy;
}

bool _looksLikeInvalidOtp(String normalized) {
  return normalized.contains('CODE') &&
      (normalized.contains('INVALID') ||
          normalized.contains('INCORRECT') ||
          normalized.contains('EXPIRED'));
}

bool _looksLikeAccountNotFound(String normalized) {
  final hasLookupFailure =
      normalized.contains('COULDN\'T FIND YOUR ACCOUNT') ||
      normalized.contains('COULD NOT FIND YOUR ACCOUNT') ||
      normalized.contains('ACCOUNT NOT FOUND') ||
      normalized.contains('BUSINESS ACCOUNT NOT FOUND') ||
      normalized.contains('USER_NOT_FOUND') ||
      normalized.contains('IDENTIFIER_NOT_FOUND') ||
      normalized.contains('FORM_IDENTIFIER_NOT_FOUND') ||
      normalized.contains('NO ACCOUNT');

  return hasLookupFailure ||
      (normalized.contains('ERROR_RECEIVED_FROM_SERVER') &&
          (normalized.contains('ACCOUNT') ||
              normalized.contains('IDENTIFIER')));
}
