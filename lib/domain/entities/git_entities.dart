import 'package:equatable/equatable.dart';

class Commit extends Equatable {
  final String sha;
  final String? shortSha;
  final String message;
  final String? body;
  final String authorName;
  final String authorEmail;
  final DateTime authoredAt;
  final String? committerName;
  final String? committerEmail;
  final DateTime? committedAt;
  final List<String> parentShas;
  final List<String>? coAuthors;

  const Commit({
    required this.sha,
    this.shortSha,
    required this.message,
    this.body,
    required this.authorName,
    required this.authorEmail,
    required this.authoredAt,
    this.committerName,
    this.committerEmail,
    this.committedAt,
    this.parentShas = const [],
    this.coAuthors,
  });

  @override
  List<Object?> get props => [sha, message, authorName, authorEmail, authoredAt];
}

class Branch extends Equatable {
  final String name;
  final bool isRemote;
  final bool isCurrent;
  final bool isDefault;
  final String? upstream; // remote/branch
  final String? tipSha;
  final int aheadBy;
  final int behindBy;

  const Branch({
    required this.name,
    required this.isRemote,
    this.isCurrent = false,
    this.isDefault = false,
    this.upstream,
    this.tipSha,
    this.aheadBy = 0,
    this.behindBy = 0,
  });

  Branch copyWith({
    bool? isCurrent,
    bool? isDefault,
    String? upstream,
    int? aheadBy,
    int? behindBy,
  }) =>
      Branch(
        name: name,
        isRemote: isRemote,
        isCurrent: isCurrent ?? this.isCurrent,
        isDefault: isDefault ?? this.isDefault,
        upstream: upstream ?? this.upstream,
        tipSha: tipSha,
        aheadBy: aheadBy ?? this.aheadBy,
        behindBy: behindBy ?? this.behindBy,
      );

  @override
  List<Object?> get props => [name, isRemote, isCurrent, isDefault, upstream];
}

class FileChange extends Equatable {
  final String path;
  final FileChangeStatus status;
  final bool isStaged;
  final int additions;
  final int deletions;

  const FileChange({
    required this.path,
    required this.status,
    this.isStaged = false,
    this.additions = 0,
    this.deletions = 0,
  });

  FileChange copyWith({bool? isStaged, int? additions, int? deletions, FileChangeStatus? status}) =>
      FileChange(
        path: path,
        status: status ?? this.status,
        isStaged: isStaged ?? this.isStaged,
        additions: additions ?? this.additions,
        deletions: deletions ?? this.deletions,
      );

  @override
  List<Object?> get props => [path, status, isStaged, additions, deletions];
}

enum FileChangeStatus { added, modified, deleted, renamed, copied, untracked, conflicted, typeChanged }

class RepoStatus extends Equatable {
  final String branch;
  final String? upstream;
  final int aheadBy;
  final int behindBy;
  final List<FileChange> staged;
  final List<FileChange> unstaged;
  final List<FileChange> untracked;
  final bool hasConflicts;

  const RepoStatus({
    required this.branch,
    this.upstream,
    this.aheadBy = 0,
    this.behindBy = 0,
    this.staged = const [],
    this.unstaged = const [],
    this.untracked = const [],
    this.hasConflicts = false,
  });

  int get totalChanges =>
      staged.length + unstaged.length + untracked.length;

  List<FileChange> get all => [...staged, ...unstaged, ...untracked];

  @override
  List<Object?> get props => [branch, upstream, aheadBy, behindBy, staged, unstaged, untracked];
}

class DiffHunk extends Equatable {
  final int oldStart;
  final int oldLines;
  final int newStart;
  final int newLines;
  final List<DiffLine> lines;

  const DiffHunk({
    required this.oldStart,
    required this.oldLines,
    required this.newStart,
    required this.newLines,
    required this.lines,
  });

  @override
  List<Object?> get props => [oldStart, newStart, lines];
}

class DiffLine extends Equatable {
  final DiffLineKind kind;
  final String content;
  final int? oldLineNumber;
  final int? newLineNumber;

  const DiffLine({
    required this.kind,
    required this.content,
    this.oldLineNumber,
    this.newLineNumber,
  });

  @override
  List<Object?> get props => [kind, content, oldLineNumber, newLineNumber];
}

enum DiffLineKind { context, addition, deletion }

class FileDiff extends Equatable {
  final String path;
  final FileChangeStatus status;
  final bool isStaged;
  final List<DiffHunk> hunks;
  final bool isBinary;

  const FileDiff({
    required this.path,
    required this.status,
    required this.isStaged,
    this.hunks = const [],
    this.isBinary = false,
  });

  bool get isEmpty => hunks.isEmpty;

  @override
  List<Object?> get props => [path, status, isStaged, isBinary];
}

class StashEntry extends Equatable {
  final int index;
  final String message;
  final String branch;
  final DateTime createdAt;

  const StashEntry({
    required this.index,
    required this.message,
    required this.branch,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [index, message, branch, createdAt];
}

class ProgressEvent extends Equatable {
  final String phase; // "Receiving objects" / "Resolving deltas" ...
  final int current;
  final int? total;
  final String? message;

  const ProgressEvent({
    required this.phase,
    required this.current,
    this.total,
    this.message,
  });

  double? get ratio {
    if (total == null || total == 0) return null;
    return (current / total!).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [phase, current, total, message];
}