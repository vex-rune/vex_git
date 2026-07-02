import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/app_paths.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';

class CreateLocalScreen extends ConsumerStatefulWidget {
  const CreateLocalScreen({super.key});

  @override
  ConsumerState<CreateLocalScreen> createState() => _CreateLocalScreenState();
}

class _CreateLocalScreenState extends ConsumerState<CreateLocalScreen> {
  final _nameCtrl = TextEditingController();
  final _pathCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPath();
  }

  Future<void> _loadPath() async {
    final dir = await AppPaths.ensureReposDir();
    if (mounted) setState(() => _pathCtrl.text = dir.path);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pathCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final useCase = ref.read(createLocalRepoProvider);
      await useCase.call(name: _nameCtrl.text.trim(), parentPath: _pathCtrl.text.trim());
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repository created')),
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
      appBar: AppBar(title: Text(l.repoCreate)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: l.repoCreateName,
                  hintText: 'my-project',
                  prefixIcon: const Icon(Icons.book_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pathCtrl,
                decoration: InputDecoration(
                  labelText: l.repoCreatePath,
                  prefixIcon: const Icon(Icons.folder),
                ),
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
                onPressed: _busy ? null : _create,
                icon: const Icon(Icons.add),
                label: Text(l.repoCreateInit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}