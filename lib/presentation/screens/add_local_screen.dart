import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';

class AddLocalScreen extends ConsumerStatefulWidget {
  const AddLocalScreen({super.key});

  @override
  ConsumerState<AddLocalScreen> createState() => _AddLocalScreenState();
}

class _AddLocalScreenState extends ConsumerState<AddLocalScreen> {
  final _pathCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _pathCtrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final path = _pathCtrl.text.trim();
    if (path.isEmpty) {
      setState(() => _error = 'Path is required');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(addLocalRepoProvider).call(path);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repository added')),
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
    return Scaffold(
      appBar: AppBar(title: Text(l.repoAddExisting)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _pathCtrl,
                decoration: InputDecoration(
                  labelText: 'Repository path',
                  hintText: Platform.isWindows ? r'C:\path\to\repo' : '/path/to/repo',
                  prefixIcon: const Icon(Icons.folder_open),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pick a folder that already contains a .git directory.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              if (_error != null)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_error!),
                  ),
                ),
              FilledButton.icon(
                onPressed: _busy ? null : _add,
                icon: const Icon(Icons.add),
                label: Text(l.repoAdd),
              ),
            ],
          ),
        ),
      ),
    );
  }
}