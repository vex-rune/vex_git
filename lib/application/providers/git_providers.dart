import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/git_service.dart';
import '../../infrastructure/git/git_on_dart_impl.dart';

final gitServiceProvider = Provider<GitService>((ref) {
  return GitOnDartImpl();
});

final repositoriesProvider = StateNotifierProvider<ReposNotifier, AsyncValue<List<Repository>>>((ref) {
  return ReposNotifier(ref.read(gitServiceProvider));
});

class ReposNotifier extends StateNotifier<AsyncValue<List<Repository>>> {
  final GitService _git;
  ReposNotifier(this._git) : super(const AsyncValue.data([]));

  Future<void> loadRepos() async {
    // 从本地存储加载仓库列表
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
}

final currentRepoProvider = StateProvider<Repository?>((ref) => null);

final branchesProvider = FutureProvider.family<List<GitBranch>, String>((ref, repoPath) async {
  final git = ref.read(gitServiceProvider);
  return git.getBranches(repoPath);
});

final statusProvider = FutureProvider.family<List<FileChange>, String>((ref, repoPath) async {
  final git = ref.read(gitServiceProvider);
  return git.getStatus(repoPath);
});

final logProvider = FutureProvider.family<List<GitCommit>, String>((ref, repoPath) async {
  final git = ref.read(gitServiceProvider);
  return git.getLog(repoPath);
});

final syncStatusProvider = StateProvider<SyncStatus>((ref) => SyncStatus.idle);