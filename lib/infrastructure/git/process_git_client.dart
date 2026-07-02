import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../core/errors/exceptions.dart';
import '../../domain/entities/git_entities.dart';
import '../../domain/repositories/git_client.dart';

class ProcessGitClient implements GitClient {
  ProcessGitClient({this.gitExecutable = 'git'});

  final String gitExecutable;
  final Map<String, _RunningOperation> _running = {};
  static const _envTokenKey = 'VEX_GIT_TOKEN';

  @override
  Future<({bool available, String? version})> probeGit() async {
    try {
      final r = await _run(['--version'], workingDir: null);
      if (r.exitCode == 0) {
        return (available: true, version: r.stdout.trim());
      }
      return (available: false, version: null);
    } catch (_) {
      return (available: false, version: null);
    }
  }

  @override
  Future<void> init({required String path, bool bare = false}) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final args = ['init'];
    if (bare) args.add('--bare');
    final r = await _run(args, workingDir: path);
    if (r.exitCode != 0) {
      throw GitException('git init failed: ${r.stderr}');
    }
  }

  @override
  Stream<ProgressEvent> clone(CloneOptions options) {
    return _runStream(
      'clone',
      [
        if (options.depth != null) ...['--depth', '${options.depth}'],
        if (options.branch != null) ...['-b', options.branch!],
        if (options.bare) '--bare',
        options.url,
        options.localPath,
      ],
      workingDir: null,
      extraEnv: _authEnv(options.token, options.sshKeyName),
    );
  }

  @override
  Future<RepoStatus> status(String repoPath) async {
    await _ensureRepo(repoPath);
    final r = await _run(['status', '--porcelain=v2', '--branch', '--ahead-behind'],
        workingDir: repoPath);
    if (r.exitCode != 0) {
      throw GitException('git status failed: ${r.stderr}');
    }
    return _parseStatus(r.stdout);
  }

  @override
  Stream<RepoStatus> watch(String repoPath, {Duration interval = const Duration(seconds: 2)}) async* {
    yield await status(repoPath);
    while (true) {
      await Future<void>.delayed(interval);
      try {
        yield await status(repoPath);
      } catch (_) {
        // 静默：仓库可能被外部删除
      }
    }
  }

  @override
  Future<List<Commit>> log(
    String repoPath, {
    int? maxCount,
    String? branch,
    String? pathFilter,
    String? authorFilter,
  }) async {
    await _ensureRepo(repoPath);
    final args = [
      'log',
      '--pretty=format:__VEX_GIT_JSON__%n{'
          '"sha":"%H",'
          '"shortSha":"%h",'
          '"message":"%s",'
          '"body":"%b",'
          '"authorName":"%an",'
          '"authorEmail":"%ae",'
          '"authoredAt":"%aI",'
          '"committerName":"%cn",'
          '"committerEmail":"%ce",'
          '"committedAt":"%cI",'
          '"parents":"%P"'
          '}',
    ];
    if (maxCount != null) {
      args.addAll(['-n', '$maxCount']);
    }
    if (branch != null) args.add(branch);
    if (pathFilter != null) {
      args.addAll(['--', pathFilter]);
    }
    final r = await _run(args, workingDir: repoPath);
    if (r.exitCode != 0) {
      throw GitException('git log failed: ${r.stderr}');
    }
    return _parseLog(r.stdout);
  }

  @override
  Future<Commit?> showCommit(String repoPath, String sha) async {
    await _ensureRepo(repoPath);
    final r = await _run(
      [
        'show',
        '--pretty=format:__VEX_GIT_JSON__%n{'
            '"sha":"%H",'
            '"shortSha":"%h",'
            '"message":"%s",'
            '"body":"%b",'
            '"authorName":"%an",'
            '"authorEmail":"%ae",'
            '"authoredAt":"%aI",'
            '"committerName":"%cn",'
            '"committerEmail":"%ce",'
            '"committedAt":"%cI",'
            '"parents":"%P"'
            '}',
        '--numstat',
        '-z',
        '--no-renames',
        sha,
      ],
      workingDir: repoPath,
    );
    if (r.exitCode != 0) return null;
    return _parseShowCommit(r.stdout);
  }

  @override
  Future<List<FileDiff>> diff(
    String repoPath, {
    bool staged = false,
    String? pathFilter,
    String? ref1,
    String? ref2,
  }) async {
    await _ensureRepo(repoPath);
    final args = ['diff', '--no-color', '--unified=3'];
    if (staged) args.add('--staged');
    if (ref1 != null && ref2 != null) {
      args.addAll([ref1, ref2]);
    } else if (ref1 != null) {
      args.add(ref1);
    }
    if (pathFilter != null) args.addAll(['--', pathFilter]);
    final r = await _run(args, workingDir: repoPath);
    if (r.exitCode != 0 && r.exitCode != 1) {
      // 1 = 有差异，正常
      throw GitException('git diff failed: ${r.stderr}');
    }
    return _parseDiff(r.stdout);
  }

  @override
  Future<void> stage(String repoPath, List<String> paths) async {
    if (paths.isEmpty) return;
    final r = await _run(['add', '--', ...paths], workingDir: repoPath);
    if (r.exitCode != 0) throw GitException('git add failed: ${r.stderr}');
  }

  @override
  Future<void> unstage(String repoPath, List<String> paths) async {
    if (paths.isEmpty) return;
    final r = await _run(
      ['reset', 'HEAD', '--', ...paths],
      workingDir: repoPath,
    );
    if (r.exitCode != 0) throw GitException('git reset failed: ${r.stderr}');
  }

  @override
  Future<void> stageAll(String repoPath) async {
    final r = await _run(['add', '-A'], workingDir: repoPath);
    if (r.exitCode != 0) throw GitException('git add failed: ${r.stderr}');
  }

  @override
  Future<void> unstageAll(String repoPath) async {
    final r = await _run(['reset', 'HEAD'], workingDir: repoPath);
    if (r.exitCode != 0) throw GitException('git reset failed: ${r.stderr}');
  }

  @override
  Future<void> discard(String repoPath, List<String> paths) async {
    if (paths.isEmpty) return;
    final r = await _run(['checkout', '--', ...paths], workingDir: repoPath);
    if (r.exitCode != 0) throw GitException('git checkout failed: ${r.stderr}');
  }

  @override
  Future<void> discardAll(String repoPath) async {
    final r = await _run(['checkout', '.'], workingDir: repoPath);
    if (r.exitCode != 0) throw GitException('git checkout failed: ${r.stderr}');
  }

  @override
  Future<Commit> commit(String repoPath, CommitOptions options) async {
    await _ensureRepo(repoPath);
    final msgFile = await _writeCommitMessageFile(repoPath, options);
    try {
      final args = ['commit', '-F', msgFile.path];
      if (options.amend) args.add('--amend');
      if (options.signOff) args.add('--signoff');
      final env = <String, String>{};
      if (options.authorName != null) env['GIT_AUTHOR_NAME'] = options.authorName!;
      if (options.authorEmail != null) env['GIT_AUTHOR_EMAIL'] = options.authorEmail!;
      env['GIT_COMMITTER_NAME'] = options.authorName ?? 'Vex Git';
      env['GIT_COMMITTER_EMAIL'] = options.authorEmail ?? 'vex@local';
      final r = await _run(args, workingDir: repoPath, extraEnv: env);
      if (r.exitCode != 0) throw GitException('git commit failed: ${r.stderr}');
      final head = await _run(['rev-parse', 'HEAD'], workingDir: repoPath);
      final show = await showCommit(repoPath, head.stdout.trim());
      if (show == null) throw GitException('commit succeeded but show returned null');
      return show;
    } finally {
      if (await msgFile.exists()) await msgFile.delete();
    }
  }

  @override
  Future<List<Branch>> listBranches(String repoPath) async {
    await _ensureRepo(repoPath);
    final r = await _run(
      [
        'for-each-ref',
        '--format=%(HEAD)%(refname:short)%(upstream:short)%(upstream:track)%(objectname)',
        'refs/heads',
        'refs/remotes',
      ],
      workingDir: repoPath,
    );
    if (r.exitCode != 0) throw GitException('git branch failed: ${r.stderr}');
    return _parseBranches(r.stdout);
  }

  @override
  Future<void> checkout(String repoPath, String target, {bool create = false}) async {
    final args = ['checkout'];
    if (create) args.add('-b');
    args.add(target);
    final r = await _run(args, workingDir: repoPath);
    if (r.exitCode != 0) throw GitException('git checkout failed: ${r.stderr}');
  }

  @override
  Future<Branch> createBranch(String repoPath, String name, {String? from}) async {
    final args = ['checkout', '-b', name];
    if (from != null) args.add(from);
    final r = await _run(args, workingDir: repoPath);
    if (r.exitCode != 0) throw GitException('git branch create failed: ${r.stderr}');
    return const Branch(name: '', isRemote: false);
  }

  @override
  Future<void> deleteBranch(String repoPath, String name, {bool force = false, bool remote = false}) async {
    if (remote) {
      final r = await _run(['push', 'origin', '--delete', name], workingDir: repoPath);
      if (r.exitCode != 0) throw GitException('git push --delete failed: ${r.stderr}');
    } else {
      final r = await _run(['branch', force ? '-D' : '-d', name], workingDir: repoPath);
      if (r.exitCode != 0) throw GitException('git branch -d failed: ${r.stderr}');
    }
  }

  @override
  Future<List<String>> listRemotes(String repoPath) async {
    final r = await _run(['remote'], workingDir: repoPath);
    if (r.exitCode != 0) return const [];
    return r.stdout.split('\n').where((s) => s.isNotEmpty).toList();
  }

  @override
  Future<void> addRemote(String repoPath, String name, String url) async {
    final r = await _run(['remote', 'add', name, url], workingDir: repoPath);
    if (r.exitCode != 0) throw GitException('git remote add failed: ${r.stderr}');
  }

  @override
  Future<void> removeRemote(String repoPath, String name) async {
    final r = await _run(['remote', 'remove', name], workingDir: repoPath);
    if (r.exitCode != 0) throw GitException('git remote remove failed: ${r.stderr}');
  }

  @override
  Future<void> setRemoteUrl(String repoPath, String name, String url) async {
    final r = await _run(['remote', 'set-url', name, url], workingDir: repoPath);
    if (r.exitCode != 0) throw GitException('git remote set-url failed: ${r.stderr}');
  }

  @override
  Stream<ProgressEvent> fetch(String repoPath, {String? remote, String? token, String? sshKeyName}) {
    final args = ['fetch', '--progress', if (remote != null) remote];
    return _runStream('fetch', args, workingDir: repoPath, extraEnv: _authEnv(token, sshKeyName));
  }

  @override
  Stream<ProgressEvent> pull(String repoPath, PullOptions options) {
    final args = ['pull', '--progress'];
    switch (options.mode) {
      case PullMode.merge:
        break;
      case PullMode.rebase:
        args.add('--rebase');
        break;
      case PullMode.ffOnly:
        args.add('--ff-only');
        break;
    }
    if (options.remote != null) {
      args.add(options.remote!);
      if (options.branch != null) args.add(options.branch!);
    }
    return _runStream('pull', args, workingDir: repoPath, extraEnv: _authEnv(options.token, options.sshKeyName));
  }

  @override
  Stream<ProgressEvent> push(String repoPath, PushOptions options) {
    final args = ['push', '--progress'];
    if (options.force) args.add('--force-with-lease');
    if (options.setUpstream) args.add('--set-upstream');
    if (options.remote != null) args.add(options.remote!);
    if (options.branch != null) args.add(options.branch!);
    return _runStream('push', args, workingDir: repoPath, extraEnv: _authEnv(options.token, options.sshKeyName));
  }

  @override
  Future<void> stash(String repoPath, {String? message}) async {
    final args = ['stash', 'push'];
    if (message != null) args.addAll(['-m', message]);
    final r = await _run(args, workingDir: repoPath);
    if (r.exitCode != 0) throw GitException('git stash failed: ${r.stderr}');
  }

  @override
  Future<void> stashPop(String repoPath, {int? index}) async {
    final args = ['stash', 'pop'];
    if (index != null) args.add('stash@{$index}');
    final r = await _run(args, workingDir: repoPath);
    if (r.exitCode != 0) throw GitException('git stash pop failed: ${r.stderr}');
  }

  @override
  Future<void> stashApply(String repoPath, {int? index}) async {
    final args = ['stash', 'apply'];
    if (index != null) args.add('stash@{$index}');
    final r = await _run(args, workingDir: repoPath);
    if (r.exitCode != 0) throw GitException('git stash apply failed: ${r.stderr}');
  }

  @override
  Future<void> stashDrop(String repoPath, {int? index}) async {
    final args = ['stash', 'drop'];
    if (index != null) args.add('stash@{$index}');
    final r = await _run(args, workingDir: repoPath);
    if (r.exitCode != 0) throw GitException('git stash drop failed: ${r.stderr}');
  }

  @override
  Future<List<StashEntry>> stashList(String repoPath) async {
    final r = await _run(
      ['stash', 'list', '--pretty=format:%gd|%s|%cI'],
      workingDir: repoPath,
    );
    if (r.exitCode != 0) return const [];
    return r.stdout
        .split('\n')
        .where((l) => l.isNotEmpty)
        .map((line) {
          final parts = line.split('|');
          if (parts.length < 3) return null;
          final refMatch = RegExp(r'stash@\{(\d+)\}').firstMatch(parts[0]);
          if (refMatch == null) return null;
          return StashEntry(
            index: int.parse(refMatch.group(1)!),
            message: parts[1],
            branch: '',
            createdAt: DateTime.tryParse(parts[2]) ?? DateTime.now(),
          );
        })
        .whereType<StashEntry>()
        .toList();
  }

  @override
  void cancel(String repoPath) {
    _running[repoPath]?.process.kill();
  }

  // -------- private --------

  Future<File> _writeCommitMessageFile(String repoPath, CommitOptions options) async {
    final buf = StringBuffer();
    buf.writeln(options.message);
    if (options.description != null && options.description!.isNotEmpty) {
      buf.writeln();
      buf.writeln(options.description);
    }
    for (final co in options.coAuthors) {
      if (co.trim().isNotEmpty) {
        buf.writeln();
        buf.writeln('Co-authored-by: $co');
      }
    }
    final f = File('$repoPath${Platform.pathSeparator}.git${Platform.pathSeparator}VEX_GIT_COMMIT_EDITMSG');
    await f.writeAsString(buf.toString());
    return f;
  }

  Map<String, String> _authEnv(String? token, String? sshKeyName) {
    final env = <String, String>{};
    if (token != null && token.isNotEmpty) {
      env[_envTokenKey] = token;
    }
    return env;
  }

  Future<void> _ensureRepo(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      throw NotFoundException('Repository not found at $path');
    }
    final gitDir = Directory('$path${Platform.pathSeparator}.git');
    if (!await gitDir.exists()) {
      throw NotFoundException('Not a git repository: $path');
    }
  }

  Future<_CmdResult> _run(
    List<String> args, {
    required String? workingDir,
    Map<String, String>? extraEnv,
  }) async {
    final result = await Process.run(
      gitExecutable,
      args,
      workingDirectory: workingDir,
      environment: {...Platform.environment, ...?extraEnv},
      runInShell: Platform.isWindows,
    );
    return _CmdResult(
      exitCode: result.exitCode,
      stdout: result.stdout.toString(),
      stderr: result.stderr.toString(),
    );
  }

  Stream<ProgressEvent> _runStream(
    String op,
    List<String> args, {
    required String? workingDir,
    Map<String, String>? extraEnv,
  }) async* {
    final controller = StreamController<ProgressEvent>();
    final process = await Process.start(
      gitExecutable,
      args,
      workingDirectory: workingDir,
      environment: {...Platform.environment, ...?extraEnv},
      runInShell: Platform.isWindows,
    );
    if (workingDir != null) _running[workingDir] = _RunningOperation(process);
    final buf = StringBuffer();
    final sub = process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      final ev = _parseProgressLine(op, line);
      if (ev != null) controller.add(ev);
    });
    final errSub = process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      buf.writeln(line);
      // git 进度信息会进 stderr
      final ev = _parseProgressLine(op, line);
      if (ev != null) controller.add(ev);
    });
    final exit = await process.exitCode;
    await sub.cancel();
    await errSub.cancel();
    if (workingDir != null) _running.remove(workingDir);
    if (exit != 0) {
      controller.addError(GitException('git $op failed (exit $exit):\n${buf.toString()}'));
    }
    await controller.close();
  }

  ProgressEvent? _parseProgressLine(String op, String line) {
    // 形如 "Receiving objects: 67% (12345/18432)"
    final m = RegExp(r'(\w[\w ]+):\s*(\d+)%(?:\s*\((\d+)/(\d+)\))?').firstMatch(line);
    if (m != null) {
      return ProgressEvent(
        phase: m.group(1)!.trim(),
        current: int.tryParse(m.group(3) ?? '0') ?? 0,
        total: int.tryParse(m.group(4) ?? '0'),
      );
    }
    if (line.trim().isEmpty) return null;
    return ProgressEvent(phase: op, current: 0, total: null, message: line);
  }

  RepoStatus _parseStatus(String out) {
    String? branch;
    String? upstream;
    int ahead = 0;
    int behind = 0;
    final staged = <FileChange>[];
    final unstaged = <FileChange>[];
    final untracked = <FileChange>[];
    var hasConflict = false;

    for (final line in out.split('\n')) {
      if (line.isEmpty) continue;
      if (line.startsWith('# branch.head ')) {
        branch = line.substring('# branch.head '.length).trim();
        if (branch == '(detached)') branch = null;
        continue;
      }
      if (line.startsWith('# branch.upstream ')) {
        upstream = line.substring('# branch.upstream '.length).trim();
        continue;
      }
      if (line.startsWith('# branch.ab ')) {
        final m = RegExp(r'\+(\d+) -(\d+)').firstMatch(line);
        if (m != null) {
          ahead = int.parse(m.group(1)!);
          behind = int.parse(m.group(2)!);
        }
        continue;
      }
      if (line.startsWith('#')) continue;

      // v2 格式：1/2 xy sub <mH> <mI> <mW> <hH> <hI> <path>
      // 或：? <path>
      if (line.startsWith('? ')) {
        final path = line.substring(2);
        untracked.add(FileChange(path: path, status: FileChangeStatus.untracked));
        continue;
      }
      if (line.startsWith('1 ') || line.startsWith('2 ')) {
        final parts = line.split(' ');
        if (parts.length < 2) continue;
        final xy = parts[1];
        if (xy.contains('U') || xy == 'AA' || xy == 'DD') hasConflict = true;
        final path = parts.length > 9 ? parts[9] : (parts.length > 2 ? parts[2] : '');
        if (path.isEmpty) continue;
        final indexStatus = xy[0];
        final workStatus = xy[1];
        if (indexStatus != '.') {
          staged.add(FileChange(
            path: path,
            status: _statusFromChar(indexStatus),
            isStaged: true,
          ));
        }
        if (workStatus != '.') {
          unstaged.add(FileChange(
            path: path,
            status: _statusFromChar(workStatus),
          ));
        }
        if (indexStatus == 'U' || workStatus == 'U') hasConflict = true;
      }
    }

    return RepoStatus(
      branch: branch ?? 'detached',
      upstream: upstream,
      aheadBy: ahead,
      behindBy: behind,
      staged: staged,
      unstaged: unstaged,
      untracked: untracked,
      hasConflicts: hasConflict,
    );
  }

  FileChangeStatus _statusFromChar(String c) {
    return switch (c) {
      'A' => FileChangeStatus.added,
      'M' => FileChangeStatus.modified,
      'D' => FileChangeStatus.deleted,
      'R' => FileChangeStatus.renamed,
      'C' => FileChangeStatus.copied,
      'U' => FileChangeStatus.conflicted,
      'T' => FileChangeStatus.typeChanged,
      _ => FileChangeStatus.modified,
    };
  }

  List<Commit> _parseLog(String out) {
    final lines = out.split('\n');
    final commits = <Commit>[];
    int? jsonStart;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i] == '__VEX_GIT_JSON__') {
        jsonStart = i + 1;
        continue;
      }
      if (jsonStart != null) {
        // 多行 body 也算作 JSON 的一部分（由我们写入格式保证是一行）
        final line = lines[i];
        if (line.startsWith('{') && line.endsWith('}')) {
          try {
            final json = jsonDecode(line) as Map<String, dynamic>;
            commits.add(_commitFromJson(json));
            jsonStart = null;
          } catch (_) {
            jsonStart = null;
          }
        } else {
          // 异常情况：放弃当前 commit
          jsonStart = null;
        }
      }
    }
    return commits;
  }

  Commit? _parseShowCommit(String out) {
    final lines = out.split('\n');
    int? jsonStart;
    Map<String, dynamic>? json;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i] == '__VEX_GIT_JSON__') {
        jsonStart = i + 1;
        continue;
      }
      if (jsonStart != null) {
        final line = lines[i];
        if (line.startsWith('{') && line.endsWith('}')) {
          try {
            json = jsonDecode(line) as Map<String, dynamic>;
          } catch (_) {}
          jsonStart = null;
        }
      }
    }
    if (json == null) return null;
    return _commitFromJson(json);
  }

  Commit _commitFromJson(Map<String, dynamic> j) {
    final parents = (j['parents'] as String? ?? '').split(' ').where((s) => s.isNotEmpty).toList();
    return Commit(
      sha: j['sha'] as String,
      shortSha: j['shortSha'] as String?,
      message: j['message'] as String,
      body: j['body'] as String?,
      authorName: j['authorName'] as String,
      authorEmail: j['authorEmail'] as String,
      authoredAt: DateTime.parse(j['authoredAt'] as String),
      committerName: j['committerName'] as String?,
      committerEmail: j['committerEmail'] as String?,
      committedAt: DateTime.tryParse(j['committedAt'] as String? ?? ''),
      parentShas: parents,
    );
  }

  List<Branch> _parseBranches(String out) {
    final list = <Branch>[];
    for (final line in out.split('\n')) {
      if (line.isEmpty) continue;
      final isCurrent = line.startsWith('*');
      final ref = line.substring(1);
      final isRemote = ref.startsWith('remotes/');
      final name = isRemote ? ref.substring('remotes/'.length) : ref;
      // 去除 upstream track 信息
      String? upstream;
      final m = RegExp(r' \[?([^\]:]+)(?::? ?ahead (\d+))?(?:,? ?behind (\d+))?\]?').firstMatch(name);
      String cleanName = name;
      if (m != null) {
        upstream = m.group(1);
        cleanName = name.substring(0, m.start).trim();
      }
      if (cleanName.contains('/') && cleanName.startsWith('origin/')) {
        // skip HEAD alias
      }
      list.add(Branch(
        name: cleanName,
        isRemote: isRemote,
        isCurrent: isCurrent,
        upstream: upstream,
      ));
    }
    return list;
  }

  List<FileDiff> _parseDiff(String out) {
    final result = <FileDiff>[];
    String? currentPath;
    FileChangeStatus? currentStatus;
    var currentIsBinary = false;
    final currentHunks = <DiffHunk>[];
    DiffHunk? currentHunk;
    int? oldLine;
    int? newLine;

    void flush() {
      if (currentPath != null) {
        result.add(FileDiff(
          path: currentPath!,
          status: currentStatus ?? FileChangeStatus.modified,
          isStaged: false,
          hunks: currentHunks,
          isBinary: currentIsBinary,
        ));
      }
      currentPath = null;
      currentStatus = null;
      currentIsBinary = false;
      currentHunks.clear();
      currentHunk = null;
      oldLine = null;
      newLine = null;
    }

    for (final line in out.split('\n')) {
      if (line.startsWith('diff --git ')) {
        flush();
        final m = RegExp(r'diff --git a/(.+) b/(.+)').firstMatch(line);
        if (m != null) currentPath = m.group(2);
        continue;
      }
      if (line.startsWith('new file')) {
        currentStatus = FileChangeStatus.added;
        continue;
      }
      if (line.startsWith('deleted file')) {
        currentStatus = FileChangeStatus.deleted;
        continue;
      }
      if (line.startsWith('rename ')) {
        currentStatus = FileChangeStatus.renamed;
        continue;
      }
      if (line.startsWith('Binary files') || line.contains('GIT binary patch')) {
        currentIsBinary = true;
        continue;
      }
      final hunkMatch = RegExp(r'^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@').firstMatch(line);
      if (hunkMatch != null) {
        if (currentHunk != null) currentHunks.add(currentHunk!);
        currentHunk = DiffHunk(
          oldStart: int.parse(hunkMatch.group(1)!),
          oldLines: int.tryParse(hunkMatch.group(2) ?? '1') ?? 1,
          newStart: int.parse(hunkMatch.group(3)!),
          newLines: int.tryParse(hunkMatch.group(4) ?? '1') ?? 1,
          lines: const [],
        );
        oldLine = int.parse(hunkMatch.group(1)!);
        newLine = int.parse(hunkMatch.group(3)!);
        continue;
      }
      if (currentHunk == null) continue;
      if (line.startsWith('+') && !line.startsWith('+++')) {
        currentHunk = DiffHunk(
          oldStart: currentHunk!.oldStart,
          oldLines: currentHunk!.oldLines,
          newStart: currentHunk!.newStart,
          newLines: currentHunk!.newLines,
          lines: [
            ...currentHunk!.lines,
            DiffLine(kind: DiffLineKind.addition, content: line.substring(1), newLineNumber: newLine),
          ],
        );
        newLine = (newLine ?? 0) + 1;
      } else if (line.startsWith('-') && !line.startsWith('---')) {
        currentHunk = DiffHunk(
          oldStart: currentHunk!.oldStart,
          oldLines: currentHunk!.oldLines,
          newStart: currentHunk!.newStart,
          newLines: currentHunk!.newLines,
          lines: [
            ...currentHunk!.lines,
            DiffLine(kind: DiffLineKind.deletion, content: line.substring(1), oldLineNumber: oldLine),
          ],
        );
        oldLine = (oldLine ?? 0) + 1;
      } else if (line.startsWith(' ')) {
        currentHunk = DiffHunk(
          oldStart: currentHunk!.oldStart,
          oldLines: currentHunk!.oldLines,
          newStart: currentHunk!.newStart,
          newLines: currentHunk!.newLines,
          lines: [
            ...currentHunk!.lines,
            DiffLine(
                kind: DiffLineKind.context,
                content: line.substring(1),
                oldLineNumber: oldLine,
                newLineNumber: newLine),
          ],
        );
        oldLine = (oldLine ?? 0) + 1;
        newLine = (newLine ?? 0) + 1;
      }
    }
    if (currentHunk != null && currentHunk!.lines.isNotEmpty) {
      currentHunks.add(currentHunk!);
    }
    flush();
    return result;
  }
}

class _CmdResult {
  final int exitCode;
  final String stdout;
  final String stderr;
  _CmdResult({required this.exitCode, required this.stdout, required this.stderr});
}

class _RunningOperation {
  final Process process;
  _RunningOperation(this.process);
}