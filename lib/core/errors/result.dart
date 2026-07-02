import 'exceptions.dart';
import 'failures.dart';

sealed class Result<T> {
  const Result();
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  });
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) => success(value);
}

class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);
  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) => failure(this.failure);
}

Future<Result<T>> runCatchingAsync<T>(
  Future<T> Function() block,
) async {
  try {
    final value = await block();
    return Success(value);
  } on AppException catch (e) {
    return FailureResult(_mapException(e));
  } catch (e) {
    return FailureResult(UnknownFailure(e.toString(), cause: e));
  }
}

Failure _mapException(AppException e) {
  return switch (e) {
    NetworkException() => NetworkFailure(e.message, cause: e.cause),
    AuthException() => AuthFailure(e.message, cause: e.cause),
    GitException() => GitFailure(e.message, cause: e.cause),
    NotFoundException() => NotFoundFailure(e.message, cause: e.cause),
    ConflictException() => ConflictFailure(e.message, cause: e.cause),
    ValidationException() => ValidationFailure(e.message, cause: e.cause),
    PermissionException() => PermissionFailure(e.message, cause: e.cause),
    TimeoutException() => TimeoutFailure(e.message, cause: e.cause),
  };
}