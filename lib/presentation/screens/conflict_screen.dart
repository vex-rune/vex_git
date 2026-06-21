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
      final conflicts = <String>[];
      for (final change in changes) {
        if (change.status == ChangeStatus.modified) {
          final file = File('${repo.localPath}/${change.path}');
          if (await file.exists()) {
            try {
              final content = await file.readAsString();
              if (content.contains('<<<<<<<') ||
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

  Future<void> _commitResolution() async {
    final repo = ref.read(currentRepoProvider);
    if (repo == null) return;

    try {
      final git = ref.read(gitServiceProvider);
      // Stage all resolved files
      await git.stage(repo.localPath, _conflictFiles);
      // Create merge commit
      await git.commit(repo.localPath, 'Merge conflict resolution');
      ref.invalidate(statusProvider(repo.localPath));
      ref.invalidate(logProvider(repo.localPath));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('冲突解决并提交成功')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败: $e')),
        );
      }
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
        actions: [
          if (_conflictFiles.isNotEmpty)
            TextButton(
              onPressed: _commitResolution,
              child: const Text('提交解决'),
            ),
        ],
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
                  : Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          color: Colors.orange[900]?.withValues(alpha: 0.3),
                          child: Text(
                            '${_conflictFiles.length} 个文件存在冲突，点击文件编辑解决',
                            style: const TextStyle(fontSize: 12, color: Colors.orange),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
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
                        ),
                      ],
                    ),
    );
  }

  void _showConflictDetail(String path) {
    final repo = ref.read(currentRepoProvider);
    if (repo == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ConflictDetailPage(
          repoPath: repo.localPath,
          filePath: path,
          onResolved: () {
            _loadConflicts();
          },
        ),
      ),
    );
  }
}

/// 解析冲突标记，提取本地/远程内容
String _resolveWithLocal(String content) {
  final buffer = StringBuffer();
  var inConflict = false;
  var inRemote = false;

  for (final line in content.split('\n')) {
    if (line.startsWith('<<<<<<<')) {
      inConflict = true;
      inRemote = false;
      continue;
    }
    if (line.startsWith('=======')) {
      inRemote = true;
      continue;
    }
    if (line.startsWith('>>>>>>>')) {
      inConflict = false;
      inRemote = false;
      continue;
    }
    if (!inConflict || !inRemote) {
      buffer.writeln(line);
    }
  }
  return buffer.toString().trimRight();
}

String _resolveWithRemote(String content) {
  final buffer = StringBuffer();
  var inConflict = false;
  var inRemote = false;

  for (final line in content.split('\n')) {
    if (line.startsWith('<<<<<<<')) {
      inConflict = true;
      inRemote = false;
      continue;
    }
    if (line.startsWith('=======')) {
      inRemote = true;
      continue;
    }
    if (line.startsWith('>>>>>>>')) {
      inConflict = false;
      inRemote = false;
      continue;
    }
    if (!inConflict || inRemote) {
      buffer.writeln(line);
    }
  }
  return buffer.toString().trimRight();
}

class _ConflictDetailPage extends StatefulWidget {
  final String repoPath;
  final String filePath;
  final VoidCallback onResolved;

  const _ConflictDetailPage({
    required this.repoPath,
    required this.filePath,
    required this.onResolved,
  });

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
      final fullPath = '${widget.repoPath}/${widget.filePath}';
      final file = File(fullPath);
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

  void _resolveLocal() {
    final resolved = _resolveWithLocal(_controller.text);
    setState(() {
      _controller.text = resolved;
    });
  }

  void _resolveRemote() {
    final resolved = _resolveWithRemote(_controller.text);
    setState(() {
      _controller.text = resolved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.filePath.split('/').last;
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => _resolveLocal(),
            child: const Text('保留本地', style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () => _resolveRemote(),
            child: const Text('保留远程', style: TextStyle(color: Colors.blue)),
          ),
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
                  padding: const EdgeInsets.all(10),
                  color: Colors.orange[900]?.withValues(alpha: 0.3),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '可手动编辑，或点击顶部「保留本地/远程」快速解决',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
                // 冲突内容（带高亮）
                Expanded(
                  child: _ConflictEditor(controller: _controller),
                ),
              ],
            ),
    );
  }

  Future<void> _saveFile() async {
    try {
      final fullPath = '${widget.repoPath}/${widget.filePath}';
      final file = File(fullPath);
      await file.writeAsString(_controller.text);

      // 自动 stage 已解决的文件
      if (mounted) {
        try {
          final git = ProviderScope.containerOf(context).read(gitServiceProvider);
          await git.stage(widget.repoPath, [widget.filePath]);
        } catch (_) {}
      }

      widget.onResolved();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('文件已保存并暂存')),
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

/// 冲突内容编辑器，高亮冲突标记行
class _ConflictEditor extends StatelessWidget {
  final TextEditingController controller;

  const _ConflictEditor({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, _) {
        final lines = value.text.split('\n');
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: lines.length,
          itemBuilder: (_, i) {
            final line = lines[i];
            final isOurs = line.startsWith('<<<<<<<');
            final isSeparator = line.startsWith('=======');
            final isTheirs = line.startsWith('>>>>>>>');
            final isMarker = isOurs || isSeparator || isTheirs;

            Color? bgColor;
            Color? textColor;
            if (isOurs) {
              bgColor = Colors.green.withValues(alpha: 0.2);
              textColor = Colors.green[300];
            } else if (isSeparator) {
              bgColor = Colors.grey.withValues(alpha: 0.2);
              textColor = Colors.grey[400];
            } else if (isTheirs) {
              bgColor = Colors.blue.withValues(alpha: 0.2);
              textColor = Colors.blue[300];
            }

            return Container(
              color: bgColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      line,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.5,
                        color: textColor,
                        fontWeight: isMarker ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
