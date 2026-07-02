import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';

class AppPaths {
  AppPaths._();

  /// 应用根目录（保存 .vex_git.config / .vex_git_store）
  /// v1 固定在「文档目录」下，符合用户最初要求。
  static Future<Directory> get appRoot async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(docs.path, 'VexGit'));
  }

  static Future<Directory> ensureAppRoot() async {
    final root = await appRoot;
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    return root;
  }

  static Future<File> get configFile async {
    final root = await ensureAppRoot();
    return File(p.join(root.path, AppConstants.configFileName));
  }

  static Future<Directory> get storeDir async {
    final root = await ensureAppRoot();
    return Directory(p.join(root.path, AppConstants.storeDirName));
  }

  static Future<Directory> ensureStoreDir() async {
    final dir = await storeDir;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<Directory> get reposDir async {
    final store = await ensureStoreDir();
    return Directory(p.join(store.path, AppConstants.storeReposDir));
  }

  static Future<Directory> ensureReposDir() async {
    final dir = await reposDir;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<Directory> get cacheDir async {
    final store = await ensureStoreDir();
    final dir = Directory(p.join(store.path, AppConstants.storeCacheDir));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> get logsDir async {
    final store = await ensureStoreDir();
    final dir = Directory(p.join(store.path, AppConstants.storeLogsDir));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// 将 owner/repo 转为本地存储目录名
  static String repoSlugFromUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    String? last;
    if (uri != null && uri.pathSegments.isNotEmpty) {
      last = uri.pathSegments.last;
      if (last.endsWith('.git')) last = last.substring(0, last.length - 4);
    }
    last ??= url.split('/').last;
    return last.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  }

  static String ownerRepoFromUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return url;
    final segs = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segs.length >= 2) return '${segs[segs.length - 2]}/${segs[segs.length - 1].replaceAll(RegExp(r"\.git$"), "")}';
    return url;
  }
}