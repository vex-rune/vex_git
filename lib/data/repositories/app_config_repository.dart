import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/exceptions.dart';
import '../../core/utils/app_paths.dart';
import '../../domain/entities/app_config.dart';
import '../../domain/repositories/app_config_repository.dart' as domain;

class AppConfigRepositoryImpl implements domain.AppConfigRepository {
  AppConfig _cache = const AppConfig();
  bool _loaded = false;
  final _controller = StreamController<AppConfig>.broadcast();

  static const _kConfigKey = 'vex_git_config_json';

  @override
  Future<AppConfig> load() async {
    if (_loaded) return _cache;
    try {
      String? raw;
      if (kIsWeb) {
        // Web: SharedPreferences uses localStorage / IndexedDB under the hood.
        final prefs = await SharedPreferences.getInstance();
        raw = prefs.getString(_kConfigKey);
      } else {
        // Native: write to .vex_git.config so it's portable, then mirror
        // into SharedPreferences for fast access.
        final file = await AppPaths.configFile;
        if (await file.exists()) {
          raw = await file.readAsString();
        }
      }
      if (raw == null || raw.trim().isEmpty) {
        _cache = const AppConfig();
      } else {
        _cache = AppConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
      _loaded = true;
      return _cache;
    } on FormatException catch (e) {
      throw ValidationException('Config file is corrupted: ${e.message}');
    } catch (e) {
      throw ValidationException('Failed to read config: $e');
    }
  }

  @override
  Future<void> save(AppConfig config) async {
    final json = const JsonEncoder.withIndent('  ').convert(config.toJson());
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kConfigKey, json);
    } else {
      final file = await AppPaths.configFile;
      await AppPaths.ensureAppRoot();
      await file.writeAsString(json, flush: true);
    }
    _cache = config;
    _loaded = true;
    _controller.add(config);
  }

  @override
  Stream<AppConfig> watch() async* {
    yield await load();
    yield* _controller.stream;
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}