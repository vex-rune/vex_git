import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';

class FileViewerScreen extends ConsumerStatefulWidget {
  final String repoId;
  final String path;
  const FileViewerScreen({super.key, required this.repoId, required this.path});

  @override
  ConsumerState<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends ConsumerState<FileViewerScreen> {
  String? _content;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final file = File(widget.path);
      if (await file.exists()) {
        final c = await file.readAsString();
        if (mounted) setState(() => _content = c);
      } else {
        if (mounted) setState(() => _error = 'File not found');
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path.split(Platform.pathSeparator).last),
      ),
      body: _error != null
          ? Center(child: Text('${l.commonError}: $_error'))
          : _content == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _content!,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  ),
                ),
    );
  }
}