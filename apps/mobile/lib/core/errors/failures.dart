import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

class OfflineFailure extends Failure {
  const OfflineFailure();
}

class ServerFailure extends Failure {
  const ServerFailure();
}

class TimeoutFailure extends Failure {
  const TimeoutFailure();
}

class CacheFailure extends Failure {
  const CacheFailure();
}

class ValidationFailure extends Failure {
  const ValidationFailure([this.message]);

  final String? message;

  @override
  List<Object?> get props => [message];
}

class UnknownFailure extends Failure {
  const UnknownFailure();
}
