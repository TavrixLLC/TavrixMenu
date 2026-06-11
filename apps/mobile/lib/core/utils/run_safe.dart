import 'package:dartz/dartz.dart';

import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../network/network_info.dart';

Future<Either<Failure, T>> runSafe<T>(
  Future<T> Function() action,
  NetworkInfo networkInfo,
) async {
  if (await networkInfo.isConnected) {
    try {
      final result = await action();
      return Right(result);
    } on ServerException {
      return const Left(ServerFailure());
    } on OfflineException {
      return const Left(OfflineFailure());
    } on TimeoutException {
      return const Left(TimeoutFailure());
    } on EmptyCacheException {
      return const Left(CacheFailure());
    } on ValidationException catch (error) {
      return Left(ValidationFailure(error.message));
    } on UnauthorizedException {
      return const Left(ServerFailure());
    } on ForbiddenException {
      return const Left(ServerFailure());
    } on NotFoundException {
      return const Left(ServerFailure());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  } else {
    return const Left(OfflineFailure());
  }
}
