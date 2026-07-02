import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_config.dart';

import '../../domain/entities/git_entities.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';

final _commitProvider = FutureProvider.family<Commit?, _CommitKey>((ref, key) {
  return ref.read(getCommitDetailProvider).call(key.repoPath, key.sha);
});

final _repoByIdProvider2 = FutureProvider.family<RepoConfig?, String>((ref, id) async {
  final cfg = await ref.read(appConfigRepoProvider).load();
  final matches = cfg.repositories.where((r) => r.id == id);
  return matches.isNotEmpty ? matches.first : null;
});

class _CommitKey {
  final String repoPath;
  final String sha;
  const _CommitKey(this.repoPath, this.sha);
  @override
  bool operator ==(Object other) =>
      other is _CommitKey && repoPath == other.repoPath && sha == other.sha;
  @override
  int get hashCode => Object.hash(repoPath, sha);
}

class CommitDetailScreen extends ConsumerWidget {
  final String repoId;
  final String sha;
  const CommitDetailScreen({super.key, required this.repoId, required this.sha});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final repoAsync = ref.watch(_repoByIdProvider2(repoId));
    return Scaffold(
      appBar: AppBar(title: Text(sha.substring(0, 7))),
      body: repoAsync.when(
        data: (RepoConfig? repo) {
          if (repo == null) return const Center(child: Text('Not found'));
          final key = _CommitKey(repo.localPath, sha);
          final async = ref.watch(_commitProvider(key));
          return async.when(
            data: (commit) {
              if (commit == null) return Center(child: Text('${l.commonError}: commit not found'));
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(commit.message, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (commit.body != null && commit.body!.isNotEmpty)
                    Text(commit.body!, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  _MetaRow(icon: Icons.person, label: l.historyAuthor, value: '${commit.authorName} <${commit.authorEmail}>'),
                  _MetaRow(icon: Icons.calendar_today, label: l.historyDate, value: commit.authoredAt.toLocal().toString()),
                  if (commit.committerName != null)
                    _MetaRow(icon: Icons.commit, label: 'Committer', value: '${commit.committerName} <${commit.committerEmail ?? ""}>'),
                  _MetaRow(icon: Icons.tag, label: 'SHA', value: commit.sha),
                  if (commit.parentShas.isNotEmpty)
                    _MetaRow(icon: Icons.account_tree, label: 'Parents', value: commit.parentShas.join(', ')),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object e, _) => Center(child: Text('${l.commonError}: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('${l.commonError}: $e')),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MetaRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(label, style: Theme.of(context).textTheme.labelSmall),
          ),
          Expanded(child: SelectableText(value, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
