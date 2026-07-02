import '../../../core/errors/exceptions.dart';
import '../../../infrastructure/github/github_api_client.dart';
import '../../../infrastructure/storage/secure_store.dart';
import '../../entities/app_config.dart';
import '../../repositories/app_config_repository.dart' as repo;

/// 启动 OAuth Device Flow，返回 device code + 用户需访问的 URL
class StartDeviceLogin {
  final GitHubApiClient api;
  StartDeviceLogin(this.api);

  Future<DeviceCodeResponse> call({
    required String clientId,
    required List<String> scopes,
    String? host,
  }) {
    return api.requestDeviceCode(clientId: clientId, scopes: scopes, host: host);
  }
}

/// 轮询 token，完成后保存到 secure store + config
class CompleteDeviceLogin {
  final GitHubApiClient api;
  final SecureStore secure;
  final repo.AppConfigRepository config;
  CompleteDeviceLogin(this.api, this.secure, this.config);

  Future<AccountConfig> call({
    required String clientId,
    required DeviceCodeResponse device,
    String? host,
  }) async {
    final interval = Duration(seconds: device.interval);
    final deadline = DateTime.now().add(Duration(seconds: device.expiresIn));
    String? token;
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(interval);
      final r = await api.pollDeviceCode(
        clientId: clientId,
        deviceCode: device.deviceCode,
        host: host,
      );
      if (r.token != null) {
        token = r.token;
        break;
      }
      switch (r.error) {
        case null:
        case DeviceFlowError.authorizationPending:
        case DeviceFlowError.slowDown:
          continue;
        case DeviceFlowError.expiredToken:
          throw AuthException('Device code expired. Please restart login.');
        case DeviceFlowError.accessDenied:
          throw AuthException('Access denied by user.');
        case DeviceFlowError.incorrectDeviceCode:
        case DeviceFlowError.network:
          throw AuthException('Network error during login.');
      }
    }
    if (token == null) {
      throw AuthException('Login timed out');
    }
    api.token = token;
    final user = await api.getCurrentUser();
    final id = '${host ?? "github.com"}_${user.id}';
    await secure.saveAccountToken(id, token);
    api.token = null;
    final account = AccountConfig(
      id: id,
      host: host ?? 'github.com',
      login: user.login,
      displayName: user.name,
      avatarUrl: user.avatarUrl,
      scopes: const ['repo', 'read:user', 'user:email', 'workflow'],
    );
    final cfg = await config.load();
    final updatedAccounts = [
      ...cfg.accounts.where((a) => a.id != id),
      account,
    ];
    await config.save(cfg.copyWith(
      accounts: updatedAccounts,
      activeAccountId: id,
    ));
    return account;
  }
}

class Logout {
  final SecureStore secure;
  final repo.AppConfigRepository config;
  Logout(this.secure, this.config);

  Future<void> call(String accountId) async {
    await secure.deleteAccountToken(accountId);
    final cfg = await config.load();
    final remaining = cfg.accounts.where((a) => a.id != accountId).toList();
    await config.save(cfg.copyWith(
      accounts: remaining,
      activeAccountId: remaining.isEmpty ? null : (cfg.activeAccountId == accountId ? null : cfg.activeAccountId),
      clearActiveAccount: cfg.activeAccountId == accountId,
    ));
  }
}