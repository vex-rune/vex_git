import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/app_config.dart';
import '../../domain/entities/git_entities.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../widgets/diff_view.dart';

final _repoByIdProvider = FutureProvider.family<RepoConfig?, String>((ref, id) async {
  final cfg = await ref.read(appConfigRepoProvider).load();
  final matches = cfg.repositories.where((r) => r.id == id);
  return matches.isNotEmpty ? matches.first : null;
});

final _statusStreamProvider = StreamProvider.family<RepoStatus, String>((ref, repoId) {
  final repoAsync = ref.watch(_repoByIdProvider(repoId));
  final repo = repoAsync.value;
  if (repo == null) return const Stream.empty();
  return ref.read(watchRepoStatusProvider).call(repo.localPath);
});

final _diffProvider = FutureProvider.family<List<FileDiff>, String>((ref, repoId) async {
  final repoAsync = ref.watch(_repoByIdProvider(repoId));
  final repo = repoAsync.value;
  if (repo == null) return const [];
  return ref.read(getDiffProvider).call(repo.localPath);
});

final _logProvider = FutureProvider.family<List<Commit>, String>((ref, repoId) async {
  final repoAsync = ref.watch(_repoByIdProvider(repoId));
  final repo = repoAsync.value;
  if (repo == null) return const [];
  return ref.read(getCommitLogProvider).call(repo.localPath, maxCount: 30);
});

class RepoDetailScreen extends ConsumerWidget {
  final String repoId;
  const RepoDetailScreen({super.key, required this.repoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final repoAsync = ref.watch(_repoByIdProvider(repoId));
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: repoAsync.when(
            data: (r) => Text(r?.name ?? 'Repository'),
            loading: () => const Text('...'),
            error: (_, __) => Text(l.commonError),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.edit_note), text: 'Changes'),
              Tab(icon: Icon(Icons.history), text: 'History'),
              Tab(icon: Icon(Icons.account_tree), text: 'Branches'),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (v) => _onMenu(context, ref, v),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'fetch', child: Text(l.syncFetch)),
                PopupMenuItem(value: 'pull', child: Text(l.syncPull)),
                PopupMenuItem(value: 'push', child: Text(l.syncPush)),
                const PopupMenuDivider(),
                PopupMenuItem(value: 'commit', child: Text(l.changesCommit)),
              ],
            ),
          ],
        ),
        body: repoAsync.when(
          data: (r) {
            if (r == null) return const Center(child: Text('Not found'));
            return TabBarView(
              children: [
                _ChangesTab(repoId: repoId),
                _HistoryTab(repoId: repoId),
                _BranchesTab(repoId: repoId),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${l.commonError}: $e')),
        ),
      ),
    );
  }

  Future<void> _onMenu(BuildContext context, WidgetRef ref, String action) async {
    final l = AppLocalizations.of(context);
    final repo = await ref.read(_repoByIdProvider(repoId).future);
    if (repo == null || !context.mounted) return;
    switch (action) {
      case 'fetch':
        if (!context.mounted) return;
        await _runStream(context, ref, l.syncFetch, () => ref.read(fetchProvider).call(repo.localPath));
        break;
      case 'pull':
        if (!context.mounted) return;
        await _runStream(context, ref, l.syncPull, () => ref.read(pullProvider).call(repo.localPath));
        ref.invalidate(_statusStreamProvider(repoId));
        ref.invalidate(_diffProvider(repoId));
        break;
      case 'push':
        if (!context.mounted) return;
        await _runStream(context, ref, l.syncPush, () => ref.read(pushProvider).call(repo.localPath));
        ref.invalidate(_statusStreamProvider(repoId));
        break;
      case 'commit':
        if (context.mounted) { unawaited(context.push('/commit/$repoId')); }
        break;
    }
  }

  Future<void> _runStream(
    BuildContext context,
    WidgetRef ref,
    String title,
    Stream<ProgressEvent> Function() factory,
  ) async {
    final progress = ValueNotifier<ProgressEvent?>(null);
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dctx) => AlertDialog(
        title: Text('$title...'),
        content: ValueListenableBuilder<ProgressEvent?>(
          valueListenable: progress,
          builder: (_, ev, __) {
            if (ev == null) return const LinearProgressIndicator();
            final ratio = ev.ratio;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${ev.phase} ${ev.current}/${ev.total ?? "?"}'),
                if (ratio != null) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: ratio),
                ],
              ],
            );
          },
        ),
      ),
    );
    final sub = (factory()).listen(
      (e) => progress.value = e,
      onError: (Object e) {
        navigator.pop();
        progress.dispose();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        }
      },
      onDone: () {
        navigator.pop();
        progress.dispose();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title done')));
        }
      },
    );
    unawaited(sub.asFuture<void>().catchError((Object _) {}));
  }
}

class _ChangesTab extends ConsumerWidget {
  final String repoId;
  const _ChangesTab({required this.repoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final statusAsync = ref.watch(_statusStreamProvider(repoId));
    final diffAsync = ref.watch(_diffProvider(repoId));
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(_statusStreamProvider(repoId));
        ref.invalidate(_diffProvider(repoId));
        await Future<void>.delayed(const Duration(milliseconds: 300));
      },
      child: statusAsync.when(
        data: (status) {
          if (status.totalChanges == 0) {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(child: Text(l.changesNoChanges)),
                ),
              ],
            );
          }
          return ListView(
            children: [
              _SyncBar(status: status),
              if (status.staged.isNotEmpty) ...[
                _SectionLabel(label: '${l.changesStaged} (${status.staged.length})'),
                for (final c in status.staged) _FileChangeRow(repoId: repoId, change: c, staged: true),
              ],
              if (status.unstaged.isNotEmpty) ...[
                _SectionLabel(label: '${l.changesWorking} (${status.unstaged.length})'),
                for (final c in status.unstaged) _FileChangeRow(repoId: repoId, change: c, staged: false),
              ],
              if (status.untracked.isNotEmpty) ...[
                _SectionLabel(label: 'Untracked (${status.untracked.length})'),
                for (final c in status.untracked) _FileChangeRow(repoId: repoId, change: c, staged: false),
              ],
              const SizedBox(height: 16),
              diffAsync.when(
                data: (diffs) => diffs.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DiffView(diffs: diffs),
                      ),
                loading: () => const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
                error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('${l.commonError}: $e')),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.commonError}: $e')),
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  final String repoId;
  const _HistoryTab({required this.repoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(_logProvider(repoId));
    return async.when(
      data: (list) {
        if (list.isEmpty) return Center(child: Text(l.historyNoCommits));
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(_logProvider(repoId));
            await Future<void>.delayed(const Duration(milliseconds: 300));
          },
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = list[i];
              return ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  child: Text(
                    (c.shortSha ?? c.sha.substring(0, 7)).substring(0, 4),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                title: Text(c.message.split('\n').first, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${c.authorName} - ${c.authoredAt.toLocal().toString().split('.').first}'),
                onTap: () => context.push('/commit-detail/$repoId/${c.sha}'),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l.commonError}: $e')),
    );
  }
}

class _BranchesTab extends ConsumerWidget {
  final String repoId;
  const _BranchesTab({required this.repoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.account_tree),
        label: const Text('Manage branches'),
        onPressed: () => context.push('/branch/$repoId'),
      ),
    );
  }
}

class _SyncBar extends StatelessWidget {
  final RepoStatus status;
  const _SyncBar({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Row(
        children: [
          const Icon(Icons.account_tree_outlined, size: 16),
          const SizedBox(width: 4),
          Text(status.branch, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(width: 12),
          if (status.aheadBy > 0) ...[
            const Icon(Icons.arrow_upward, size: 14),
            Text('$status.aheadBy', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 8),
          ],
          if (status.behindBy > 0) ...[
            const Icon(Icons.arrow_downward, size: 14),
            Text('$status.behindBy', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 8),
          ],
          const Spacer(),
          if (status.hasConflicts)
            const Chip(
              label: Text('Conflicts'),
              avatar: Icon(Icons.warning_amber, size: 16),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _FileChangeRow extends ConsumerWidget {
  final String repoId;
  final FileChange change;
  final bool staged;
  const _FileChangeRow({required this.repoId, required this.change, required this.staged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Slidable(
      key: ValueKey(change.path),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) async {
              final repo = await ref.read(_repoByIdProvider(repoId).future);
              if (repo == null || !context.mounted) return;
              if (staged) {
                await ref.read(unstageFilesProvider).call(repo.localPath, [change.path]);
              } else {
                await ref.read(stageFilesProvider).call(repo.localPath, [change.path]);
              }
              ref.invalidate(_statusStreamProvider(repoId));
              ref.invalidate(_diffProvider(repoId));
            },
            backgroundColor: staged ? Colors.orange : Colors.green,
            foregroundColor: Colors.white,
            icon: staged ? Icons.remove_circle_outline : Icons.add_circle_outline,
            label: staged ? 'Unstage' : 'Stage',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Discard changes?'),
                  content: Text('This will permanently discard local changes to ${change.path}.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Discard')),
                  ],
                ),
              );
              if (confirm == true) {
                final repo = await ref.read(_repoByIdProvider(repoId).future);
                if (repo == null) return;
                await ref.read(discardFilesProvider).call(repo.localPath, [change.path]);
                ref.invalidate(_statusStreamProvider(repoId));
                ref.invalidate(_diffProvider(repoId));
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Discard',
          ),
        ],
      ),
      child: ListTile(
        dense: true,
        leading: Icon(_icon(change.status), color: _color(change.status), size: 18),
        title: Text(change.path, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text(change.isStaged ? 'staged' : '', style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}

IconData _icon(FileChangeStatus s) {
  return switch (s) {
    FileChangeStatus.added => Icons.add_circle_outline,
    FileChangeStatus.modified => Icons.edit_outlined,
    FileChangeStatus.deleted => Icons.delete_outline,
    FileChangeStatus.renamed => Icons.drive_file_rename_outline,
    FileChangeStatus.copied => Icons.copy_all_outlined,
    FileChangeStatus.untracked => Icons.help_outline,
    FileChangeStatus.conflicted => Icons.warning_amber_outlined,
    FileChangeStatus.typeChanged => Icons.change_circle_outlined,
  };
}

Color _color(FileChangeStatus s) {
  return switch (s) {
    FileChangeStatus.added => Colors.green,
    FileChangeStatus.modified => Colors.orange,
    FileChangeStatus.deleted => Colors.red,
    FileChangeStatus.untracked => Colors.blueGrey,
    FileChangeStatus.conflicted => Colors.red,
    _ => Colors.grey,
  };
}
