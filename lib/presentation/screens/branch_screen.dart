import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_config.dart';
import '../../domain/entities/git_entities.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';

final _branchesProvider = FutureProvider.family<List<Branch>, String>((ref, repoId) async {
  final repo = await ref.read(appConfigRepoProvider).load();
  final r = repo.repositories.firstWhere(
    (e) => e.id == repoId,
    orElse: () => RepoConfig(id: '', name: '', localPath: '', addedAt: DateTime.fromMillisecondsSinceEpoch(0)),
  );
  if (r.id.isEmpty || r.localPath.isEmpty) return const [];
  return ref.read(listBranchesProvider).call(r.localPath);
});

class BranchScreen extends ConsumerWidget {
  final String repoId;
  const BranchScreen({super.key, required this.repoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(_branchesProvider(repoId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l.branchCreate),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDialog(context, ref),
          ),
        ],
      ),
      body: async.when(
        data: (list) {
          final locals = list.where((b) => !b.isRemote).toList();
          final remotes = list.where((b) => b.isRemote).toList();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_branchesProvider(repoId)),
            child: ListView(
              children: [
                if (locals.isNotEmpty) ...[
                  _section(context, l.branchLocal),
                  ...locals.map((b) => _BranchTile(repoId: repoId, branch: b)),
                ],
                if (remotes.isNotEmpty) ...[
                  _section(context, l.branchRemote),
                  ...remotes.map((b) => _BranchTile(repoId: repoId, branch: b)),
                ],
                if (locals.isEmpty && remotes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(child: Text(l.branchNoBranches)),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.commonError}: $e')),
      ),
    );
  }

  Widget _section(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final l = AppLocalizations.of(context);
    final from = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.branchCreate),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l.branchName,
            hintText: 'feature/awesome',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: Text(l.commonCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: Text(l.commonConfirm),
          ),
        ],
      ),
    );
    if (from != null && from.isNotEmpty) {
      final repo = await ref.read(appConfigRepoProvider).load();
      final r = repo.repositories.firstWhere((e) => e.id == repoId);
      try {
        await ref.read(createBranchProvider).call(r.localPath, from);
        ref.invalidate(_branchesProvider(repoId));
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        }
      }
    }
  }
}

class _BranchTile extends ConsumerWidget {
  final String repoId;
  final Branch branch;
  const _BranchTile({required this.repoId, required this.branch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final color = branch.isCurrent
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Icon(
        branch.isCurrent ? Icons.check_circle : (branch.isRemote ? Icons.cloud_outlined : Icons.account_tree_outlined),
        color: color,
      ),
      title: Text(branch.name, style: TextStyle(color: color, fontWeight: branch.isCurrent ? FontWeight.w600 : null)),
      subtitle: branch.upstream != null
          ? Text('-> ${branch.upstream}', style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing: branch.isCurrent
          ? null
          : PopupMenuButton<String>(
              onSelected: (v) => _onSelected(context, ref, v),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'checkout', child: Text(l.branchCheckout)),
                if (!branch.isRemote)
                  PopupMenuItem(value: 'delete', child: Text(l.branchDelete)),
              ],
            ),
      onTap: branch.isCurrent ? null : () => _checkout(context, ref),
    );
  }

  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    final repo = await ref.read(appConfigRepoProvider).load();
    final r = repo.repositories.firstWhere((e) => e.id == repoId);
    try {
      await ref.read(checkoutBranchProvider).call(r.localPath, branch.name);
      ref.invalidate(_branchesProvider(repoId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _onSelected(BuildContext context, WidgetRef ref, String action) async {
    if (action == 'checkout') {
      await _checkout(context, ref);
      return;
    }
    if (action == 'delete') {
      final l = AppLocalizations.of(context);
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l.branchDelete),
          content: Text('Delete ${branch.name}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.commonCancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.commonDelete)),
          ],
        ),
      );
      if (confirm == true) {
        final repo = await ref.read(appConfigRepoProvider).load();
        final r = repo.repositories.firstWhere((e) => e.id == repoId);
        try {
          await ref.read(deleteBranchProvider).call(r.localPath, branch.name);
          ref.invalidate(_branchesProvider(repoId));
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
          }
        }
      }
    }
  }
}