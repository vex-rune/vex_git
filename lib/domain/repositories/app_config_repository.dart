import '../entities/app_config.dart';

abstract class AppConfigRepository {
  Future<AppConfig> load();
  Future<void> save(AppConfig config);
  Stream<AppConfig> watch();
}