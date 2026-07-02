# Vex Git - 架构说明

## 一、整体架构

```
+--------------------------------------------------+
|  Presentation (UI / Widgets)                    |
|  - Riverpod providers                            |
|  - GoRouter                                      |
|  - Material 3 / 自定义设计                       |
+--------------------------------------------------+
                       |
+--------------------------------------------------+
|  Domain (纯 Dart)                                |
|  - Entities                                      |
|  - Repository 接口                                |
|  - UseCases                                      |
+--------------------------------------------------+
                       |
+--------------------------------------------------+
|  Data (实现)                                      |
|  - Models (DTO)                                  |
|  - DataSources (Local / Remote)                  |
|  - RepositoryImpl                                |
+--------------------------------------------------+
                       |
+--------------------------------------------------+
|  Infrastructure (第三方适配)                      |
|  - Git 客户端（libgit2 FFI）                     |
|  - GitHub REST/GraphQL API                       |
|  - Secure Storage                                |
|  - Path Provider                                 |
+--------------------------------------------------+
```

## 二、关键技术选型

| 关注点 | 选型 | 说明 |
|---|---|---|
| 状态管理 | flutter_riverpod ^2.6.1 | 可测试、无 BuildContext 依赖 |
| 路由 | go_router ^14.8.1 | 声明式 + 深链 |
| Git 内核 | libgit2 via libgit2dart FFI | 高性能、原生 API 兼容 |
| HTTP | dio ^5.x | 拦截器、重试、OAuth |
| 安全存储 | flutter_secure_storage ^9.x | Keychain / Keystore |
| 持久化 | drift ^2.x (SQLite) | 仓库元数据、PR 缓存 |
| 偏好 | shared_preferences ^2.x | 简单 KV |
| 国际化 | flutter_localizations + intl | ARB 文件 |
| 日志 | talker ^4.x | 文件 + 控制台 |
| 测试 | flutter_test + mocktail | 单元 + widget |

## 三、目录约定

```
lib/
├── app/                          # 应用入口、路由、主题
│   ├── app.dart                  # MaterialApp 构造
│   ├── router/                   # GoRouter 配置
│   └── theme/                    # 主题、颜色 token
├── core/                         # 跨切关注点
│   ├── constants/                # 常量
│   ├── errors/                   # Failure / Exception
│   ├── utils/                    # 工具函数
│   └── widgets/                  # 通用 widget
├── data/                         # 数据层
│   ├── datasources/
│   │   ├── local/                # SQLite、文件
│   │   └── remote/               # GitHub API
│   ├── models/                   # DTO + JSON 序列化
│   └── repositories/             # Repository 实现
├── domain/                       # 领域层
│   ├── entities/                 # 业务实体
│   ├── repositories/             # Repository 接口
│   └── usecases/                 # 业务用例
├── infrastructure/               # 基础设施
│   ├── git/                      # libgit2 封装
│   ├── github/                   # GitHub API 客户端
│   └── storage/                  # 配置 / Secure 封装
├── presentation/                 # UI
│   ├── providers/                # Riverpod 全局 provider
│   ├── features/                 # 每个 feature 一个子目录
│   │   └── <feature>/
│   │       ├── providers.dart
│   │       ├── screen.dart
│   │       └── widgets.dart
│   └── widgets/                  # 跨 feature 共享 widget
├── l10n/                         # 国际化资源
└── main.dart                     # 入口
```

## 四、核心抽象

### 4.1 GitClient（基础设施层）

所有 Git 操作通过此接口暴露，**不直接让 UI 感知 libgit2**：

```dart
abstract class GitClient {
  Future<RepoHandle> open(String path);
  Future<void> clone({required String url, required String localPath,
                     String? token, String? sshKey});
  Future<RevStatus> status(String path);
  Future<List<Commit>> log(String path, {int? max, String? branch});
  Future<void> stage(String path, List<String> paths);
  Future<void> unstage(String path, List<String> paths);
  Future<Commit> commit(String path, {required String message,
                                     bool amend = false, String? author});
  Future<DiffResult> diff(String path, {String? pathFilter, String? ref});
  Future<List<Branch>> branches(String path);
  Future<void> checkout(String path, String target, {bool create = false});
  Future<void> fetch(String path, {String? remote});
  Future<void> pull(String path, {PullMode mode});
  Future<void> push(String path, {bool force = false, bool setUpstream = false});
  Future<void> stash(String path, {String? message, bool pop = false});
  Future<List<FileChange>> stashList(String path);
  Future<Stream<ProgressEvent>> operationStream(String path);
}
```

### 4.2 Repository（领域层）

```dart
abstract class RepositoryRepository {
  Future<List<RepoEntity>> list();
  Future<RepoEntity> addLocal(String path);
  Future<void> remove(String id);
  Future<void> rename(String id, String newName);
  Future<void> setLocalPath(String newPath);
  Future<RepoEntity> clone({required String url, String? destPath});
}
```

### 4.3 UseCase 模式

每个 UseCase 是单一目的类，可独立测试：

```dart
class StageFiles {
  final GitClient _git;
  StageFiles(this._git);
  Future<void> call(String repoPath, List<String> paths) =>
      _git.stage(repoPath, paths);
}
```

## 五、状态管理边界

| 层 | 状态 | Provider 类型 |
|---|---|---|
| 基础设施 | 单例服务（GitClient、ApiClient） | `Provider` |
| 数据仓储 | 实例化 | `Provider` / `FutureProvider` |
| UseCase | 一次性调用 | 直接在 widget 通过 ref.read 调 |
| UI 状态 | 列表、筛选、表单 | `NotifierProvider` / `AsyncNotifierProvider` |
| 全局会话 | 当前账户、当前仓库 | `NotifierProvider` |

## 六、错误体系

所有失败统一为 `Failure` 子类，UI 层用 `result.fold` 处理：

```dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}
class NetworkFailure extends Failure { ... }
class AuthFailure extends Failure { ... }
class GitFailure extends Failure { ... }
class NotFoundFailure extends Failure { ... }
class ConflictFailure extends Failure { ... }
class UnknownFailure extends Failure { ... }
```

## 七、并发与进度

- **长时间操作**（clone / push / pull）走 `Stream<ProgressEvent>` 暴露进度
- **UI 订阅**：`ref.watch(streamProvider)` 自动取消旧订阅
- **取消令牌**：`CancelToken` 在 widget dispose 时自动触发