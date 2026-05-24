enum SyncStatus { idle, syncing, success }

enum SyncErrorType {
  networkError,
  authError,
  conflictError,
  fileError,
  timeoutError,
  unknown;

  String get message {
    switch (this) {
      case SyncErrorType.networkError:
        return '网络异常，请检查网络连接';
      case SyncErrorType.authError:
        return '权限不足，请重新授权';
      case SyncErrorType.conflictError:
        return '存在版本冲突，请先处理';
      case SyncErrorType.fileError:
        return '文件损坏，请重新克隆';
      case SyncErrorType.timeoutError:
        return '请求超时，请重试';
      case SyncErrorType.unknown:
        return '操作失败，请稍后重试';
    }
  }
}

class SyncException implements Exception {
  final SyncErrorType type;
  final String? detail;

  const SyncException(this.type, [this.detail]);

  @override
  String toString() => detail != null ? '${type.message}: $detail' : type.message;
}