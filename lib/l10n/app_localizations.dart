import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Vex Git'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get navChanges;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get navBranches;

  /// No description provided for @navPullRequests.
  ///
  /// In en, this message translates to:
  /// **'Pull Requests'**
  String get navPullRequests;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to GitHub'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your GitHub account to clone, commit, and collaborate.'**
  String get authLoginSubtitle;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in with GitHub'**
  String get authLoginButton;

  /// No description provided for @authEnterprise.
  ///
  /// In en, this message translates to:
  /// **'Sign in to GitHub Enterprise'**
  String get authEnterprise;

  /// No description provided for @authDeviceCode.
  ///
  /// In en, this message translates to:
  /// **'Enter this code on GitHub'**
  String get authDeviceCode;

  /// No description provided for @authOpenBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open GitHub'**
  String get authOpenBrowser;

  /// No description provided for @authAwaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for authorization...'**
  String get authAwaiting;

  /// No description provided for @authSuccess.
  ///
  /// In en, this message translates to:
  /// **'Signed in successfully'**
  String get authSuccess;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed'**
  String get authFailed;

  /// No description provided for @authLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authLogout;

  /// No description provided for @repoListTitle.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get repoListTitle;

  /// No description provided for @repoAdd.
  ///
  /// In en, this message translates to:
  /// **'Add repository'**
  String get repoAdd;

  /// No description provided for @repoClone.
  ///
  /// In en, this message translates to:
  /// **'Clone repository'**
  String get repoClone;

  /// No description provided for @repoCreate.
  ///
  /// In en, this message translates to:
  /// **'Create local repository'**
  String get repoCreate;

  /// No description provided for @repoAddExisting.
  ///
  /// In en, this message translates to:
  /// **'Add local repository'**
  String get repoAddExisting;

  /// No description provided for @repoCloneUrl.
  ///
  /// In en, this message translates to:
  /// **'Repository URL'**
  String get repoCloneUrl;

  /// No description provided for @repoClonePath.
  ///
  /// In en, this message translates to:
  /// **'Local path'**
  String get repoClonePath;

  /// No description provided for @repoCloneStart.
  ///
  /// In en, this message translates to:
  /// **'Clone'**
  String get repoCloneStart;

  /// No description provided for @repoCreateName.
  ///
  /// In en, this message translates to:
  /// **'Repository name'**
  String get repoCreateName;

  /// No description provided for @repoCreatePath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get repoCreatePath;

  /// No description provided for @repoCreateInit.
  ///
  /// In en, this message translates to:
  /// **'Initialize'**
  String get repoCreateInit;

  /// No description provided for @repoNoRepos.
  ///
  /// In en, this message translates to:
  /// **'No repositories yet'**
  String get repoNoRepos;

  /// No description provided for @repoNoReposHint.
  ///
  /// In en, this message translates to:
  /// **'Clone a repository or add a local one to get started.'**
  String get repoNoReposHint;

  /// No description provided for @repoAhead.
  ///
  /// In en, this message translates to:
  /// **'{count} ahead'**
  String repoAhead(int count);

  /// No description provided for @repoBehind.
  ///
  /// In en, this message translates to:
  /// **'{count} behind'**
  String repoBehind(int count);

  /// No description provided for @repoChanges.
  ///
  /// In en, this message translates to:
  /// **'{count} changes'**
  String repoChanges(int count);

  /// No description provided for @repoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from list'**
  String get repoRemove;

  /// No description provided for @repoRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get repoRename;

  /// No description provided for @repoSetPath.
  ///
  /// In en, this message translates to:
  /// **'Change local path'**
  String get repoSetPath;

  /// No description provided for @repoOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get repoOpen;

  /// No description provided for @branchCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current branch'**
  String get branchCurrent;

  /// No description provided for @branchCreate.
  ///
  /// In en, this message translates to:
  /// **'New branch'**
  String get branchCreate;

  /// No description provided for @branchDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get branchDelete;

  /// No description provided for @branchCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get branchCheckout;

  /// No description provided for @branchMergeInto.
  ///
  /// In en, this message translates to:
  /// **'Merge into current'**
  String get branchMergeInto;

  /// No description provided for @branchName.
  ///
  /// In en, this message translates to:
  /// **'Branch name'**
  String get branchName;

  /// No description provided for @branchFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get branchFrom;

  /// No description provided for @branchLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get branchLocal;

  /// No description provided for @branchRemote.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get branchRemote;

  /// No description provided for @branchNoBranches.
  ///
  /// In en, this message translates to:
  /// **'No branches'**
  String get branchNoBranches;

  /// No description provided for @branchDefaultProtected.
  ///
  /// In en, this message translates to:
  /// **'Protected default branch'**
  String get branchDefaultProtected;

  /// No description provided for @changesTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get changesTitle;

  /// No description provided for @changesStage.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get changesStage;

  /// No description provided for @changesUnstage.
  ///
  /// In en, this message translates to:
  /// **'Unstage'**
  String get changesUnstage;

  /// No description provided for @changesDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get changesDiscard;

  /// No description provided for @changesSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get changesSelectAll;

  /// No description provided for @changesDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get changesDeselectAll;

  /// No description provided for @changesCommit.
  ///
  /// In en, this message translates to:
  /// **'Commit'**
  String get changesCommit;

  /// No description provided for @changesCommitMessage.
  ///
  /// In en, this message translates to:
  /// **'Commit message'**
  String get changesCommitMessage;

  /// No description provided for @changesCommitDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get changesCommitDescription;

  /// No description provided for @changesCommitAmend.
  ///
  /// In en, this message translates to:
  /// **'Amend last commit'**
  String get changesCommitAmend;

  /// No description provided for @changesCommitCoAuthor.
  ///
  /// In en, this message translates to:
  /// **'Co-authored-by'**
  String get changesCommitCoAuthor;

  /// No description provided for @changesStash.
  ///
  /// In en, this message translates to:
  /// **'Stash'**
  String get changesStash;

  /// No description provided for @changesStashPop.
  ///
  /// In en, this message translates to:
  /// **'Pop stash'**
  String get changesStashPop;

  /// No description provided for @changesStashApply.
  ///
  /// In en, this message translates to:
  /// **'Apply stash'**
  String get changesStashApply;

  /// No description provided for @changesStashDrop.
  ///
  /// In en, this message translates to:
  /// **'Drop stash'**
  String get changesStashDrop;

  /// No description provided for @changesNoChanges.
  ///
  /// In en, this message translates to:
  /// **'No changes'**
  String get changesNoChanges;

  /// No description provided for @changesWorking.
  ///
  /// In en, this message translates to:
  /// **'Working directory'**
  String get changesWorking;

  /// No description provided for @changesStaged.
  ///
  /// In en, this message translates to:
  /// **'Staged'**
  String get changesStaged;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historySearch.
  ///
  /// In en, this message translates to:
  /// **'Search commits'**
  String get historySearch;

  /// No description provided for @historyNoCommits.
  ///
  /// In en, this message translates to:
  /// **'No commits yet'**
  String get historyNoCommits;

  /// No description provided for @historyAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get historyAuthor;

  /// No description provided for @historyDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get historyDate;

  /// No description provided for @historyMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get historyMessage;

  /// No description provided for @historyFiles.
  ///
  /// In en, this message translates to:
  /// **'Changed files'**
  String get historyFiles;

  /// No description provided for @historyFileHistory.
  ///
  /// In en, this message translates to:
  /// **'File history'**
  String get historyFileHistory;

  /// No description provided for @historyBlame.
  ///
  /// In en, this message translates to:
  /// **'Blame'**
  String get historyBlame;

  /// No description provided for @syncFetch.
  ///
  /// In en, this message translates to:
  /// **'Fetch'**
  String get syncFetch;

  /// No description provided for @syncPull.
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get syncPull;

  /// No description provided for @syncPush.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get syncPush;

  /// No description provided for @syncForcePush.
  ///
  /// In en, this message translates to:
  /// **'Force push'**
  String get syncForcePush;

  /// No description provided for @syncInProgress.
  ///
  /// In en, this message translates to:
  /// **'{operation} in progress...'**
  String syncInProgress(String operation);

  /// No description provided for @syncSuccess.
  ///
  /// In en, this message translates to:
  /// **'{operation} successful'**
  String syncSuccess(String operation);

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'{operation} failed'**
  String syncFailed(String operation);

  /// No description provided for @syncUncommittedWarn.
  ///
  /// In en, this message translates to:
  /// **'You have uncommitted changes'**
  String get syncUncommittedWarn;

  /// No description provided for @syncUncommittedStash.
  ///
  /// In en, this message translates to:
  /// **'Stash and continue'**
  String get syncUncommittedStash;

  /// No description provided for @syncUncommittedCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get syncUncommittedCancel;

  /// No description provided for @syncUncommittedDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get syncUncommittedDiscard;

  /// No description provided for @syncForcePushWarn.
  ///
  /// In en, this message translates to:
  /// **'Force push will overwrite remote history'**
  String get syncForcePushWarn;

  /// No description provided for @syncForcePushConfirm.
  ///
  /// In en, this message translates to:
  /// **'Force push'**
  String get syncForcePushConfirm;

  /// No description provided for @syncConflicts.
  ///
  /// In en, this message translates to:
  /// **'Conflicts detected'**
  String get syncConflicts;

  /// No description provided for @syncConflictsResolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve conflicts'**
  String get syncConflictsResolve;

  /// No description provided for @conflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Resolve conflicts'**
  String get conflictTitle;

  /// No description provided for @conflictLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get conflictLocal;

  /// No description provided for @conflictRemote.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get conflictRemote;

  /// No description provided for @conflictBase.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get conflictBase;

  /// No description provided for @conflictKeepLocal.
  ///
  /// In en, this message translates to:
  /// **'Keep local'**
  String get conflictKeepLocal;

  /// No description provided for @conflictKeepRemote.
  ///
  /// In en, this message translates to:
  /// **'Keep remote'**
  String get conflictKeepRemote;

  /// No description provided for @conflictKeepBoth.
  ///
  /// In en, this message translates to:
  /// **'Keep both'**
  String get conflictKeepBoth;

  /// No description provided for @conflictManual.
  ///
  /// In en, this message translates to:
  /// **'Edit manually'**
  String get conflictManual;

  /// No description provided for @conflictStageResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark as resolved'**
  String get conflictStageResolved;

  /// No description provided for @prTitle.
  ///
  /// In en, this message translates to:
  /// **'Pull Requests'**
  String get prTitle;

  /// No description provided for @prOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get prOpen;

  /// No description provided for @prClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get prClosed;

  /// No description provided for @prMerged.
  ///
  /// In en, this message translates to:
  /// **'Merged'**
  String get prMerged;

  /// No description provided for @prNoPRs.
  ///
  /// In en, this message translates to:
  /// **'No pull requests'**
  String get prNoPRs;

  /// No description provided for @prCreate.
  ///
  /// In en, this message translates to:
  /// **'Create pull request'**
  String get prCreate;

  /// No description provided for @prMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get prMerge;

  /// No description provided for @prSquash.
  ///
  /// In en, this message translates to:
  /// **'Squash and merge'**
  String get prSquash;

  /// No description provided for @prRebase.
  ///
  /// In en, this message translates to:
  /// **'Rebase and merge'**
  String get prRebase;

  /// No description provided for @prClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get prClose;

  /// No description provided for @prReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get prReview;

  /// No description provided for @prChecks.
  ///
  /// In en, this message translates to:
  /// **'Checks'**
  String get prChecks;

  /// No description provided for @prFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get prFiles;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsGit.
  ///
  /// In en, this message translates to:
  /// **'Git'**
  String get settingsGit;

  /// No description provided for @settingsDefaultBranchPrefix.
  ///
  /// In en, this message translates to:
  /// **'Default branch prefix'**
  String get settingsDefaultBranchPrefix;

  /// No description provided for @settingsCommitSigning.
  ///
  /// In en, this message translates to:
  /// **'Commit signing'**
  String get settingsCommitSigning;

  /// No description provided for @settingsSigningOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsSigningOff;

  /// No description provided for @settingsSigningGpg.
  ///
  /// In en, this message translates to:
  /// **'GPG'**
  String get settingsSigningGpg;

  /// No description provided for @settingsSigningSsh.
  ///
  /// In en, this message translates to:
  /// **'SSH'**
  String get settingsSigningSsh;

  /// No description provided for @settingsSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get settingsSync;

  /// No description provided for @settingsAutoFetch.
  ///
  /// In en, this message translates to:
  /// **'Auto-fetch before commit'**
  String get settingsAutoFetch;

  /// No description provided for @settingsShowAvatars.
  ///
  /// In en, this message translates to:
  /// **'Show avatars'**
  String get settingsShowAvatars;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get settingsNotificationsEnabled;

  /// No description provided for @settingsStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get settingsStorage;

  /// No description provided for @settingsStoragePath.
  ///
  /// In en, this message translates to:
  /// **'Repository storage path'**
  String get settingsStoragePath;

  /// No description provided for @settingsStoragePathHint.
  ///
  /// In en, this message translates to:
  /// **'Where new clones are stored'**
  String get settingsStoragePathHint;

  /// No description provided for @settingsAutoScanInterval.
  ///
  /// In en, this message translates to:
  /// **'Auto scan interval'**
  String get settingsAutoScanInterval;

  /// No description provided for @settingsAutoScan10.
  ///
  /// In en, this message translates to:
  /// **'10 minutes'**
  String get settingsAutoScan10;

  /// No description provided for @settingsAutoScan20.
  ///
  /// In en, this message translates to:
  /// **'20 minutes'**
  String get settingsAutoScan20;

  /// No description provided for @settingsAutoScanCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get settingsAutoScanCustom;

  /// No description provided for @settingsClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get settingsClearCache;

  /// No description provided for @settingsResetConfig.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get settingsResetConfig;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsExportLogs.
  ///
  /// In en, this message translates to:
  /// **'Export diagnostic logs'**
  String get settingsExportLogs;

  /// No description provided for @credentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get credentialsTitle;

  /// No description provided for @credentialsHttps.
  ///
  /// In en, this message translates to:
  /// **'HTTPS'**
  String get credentialsHttps;

  /// No description provided for @credentialsUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get credentialsUsername;

  /// No description provided for @credentialsToken.
  ///
  /// In en, this message translates to:
  /// **'Personal access token'**
  String get credentialsToken;

  /// No description provided for @credentialsSsh.
  ///
  /// In en, this message translates to:
  /// **'SSH'**
  String get credentialsSsh;

  /// No description provided for @credentialsSshKey.
  ///
  /// In en, this message translates to:
  /// **'SSH key'**
  String get credentialsSshKey;

  /// No description provided for @credentialsSshGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate new key'**
  String get credentialsSshGenerate;

  /// No description provided for @credentialsSshImport.
  ///
  /// In en, this message translates to:
  /// **'Import private key'**
  String get credentialsSshImport;

  /// No description provided for @credentialsSshCopyPublic.
  ///
  /// In en, this message translates to:
  /// **'Copy public key'**
  String get credentialsSshCopyPublic;

  /// No description provided for @credentialsSshCopied.
  ///
  /// In en, this message translates to:
  /// **'Public key copied to clipboard'**
  String get credentialsSshCopied;

  /// No description provided for @credentialsAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get credentialsAddAccount;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get commonNetworkError;

  /// No description provided for @commonAuthError.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get commonAuthError;

  /// No description provided for @commonNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get commonNotFound;

  /// No description provided for @commonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get commonUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
