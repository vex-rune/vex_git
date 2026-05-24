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
  List<_ChangedFile> _changedFiles = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDiff();
  }

  Future<void> _loadDiff() async {
    final repo = ref.read(currentRepoProvider);
    if (repo == null) return;

    try {
      final git = ref.read(gitServiceProvider);
      final log = await git.getLog(repo.localPath, limit: 100);
      final commit = log.firstWhere(
        (c) => c.sha == widget.sha || c.shortSha == widget.sha,
        orElse: () => throw Exception('Commit not found'),
      );

      // For now, show a simplified view since git_on_dart doesn't support diff
      // In a full implementation, we'd parse the commit tree and compare with parents
      setState(() {
        _changedFiles = [
          _ChangedFile(path: '(commit content)', oldContent: '', newContent: commit.message),
        ];
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
    final repo = ref.watch(currentRepoProvider);

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
              : Column(
                  children: [
                    // Commit info header
                    if (repo != null) _buildCommitHeader(repo),
                    const Divider(height: 1),
                    // Changed files list
                    Expanded(
                      child: ListView.builder(
                        itemCount: _changedFiles.length,
                        itemBuilder: (_, i) => _buildFileItem(_changedFiles[i]),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildCommitHeader(Repository repo) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blueGrey[700],
                child: const Icon(Icons.person, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commit ${widget.sha.substring(0, 7)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatTime(DateTime.now()),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '文件变更预览（详细 diff 开发中）',
            style: TextStyle(fontSize: 12, color: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(_ChangedFile file) {
    return ExpansionTile(
      leading: Icon(
        _iconForPath(file.path),
        color: Colors.blueGrey,
        size: 20,
      ),
      title: Text(
        file.path,
        style: const TextStyle(fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File path header
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.description, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        file.path,
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content preview
              Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  (file.newContent ?? '').isEmpty ? '(空文件)' : file.newContent ?? '',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  IconData _iconForPath(String path) {
    if (path.endsWith('.dart')) return Icons.code;
    if (path.endsWith('.md')) return Icons.article;
    if (path.endsWith('.json')) return Icons.data_object;
    if (path.endsWith('.yaml') || path.endsWith('.yml')) return Icons.settings;
    if (path.endsWith('.txt')) return Icons.text_snippet;
    if (path.endsWith('.png') || path.endsWith('.jpg') || path.endsWith('.svg')) return Icons.image;
    return Icons.insert_drive_file;
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 30) return '${diff.inDays}天前';
    return '${t.month}/${t.day}';
  }
}

class _ChangedFile {
  final String path;
  final String? oldContent;
  final String? newContent;

  _ChangedFile({
    required this.path,
    this.oldContent,
    this.newContent,
  });
}