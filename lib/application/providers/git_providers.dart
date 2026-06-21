import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/diff/diff_utils.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/git_service.dart';
import '../../infrastructure/git/git_on_dart_impl.dart';

const _reposKey = 'repositories';

final gitServiceProvider = Provider<GitService>((ref) {
  return GitOnDartImpl();
});

final repositoriesProvider =
    StateNotifierProvider<ReposNotifier, AsyncValue<List<Repository>>>((ref) {
  return ReposNotifier(ref.read(gitServiceProvider));
});

class ReposNotifier extends StateNotifier<AsyncValue<List<Repository>>> {
  final GitService _git;
  ReposNotifier(this._git) : super(const AsyncValue.data([]));

  Future<void> loadRepos() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_reposKey);
    if (json == null || json.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      final list = (jsonDecode(json) as List)
          .map((e) => Repository.fromJson(e as Map<String, dynamic>))
          .toList();
      state = AsyncValue.data(list);
    } catch (_) {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> _saveRepos() async {
    final prefs = await SharedPreferences.getInstance();
    final list = state.valueOrNull ?? [];
    await prefs.setString(_reposKey, jsonEncode(list.map((r) => r.toJson()).toList()));
  }

  Future<void> cloneRepo(String url, String localPath) async {
    state = const AsyncValue.loading();
    try {
      await _git.clone(
        url: url,
        localPath: localPath,
        onProgress: (p) {},
        onCancel: () {},
      );
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addRepo(Repository repo) {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([...current, repo]);
    _saveRepos();
  }

  void removeRepo(String repoId) {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current.where((r) => r.id != repoId).toList());
    _saveRepos();
  }

  void renameRepo(String repoId, String newName) {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([
      for (final r in current)
        if (r.id == repoId)
          Repository(
            id: r.id,
            name: newName,
            description: r.description,
            localPath: r.localPath,
            remoteUrl: r.remoteUrl,
            platform: r.platform,
            defaultBranch: r.defaultBranch,
            createdAt: r.createdAt,
          )
        else
          r,
    ]);
    _saveRepos();
  }
}

final currentRepoProvider = StateProvider<Repository?>((ref) => null);

final branchesProvider =
    FutureProvider.family<List<GitBranch>, String>((ref, repoPath) async {
  final git = ref.read(gitServiceProvider);
  return git.getBranches(repoPath);
});

final statusProvider =
    FutureProvider.family<List<FileChange>, String>((ref, repoPath) async {
  final git = ref.read(gitServiceProvider);
  return git.getStatus(repoPath);
});

final logProvider =
    FutureProvider.family<List<GitCommit>, String>((ref, repoPath) async {
  final git = ref.read(gitServiceProvider);
  return git.getLog(repoPath);
});

final syncStatusProvider = StateProvider<SyncStatus>((ref) => SyncStatus.idle);

final diffProvider =
    FutureProvider.family<List<DiffLine>, ({String repoPath, String filePath})>(
        (ref, params) async {
  final git = ref.read(gitServiceProvider);
  return git.getDiff(params.repoPath, params.filePath);
});
