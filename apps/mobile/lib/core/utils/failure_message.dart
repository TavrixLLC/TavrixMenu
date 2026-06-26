import '../errors/failures.dart';

String failureMessage(Failure failure) {
  return switch (failure) {
    OfflineFailure() =>
      'We could not reach Waflo. Check your connection and try again.',
    ServerFailure() => 'The server could not complete this request.',
    TimeoutFailure() => 'The request timed out. Please try again.',
    CacheFailure() => 'Cached data is not available.',
    ValidationFailure(:final message) =>
      message ?? 'Please check the form values.',
    UnauthorizedFailure() => 'Please sign in again to continue.',
    ForbiddenFailure() =>
      'Your role does not allow this action for this business.',
    NotFoundFailure() => 'The requested record could not be found.',
    ConflictFailure(:final message) =>
      message ??
          'This stamp could not be added — the reward may already be at its limit.',
    UnknownFailure() => 'Something unexpected happened.',
    Failure() => 'Something unexpected happened.',
  };
}
