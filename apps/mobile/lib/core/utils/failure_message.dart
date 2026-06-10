import '../errors/failures.dart';

String failureMessage(Failure failure) {
  return switch (failure) {
    OfflineFailure() => 'You appear to be offline.',
    ServerFailure() => 'The server could not complete this request.',
    ConfigurationFailure(:final message) =>
      message ?? 'The app is missing required configuration.',
    TimeoutFailure() => 'The request timed out. Please try again.',
    CacheFailure() => 'Cached data is not available.',
    ValidationFailure(:final message) =>
      message ?? 'Please check the form values.',
    UnauthorizedFailure() => 'Dev authentication was rejected by the backend.',
    ForbiddenFailure() => 'This user does not have access to the business app.',
    NotFoundFailure() => 'The requested resource was not found.',
    UnknownFailure() => 'Something unexpected happened.',
    Failure() => 'Something unexpected happened.',
  };
}
