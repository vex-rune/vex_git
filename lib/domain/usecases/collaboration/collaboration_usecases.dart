import '../../../infrastructure/github/github_api_client.dart';

class ListUserRepos {
  final GitHubApiClient api;
  ListUserRepos(this.api);
  Future<List<GitHubRepository>> call({int perPage = 30}) {
    return api.listUserRepositories(perPage: perPage);
  }
}

class ListPullRequests {
  final GitHubApiClient api;
  ListPullRequests(this.api);
  Future<List<PullRequestSummary>> call(String owner, String repo, {String state = 'open'}) {
    return api.listPullRequests(owner, repo, state: state);
  }
}

class GetPullRequest {
  final GitHubApiClient api;
  GetPullRequest(this.api);
  Future<PullRequestSummary> call(String owner, String repo, int number) {
    return api.getPullRequest(owner, repo, number);
  }
}

class CreatePullRequest {
  final GitHubApiClient api;
  CreatePullRequest(this.api);
  Future<PullRequestSummary> call({
    required String owner,
    required String repo,
    required String title,
    required String head,
    required String base,
    String? body,
    bool draft = false,
  }) {
    return api.createPullRequest(
      owner: owner,
      repo: repo,
      title: title,
      head: head,
      base: base,
      body: body,
      draft: draft,
    );
  }
}

class MergePullRequest {
  final GitHubApiClient api;
  MergePullRequest(this.api);
  Future<void> call(String owner, String repo, int number, {String method = 'merge', String? message}) {
    return api.mergePullRequest(owner, repo, number, method: method, commitMessage: message);
  }
}