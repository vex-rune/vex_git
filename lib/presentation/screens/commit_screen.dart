import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/app_config.dart';
import '../../domain/entities/git_entities.dart';
import '../../domain/repositories/git_client.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';

final _statusProvider = FutureProvider.family<RepoStatus, String>((ref, repoId) async {
  final repo = await ref.read(appConfigRepoProvider).load();
  final r = repo.repositories.firstWhere(
    (e) => e.id == repoId,
    orElse: () => RepoConfig(id: '', name: '', localPath: '', addedAt: DateTime.fromMillisecondsSinceEpoch(0)),
  );
  if (r.id.isEmpty || r.localPath.isEmpty) {
    return const RepoStatus(branch: '');
  }
  return ref.read(getRepoStatusProvider).call(r.localPath);
});

class CommitScreen extends ConsumerStatefulWidget {
  final String repoId;
  const CommitScreen({super.key, required this.repoId});

  @override
  ConsumerState<CommitScreen> createState() => _CommitScreenState();
}

class _CommitScreenState extends ConsumerState<CommitScreen> {
  final _messageCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _coAuthorCtrl = TextEditingController();
  bool _amend = false;
  bool _signOff = false;
  bool _busy = false;
  String? _error;
  final Set<String> _selected = {};

  @override
  void dispose() {
    _messageCtrl.dispose();
    _descriptionCtrl.dispose();
    _coAuthorCtrl.dispose();
    super.dispose();
  }

  Future<void> _commit() async {
    final msg = _messageCtrl.text.trim();
    if (msg.isEmpty) {
      setState(() => _error = 'Commit message is required');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = await ref.read(appConfigRepoProvider).load();
      final r = repo.repositories.firstWhere((e) => e.id == widget.repoId);
      final coAuthors = _coAuthorCtrl.text
          .split(RegExp(r'[\n,;]'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      await ref.read(createCommitProvider).call(
            r.localPath,
            CommitOptions(
              message: msg,
              description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
              amend: _amend,
              signOff: _signOff,
              coAuthors: coAuthors,
            ),
          );
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Committed')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(_statusProvider(widget.repoId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l.changesCommit),
        actions: [
          TextButton(
            onPressed: _busy ? null : _commit,
            child: Text(l.changesCommit),
          ),
        ],
      ),
      body: async.when(
        data: (status) {
          final allChanges = [
            ...status.staged,
            ...status.unstaged,
            ...status.untracked,
          ];
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    if (allChanges.isNotEmpty) ...[
                      _SectionHeader(
                        title: '${l.changesStaged} (${status.staged.length}) / ${l.changesWorking} (${allChanges.length - status.staged.length})',
                        actions: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                if (_selected.length == allChanges.length) {
                                  _selected.clear();
                                } else {
                                  _selected
                                    ..clear()
                                    ..addAll(allChanges.map((c) => c.path));
                                }
                              });
                            },
                            icon: Icon(_selected.length == allChanges.length
                                ? Icons.deselect
                                : Icons.select_all),
                            label: Text(_selected.length == allChanges.length
                                ? l.changesDeselectAll
                                : l.changesSelectAll),
                          ),
                        ],
                      ),
                      for (final c in allChanges)
                        CheckboxListTile(
                          dense: true,
                          value: c.isStaged || _selected.contains(c.path),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selected.add(c.path);
                              } else {
                                _selected.remove(c.path);
                              }
                            });
                          },
                          title: Text(c.path, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(_statusLabel(c.status, l), style: Theme.of(context).textTheme.bodySmall),
                          secondary: Icon(_statusIcon(c.status), color: _statusColor(context, c.status)),
                        ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(child: Text(l.changesNoChanges)),
                      ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _messageCtrl,
                            maxLines: 3,
                            minLines: 1,
                            decoration: InputDecoration(labelText: l.changesCommitMessage),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _descriptionCtrl,
                            maxLines: 4,
                            minLines: 2,
                            decoration: InputDecoration(labelText: l.changesCommitDescription),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _coAuthorCtrl,
                            decoration: InputDecoration(
                              labelText: l.changesCommitCoAuthor,
                              hintText: 'name <email>',
                            ),
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            dense: true,
                            value: _amend,
                            onChanged: (v) => setState(() => _amend = v ?? false),
                            title: Text(l.changesCommitAmend),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: _signOff,
                            onChanged: (v) => setState(() => _signOff = v ?? false),
                            title: const Text('Sign off (Signed-off-by)'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null)
                Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.errorContainer,
                  padding: const EdgeInsets.all(12),
                  child: Text(_error!),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  const _SectionHeader({required this.title, this.actions = const []});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

String _statusLabel(FileChangeStatus s, AppLocalizations l) {
  return switch (s) {
    FileChangeStatus.added => 'A',
    FileChangeStatus.modified => 'M',
    FileChangeStatus.deleted => 'D',
    FileChangeStatus.renamed => 'R',
    FileChangeStatus.copied => 'C',
    FileChangeStatus.untracked => '?',
    FileChangeStatus.conflicted => '!',
    FileChangeStatus.typeChanged => 'T',
  };
}

IconData _statusIcon(FileChangeStatus s) {
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

Color _statusColor(BuildContext context, FileChangeStatus s) {
  return switch (s) {
    FileChangeStatus.added => Colors.green,
    FileChangeStatus.modified => Colors.orange,
    FileChangeStatus.deleted => Colors.red,
    FileChangeStatus.untracked => Colors.blueGrey,
    FileChangeStatus.conflicted => Colors.red,
    _ => Theme.of(context).colorScheme.outline,
  };
}