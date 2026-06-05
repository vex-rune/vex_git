// ignore_for_file: ambiguous_import, undefined_getter, implementation_imports, unnecessary_import

import 'package:git_on_dart/git_on_dart.dart' hide GitCommit;
import 'package:git_on_dart/src/core/repository.dart' show GitRepository;
import 'package:git_on_dart/src/operations/add_operations.dart';
import 'package:git_on_dart/src/operations/checkout_operations.dart';
import 'package:git_on_dart/src/operations/commit_operations.dart';
import 'package:git_on_dart/src/operations/log_operations.dart';
import 'package:git_on_dart/src/operations/merge_operations.dart';
import 'package:git_on_dart/src/operations/status_operations.dart';
import 'package:git_on_dart/src/remote/pull_operations.dart';
import 'package:git_on_dart/src/remote/push_operations.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/git_service.dart';

class GitOnDartImpl implements GitService {
  @override
  Future<void> init(String path, {String? defaultBranch}) async {
    final repo = await GitRepository.init(path);
    if (defaultBranch != null) {
      final checkout = CheckoutOperation(repo);
      await checkout.checkoutNewBranch(defaultBranch);
    }
  }

  @override
  Future<void> clone({
    required String url,
    required String localPath,
    required void Function(double progress) onProgress,
    required void Function() onCancel,
  }) async {
    final op = CloneOperation();
    await op.clone(
      url: url,
      path: localPath,
      onProgress: (stage, p) => onProgress(p),
    );
  }

  @override
  Future<List<FileChange>> getStatus(String repoPath) async {
    final repo = await GitRepository.open(repoPath);
    final status = await StatusOperation(repo).status();
    final changes = <FileChange>[];

    for (final e in status.untracked) {
      changes.add(FileChange(path: e.path, status: ChangeStatus.added));
    }
    for (final e in status.staged) {
      changes.add(FileChange(path: e.path, status: _mapStagedStatus(e.status)));
    }
    for (final e in status.unstaged) {
      changes.add(FileChange(path: e.path, status: _mapFileStatus(e.status)));
    }

    return changes;
  }

  ChangeStatus _mapStagedStatus(FileStatus s) {
    switch (s) {
      case FileStatus.added:
        return ChangeStatus.added;
      case FileStatus.deleted:
        return ChangeStatus.deleted;
      case FileStatus.renamed:
        return ChangeStatus.renamed;
      default:
        return ChangeStatus.modified;
    }
  }

  ChangeStatus _mapFileStatus(FileStatus s) {
    switch (s) {
      case FileStatus.modified:
        return ChangeStatus.modified;
      case FileStatus.deleted:
        return ChangeStatus.deleted;
      case FileStatus.renamed:
        return ChangeStatus.renamed;
      default:
        return ChangeStatus.modified;
    }
  }

  @override
  Future<String> getDiff(String repoPath, String filePath) async {
    return '';
  }

  @override
  Future<void> stage(String repoPath, List<String> files) async {
    final repo = await GitRepository.open(repoPath);
    await AddOperation(repo).add(files);
  }

  @override
  Future<void> unstage(String repoPath, List<String> files) async {
    final repo = await GitRepository.open(repoPath);
    // git reset HEAD 等效操作：通过 checkout 恢复暂存区
    final checkout = CheckoutOperation(repo);
    final currentBranch = await repo.getCurrentBranch() ?? 'HEAD';
    await checkout.checkoutBranch(currentBranch);
  }

  @override
  Future<GitCommit> commit(String repoPath, String message, {String? body}) async {
    final repo = await GitRepository.open(repoPath);
    final fullMsg = body != null ? '$message\n\n$body' : message;
    final result = await CommitOperation(repo).commit(fullMsg);
    return GitCommit(
      sha: result.hash,
      message: message,
      author: result.author.name,
      authorEmail: result.author.email,
      timestamp: result.author.timestamp,
      parentShas: result.parents,
    );
  }

  @override
  Future<GitCommit> amendCommit(String repoPath, String message, {String? body}) async {
    final repo = await GitRepository.open(repoPath);
    final fullMsg = body != null ? '$message\n\n$body' : message;
    final result = await CommitOperation(repo).amend(fullMsg);
    return GitCommit(
      sha: result.hash,
      message: message,
      author: result.author.name,
      authorEmail: result.author.email,
      timestamp: result.author.timestamp,
      parentShas: result.parents,
    );
  }

  @override
  Future<List<GitCommit>> getLog(String repoPath, {int limit = 50}) async {
    final repo = await GitRepository.open(repoPath);
    final logOp = LogOperation(repo);
    final logs = await logOp.getHistory(options: LogOptions(maxCount: limit));
    return logs.map((l) => GitCommit(
      sha: l.hash,
      message: l.message,
      author: l.author.name,
      authorEmail: l.author.email,
      timestamp: l.author.timestamp,
      parentShas: l.parents,
    )).toList();
  }

  @override
  Future<void> pull(String repoPath) async {
    final repo = await GitRepository.open(repoPath);
    await PullOperation(repo).pull('origin');
  }

  @override
  Future<void> push(String repoPath) async {
    final repo = await GitRepository.open(repoPath);
    await PushOperation(repo).push('origin');
  }

  @override
  Future<List<GitBranch>> getBranches(String repoPath) async {
    final repo = await GitRepository.open(repoPath);
    final branches = await repo.listBranches();
    final current = await repo.getCurrentBranch();
    return branches.map((b) => GitBranch(
      name: b,
      type: b.startsWith('origin/') ? BranchType.remote : BranchType.local,
      isCurrent: b == current,
    )).toList();
  }

  @override
  Future<void> checkout(String repoPath, String branchName) async {
    final repo = await GitRepository.open(repoPath);
    final checkout = CheckoutOperation(repo);
    await checkout.checkoutBranch(branchName);
  }

  @override
  Future<void> createBranch(String repoPath, String branchName) async {
    final repo = await GitRepository.open(repoPath);
    final checkout = CheckoutOperation(repo);
    await checkout.checkoutNewBranch(branchName);
  }

  @override
  Future<void> deleteBranch(String repoPath, String branchName) async {
    final repo = await GitRepository.open(repoPath);
    await repo.deleteBranch(branchName);
  }

  @override
  Future<void> merge(String repoPath, String branchName) async {
    final repo = await GitRepository.open(repoPath);
    await MergeOperation(repo).merge(branchName);
  }

  @override
  Future<String> getCurrentBranch(String repoPath) async {
    final repo = await GitRepository.open(repoPath);
    return await repo.getCurrentBranch() ?? 'main';
  }

  @override
  Future<String?> getRemoteSha(String repoPath, String remote, String branch) async {
    try {
      final repo = await GitRepository.open(repoPath);
      final branches = await repo.listBranches();
      final remoteRef = '$remote/$branch';
      if (branches.contains(remoteRef)) {
        final logOp = LogOperation(repo);
        final logs = await logOp.getHistory(options: LogOptions(maxCount: 1));
        if (logs.isNotEmpty) {
          return logs.first.hash;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}