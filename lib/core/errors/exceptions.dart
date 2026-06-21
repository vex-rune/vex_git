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

/// 将原始错误转换为用户友好的提示信息
String formatError(Object e) {
  final msg = e.toString().toLowerCase();
  if (msg.contains('permission') || msg.contains('401') || msg.contains('403') || msg.contains('auth')) {
    return '权限不足，请检查 Token 或密钥配置';
  }
  if (msg.contains('network') || msg.contains('timeout') || msg.contains('socket') || msg.contains('connection')) {
    return '网络异常，请检查网络连接';
  }
  if (msg.contains('conflict') || msg.contains('<<<<<<')) {
    return '存在版本冲突，请先处理冲突';
  }
  if (msg.contains('not found') || msg.contains('404')) {
    return '仓库或分支不存在';
  }
  if (msg.contains('clone')) {
    return '克隆失败: $e';
  }
  return '操作失败: $e';
}