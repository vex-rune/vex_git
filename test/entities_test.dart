import 'package:flutter_test/flutter_test.dart';
import 'package:vex_git/domain/entities/app_config.dart';

void main() {
  group('AppConfig', () {
    test('round-trips through JSON', () {
      final original = AppConfig(
        activeAccountId: 'acc1',
        accounts: const [
          AccountConfig(
            id: 'acc1',
            host: 'github.com',
            login: 'octocat',
            displayName: 'Octo Cat',
            avatarUrl: 'https://example.com/avatar.png',
            scopes: const ['repo', 'read:user'],
          ),
        ],
        repositories: [
          RepoConfig(
            id: 'r1',
            name: 'demo',
            localPath: '/tmp/demo',
            remoteUrl: 'https://github.com/octocat/demo.git',
            defaultBranch: 'main',
            addedAt: DateTime.fromMillisecondsSinceEpoch(0),
          ),
        ],
      );
      final json = original.toJson();
      final restored = AppConfig.fromJson(json);
      expect(restored.activeAccountId, 'acc1');
      expect(restored.accounts, hasLength(1));
      expect(restored.accounts.first.login, 'octocat');
      expect(restored.repositories.first.name, 'demo');
    });

    test('copyWith can clear active account', () {
      const cfg = AppConfig(activeAccountId: 'a');
      final cleared = cfg.copyWith(clearActiveAccount: true);
      expect(cleared.activeAccountId, isNull);
    });

    test('handles missing fields gracefully', () {
      final cfg = AppConfig.fromJson({});
      expect(cfg.accounts, isEmpty);
      expect(cfg.repositories, isEmpty);
      expect(cfg.preferences.themeMode, AppThemeMode.system);
    });
  });

  group('PreferencesConfig', () {
    test('default values are sensible', () {
      const p = PreferencesConfig();
      expect(p.themeMode, AppThemeMode.system);
      expect(p.language, AppLanguage.system);
      expect(p.defaultBranchPrefix, 'feature/');
      expect(p.signingMode, CommitSigning.off);
      expect(p.autoScanIntervalMinutes, 10);
    });

    test('clearCustomRepoStorePath removes path', () {
      const p = PreferencesConfig(customRepoStorePath: '/foo');
      final cleared = p.copyWith(clearCustomRepoStorePath: true);
      expect(cleared.customRepoStorePath, isNull);
    });
  });
}
