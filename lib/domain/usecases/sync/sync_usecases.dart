import '../../../domain/entities/git_entities.dart';
import '../../../domain/repositories/git_client.dart';

class FetchRemote {
  final GitClient git;
  FetchRemote(this.git);
  Stream<ProgressEvent> call(String repoPath, {String? remote, String? token}) {
    return git.fetch(repoPath, remote: remote, token: token);
  }
}

class PullChanges {
  final GitClient git;
  PullChanges(this.git);
  Stream<ProgressEvent> call(String repoPath, {PullMode mode = PullMode.merge, String? remote, String? branch, String? token}) {
    return git.pull(repoPath, PullOptions(mode: mode, remote: remote, branch: branch, token: token));
  }
}

class PushChanges {
  final GitClient git;
  PushChanges(this.git);
  Stream<ProgressEvent> call(String repoPath, {String? remote, String? branch, bool force = false, bool setUpstream = false, String? token}) {
    return git.push(repoPath, PushOptions(remote: remote, branch: branch, force: force, setUpstream: setUpstream, token: token));
  }
}