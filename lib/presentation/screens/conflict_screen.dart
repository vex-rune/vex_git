import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/git_providers.dart';
import '../../domain/entities/entities.dart';

class ConflictScreen extends ConsumerStatefulWidget {
  final String repoId;

  const ConflictScreen({super.key, required this.repoId});

  @override
  ConsumerState<ConflictScreen> createState() => _ConflictScreenState();
}

class _ConflictScreenState extends ConsumerState<ConflictScreen> {
  List<String> _conflictFiles = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConflicts();
  }

  Future<void> _loadConflicts() async {
    final repo = ref.read(currentRepoProvider);
    if (repo == null) return;

    try {
      final git = ref.read(gitServiceProvider);
      final changes = await git.getStatus(repo.localPath);
      // 冲突文件通常状态为 modified（CONFLICT）
      // 由于 git_on_dart 可能不直接标记冲突，我们通过检查文件内容中的冲突标记来检测
      final conflicts = <String>[];
      for (final change in changes) {
        if (change.status == ChangeStatus.modified) {
          final file = File('${repo.localPath}/${change.path}');
          if (await file.exists()) {
            try {
              final content = await file.readAsString();
              if (content.contains('<<<<<<<') ||
                  content.contains('=======') ||
                  content.contains('>>>>>>>')) {
                conflicts.add(change.path);
              }
            } catch (_) {}
          }
        }
      }
      setState(() {
        _conflictFiles = conflicts;
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
        title: const Text('冲突处理'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('错误: $_error'))
              : _conflictFiles.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 48, color: Colors.green),
                          SizedBox(height: 12),
                          Text('没有冲突文件', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _conflictFiles.length,
                      itemBuilder: (_, i) {
                        final path = _conflictFiles[i];
                        return ListTile(
                          leading: const Icon(Icons.warning, color: Colors.orange),
                          title: Text(path, style: const TextStyle(fontSize: 13)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showConflictDetail(path),
                        );
                      },
                    ),
    );
  }

  void _showConflictDetail(String path) {
    final repo = ref.read(currentRepoProvider);
    if (repo == null) return;

    final file = File('${repo.localPath}/$path');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ConflictDetailPage(
          filePath: file.path,
          onResolved: () {
            _loadConflicts();
          },
        ),
      ),
    );
  }
}

class _ConflictDetailPage extends StatefulWidget {
  final String filePath;
  final VoidCallback onResolved;

  const _ConflictDetailPage({required this.filePath, required this.onResolved});

  @override
  State<_ConflictDetailPage> createState() => _ConflictDetailPageState();
}

class _ConflictDetailPageState extends State<_ConflictDetailPage> {
  String? _content;
  bool _loading = true;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      final file = File(widget.filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          _content = content;
          _controller.text = content;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _content = '无法读取文件: $e';
        _controller.text = _content!;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.filePath.split('/').last;
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: _saveFile,
            child: const Text('保存'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 冲突说明
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.orange[900]?.withValues(alpha: 0.3),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '编辑文件移除冲突标记（<<<<<<<、=======、>>>>>>>）后保存',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
                // 编辑器
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _saveFile() async {
    try {
      final file = File(widget.filePath);
      await file.writeAsString(_controller.text);
      widget.onResolved();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('文件已保存')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }
}
