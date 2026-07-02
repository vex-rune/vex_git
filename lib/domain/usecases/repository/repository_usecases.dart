import 'dart:io';
import 'dart:math';

import '../../../core/errors/exceptions.dart';
import '../../../core/utils/app_paths.dart';
import '../../../domain/entities/app_config.dart';
import '../../../domain/repositories/app_config_repository.dart' as config_repo;
import '../../../infrastructure/git/process_git_client.dart';
import '../../../domain/repositories/git_client.dart';
import '../../../infrastructure/github/github_api_client.dart';

class ListRepositories {
  final config_repo.AppConfigRepository config;
  ListRepositories(this.config);
  Future<List<RepoConfig>> call() async {
    final cfg = await config.load();
    return cfg.repositories;
  }
}

class AddLocalRepository {
  final config_repo.AppConfigRepository config;
  final ProcessGitClient git;
  AddLocalRepository(this.config, this.git);

  Future<RepoConfig> call(String localPath) async {
    final dir = Directory(localPath);
    if (!await dir.exists()) {
      throw ValidationException('Directory does not exist: $localPath');
    }
    final gitDir = Directory('${dir.path}${Platform.pathSeparator}.git');
    if (!await gitDir.exists()) {
      throw ValidationException('Not a git repository: $localPath');
    }
    // 探测 remote url + 当前分支
    final remotes = await git.listRemotes(localPath);
    String? remoteUrl;
    if (remotes.contains('origin')) {
      final r = await Process.run('git', ['config', '--get', 'remote.origin.url'],
          workingDirectory: localPath, runInShell: true);
      if (r.exitCode == 0) {
        remoteUrl = r.stdout.toString().trim();
      }
    }
    final status = await git.status(localPath);
    final name = dir.path.split(Platform.pathSeparator).last;
    final cfg = await config.load();
    final id = _id();
    final repo = RepoConfig(
      id: id,
      name: name,
      localPath: localPath,
      remoteUrl: remoteUrl,
      defaultBranch: status.branch,
      addedAt: DateTime.now(),
    );
    await config.save(cfg.copyWith(
      repositories: [...cfg.repositories, repo],
    ));
    return repo;
  }
}

class CreateLocalRepository {
  final config_repo.AppConfigRepository config;
  final ProcessGitClient git;
  CreateLocalRepository(this.config, this.git);

  Future<RepoConfig> call({required String name, required String parentPath}) async {
    if (name.trim().isEmpty) {
      throw ValidationException('Repository name cannot be empty');
    }
    final fullPath = '$parentPath${Platform.pathSeparator}$name';
    final dir = Directory(fullPath);
    if (await dir.exists()) {
      throw ValidationException('Directory already exists: $fullPath');
    }
    await dir.create(recursive: true);
    await git.init(path: fullPath);
    final cfg = await config.load();
    final id = _id();
    final repo = RepoConfig(
      id: id,
      name: name,
      localPath: fullPath,
      addedAt: DateTime.now(),
    );
    await config.save(cfg.copyWith(
      repositories: [...cfg.repositories, repo],
    ));
    return repo;
  }
}

class CloneRepository {
  final config_repo.AppConfigRepository config;
  final GitClient git;
  final GitHubApiClient api;
  CloneRepository(this.config, this.git, this.api);

  /// 把 url + 进度流返回给 UI；调用方负责订阅进度 + 等待完成
  Future<RepoConfig> call({
    required String url,
    String? destPath,
    String? token,
    String? branch,
  }) async {
    final storePath = destPath ?? await AppPaths.ensureReposDir().then((d) => d.path);
    final slug = AppPaths.repoSlugFromUrl(url);
    final targetPath = '$storePath${Platform.pathSeparator}$slug';
    final stream = git.clone(CloneOptions(
      url: url,
      localPath: targetPath,
      token: token,
      branch: branch,
    ));
    // 等待完成：collect stream
    await for (final _ in stream) {
      // progress handled by UI separately
    }
    final cfg = await config.load();
    final repo = RepoConfig(
      id: _id(),
      name: slug,
      localPath: targetPath,
      remoteUrl: url,
      defaultBranch: branch,
      addedAt: DateTime.now(),
    );
    await config.save(cfg.copyWith(
      repositories: [...cfg.repositories, repo],
    ));
    return repo;
  }
}

class RemoveRepository {
  final config_repo.AppConfigRepository config;
  RemoveRepository(this.config);

  Future<void> call(String repoId) async {
    final cfg = await config.load();
    final next = cfg.repositories.where((r) => r.id != repoId).toList();
    await config.save(cfg.copyWith(repositories: next));
  }
}

class RenameRepository {
  final config_repo.AppConfigRepository config;
  RenameRepository(this.config);

  Future<void> call(String repoId, String newName) async {
    if (newName.trim().isEmpty) {
      throw ValidationException('Name cannot be empty');
    }
    final cfg = await config.load();
    final next = cfg.repositories.map((r) {
      if (r.id != repoId) return r;
      return RepoConfig(
        id: r.id,
        name: newName,
        localPath: r.localPath,
        remoteUrl: r.remoteUrl,
        defaultBranch: r.defaultBranch,
        addedAt: r.addedAt,
      );
    }).toList();
    await config.save(cfg.copyWith(repositories: next));
  }
}

class UpdateRepoPath {
  final config_repo.AppConfigRepository config;
  UpdateRepoPath(this.config);

  Future<void> call(String repoId, String newPath) async {
    final dir = Directory(newPath);
    if (!await dir.exists()) {
      throw ValidationException('Directory does not exist: $newPath');
    }
    final gitDir = Directory('${dir.path}${Platform.pathSeparator}.git');
    if (!await gitDir.exists()) {
      throw ValidationException('Target is not a git repository: $newPath');
    }
    final cfg = await config.load();
    final next = cfg.repositories.map((r) {
      if (r.id != repoId) return r;
      return RepoConfig(
        id: r.id,
        name: r.name,
        localPath: newPath,
        remoteUrl: r.remoteUrl,
        defaultBranch: r.defaultBranch,
        addedAt: r.addedAt,
      );
    }).toList();
    await config.save(cfg.copyWith(repositories: next));
  }
}

String _id() {
  final r = Random();
  final now = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  final rand = List.generate(8, (_) => r.nextInt(36).toRadixString(36)).join();
  return '${now}_$rand';
}