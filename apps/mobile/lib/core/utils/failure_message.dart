import '../errors/failures.dart';

String failureMessage(Failure failure) {
  return switch (failure) {
    OfflineFailure() =>
      'We could not reach Waflo. Check your connection and try again.',
    ServerFailure() =>
      "We couldn't complete this action right now. Please try again.",
    TimeoutFailure() => 'The request timed out. Please try again.',
    CacheFailure() => 'Cached data is not available.',
    ValidationFailure(:final message) =>
      _friendlyDetail(message) ?? 'Please check the form values.',
    UnauthorizedFailure() => 'Please sign in again to continue.',
    ForbiddenFailure() =>
      'Your role does not allow this action for this business.',
    NotFoundFailure() => 'The requested record could not be found.',
    ConflictFailure(:final message) =>
      _friendlyDetail(message) ??
          'This stamp could not be added. The reward may already be at its limit.',
    UnknownFailure() =>
      "We couldn't complete this action right now. Please try again.",
    Failure() =>
      "We couldn't complete this action right now. Please try again.",
  };
}

String? _friendlyDetail(String? message) {
  final trimmed = message?.trim();
  if (trimmed == null || trimmed.isEmpty || _looksTechnical(trimmed)) {
    return null;
  }
  return trimmed;
}

bool _looksTechnical(String message) {
  return message.contains(RegExp(r'\b[A-Z0-9]+(?:_[A-Z0-9]+)+\b')) ||
      message.contains('Exception') ||
      message.contains('StackTrace') ||
      message.contains('{') ||
      message.contains('}');
}
