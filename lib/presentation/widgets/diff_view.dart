import 'package:flutter/material.dart';

import '../../domain/entities/git_entities.dart';

class DiffView extends StatelessWidget {
  final List<FileDiff> diffs;
  const DiffView({super.key, required this.diffs});

  @override
  Widget build(BuildContext context) {
    if (diffs.isEmpty) {
      return const Center(child: Text('No changes'));
    }
    return ListView.builder(
      itemCount: diffs.length,
      itemBuilder: (_, i) => _FileDiffBlock(diff: diffs[i]),
    );
  }
}

class _FileDiffBlock extends StatelessWidget {
  final FileDiff diff;
  const _FileDiffBlock({required this.diff});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
        leading: Icon(_statusIcon(diff.status), color: _statusColor(diff.status)),
        title: Text(diff.path, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: diff.isBinary ? const Text('Binary file') : null,
        children: diff.isBinary
            ? const []
            : diff.hunks
                .map((h) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: h.lines
                            .map((ln) => _DiffLineRow(line: ln))
                            .toList(),
                      ),
                    ))
                .toList(),
      ),
    );
  }
}

class _DiffLineRow extends StatelessWidget {
  final DiffLine line;
  const _DiffLineRow({required this.line});

  @override
  Widget build(BuildContext context) {
    Color? bg;
    String prefix = ' ';
    if (line.kind == DiffLineKind.addition) {
      bg = Colors.green.withValues(alpha: 0.12);
      prefix = '+';
    } else if (line.kind == DiffLineKind.deletion) {
      bg = Colors.red.withValues(alpha: 0.12);
      prefix = '-';
    }
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              '${line.newLineNumber ?? line.oldLineNumber ?? ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontFamily: 'monospace',
                  ),
            ),
          ),
          SizedBox(
            width: 16,
            child: Text(
              prefix,
              style: TextStyle(
                fontFamily: 'monospace',
                color: line.kind == DiffLineKind.addition
                    ? Colors.green
                    : line.kind == DiffLineKind.deletion
                        ? Colors.red
                        : null,
              ),
            ),
          ),
          Expanded(
            child: Text(
              line.content,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _statusIcon(FileChangeStatus s) {
  return switch (s) {
    FileChangeStatus.added => Icons.add_circle_outline,
    FileChangeStatus.modified => Icons.edit_outlined,
    FileChangeStatus.deleted => Icons.delete_outline,
    FileChangeStatus.renamed => Icons.drive_file_rename_outline,
    FileChangeStatus.copied => Icons.copy_all_outlined,
    FileChangeStatus.untracked => Icons.help_outline,
    FileChangeStatus.conflicted => Icons.warning_amber_outlined,
    FileChangeStatus.typeChanged => Icons.change_circle_outlined,
  };
}

Color _statusColor(FileChangeStatus s) {
  return switch (s) {
    FileChangeStatus.added => Colors.green,
    FileChangeStatus.modified => Colors.orange,
    FileChangeStatus.deleted => Colors.red,
    FileChangeStatus.untracked => Colors.blueGrey,
    FileChangeStatus.conflicted => Colors.red,
    _ => Colors.grey,
  };
}