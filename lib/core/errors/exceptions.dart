sealed class AppException implements Exception {
  final String message;
  final Object? cause;
  AppException(this.message, [this.cause]);
  @override
  String toString() => "$runtimeType: $message";
}

class NetworkException extends AppException {
  NetworkException(super.message, [super.cause]);
}

class AuthException extends AppException {
  AuthException(super.message, [super.cause]);
}

class GitException extends AppException {
  GitException(super.message, [super.cause]);
}

class NotFoundException extends AppException {
  NotFoundException(super.message, [super.cause]);
}

class ConflictException extends AppException {
  ConflictException(super.message, [super.cause]);
}

class ValidationException extends AppException {
  ValidationException(super.message, [super.cause]);
}

class PermissionException extends AppException {
  PermissionException(super.message, [super.cause]);
}

class TimeoutException extends AppException {
  TimeoutException(super.message, [super.cause]);
}