// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vex Git';

  @override
  String get navHome => 'Home';

  @override
  String get navChanges => 'Changes';

  @override
  String get navHistory => 'History';

  @override
  String get navBranches => 'Branches';

  @override
  String get navPullRequests => 'Pull Requests';

  @override
  String get navSettings => 'Settings';

  @override
  String get authLoginTitle => 'Sign in to GitHub';

  @override
  String get authLoginSubtitle =>
      'Connect your GitHub account to clone, commit, and collaborate.';

  @override
  String get authLoginButton => 'Sign in with GitHub';

  @override
  String get authEnterprise => 'Sign in to GitHub Enterprise';

  @override
  String get authDeviceCode => 'Enter this code on GitHub';

  @override
  String get authOpenBrowser => 'Open GitHub';

  @override
  String get authAwaiting => 'Waiting for authorization...';

  @override
  String get authSuccess => 'Signed in successfully';

  @override
  String get authFailed => 'Sign in failed';

  @override
  String get authLogout => 'Sign out';

  @override
  String get repoListTitle => 'Repositories';

  @override
  String get repoAdd => 'Add repository';

  @override
  String get repoClone => 'Clone repository';

  @override
  String get repoCreate => 'Create local repository';

  @override
  String get repoAddExisting => 'Add local repository';

  @override
  String get repoCloneUrl => 'Repository URL';

  @override
  String get repoClonePath => 'Local path';

  @override
  String get repoCloneStart => 'Clone';

  @override
  String get repoCreateName => 'Repository name';

  @override
  String get repoCreatePath => 'Path';

  @override
  String get repoCreateInit => 'Initialize';

  @override
  String get repoNoRepos => 'No repositories yet';

  @override
  String get repoNoReposHint =>
      'Clone a repository or add a local one to get started.';

  @override
  String repoAhead(int count) {
    return '$count ahead';
  }

  @override
  String repoBehind(int count) {
    return '$count behind';
  }

  @override
  String repoChanges(int count) {
    return '$count changes';
  }

  @override
  String get repoRemove => 'Remove from list';

  @override
  String get repoRename => 'Rename';

  @override
  String get repoSetPath => 'Change local path';

  @override
  String get repoOpen => 'Open';

  @override
  String get branchCurrent => 'Current branch';

  @override
  String get branchCreate => 'New branch';

  @override
  String get branchDelete => 'Delete';

  @override
  String get branchCheckout => 'Checkout';

  @override
  String get branchMergeInto => 'Merge into current';

  @override
  String get branchName => 'Branch name';

  @override
  String get branchFrom => 'From';

  @override
  String get branchLocal => 'Local';

  @override
  String get branchRemote => 'Remote';

  @override
  String get branchNoBranches => 'No branches';

  @override
  String get branchDefaultProtected => 'Protected default branch';

  @override
  String get changesTitle => 'Changes';

  @override
  String get changesStage => 'Stage';

  @override
  String get changesUnstage => 'Unstage';

  @override
  String get changesDiscard => 'Discard';

  @override
  String get changesSelectAll => 'Select all';

  @override
  String get changesDeselectAll => 'Deselect all';

  @override
  String get changesCommit => 'Commit';

  @override
  String get changesCommitMessage => 'Commit message';

  @override
  String get changesCommitDescription => 'Description (optional)';

  @override
  String get changesCommitAmend => 'Amend last commit';

  @override
  String get changesCommitCoAuthor => 'Co-authored-by';

  @override
  String get changesStash => 'Stash';

  @override
  String get changesStashPop => 'Pop stash';

  @override
  String get changesStashApply => 'Apply stash';

  @override
  String get changesStashDrop => 'Drop stash';

  @override
  String get changesNoChanges => 'No changes';

  @override
  String get changesWorking => 'Working directory';

  @override
  String get changesStaged => 'Staged';

  @override
  String get historyTitle => 'History';

  @override
  String get historySearch => 'Search commits';

  @override
  String get historyNoCommits => 'No commits yet';

  @override
  String get historyAuthor => 'Author';

  @override
  String get historyDate => 'Date';

  @override
  String get historyMessage => 'Message';

  @override
  String get historyFiles => 'Changed files';

  @override
  String get historyFileHistory => 'File history';

  @override
  String get historyBlame => 'Blame';

  @override
  String get syncFetch => 'Fetch';

  @override
  String get syncPull => 'Pull';

  @override
  String get syncPush => 'Push';

  @override
  String get syncForcePush => 'Force push';

  @override
  String syncInProgress(String operation) {
    return '$operation in progress...';
  }

  @override
  String syncSuccess(String operation) {
    return '$operation successful';
  }

  @override
  String syncFailed(String operation) {
    return '$operation failed';
  }

  @override
  String get syncUncommittedWarn => 'You have uncommitted changes';

  @override
  String get syncUncommittedStash => 'Stash and continue';

  @override
  String get syncUncommittedCancel => 'Cancel';

  @override
  String get syncUncommittedDiscard => 'Discard changes';

  @override
  String get syncForcePushWarn => 'Force push will overwrite remote history';

  @override
  String get syncForcePushConfirm => 'Force push';

  @override
  String get syncConflicts => 'Conflicts detected';

  @override
  String get syncConflictsResolve => 'Resolve conflicts';

  @override
  String get conflictTitle => 'Resolve conflicts';

  @override
  String get conflictLocal => 'Local';

  @override
  String get conflictRemote => 'Remote';

  @override
  String get conflictBase => 'Base';

  @override
  String get conflictKeepLocal => 'Keep local';

  @override
  String get conflictKeepRemote => 'Keep remote';

  @override
  String get conflictKeepBoth => 'Keep both';

  @override
  String get conflictManual => 'Edit manually';

  @override
  String get conflictStageResolved => 'Mark as resolved';

  @override
  String get prTitle => 'Pull Requests';

  @override
  String get prOpen => 'Open';

  @override
  String get prClosed => 'Closed';

  @override
  String get prMerged => 'Merged';

  @override
  String get prNoPRs => 'No pull requests';

  @override
  String get prCreate => 'Create pull request';

  @override
  String get prMerge => 'Merge';

  @override
  String get prSquash => 'Squash and merge';

  @override
  String get prRebase => 'Rebase and merge';

  @override
  String get prClose => 'Close';

  @override
  String get prReview => 'Review';

  @override
  String get prChecks => 'Checks';

  @override
  String get prFiles => 'Files';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsGit => 'Git';

  @override
  String get settingsDefaultBranchPrefix => 'Default branch prefix';

  @override
  String get settingsCommitSigning => 'Commit signing';

  @override
  String get settingsSigningOff => 'Off';

  @override
  String get settingsSigningGpg => 'GPG';

  @override
  String get settingsSigningSsh => 'SSH';

  @override
  String get settingsSync => 'Sync';

  @override
  String get settingsAutoFetch => 'Auto-fetch before commit';

  @override
  String get settingsShowAvatars => 'Show avatars';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsEnabled => 'Enable notifications';

  @override
  String get settingsStorage => 'Storage';

  @override
  String get settingsStoragePath => 'Repository storage path';

  @override
  String get settingsStoragePathHint => 'Where new clones are stored';

  @override
  String get settingsAutoScanInterval => 'Auto scan interval';

  @override
  String get settingsAutoScan10 => '10 minutes';

  @override
  String get settingsAutoScan20 => '20 minutes';

  @override
  String get settingsAutoScanCustom => 'Custom';

  @override
  String get settingsClearCache => 'Clear cache';

  @override
  String get settingsResetConfig => 'Reset to defaults';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsExportLogs => 'Export diagnostic logs';

  @override
  String get credentialsTitle => 'Credentials';

  @override
  String get credentialsHttps => 'HTTPS';

  @override
  String get credentialsUsername => 'Username';

  @override
  String get credentialsToken => 'Personal access token';

  @override
  String get credentialsSsh => 'SSH';

  @override
  String get credentialsSshKey => 'SSH key';

  @override
  String get credentialsSshGenerate => 'Generate new key';

  @override
  String get credentialsSshImport => 'Import private key';

  @override
  String get credentialsSshCopyPublic => 'Copy public key';

  @override
  String get credentialsSshCopied => 'Public key copied to clipboard';

  @override
  String get credentialsAddAccount => 'Add account';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Error';

  @override
  String get commonNetworkError => 'Network error';

  @override
  String get commonAuthError => 'Authentication failed';

  @override
  String get commonNotFound => 'Not found';

  @override
  String get commonUnknown => 'Unknown error';
}
