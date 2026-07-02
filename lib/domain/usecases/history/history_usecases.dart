import '../../../domain/entities/git_entities.dart';
import '../../../domain/repositories/git_client.dart';

class GetCommitLog {
  final GitClient git;
  GetCommitLog(this.git);
  Future<List<Commit>> call(String repoPath, {int? maxCount, String? branch, String? author, String? path}) {
    return git.log(repoPath, maxCount: maxCount, branch: branch, authorFilter: author, pathFilter: path);
  }
}

class GetCommitDetail {
  final GitClient git;
  GetCommitDetail(this.git);
  Future<Commit?> call(String repoPath, String sha) => git.showCommit(repoPath, sha);
}