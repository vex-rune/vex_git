import 'package:equatable/equatable.dart';

enum ChangeStatus { added, modified, deleted, renamed, copied }

class FileChange extends Equatable {
  final String path;
  final ChangeStatus status;
  final String? oldPath;
  final String? diff;

  const FileChange({
    required this.path,
    required this.status,
    this.oldPath,
    this.diff,
  });

  @override
  List<Object?> get props => [path, status, oldPath];
}