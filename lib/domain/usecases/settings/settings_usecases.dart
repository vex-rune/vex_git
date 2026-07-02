import '../../../domain/entities/app_config.dart';
import '../../../domain/repositories/app_config_repository.dart' as config_repo;

class GetPreferences {
  final config_repo.AppConfigRepository repo;
  GetPreferences(this.repo);
  Future<PreferencesConfig> call() async => (await repo.load()).preferences;
}

class UpdatePreferences {
  final config_repo.AppConfigRepository repo;
  UpdatePreferences(this.repo);

  Future<void> call(PreferencesConfig Function(PreferencesConfig) updater) async {
    final cfg = await repo.load();
    await repo.save(cfg.copyWith(preferences: updater(cfg.preferences)));
  }
}

class SetActiveAccount {
  final config_repo.AppConfigRepository repo;
  SetActiveAccount(this.repo);
  Future<void> call(String? accountId) async {
    final cfg = await repo.load();
    await repo.save(cfg.copyWith(
      activeAccountId: accountId,
      clearActiveAccount: accountId == null,
    ));
  }
}

class ResetPreferences {
  final config_repo.AppConfigRepository repo;
  ResetPreferences(this.repo);
  Future<void> call() async {
    final cfg = await repo.load();
    await repo.save(cfg.copyWith(preferences: const PreferencesConfig()));
  }
}