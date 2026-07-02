import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../infrastructure/github/github_api_client.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';

final _prProvider = FutureProvider.family<PullRequestSummary, _PrDetailKey>((ref, key) {
  return ref.read(getPrProvider).call(key.owner, key.repo, key.number);
});

class _PrDetailKey {
  final String owner;
  final String repo;
  final int number;
  const _PrDetailKey(this.owner, this.repo, this.number);
  @override
  bool operator ==(Object other) =>
      other is _PrDetailKey && owner == other.owner && repo == other.repo && number == other.number;
  @override
  int get hashCode => Object.hash(owner, repo, number);
}

class PullRequestDetailScreen extends ConsumerWidget {
  final String owner;
  final String repo;
  final int number;
  const PullRequestDetailScreen({super.key, required this.owner, required this.repo, required this.number});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(_prProvider(_PrDetailKey(owner, repo, number)));
    return Scaffold(
      appBar: AppBar(
        title: Text('PR #$number'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open on GitHub',
            onPressed: () => launchUrl(
              Uri.parse('https://github.com/$owner/$repo/pull/$number'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
      body: async.when(
        data: (p) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Chip(
                    avatar: Icon(
                      p.merged
                          ? Icons.merge_outlined
                          : p.state == 'open'
                              ? Icons.call_split
                              : Icons.cancel_outlined,
                      color: p.merged
                          ? Colors.purple
                          : p.state == 'open'
                              ? Colors.green
                              : Colors.red,
                      size: 16,
                    ),
                    label: Text(p.merged ? l.prMerged : (p.state == 'open' ? l.prOpen : l.prClosed)),
                  ),
                  if (p.draft) ...[
                    const SizedBox(width: 8),
                    const Chip(label: Text('Draft')),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(p.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                '${p.user?.login ?? "?"}  wants to merge ${p.headRef} into ${p.baseRef}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (p.body != null && p.body!.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(p.body!),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.link),
                      label: Text(p.headRef),
                      onPressed: () {},
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward),
                  ),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.fork_right),
                      label: Text(p.baseRef),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (p.state == 'open' && !p.draft)
                FilledButton.icon(
                  icon: const Icon(Icons.merge),
                  label: Text(l.prMerge),
                  onPressed: () => _showMergeSheet(context, ref, p),
                ),
              if (p.state == 'open') ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.close),
                  label: Text(l.prClose),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(l.prClose),
                        content: Text('Close PR #$number?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.commonCancel)),
                          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.commonConfirm)),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      try {
                        await ref.read(githubApiProvider).closePullRequest(owner, repo, number);
                        ref.invalidate(_prProvider(_PrDetailKey(owner, repo, number)));
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                        }
                      }
                    }
                  },
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.commonError}: $e')),
      ),
    );
  }

  Future<void> _showMergeSheet(BuildContext context, WidgetRef ref, PullRequestSummary p) async {
    final l = AppLocalizations.of(context);
    final method = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.merge),
              title: Text(l.prMerge),
              subtitle: const Text('Create a merge commit'),
              onTap: () => Navigator.pop(context, 'merge'),
            ),
            ListTile(
              leading: const Icon(Icons.compress),
              title: Text(l.prSquash),
              subtitle: const Text('Squash commits into one'),
              onTap: () => Navigator.pop(context, 'squash'),
            ),
            ListTile(
              leading: const Icon(Icons.fast_forward),
              title: Text(l.prRebase),
              subtitle: const Text('Rebase commits onto base'),
              onTap: () => Navigator.pop(context, 'rebase'),
            ),
          ],
        ),
      ),
    );
    if (method != null) {
      try {
        await ref.read(mergePrProvider).call(owner, repo, number, method: method);
        ref.invalidate(_prProvider(_PrDetailKey(owner, repo, number)));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PR merged')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        }
      }
    }
  }
}