import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/git_providers.dart';
import '../../domain/entities/entities.dart';

class CommitDetailScreen extends ConsumerStatefulWidget {
  final String repoId;
  final String sha;

  const CommitDetailScreen({
    super.key,
    required this.repoId,
    required this.sha,
  });

  @override
  ConsumerState<CommitDetailScreen> createState() => _CommitDetailScreenState();
}

class _CommitDetailScreenState extends ConsumerState<CommitDetailScreen> {
  GitCommit? _commit;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCommit();
  }

  Future<void> _loadCommit() async {
    final repo = ref.read(currentRepoProvider);
    if (repo == null) return;

    try {
      final git = ref.read(gitServiceProvider);
      final log = await git.getLog(repo.localPath, limit: 200);
      final commit = log.firstWhere(
        (c) => c.sha == widget.sha || c.shortSha == widget.sha,
        orElse: () => throw Exception('未找到该提交'),
      );
      setState(() {
        _commit = commit;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sha.substring(0, 7)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('错误: $_error'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final c = _commit!;
    return ListView(
      children: [
        // Commit message
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey[900],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.message,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.blueGrey[700],
                    child: Text(
                      c.author.isNotEmpty ? c.author[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.author, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        Text(c.authorEmail, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Metadata
        _buildMetadataTile(Icons.tag, '提交', c.sha),
        _buildMetadataTile(Icons.access_time, '时间', _formatDateTime(c.timestamp)),
        if (c.parentShas.isNotEmpty)
          _buildMetadataTile(Icons.arrow_back, '父提交', c.parentShas.join(', ')),

        const Divider(height: 1),

        // File changes placeholder
        const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '文件变更详情需要 git_on_dart 支持 tree diff，当前版本暂不支持',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, size: 18, color: Colors.grey[500]),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
      ),
      dense: true,
    );
  }

  String _formatDateTime(DateTime t) {
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} '
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
  }
}
