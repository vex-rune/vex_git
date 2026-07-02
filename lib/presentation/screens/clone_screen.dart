import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/app_paths.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';

class CloneScreen extends ConsumerStatefulWidget {
  const CloneScreen({super.key});

  @override
  ConsumerState<CloneScreen> createState() => _CloneScreenState();
}

class _CloneScreenState extends ConsumerState<CloneScreen> {
  final _urlCtrl = TextEditingController();
  final _pathCtrl = TextEditingController();
  String? _selectedAccountId;
  bool _cloning = false;
  String? _error;
  String? _progressLine;
  double? _progressRatio;

  @override
  void initState() {
    super.initState();
    _loadDefaultPath();
  }

  Future<void> _loadDefaultPath() async {
    final dir = await AppPaths.ensureReposDir();
    if (mounted) setState(() => _pathCtrl.text = dir.path);
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _pathCtrl.dispose();
    super.dispose();
  }

  Future<void> _clone() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'URL is required');
      return;
    }
    setState(() {
      _cloning = true;
      _error = null;
      _progressLine = 'Starting clone...';
      _progressRatio = null;
    });
    try {
      // 找到该 url 所属账户的 token（简化：直接用 active 的）
      final cfg = await ref.read(appConfigRepoProvider).load();
      final activeId = cfg.activeAccountId;
      String? token;
      if (activeId != null) {
        token = await ref.read(secureStoreProvider).readAccountToken(activeId);
      }
      final useCase = ref.read(cloneRepoProvider);
      // 进度订阅（best effort）
      // 简化版：调用 clone（同步等待）
      // Future 改造点：用 stream 替代同步 await
      await useCase.call(
        url: url,
        destPath: _pathCtrl.text.trim().isEmpty ? null : _pathCtrl.text.trim(),
        token: token,
      );
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clone successful')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _cloning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.repoClone)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _urlCtrl,
                decoration: InputDecoration(
                  labelText: l.repoCloneUrl,
                  hintText: 'https://github.com/owner/repo.git',
                  prefixIcon: const Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pathCtrl,
                decoration: InputDecoration(
                  labelText: l.repoClonePath,
                  hintText: 'Leave empty for default',
                  prefixIcon: const Icon(Icons.folder),
                ),
              ),
              const SizedBox(height: 16),
              Builder(builder: (context) {
                final cfg = ref.watch(configStreamProvider).value;
                if (cfg == null) return const SizedBox.shrink();
                return DropdownButtonFormField<String?>(
                  initialValue: _selectedAccountId ?? cfg.activeAccountId,
                  decoration: const InputDecoration(
                    labelText: 'Account',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('Public only (no auth)')),
                    ...cfg.accounts.map((a) => DropdownMenuItem<String?>(
                          value: a.id,
                          child: Text('@' + a.login + ' (' + a.host + ')'),
                        )),
                  ],
                  onChanged: _cloning ? null : (v) => setState(() => _selectedAccountId = v),
                );
              }),

              if (_cloning) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_progressLine ?? 'Working...'),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: _progressRatio),
                      ],
                    ),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!)),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),
              FilledButton.icon(
                onPressed: _cloning ? null : _clone,
                icon: _cloning
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_download),
                label: Text(l.repoCloneStart),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
