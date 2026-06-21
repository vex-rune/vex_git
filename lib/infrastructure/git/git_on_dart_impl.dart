// ignore_for_file: ambiguous_import, undefined_getter, implementation_imports, unnecessary_import

import 'dart:io';
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
import '../../core/diff/diff_utils.dart';
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
  Future<List<DiffLine>> getDiff(String repoPath, String filePath) async {
    final repo = await GitRepository.open(repoPath);

    // 读取 HEAD 版本的文件内容
    final headContent = await _readFileFromHead(repo, filePath);
    if (headContent == null) {
      // 新文件，整个文件都是新增
      final file = File('${repo.workDir}/$filePath');
      if (await file.exists()) {
        final newContent = await file.readAsString();
        final lines = newContent.split('\n');
        return List.generate(lines.length, (i) => DiffLine(
          oldLineNo: 0,
          newLineNo: i + 1,
          content: lines[i],
          type: DiffType.added,
        ));
      }
      return [];
    }

    // 读取工作区当前文件内容
    final file = File('${repo.workDir}/$filePath');
    if (!await file.exists()) {
      // 文件被删除
      final lines = headContent.split('\n');
      return List.generate(lines.length, (i) => DiffLine(
        oldLineNo: i + 1,
        newLineNo: 0,
        content: lines[i],
        type: DiffType.removed,
      ));
    }

    final newContent = await file.readAsString();
    return computeDiff(headContent, newContent);
  }

  /// 从 HEAD 提交中读取指定路径的文件内容
  Future<String?> _readFileFromHead(GitRepository repo, String filePath) async {
    try {
      final headHash = await repo.getCurrentCommit();
      if (headHash == null) return null;

      final commit = await repo.readCommit(headHash);
      return await _findFileInTree(repo, commit.tree, filePath);
    } catch (_) {
      return null;
    }
  }

  /// 递归在 tree 中查找文件内容
  Future<String?> _findFileInTree(GitRepository repo, String treeHash, String targetPath) async {
    final tree = await repo.readTree(treeHash);
    final parts = targetPath.split('/');
    final firstPart = parts.first;

    final entry = tree.findEntry(firstPart);
    if (entry == null) return null;

    if (parts.length == 1) {
      // 找到目标文件
      if (entry.isDirectory) return null;
      final blob = await repo.readBlob(entry.hash);
      return blob.contentAsString;
    }

    // 递归进入子目录
    if (!entry.isDirectory) return null;
    final remainingPath = parts.sublist(1).join('/');
    return await _findFileInTree(repo, entry.hash, remainingPath);
  }

  @override
  Future<List<FileChange>> getCommitChanges(String repoPath, String commitSha) async {
    final repo = await GitRepository.open(repoPath);
    final commit = await repo.readCommit(commitSha);

    if (commit.parents.isEmpty) {
      // 初始提交，tree 中所有文件都是新增
      return await _listTreeFiles(repo, commit.tree, '');
    }

    // 对比当前提交与父提交的 tree
    final parentCommit = await repo.readCommit(commit.parents.first);
    return await _diffTrees(repo, parentCommit.tree, commit.tree, '');
  }

  /// 列出 tree 中所有文件（用于初始提交）
  Future<List<FileChange>> _listTreeFiles(GitRepository repo, String treeHash, String prefix) async {
    final tree = await repo.readTree(treeHash);
    final files = <FileChange>[];

    for (final entry in tree.entries) {
      final path = prefix.isEmpty ? entry.name : '$prefix/${entry.name}';
      if (entry.isDirectory) {
        files.addAll(await _listTreeFiles(repo, entry.hash, path));
      } else {
        files.add(FileChange(path: path, status: ChangeStatus.added));
      }
    }
    return files;
  }

  /// 对比两个 tree 的差异
  Future<List<FileChange>> _diffTrees(GitRepository repo, String oldTreeHash, String newTreeHash, String prefix) async {
    final oldTree = await repo.readTree(oldTreeHash);
    final newTree = await repo.readTree(newTreeHash);
    final files = <FileChange>[];

    final oldMap = {for (final e in oldTree.entries) e.name: e};
    final newMap = {for (final e in newTree.entries) e.name: e};

    // 检查新增和修改
    for (final entry in newTree.entries) {
      final path = prefix.isEmpty ? entry.name : '$prefix/${entry.name}';
      if (entry.isDirectory) {
        final oldEntry = oldMap[entry.name];
        if (oldEntry != null && oldEntry.isDirectory) {
          files.addAll(await _diffTrees(repo, oldEntry.hash, entry.hash, path));
        } else {
          files.addAll(await _listTreeFiles(repo, entry.hash, path));
        }
      } else {
        final oldEntry = oldMap[entry.name];
        if (oldEntry == null) {
          files.add(FileChange(path: path, status: ChangeStatus.added));
        } else if (oldEntry.hash != entry.hash) {
          files.add(FileChange(path: path, status: ChangeStatus.modified));
        }
      }
    }

    // 检查删除
    for (final entry in oldTree.entries) {
      if (!newMap.containsKey(entry.name)) {
        final path = prefix.isEmpty ? entry.name : '$prefix/${entry.name}';
        if (entry.isDirectory) {
          files.addAll(await _listDeletedFiles(repo, entry.hash, path));
        } else {
          files.add(FileChange(path: path, status: ChangeStatus.deleted));
        }
      }
    }

    return files;
  }

  /// 列出被删除的文件
  Future<List<FileChange>> _listDeletedFiles(GitRepository repo, String treeHash, String prefix) async {
    final tree = await repo.readTree(treeHash);
    final files = <FileChange>[];

    for (final entry in tree.entries) {
      final path = '$prefix/${entry.name}';
      if (entry.isDirectory) {
        files.addAll(await _listDeletedFiles(repo, entry.hash, path));
      } else {
        files.add(FileChange(path: path, status: ChangeStatus.deleted));
      }
    }
    return files;
  }

  @override
  Future<void> stage(String repoPath, List<String> files) async {
    final repo = await GitRepository.open(repoPath);
    await AddOperation(repo).add(files);
  }

  @override
  Future<void> unstage(String repoPath, List<String> files) async {
    final repo = await GitRepository.open(repoPath);
    final addOp = AddOperation(repo);
    for (final file in files) {
      await addOp.remove(file);
    }
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
  Future<void> pull(String repoPath, {String? token}) async {
    final repo = await GitRepository.open(repoPath);
    final creds = token != null ? HttpsCredentials.token(token) : null;
    await PullOperation(repo).pull('origin', credentials: creds);
  }

  @override
  Future<void> push(String repoPath, {String? token}) async {
    final repo = await GitRepository.open(repoPath);
    final creds = token != null ? HttpsCredentials.token(token) : null;
    await PushOperation(repo).push('origin', credentials: creds);
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

  @override
  Future<void> discardAllChanges(String repoPath) async {
    final repo = await GitRepository.open(repoPath);
    final status = await StatusOperation(repo).status();
    final checkout = CheckoutOperation(repo);

    // 恢复已跟踪文件（staged + unstaged）
    for (final e in status.staged) {
      await checkout.restoreFile(e.path);
    }
    for (final e in status.unstaged) {
      await checkout.restoreFile(e.path);
    }

    // 删除未跟踪文件
    for (final e in status.untracked) {
      final file = File('${repo.workDir}/${e.path}');
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}