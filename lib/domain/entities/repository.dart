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
  final String? token;

  const Repository({
    required this.id,
    required this.name,
    this.description,
    required this.localPath,
    this.remoteUrl,
    required this.platform,
    required this.defaultBranch,
    required this.createdAt,
    this.token,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      localPath: json['localPath'] as String,
      remoteUrl: json['remoteUrl'] as String?,
      platform: GitPlatform.values.firstWhere(
        (e) => e.name == json['platform'],
        orElse: () => GitPlatform.unknown,
      ),
      defaultBranch: json['defaultBranch'] as String? ?? 'main',
      createdAt: DateTime.parse(json['createdAt'] as String),
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'localPath': localPath,
        'remoteUrl': remoteUrl,
        'platform': platform.name,
        'defaultBranch': defaultBranch,
        'createdAt': createdAt.toIso8601String(),
        if (token != null) 'token': token,
      };

  @override
  List<Object?> get props => [id, name, localPath, remoteUrl];
}