class AppException implements Exception {
  final String message;
  final String? detail;

  const AppException(this.message, [this.detail]);

  @override
  String toString() => detail != null ? '$message: $detail' : message;
}

class NetworkException extends AppException {
  const NetworkException([String? detail]) : super('网络异常，请检查网络连接', detail);
}

class AuthException extends AppException {
  const AuthException([String? detail]) : super('权限不足，请重新授权', detail);
}

class ConflictException extends AppException {
  const ConflictException([String? detail]) : super('存在版本冲突，请先处理', detail);
}

class CloneException extends AppException {
  const CloneException([String? detail]) : super('克隆失败', detail);
}