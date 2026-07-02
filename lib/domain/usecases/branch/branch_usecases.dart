import '../../../domain/entities/git_entities.dart';
import '../../../domain/repositories/git_client.dart';

class ListBranches {
  final GitClient git;
  ListBranches(this.git);
  Future<List<Branch>> call(String repoPath) => git.listBranches(repoPath);
}

class CheckoutBranch {
  final GitClient git;
  CheckoutBranch(this.git);
  Future<void> call(String repoPath, String target) => git.checkout(repoPath, target);
}

class CreateBranch {
  final GitClient git;
  CreateBranch(this.git);
  Future<void> call(String repoPath, String name, {String? from}) {
    return git.createBranch(repoPath, name, from: from).then((_) {});
  }
}

class DeleteBranch {
  final GitClient git;
  DeleteBranch(this.git);
  Future<void> call(String repoPath, String name, {bool force = false, bool remote = false}) {
    return git.deleteBranch(repoPath, name, force: force, remote: remote);
  }
}