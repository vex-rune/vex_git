import 'package:equatable/equatable.dart';

class AppConfig extends Equatable {
  final int version;
  final String? activeAccountId;
  final List<AccountConfig> accounts;
  final PreferencesConfig preferences;
  final List<RepoConfig> repositories;

  const AppConfig({
    this.version = 1,
    this.activeAccountId,
    this.accounts = const [],
    this.preferences = const PreferencesConfig(),
    this.repositories = const [],
  });

  AppConfig copyWith({
    int? version,
    String? activeAccountId,
    bool clearActiveAccount = false,
    List<AccountConfig>? accounts,
    PreferencesConfig? preferences,
    List<RepoConfig>? repositories,
  }) {
    return AppConfig(
      version: version ?? this.version,
      activeAccountId: clearActiveAccount ? null : (activeAccountId ?? this.activeAccountId),
      accounts: accounts ?? this.accounts,
      preferences: preferences ?? this.preferences,
      repositories: repositories ?? this.repositories,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'activeAccountId': activeAccountId,
        'accounts': accounts.map((a) => a.toJson()).toList(),
        'preferences': preferences.toJson(),
        'repositories': repositories.map((r) => r.toJson()).toList(),
      };

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      version: (json['version'] as int?) ?? 1,
      activeAccountId: json['activeAccountId'] as String?,
      accounts: ((json['accounts'] as List?) ?? const [])
          .map((e) => AccountConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      preferences: PreferencesConfig.fromJson(
        (json['preferences'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      repositories: ((json['repositories'] as List?) ?? const [])
          .map((e) => RepoConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [version, activeAccountId, accounts, preferences, repositories];
}

class AccountConfig extends Equatable {
  final String id;
  final String host; // github.com / gitee.com / enterprise url
  final String login;
  final String? displayName;
  final String? avatarUrl;
  final List<String> scopes;
  final AccountKind kind;

  const AccountConfig({
    required this.id,
    required this.host,
    required this.login,
    this.displayName,
    this.avatarUrl,
    this.scopes = const [],
    this.kind = AccountKind.githubCom,
  });

  AccountConfig copyWith({
    String? displayName,
    String? avatarUrl,
    List<String>? scopes,
  }) =>
      AccountConfig(
        id: id,
        host: host,
        login: login,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        scopes: scopes ?? this.scopes,
        kind: kind,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'host': host,
        'login': login,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'scopes': scopes,
        'kind': kind.name,
      };

  factory AccountConfig.fromJson(Map<String, dynamic> json) {
    return AccountConfig(
      id: json['id'] as String,
      host: json['host'] as String,
      login: json['login'] as String,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      scopes: ((json['scopes'] as List?) ?? const []).cast<String>(),
      kind: AccountKind.values.firstWhere(
        (k) => k.name == (json['kind'] as String? ?? 'githubCom'),
        orElse: () => AccountKind.githubCom,
      ),
    );
  }

  @override
  List<Object?> get props => [id, host, login, displayName, avatarUrl, scopes, kind];
}

enum AccountKind { githubCom, githubEnterprise, gitee, gitlab }

class PreferencesConfig extends Equatable {
  final AppThemeMode themeMode;
  final AppLanguage language;
  final String defaultBranchPrefix;
  final CommitSigning signingMode;
  final bool autoFetchBeforeCommit;
  final bool showAvatars;
  final bool notificationsEnabled;
  final String? customRepoStorePath; // 用户可改存储根，覆盖默认
  final int autoScanIntervalMinutes;
  final List<String> ignoredExtensions;

  const PreferencesConfig({
    this.themeMode = AppThemeMode.system,
    this.language = AppLanguage.system,
    this.defaultBranchPrefix = 'feature/',
    this.signingMode = CommitSigning.off,
    this.autoFetchBeforeCommit = false,
    this.showAvatars = true,
    this.notificationsEnabled = false,
    this.customRepoStorePath,
    this.autoScanIntervalMinutes = 10,
    this.ignoredExtensions = const [],
  });

  PreferencesConfig copyWith({
    AppThemeMode? themeMode,
    AppLanguage? language,
    String? defaultBranchPrefix,
    CommitSigning? signingMode,
    bool? autoFetchBeforeCommit,
    bool? showAvatars,
    bool? notificationsEnabled,
    String? customRepoStorePath,
    bool clearCustomRepoStorePath = false,
    int? autoScanIntervalMinutes,
    List<String>? ignoredExtensions,
  }) =>
      PreferencesConfig(
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
        defaultBranchPrefix: defaultBranchPrefix ?? this.defaultBranchPrefix,
        signingMode: signingMode ?? this.signingMode,
        autoFetchBeforeCommit: autoFetchBeforeCommit ?? this.autoFetchBeforeCommit,
        showAvatars: showAvatars ?? this.showAvatars,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        customRepoStorePath:
            clearCustomRepoStorePath ? null : (customRepoStorePath ?? this.customRepoStorePath),
        autoScanIntervalMinutes: autoScanIntervalMinutes ?? this.autoScanIntervalMinutes,
        ignoredExtensions: ignoredExtensions ?? this.ignoredExtensions,
      );

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'language': language.name,
        'defaultBranchPrefix': defaultBranchPrefix,
        'signingMode': signingMode.name,
        'autoFetchBeforeCommit': autoFetchBeforeCommit,
        'showAvatars': showAvatars,
        'notificationsEnabled': notificationsEnabled,
        'customRepoStorePath': customRepoStorePath,
        'autoScanIntervalMinutes': autoScanIntervalMinutes,
        'ignoredExtensions': ignoredExtensions,
      };

  factory PreferencesConfig.fromJson(Map<String, dynamic> json) => PreferencesConfig(
        themeMode: AppThemeMode.values.firstWhere(
          (e) => e.name == json['themeMode'],
          orElse: () => AppThemeMode.system,
        ),
        language: AppLanguage.values.firstWhere(
          (e) => e.name == json['language'],
          orElse: () => AppLanguage.system,
        ),
        defaultBranchPrefix: json['defaultBranchPrefix'] as String? ?? 'feature/',
        signingMode: CommitSigning.values.firstWhere(
          (e) => e.name == json['signingMode'],
          orElse: () => CommitSigning.off,
        ),
        autoFetchBeforeCommit: json['autoFetchBeforeCommit'] as bool? ?? false,
        showAvatars: json['showAvatars'] as bool? ?? true,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
        customRepoStorePath: json['customRepoStorePath'] as String?,
        autoScanIntervalMinutes: json['autoScanIntervalMinutes'] as int? ?? 10,
        ignoredExtensions:
            ((json['ignoredExtensions'] as List?) ?? const []).cast<String>(),
      );

  @override
  List<Object?> get props => [
        themeMode,
        language,
        defaultBranchPrefix,
        signingMode,
        autoFetchBeforeCommit,
        showAvatars,
        notificationsEnabled,
        customRepoStorePath,
        autoScanIntervalMinutes,
        ignoredExtensions,
      ];
}

enum AppThemeMode { system, light, dark }
enum AppLanguage { system, en, zh }
enum CommitSigning { off, gpg, ssh }

class RepoConfig extends Equatable {
  final String id;
  final String name;
  final String localPath;
  final String? remoteUrl;
  final String? defaultBranch;
  final DateTime addedAt;

  const RepoConfig({
    required this.id,
    required this.name,
    required this.localPath,
    this.remoteUrl,
    this.defaultBranch,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'localPath': localPath,
        'remoteUrl': remoteUrl,
        'defaultBranch': defaultBranch,
        'addedAt': addedAt.toIso8601String(),
      };

  factory RepoConfig.fromJson(Map<String, dynamic> json) => RepoConfig(
        id: json['id'] as String,
        name: json['name'] as String,
        localPath: json['localPath'] as String,
        remoteUrl: json['remoteUrl'] as String?,
        defaultBranch: json['defaultBranch'] as String?,
        addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ?? DateTime.now(),
      );

  @override
  List<Object?> get props => [id, name, localPath, remoteUrl, defaultBranch, addedAt];
}