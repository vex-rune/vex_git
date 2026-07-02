import '../entities/git_entities.dart';

enum PullMode { merge, rebase, ffOnly }

class CloneOptions {
  final String url;
  final String localPath;
  final String? token;
  final String? sshKeyName;
  final String? branch;
  final bool bare;
  final int? depth;

  const CloneOptions({
    required this.url,
    required this.localPath,
    this.token,
    this.sshKeyName,
    this.branch,
    this.bare = false,
    this.depth,
  });
}

class PushOptions {
  final String? remote;
  final String? branch;
  final bool force;
  final bool setUpstream;
  final String? token;
  final String? sshKeyName;

  const PushOptions({
    this.remote,
    this.branch,
    this.force = false,
    this.setUpstream = false,
    this.token,
    this.sshKeyName,
  });
}

class PullOptions {
  final PullMode mode;
  final String? remote;
  final String? branch;
  final String? token;
  final String? sshKeyName;

  const PullOptions({
    this.mode = PullMode.merge,
    this.remote,
    this.branch,
    this.token,
    this.sshKeyName,
  });
}

class CommitOptions {
  final String message;
  final String? description;
  final bool amend;
  final bool signOff;
  final List<String> coAuthors;
  final String? authorName;
  final String? authorEmail;

  const CommitOptions({
    required this.message,
    this.description,
    this.amend = false,
    this.signOff = false,
    this.coAuthors = const [],
    this.authorName,
    this.authorEmail,
  });
}

abstract class GitClient {
  /// 返回 git 是否在 PATH 可用、版本是多少
  Future<({bool available, String? version})> probeGit();

  /// 初始化空仓库
  Future<void> init({required String path, bool bare = false});

  /// 克隆
  Stream<ProgressEvent> clone(CloneOptions options);

  /// 状态
  Future<RepoStatus> status(String repoPath);

  /// 工作区变更监控（轮询）
  Stream<RepoStatus> watch(String repoPath, {Duration interval = const Duration(seconds: 2)});

  /// 提交历史
  Future<List<Commit>> log(
    String repoPath, {
    int? maxCount,
    String? branch,
    String? pathFilter,
    String? authorFilter,
  });

  /// 单个 commit 详情
  Future<Commit?> showCommit(String repoPath, String sha);

  /// diff
  Future<List<FileDiff>> diff(
    String repoPath, {
    bool staged = false,
    String? pathFilter,
    String? ref1,
    String? ref2,
  });

  /// stage / unstage
  Future<void> stage(String repoPath, List<String> paths);
  Future<void> unstage(String repoPath, List<String> paths);
  Future<void> stageAll(String repoPath);
  Future<void> unstageAll(String repoPath);

  /// discard
  Future<void> discard(String repoPath, List<String> paths);
  Future<void> discardAll(String repoPath);

  /// commit
  Future<Commit> commit(String repoPath, CommitOptions options);

  /// branches
  Future<List<Branch>> listBranches(String repoPath);
  Future<void> checkout(String repoPath, String target, {bool create = false});
  Future<Branch> createBranch(String repoPath, String name, {String? from});
  Future<void> deleteBranch(String repoPath, String name, {bool force = false, bool remote = false});

  /// 远端
  Future<List<String>> listRemotes(String repoPath);
  Future<void> addRemote(String repoPath, String name, String url);
  Future<void> removeRemote(String repoPath, String name);
  Future<void> setRemoteUrl(String repoPath, String name, String url);

  /// sync
  Stream<ProgressEvent> fetch(String repoPath, {String? remote, String? token, String? sshKeyName});
  Stream<ProgressEvent> pull(String repoPath, PullOptions options);
  Stream<ProgressEvent> push(String repoPath, PushOptions options);

  /// stash
  Future<void> stash(String repoPath, {String? message});
  Future<void> stashPop(String repoPath, {int? index});
  Future<void> stashApply(String repoPath, {int? index});
  Future<void> stashDrop(String repoPath, {int? index});
  Future<List<StashEntry>> stashList(String repoPath);

  /// 取消当前正在执行的操作
  void cancel(String repoPath);
}