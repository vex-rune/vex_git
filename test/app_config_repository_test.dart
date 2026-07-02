import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:vex_git/data/repositories/app_config_repository.dart';
import 'package:vex_git/domain/entities/app_config.dart';

class _MockPathProvider extends PathProviderPlatform with MockPlatformInterfaceMixin {
  _MockPathProvider(this.root);
  final String root;
  @override
  Future<String?> getApplicationDocumentsPath() async => root;
  @override
  Future<String?> getApplicationSupportPath() async => root;
  @override
  Future<String?> getTemporaryPath() async => root;
  @override
  Future<String?> getLibraryPath() async => root;
  @override
  Future<String?> getDownloadsPath() async => root;
  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async => [root];
  @override
  Future<String?> getExternalStoragePath() async => root;
}

void main() {
  late Directory tempDir;
  late AppConfigRepositoryImpl repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vexgit_repo_test_');
    PathProviderPlatform.instance = _MockPathProvider(tempDir.path);
    repo = AppConfigRepositoryImpl();
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('returns empty config when no file exists', () async {
    final cfg = await repo.load();
    expect(cfg.accounts, isEmpty);
    expect(cfg.repositories, isEmpty);
  });

  test('saves and reloads config', () async {
    const cfg = AppConfig(
      activeAccountId: 'a1',
      accounts: [
        AccountConfig(id: 'a1', host: 'github.com', login: 'octo'),
      ],
    );
    await repo.save(cfg);
    final restored = await repo.load();
    expect(restored.activeAccountId, 'a1');
    expect(restored.accounts.first.login, 'octo');
  });

  test('config file path is inside app root', () async {
    await repo.save(const AppConfig());
    final configFile = File(p.join(tempDir.path, 'VexGit', '.vex_git.config'));
    expect(await configFile.exists(), isTrue);
  });

  test('watch emits initial value then updates', () async {
    final values = <AppConfig>[];
    final sub = repo.watch().listen(values.add);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await repo.save(const AppConfig(activeAccountId: 'b2'));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();
    expect(values.length, greaterThanOrEqualTo(2));
    expect(values.last.activeAccountId, 'b2');
  });
}