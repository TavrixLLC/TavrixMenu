import '../errors/failures.dart';

String failureMessage(Failure failure) {
  return switch (failure) {
    OfflineFailure() => 'You appear to be offline.',
    ServerFailure() => 'The server could not complete this request.',
    TimeoutFailure() => 'The request timed out. Please try again.',
    CacheFailure() => 'Cached data is not available.',
    ValidationFailure(:final message) =>
      message ?? 'Please check the form values.',
    UnknownFailure() => 'Something unexpected happened.',
    Failure() => 'Something unexpected happened.',
  };
}
