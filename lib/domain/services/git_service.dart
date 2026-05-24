import '../entities/entities.dart';

abstract class GitService {
  /// 初始化本地仓库
  Future<void> init(String path, {String? defaultBranch});

  /// 克隆远程仓库
  Future<void> clone({
    required String url,
    required String localPath,
    required void Function(double progress) onProgress,
    required void Function() onCancel,
  });

  /// 获取文件变更列表
  Future<List<FileChange>> getStatus(String repoPath);

  /// 获取差异内容
  Future<String> getDiff(String repoPath, String filePath);

  /// 暂存文件
  Future<void> stage(String repoPath, List<String> files);

  /// 取消暂存
  Future<void> unstage(String repoPath, List<String> files);

  /// 提交
  Future<GitCommit> commit(String repoPath, String message, {String? body});

  /// 修改上一次提交
  Future<GitCommit> amendCommit(String repoPath, String message, {String? body});

  /// 获取提交历史
  Future<List<GitCommit>> getLog(String repoPath, {int limit = 50});

  /// 拉取
  Future<void> pull(String repoPath);

  /// 推送
  Future<void> push(String repoPath);

  /// 获取分支列表
  Future<List<GitBranch>> getBranches(String repoPath);

  /// 切换分支
  Future<void> checkout(String repoPath, String branchName);

  /// 新建分支
  Future<void> createBranch(String repoPath, String branchName);

  /// 删除分支
  Future<void> deleteBranch(String repoPath, String branchName);

  /// 合并分支
  Future<void> merge(String repoPath, String branchName);

  /// 获取当前分支名
  Future<String> getCurrentBranch(String repoPath);

  /// 检测远程分支最新 commit sha
  Future<String?> getRemoteSha(String repoPath, String remote, String branch);
}