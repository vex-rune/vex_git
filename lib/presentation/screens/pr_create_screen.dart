import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';

class PullRequestCreateScreen extends ConsumerStatefulWidget {
  final String owner;
  final String repo;
  const PullRequestCreateScreen({super.key, required this.owner, required this.repo});

  @override
  ConsumerState<PullRequestCreateScreen> createState() => _PullRequestCreateScreenState();
}

class _PullRequestCreateScreenState extends ConsumerState<PullRequestCreateScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _head = '';
  String _base = 'main';
  bool _draft = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _head.isEmpty) {
      setState(() => _error = 'Title and head branch are required');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(createPrProvider).call(
            owner: widget.owner,
            repo: widget.repo,
            title: title,
            head: _head,
            base: _base,
            body: _bodyCtrl.text.trim().isEmpty ? null : _bodyCtrl.text.trim(),
            draft: _draft,
          );
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pull request created')),
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
      appBar: AppBar(
        title: Text(l.prCreate),
        actions: [
          TextButton(
            onPressed: _busy ? null : _create,
            child: Text(l.prCreate),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Head branch',
                        prefixIcon: Icon(Icons.call_split),
                      ),
                      onChanged: (v) => _head = v.trim(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.arrow_forward),
                  ),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: _base),
                      decoration: const InputDecoration(
                        labelText: 'Base branch',
                        prefixIcon: Icon(Icons.fork_right),
                      ),
                      onChanged: (v) => _base = v.trim(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bodyCtrl,
                maxLines: 8,
                minLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Draft'),
                value: _draft,
                onChanged: (v) => setState(() => _draft = v),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_error!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}