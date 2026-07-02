import '../../../domain/entities/git_entities.dart';
import '../../../domain/repositories/git_client.dart';

class GetRepoStatus {
  final GitClient git;
  GetRepoStatus(this.git);
  Future<RepoStatus> call(String repoPath) => git.status(repoPath);
}

class WatchRepoStatus {
  final GitClient git;
  WatchRepoStatus(this.git);
  Stream<RepoStatus> call(String repoPath, {Duration interval = const Duration(seconds: 2)}) {
    return git.watch(repoPath, interval: interval);
  }
}

class StageFiles {
  final GitClient git;
  StageFiles(this.git);
  Future<void> call(String repoPath, List<String> paths) => git.stage(repoPath, paths);
}

class UnstageFiles {
  final GitClient git;
  UnstageFiles(this.git);
  Future<void> call(String repoPath, List<String> paths) => git.unstage(repoPath, paths);
}

class StageAll {
  final GitClient git;
  StageAll(this.git);
  Future<void> call(String repoPath) => git.stageAll(repoPath);
}

class UnstageAll {
  final GitClient git;
  UnstageAll(this.git);
  Future<void> call(String repoPath) => git.unstageAll(repoPath);
}

class DiscardFiles {
  final GitClient git;
  DiscardFiles(this.git);
  Future<void> call(String repoPath, List<String> paths) => git.discard(repoPath, paths);
}

class GetDiff {
  final GitClient git;
  GetDiff(this.git);
  Future<List<FileDiff>> call(String repoPath, {bool staged = false, String? pathFilter}) {
    return git.diff(repoPath, staged: staged, pathFilter: pathFilter);
  }
}

class CreateCommit {
  final GitClient git;
  CreateCommit(this.git);
  Future<Commit> call(String repoPath, CommitOptions options) => git.commit(repoPath, options);
}

class StashChanges {
  final GitClient git;
  StashChanges(this.git);
  Future<void> call(String repoPath, {String? message}) => git.stash(repoPath, message: message);
}

class StashPop {
  final GitClient git;
  StashPop(this.git);
  Future<void> call(String repoPath, {int? index}) => git.stashPop(repoPath, index: index);
}

class StashApply {
  final GitClient git;
  StashApply(this.git);
  Future<void> call(String repoPath, {int? index}) => git.stashApply(repoPath, index: index);
}

class StashDrop {
  final GitClient git;
  StashDrop(this.git);
  Future<void> call(String repoPath, {int? index}) => git.stashDrop(repoPath, index: index);
}

class ListStashes {
  final GitClient git;
  ListStashes(this.git);
  Future<List<StashEntry>> call(String repoPath) => git.stashList(repoPath);
}