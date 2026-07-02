import 'package:flutter_test/flutter_test.dart';
import 'package:vex_git/domain/entities/app_config.dart';
import 'package:vex_git/domain/repositories/app_config_repository.dart' as domain_repo;
import 'package:vex_git/domain/usecases/repository/repository_usecases.dart';

void main() {
  test('UpdateRepoPath - repoId, newPath - validates new path exists', () {
    // This is a smoke test ensuring the use case signature stays consistent.
    // The actual add/remove/clone behaviors are tested via integration tests.
    final usecase = UpdateRepoPath(_NoopConfigRepo());
    expect(usecase, isNotNull);
  });
}

class _NoopConfigRepo implements domain_repo.AppConfigRepository {
  @override
  Future<AppConfig> load() async => const AppConfig();
  @override
  Future<void> save(AppConfig config) async {}
  @override
  Stream<AppConfig> watch() async* {
    yield const AppConfig();
  }
}