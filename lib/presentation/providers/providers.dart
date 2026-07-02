import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/app_config_repository.dart';
import '../../domain/entities/app_config.dart';
import '../../domain/repositories/app_config_repository.dart' as domain;
import '../../domain/repositories/git_client.dart';
import '../../domain/usecases/auth/auth_usecases.dart';
import '../../domain/usecases/branch/branch_usecases.dart';
import '../../domain/usecases/collaboration/collaboration_usecases.dart';
import '../../domain/usecases/commit/commit_usecases.dart';
import '../../domain/usecases/history/history_usecases.dart';
import '../../domain/usecases/repository/repository_usecases.dart';
import '../../domain/usecases/settings/settings_usecases.dart';
import '../../domain/usecases/sync/sync_usecases.dart';
import '../../infrastructure/git/process_git_client.dart';
import '../../infrastructure/github/github_api_client.dart';
import '../../infrastructure/storage/secure_store.dart';

// ---- Infrastructure ----

final secureStoreProvider = Provider<SecureStore>((ref) => SecureStore());

final processGitClientProvider = Provider<ProcessGitClient>((ref) {
  return ProcessGitClient();
});

final gitClientProvider = Provider<GitClient>((ref) {
  return ProcessGitClient();
});

final githubApiProvider = Provider<GitHubApiClient>((ref) {
  final api = GitHubApiClient();
  // 启动时从 active account 注入 token
  ref.listen<AsyncValue<AppConfig>>(configStreamProvider, (_, next) {
    final cfg = next.value;
    if (cfg == null) {
      api.token = null;
      return;
    }
    final activeId = cfg.activeAccountId;
    if (activeId == null) {
      api.token = null;
      return;
    }
    final account = cfg.accounts.firstWhere(
      (a) => a.id == activeId,
      orElse: () => const AccountConfig(id: '', host: '', login: ''),
    );
    if (account.id.isEmpty) {
      api.token = null;
      return;
    }
    // 注：SecureStore 是异步的，这里仅在 token 已就绪的情况下设置
    ref.read(secureStoreProvider).readAccountToken(account.id).then((t) {
      api.token = t;
    });
  });
  return api;
});

// ---- Data ----

final appConfigRepoProvider = Provider<domain.AppConfigRepository>((ref) {
  return AppConfigRepositoryImpl();
});

// ---- Config stream ----

final configStreamProvider = StreamProvider<AppConfig>((ref) {
  return ref.read(appConfigRepoProvider).watch();
});

// ---- UseCases ----

final startDeviceLoginProvider = Provider<StartDeviceLogin>(
    (ref) => StartDeviceLogin(ref.read(githubApiProvider)));

final completeDeviceLoginProvider = Provider<CompleteDeviceLogin>((ref) {
  return CompleteDeviceLogin(
    ref.read(githubApiProvider),
    ref.read(secureStoreProvider),
    ref.read(appConfigRepoProvider),
  );
});

final logoutUseCaseProvider =
    Provider<Logout>((ref) => Logout(ref.read(secureStoreProvider), ref.read(appConfigRepoProvider)));

// Repository
final listReposProvider = Provider<ListRepositories>((ref) => ListRepositories(ref.read(appConfigRepoProvider)));
final addLocalRepoProvider = Provider<AddLocalRepository>(
    (ref) => AddLocalRepository(ref.read(appConfigRepoProvider), ref.read(processGitClientProvider)));
final createLocalRepoProvider = Provider<CreateLocalRepository>(
    (ref) => CreateLocalRepository(ref.read(appConfigRepoProvider), ref.read(processGitClientProvider)));
final cloneRepoProvider = Provider<CloneRepository>((ref) => CloneRepository(
      ref.read(appConfigRepoProvider),
      ref.read(gitClientProvider),
      ref.read(githubApiProvider),
    ));
final removeRepoProvider = Provider<RemoveRepository>((ref) => RemoveRepository(ref.read(appConfigRepoProvider)));
final renameRepoProvider = Provider<RenameRepository>((ref) => RenameRepository(ref.read(appConfigRepoProvider)));
final updateRepoPathProvider = Provider<UpdateRepoPath>((ref) => UpdateRepoPath(ref.read(appConfigRepoProvider)));

// Commit
final getRepoStatusProvider = Provider<GetRepoStatus>((ref) => GetRepoStatus(ref.read(gitClientProvider)));
final watchRepoStatusProvider = Provider<WatchRepoStatus>((ref) => WatchRepoStatus(ref.read(gitClientProvider)));
final stageFilesProvider = Provider<StageFiles>((ref) => StageFiles(ref.read(gitClientProvider)));
final unstageFilesProvider = Provider<UnstageFiles>((ref) => UnstageFiles(ref.read(gitClientProvider)));
final stageAllProvider = Provider<StageAll>((ref) => StageAll(ref.read(gitClientProvider)));
final unstageAllProvider = Provider<UnstageAll>((ref) => UnstageAll(ref.read(gitClientProvider)));
final discardFilesProvider = Provider<DiscardFiles>((ref) => DiscardFiles(ref.read(gitClientProvider)));
final getDiffProvider = Provider<GetDiff>((ref) => GetDiff(ref.read(gitClientProvider)));
final createCommitProvider = Provider<CreateCommit>((ref) => CreateCommit(ref.read(gitClientProvider)));
final stashChangesProvider = Provider<StashChanges>((ref) => StashChanges(ref.read(gitClientProvider)));
final stashPopProvider = Provider<StashPop>((ref) => StashPop(ref.read(gitClientProvider)));
final stashApplyProvider = Provider<StashApply>((ref) => StashApply(ref.read(gitClientProvider)));
final stashDropProvider = Provider<StashDrop>((ref) => StashDrop(ref.read(gitClientProvider)));
final listStashesProvider = Provider<ListStashes>((ref) => ListStashes(ref.read(gitClientProvider)));

// Branch
final listBranchesProvider = Provider<ListBranches>((ref) => ListBranches(ref.read(gitClientProvider)));
final checkoutBranchProvider = Provider<CheckoutBranch>((ref) => CheckoutBranch(ref.read(gitClientProvider)));
final createBranchProvider = Provider<CreateBranch>((ref) => CreateBranch(ref.read(gitClientProvider)));
final deleteBranchProvider = Provider<DeleteBranch>((ref) => DeleteBranch(ref.read(gitClientProvider)));

// Sync
final fetchProvider = Provider<FetchRemote>((ref) => FetchRemote(ref.read(gitClientProvider)));
final pullProvider = Provider<PullChanges>((ref) => PullChanges(ref.read(gitClientProvider)));
final pushProvider = Provider<PushChanges>((ref) => PushChanges(ref.read(gitClientProvider)));

// History
final getCommitLogProvider = Provider<GetCommitLog>((ref) => GetCommitLog(ref.read(gitClientProvider)));
final getCommitDetailProvider = Provider<GetCommitDetail>((ref) => GetCommitDetail(ref.read(gitClientProvider)));

// Collaboration
final listUserReposProvider = Provider<ListUserRepos>((ref) => ListUserRepos(ref.read(githubApiProvider)));
final listPrsProvider = Provider<ListPullRequests>((ref) => ListPullRequests(ref.read(githubApiProvider)));
final getPrProvider = Provider<GetPullRequest>((ref) => GetPullRequest(ref.read(githubApiProvider)));
final createPrProvider = Provider<CreatePullRequest>((ref) => CreatePullRequest(ref.read(githubApiProvider)));
final mergePrProvider = Provider<MergePullRequest>((ref) => MergePullRequest(ref.read(githubApiProvider)));

// Settings
final getPreferencesProvider = Provider<GetPreferences>((ref) => GetPreferences(ref.read(appConfigRepoProvider)));
final updatePreferencesProvider =
    Provider<UpdatePreferences>((ref) => UpdatePreferences(ref.read(appConfigRepoProvider)));
final setActiveAccountProvider =
    Provider<SetActiveAccount>((ref) => SetActiveAccount(ref.read(appConfigRepoProvider)));
final resetPreferencesProvider =
    Provider<ResetPreferences>((ref) => ResetPreferences(ref.read(appConfigRepoProvider)));