import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Token 类
  static const _kAccountTokenPrefix = 'account_token:';
  static const _kSshKeyPrefix = 'ssh_key:';
  static const _kAppPin = 'app_pin';
  static const _kBiometricEnabled = 'biometric_enabled';

  // ---- 账户 Token ----
  Future<void> saveAccountToken(String accountId, String token) async {
    await _storage.write(key: '$_kAccountTokenPrefix$accountId', value: token);
  }

  Future<String?> readAccountToken(String accountId) {
    return _storage.read(key: '$_kAccountTokenPrefix$accountId');
  }

  Future<void> deleteAccountToken(String accountId) {
    return _storage.delete(key: '$_kAccountTokenPrefix$accountId');
  }

  // ---- SSH 私钥 ----
  Future<void> saveSshKey(String name, String privateKey, {String? passphrase}) async {
    await _storage.write(key: '$_kSshKeyPrefix$name', value: privateKey);
    if (passphrase != null) {
      await _storage.write(key: '$_kSshKeyPrefix${name}_pass', value: passphrase);
    }
  }

  Future<String?> readSshKey(String name) => _storage.read(key: '$_kSshKeyPrefix$name');
  Future<String?> readSshPassphrase(String name) => _storage.read(key: '$_kSshKeyPrefix${name}_pass');

  Future<void> deleteSshKey(String name) async {
    await _storage.delete(key: '$_kSshKeyPrefix$name');
    await _storage.delete(key: '$_kSshKeyPrefix${name}_pass');
  }

  // ---- 应用锁 ----
  Future<void> setAppPin(String pin) => _storage.write(key: _kAppPin, value: pin);
  Future<String?> getAppPin() => _storage.read(key: _kAppPin);
  Future<void> deleteAppPin() => _storage.delete(key: _kAppPin);

  Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(key: _kBiometricEnabled, value: enabled.toString());
  Future<bool> getBiometricEnabled() async {
    final v = await _storage.read(key: _kBiometricEnabled);
    return v == 'true';
  }

  Future<void> clearAll() => _storage.deleteAll();
}