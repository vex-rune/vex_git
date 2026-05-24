import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import '../../application/providers/git_providers.dart';
import '../../domain/entities/entities.dart';

class FileViewerScreen extends ConsumerStatefulWidget {
  final String repoId;
  final String filePath;
  final bool isDir;

  const FileViewerScreen({
    super.key,
    required this.repoId,
    required this.filePath,
    this.isDir = false,
  });

  @override
  ConsumerState<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends ConsumerState<FileViewerScreen> {
  List<FileSystemEntity> _entries = [];
  String? _fileContent;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final repo = ref.read(currentRepoProvider);
    if (repo == null) return;

    try {
      if (widget.isDir || widget.filePath.isEmpty) {
        final dirPath = widget.filePath.isEmpty ? repo.localPath : widget.filePath;
        final dir = Directory(dirPath);
        final entries = await dir.list().toList();
        // Sort: directories first, then files, both alphabetically
        entries.sort((a, b) {
          final aIsDir = a is Directory;
          final bIsDir = b is Directory;
          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;
          return p.basename(a.path).compareTo(p.basename(b.path));
        });
        setState(() {
          _entries = entries;
          _loading = false;
        });
      } else {
        // Read file content
        final file = File(widget.filePath);
        if (await file.exists()) {
          final content = await file.readAsString();
          setState(() {
            _fileContent = content;
            _loading = false;
          });
        } else {
          setState(() {
            _fileContent = '(二进制文件或无法读取)';
            _loading = false;
          });
        }
      }
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
        title: Text(
          widget.filePath.isEmpty
              ? repo?.name ?? '文件浏览'
              : p.basename(widget.filePath),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!widget.isDir && _fileContent != null)
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: '复制内容',
              onPressed: () {
                // TODO: copy to clipboard
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已复制')),
                );
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('错误: $_error'))
              : widget.isDir || widget.filePath.isEmpty
                  ? _buildDirView(repo)
                  : _buildFileView(),
    );
  }

  Widget _buildDirView(Repository? repo) {
    if (_entries.isEmpty) {
      return const Center(
        child: Text('空目录', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      itemCount: _entries.length,
      itemBuilder: (_, i) {
        final entry = _entries[i];
        final isDir = entry is Directory;
        final name = p.basename(entry.path);

        // Skip .git directory
        if (name == '.git') return const SizedBox.shrink();

        return ListTile(
          leading: Icon(
            isDir ? Icons.folder : _iconForFile(name),
            color: isDir ? Colors.amber : Colors.blueGrey,
          ),
          title: Text(name),
          trailing: isDir
              ? const Icon(Icons.chevron_right, color: Colors.grey)
              : Text(
                  _formatSize(entry),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
          onTap: () => _openEntry(entry, isDir),
        );
      },
    );
  }

  Widget _buildFileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        _fileContent ?? '',
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.6,
        ),
      ),
    );
  }

  Future<void> _openEntry(FileSystemEntity entry, bool isDir) async {
    if (isDir) {
      context.push('/repo/${widget.repoId}/file?path=${Uri.encodeComponent(entry.path)}');
    } else {
      context.push('/repo/${widget.repoId}/file?path=${Uri.encodeComponent(entry.path)}');
    }
  }

  IconData _iconForFile(String name) {
    if (name.endsWith('.dart')) return Icons.code;
    if (name.endsWith('.md')) return Icons.article;
    if (name.endsWith('.json')) return Icons.data_object;
    if (name.endsWith('.yaml') || name.endsWith('.yml')) return Icons.settings;
    if (name.endsWith('.txt')) return Icons.text_snippet;
    if (name.endsWith('.png') || name.endsWith('.jpg') || name.endsWith('.gif') || name.endsWith('.svg')) return Icons.image;
    if (name.endsWith('.zip') || name.endsWith('.tar') || name.endsWith('.gz')) return Icons.archive;
    if (name.endsWith('.xml')) return Icons.code;
    if (name.endsWith('.html') || name.endsWith('.css') || name.endsWith('.js')) return Icons.web;
    return Icons.insert_drive_file;
  }

  String _formatSize(FileSystemEntity entity) {
    if (entity is File) {
      try {
        final size = entity.lengthSync();
        if (size < 1024) return '${size}B';
        if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
        return '${(size / 1024 / 1024).toStringAsFixed(1)}MB';
      } catch (_) {}
    }
    return '';
  }
}