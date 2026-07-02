sealed class Failure {
  final String message;
  final Object? cause;
  const Failure(this.message, {this.cause});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.cause});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.cause});
}

class GitFailure extends Failure {
  const GitFailure(super.message, {super.cause});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.cause});
}

class ConflictFailure extends Failure {
  const ConflictFailure(super.message, {super.cause});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.cause});
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.cause});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, {super.cause});
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.cause});
}