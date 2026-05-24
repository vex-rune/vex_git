import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../../domain/entities/entities.dart';

/// Recursive file tree widget for browsing a Git repository's current branch files.
class FileTreeWidget extends StatefulWidget {
  final Repository repo;
  final void Function(String path) onFileTap;

  const FileTreeWidget({
    super.key,
    required this.repo,
    required this.onFileTap,
  });

  @override
  State<FileTreeWidget> createState() => _FileTreeWidgetState();
}

class _FileTreeWidgetState extends State<FileTreeWidget> {
  final Map<String, List<FileSystemEntity>> _dirCache = {};
  final Set<String> _expandedDirs = {};
  bool _loading = true;
  String? _error;
  List<FileSystemEntity> _rootEntries = [];

  @override
  void initState() {
    super.initState();
    _loadRoot();
  }

  Future<void> _loadRoot() async {
    try {
      final dir = Directory(widget.repo.localPath);
      final entries = await dir.list().toList();
      entries.sort(_sortEntries);
      setState(() {
        _rootEntries = entries;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadDir(String path) async {
    if (_dirCache.containsKey(path)) return;
    try {
      final dir = Directory(path);
      final entries = await dir.list().toList();
      entries.sort(_sortEntries);
      setState(() {
        _dirCache[path] = entries;
      });
    } catch (e) {
      // Silently fail for permission errors
    }
  }

  int _sortEntries(FileSystemEntity a, FileSystemEntity b) {
    final aIsDir = a is Directory;
    final bIsDir = b is Directory;
    final aName = p.basename(a.path);
    final bName = p.basename(b.path);

    // Skip .git
    if (aName == '.git') return 1;
    if (bName == '.git') return -1;

    if (aIsDir && !bIsDir) return -1;
    if (!aIsDir && bIsDir) return 1;
    return aName.toLowerCase().compareTo(bName.toLowerCase());
  }

  void _toggleDir(String path) {
    setState(() {
      if (_expandedDirs.contains(path)) {
        _expandedDirs.remove(path);
      } else {
        _expandedDirs.add(path);
        _loadDir(path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('加载失败: $_error'));

    return ListView.builder(
      itemCount: _rootEntries.length,
      itemBuilder: (_, i) => _buildTile(_rootEntries[i], 0),
    );
  }

  Widget _buildTile(FileSystemEntity entity, int depth) {
    final name = p.basename(entity.path);
    final isDir = entity is Directory;
    final path = entity.path;
    final isExpanded = _expandedDirs.contains(path);

    // .git folder - skip
    if (name == '.git') return const SizedBox.shrink();

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(left: 16.0 + depth * 16.0, right: 8),
          leading: Icon(
            isDir
                ? (isExpanded ? Icons.folder_open : Icons.folder)
                : _iconForFile(name),
            color: isDir ? Colors.amber : _colorForFile(name),
            size: 20,
          ),
          title: Text(
            name,
            style: TextStyle(
              fontSize: 13,
              color: isDir ? Colors.white : Colors.grey[300],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: isDir
              ? IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                  onPressed: () => _toggleDir(path),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              : _buildFileSize(entity),
          onTap: () {
            if (isDir) {
              _toggleDir(path);
            } else {
              widget.onFileTap(path);
            }
          },
        ),
        if (isDir && isExpanded)
          _buildChildren(path, depth),
      ],
    );
  }

  Widget _buildChildren(String parentPath, int depth) {
    final entries = _dirCache[parentPath];
    if (entries == null) {
      return Padding(
        padding: EdgeInsets.only(left: 16.0 + (depth + 1) * 16.0),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (entries.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(left: 16.0 + (depth + 1) * 16.0),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Text('(空)', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: entries
          .where((e) => p.basename(e.path) != '.git')
          .map((e) => _buildTile(e, depth + 1))
          .toList(),
    );
  }

  Widget? _buildFileSize(FileSystemEntity entity) {
    if (entity is File) {
      try {
        final size = entity.lengthSync();
        if (size < 1024) return Text('${size}B', style: const TextStyle(fontSize: 11, color: Colors.grey));
        if (size < 1024 * 1024) return Text('${(size / 1024).toStringAsFixed(0)}KB', style: const TextStyle(fontSize: 11, color: Colors.grey));
        return Text('${(size / 1024 / 1024).toStringAsFixed(1)}MB', style: const TextStyle(fontSize: 11, color: Colors.grey));
      } catch (_) {}
    }
    return null;
  }

  IconData _iconForFile(String name) {
    if (name.endsWith('.dart')) return Icons.code;
    if (name.endsWith('.md')) return Icons.article_outlined;
    if (name.endsWith('.json')) return Icons.data_object;
    if (name.endsWith('.yaml') || name.endsWith('.yml')) return Icons.settings;
    if (name.endsWith('.txt') || name.endsWith('.log')) return Icons.text_snippet;
    if (name.endsWith('.png') || name.endsWith('.jpg') || name.endsWith('.gif') || name.endsWith('.svg') || name.endsWith('.webp')) return Icons.image;
    if (name.endsWith('.zip') || name.endsWith('.tar') || name.endsWith('.gz') || name.endsWith('.rar')) return Icons.archive;
    if (name.endsWith('.xml')) return Icons.code;
    if (name.endsWith('.html') || name.endsWith('.htm')) return Icons.web;
    if (name.endsWith('.css')) return Icons.css;
    if (name.endsWith('.js') || name.endsWith('.ts') || name.endsWith('.mjs')) return Icons.javascript;
    if (name.endsWith('.java') || name.endsWith('.kt') || name.endsWith('.kts')) return Icons.code;
    if (name.endsWith('.gradle')) return Icons.build;
    if (name.endsWith('.lock') || name.endsWith('.properties')) return Icons.lock_outline;
    if (name.endsWith('.gitignore') || name.endsWith('.editorconfig')) return Icons.settings;
    return Icons.insert_drive_file_outlined;
  }

  Color _colorForFile(String name) {
    if (name.endsWith('.dart')) return Colors.blue;
    if (name.endsWith('.md')) return Colors.teal;
    if (name.endsWith('.json')) return Colors.orange;
    if (name.endsWith('.yaml') || name.endsWith('.yml')) return Colors.orange;
    if (name.endsWith('.txt') || name.endsWith('.log')) return Colors.grey;
    if (name.endsWith('.png') || name.endsWith('.jpg') || name.endsWith('.gif') || name.endsWith('.svg') || name.endsWith('.webp')) return Colors.purple;
    if (name.endsWith('.zip') || name.endsWith('.tar') || name.endsWith('.gz') || name.endsWith('.rar')) return Colors.brown;
    if (name.endsWith('.html') || name.endsWith('.htm')) return Colors.orange;
    if (name.endsWith('.css')) return Colors.blue;
    if (name.endsWith('.js') || name.endsWith('.ts') || name.endsWith('.mjs')) return Colors.yellow;
    if (name.endsWith('.java') || name.endsWith('.kt') || name.endsWith('.kts')) return Colors.purple;
    return Colors.blueGrey;
  }
}