import 'package:equatable/equatable.dart';

enum BranchType { local, remote }

class GitBranch extends Equatable {
  final String name;
  final BranchType type;
  final bool isCurrent;
  final String? trackingBranch;

  const GitBranch({
    required this.name,
    required this.type,
    this.isCurrent = false,
    this.trackingBranch,
  });

  @override
  List<Object?> get props => [name, type];
}