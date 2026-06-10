class OfflineException implements Exception {
  const OfflineException();
}

class ServerException implements Exception {
  const ServerException([this.message]);

  final String? message;
}

class ConfigurationException implements Exception {
  const ConfigurationException(this.message);

  final String message;
}

class TimeoutException implements Exception {
  const TimeoutException();
}

class EmptyCacheException implements Exception {
  const EmptyCacheException();
}

class ValidationException implements Exception {
  const ValidationException(this.message);

  final String message;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException();
}

class ForbiddenException implements Exception {
  const ForbiddenException();
}

class NotFoundException implements Exception {
  const NotFoundException();
}
