import 'package:equatable/equatable.dart';
import 'git_platform.dart';

class Repository extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String localPath;
  final String? remoteUrl;
  final GitPlatform platform;
  final String defaultBranch;
  final DateTime createdAt;

  const Repository({
    required this.id,
    required this.name,
    this.description,
    required this.localPath,
    this.remoteUrl,
    required this.platform,
    required this.defaultBranch,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, localPath, remoteUrl];
}