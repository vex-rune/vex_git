import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeKey = 'theme_mode';
const _scanIntervalKey = 'scan_interval';

// ---- 主题 & 巡检周期（SharedPreferences）----

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

final scanIntervalProvider =
    StateNotifierProvider<ScanIntervalNotifier, int>((ref) {
  return ScanIntervalNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeKey);
    if (value == 'light') {
      state = ThemeMode.light;
    } else if (value == 'system') {
      state = ThemeMode.system;
    } else {
      state = ThemeMode.dark;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }
}

class ScanIntervalNotifier extends StateNotifier<int> {
  ScanIntervalNotifier() : super(20) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_scanIntervalKey) ?? 20;
  }

  Future<void> setInterval(int minutes) async {
    state = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scanIntervalKey, minutes);
  }
}

// ---- 凭证配置（vex/vex.config 文件）----

final vexConfigProvider = Provider<VexConfig>((ref) {
  return VexConfig();
});

/// 凭证配置管理器，读写 vex/vex.config
///
/// 文件格式为 JSON，存储在 App 文档目录下的 vex/vex.config
/// 示例：
/// ```json
/// {
///   "github_token": "ghp_xxx",
///   "gitee_token": "xxx"
/// }
/// ```
class VexConfig {
  Map<String, String> _data = {};

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final vexDir = Directory('${dir.path}/vex');
    if (!await vexDir.exists()) {
      await vexDir.create(recursive: true);
    }
    return File('${vexDir.path}/vex.config');
  }

  Future<void> load() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        _data = json.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (_) {
      _data = {};
    }
  }

  Future<void> save() async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(_data));
  }

  String? get(String key) {
    return _data[key];
  }

  Future<void> set(String key, String value) async {
    _data[key] = value;
    await save();
  }

  Future<void> remove(String key) async {
    _data.remove(key);
    await save();
  }

  String? get githubToken => get('github_token');
  set githubToken(String? v) {
    if (v == null || v.isEmpty) {
      remove('github_token');
    } else {
      set('github_token', v);
    }
  }

  String? get giteeToken => get('gitee_token');
  set giteeToken(String? v) {
    if (v == null || v.isEmpty) {
      remove('gitee_token');
    } else {
      set('gitee_token', v);
    }
  }
}
