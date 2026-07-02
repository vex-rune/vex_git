import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

class ConflictScreen extends ConsumerWidget {
  final String repoId;
  const ConflictScreen({super.key, required this.repoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.conflictTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Conflicts detected. Choose a resolution for each file.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('README.md'),
              subtitle: const Text('<<<<<<< HEAD\n...'),
              trailing: PopupMenuButton<String>(
                onSelected: (v) {},
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'local', child: Text(l.conflictKeepLocal)),
                  PopupMenuItem(value: 'remote', child: Text(l.conflictKeepRemote)),
                  PopupMenuItem(value: 'both', child: Text(l.conflictKeepBoth)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Abort'),
                  onPressed: () => context.pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Commit resolution'),
                  onPressed: () => context.pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}