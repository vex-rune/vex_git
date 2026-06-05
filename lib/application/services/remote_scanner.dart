import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/git_providers.dart';
import '../providers/settings_providers.dart';

final remoteScanProvider = Provider<RemoteScanner>((ref) {
  return RemoteScanner(ref);
});

class RemoteScanner {
  final Ref _ref;
  Timer? _timer;

  RemoteScanner(this._ref);

  void start() {
    _timer?.cancel();
    final interval = _ref.read(scanIntervalProvider);
    _timer = Timer.periodic(Duration(minutes: interval), (_) => _scan());
    _scan();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void updateInterval(int minutes) {
    stop();
    start();
  }

  Future<void> _scan() async {
    final git = _ref.read(gitServiceProvider);
    final currentRepo = _ref.read(currentRepoProvider);
    if (currentRepo == null) return;

    try {
      final currentBranch = await git.getCurrentBranch(currentRepo.localPath);
      final remoteSha = await git.getRemoteSha(
        currentRepo.localPath,
        'origin',
        currentBranch,
      );
      if (remoteSha == null) return;

      final log = await git.getLog(currentRepo.localPath, limit: 1);
      final localSha = log.isNotEmpty ? log.first.sha : null;
      if (localSha != remoteSha) {
        _ref.read(syncNotificationProvider.notifier).state = SyncNotification(
          repoName: currentRepo.name,
          message: '检测到 ${currentRepo.name} 有远程更新',
        );
      }
    } catch (_) {}
  }
}

class SyncNotification {
  final String repoName;
  final String message;

  const SyncNotification({required this.repoName, required this.message});
}

final syncNotificationProvider = StateProvider<SyncNotification?>((ref) => null);
