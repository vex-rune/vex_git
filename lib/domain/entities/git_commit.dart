import 'package:equatable/equatable.dart';

class GitCommit extends Equatable {
  final String sha;
  final String message;
  final String author;
  final String authorEmail;
  final DateTime timestamp;
  final List<String> parentShas;

  const GitCommit({
    required this.sha,
    required this.message,
    required this.author,
    required this.authorEmail,
    required this.timestamp,
    this.parentShas = const [],
  });

  String get shortSha => sha.length >= 7 ? sha.substring(0, 7) : sha;

  @override
  List<Object?> get props => [sha];
}