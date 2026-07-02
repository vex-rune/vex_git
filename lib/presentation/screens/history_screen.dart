import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_config.dart';
import '../../domain/entities/git_entities.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';

final _commitsProvider = FutureProvider.family<List<Commit>, String>((ref, repoId) async {
  final repo = await ref.read(appConfigRepoProvider).load();
  final r = repo.repositories.firstWhere(
    (e) => e.id == repoId,
    orElse: () => RepoConfig(id: '', name: '', localPath: '', addedAt: DateTime.fromMillisecondsSinceEpoch(0)),
  );
  if (r.id.isEmpty || r.localPath.isEmpty) return const [];
  return ref.read(getCommitLogProvider).call(r.localPath, maxCount: 100);
});

class HistoryScreen extends ConsumerStatefulWidget {
  final String repoId;
  const HistoryScreen({super.key, required this.repoId});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(_commitsProvider(widget.repoId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l.historyTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l.historySearch,
                isDense: true,
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
        ),
      ),
      body: async.when(
        data: (list) {
          final filtered = _query.isEmpty
              ? list
              : list.where((c) => c.message.toLowerCase().contains(_query) ||
                    c.authorName.toLowerCase().contains(_query)).toList();
          if (filtered.isEmpty) {
            return Center(child: Text(l.historyNoCommits));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_commitsProvider(widget.repoId)),
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _CommitTile(commit: filtered[i], repoId: widget.repoId),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.commonError}: $e')),
      ),
    );
  }
}

class _CommitTile extends StatelessWidget {
  final Commit commit;
  final String repoId;
  const _CommitTile({required this.commit, required this.repoId});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Text(
          (commit.shortSha ?? commit.sha.substring(0, 7)).substring(0, 4),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
      title: Text(
        commit.message.split('\n').first,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${commit.authorName} - ${_relTime(commit.authoredAt)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/commit-detail/$repoId',
          arguments: commit.sha,
        );
      },
    );
  }

  String _relTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}