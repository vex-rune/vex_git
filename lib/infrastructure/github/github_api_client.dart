import 'dart:async';

import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';

class DeviceCodeResponse {
  final String deviceCode;
  final String userCode;
  final String verificationUri;
  final String? verificationUriComplete;
  final int expiresIn;
  final int interval;

  DeviceCodeResponse({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUri,
    this.verificationUriComplete,
    required this.expiresIn,
    required this.interval,
  });

  factory DeviceCodeResponse.fromJson(Map<String, dynamic> j) => DeviceCodeResponse(
        deviceCode: j['device_code'] as String,
        userCode: j['user_code'] as String,
        verificationUri: j['verification_uri'] as String,
        verificationUriComplete: j['verification_uri_complete'] as String?,
        expiresIn: (j['expires_in'] as num).toInt(),
        interval: (j['interval'] as num).toInt(),
      );
}

enum DeviceFlowError { authorizationPending, slowDown, expiredToken, accessDenied, incorrectDeviceCode, network }

class GitHubUser {
  final int id;
  final String login;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final String? bio;

  GitHubUser({
    required this.id,
    required this.login,
    this.name,
    this.email,
    this.avatarUrl,
    this.bio,
  });

  factory GitHubUser.fromJson(Map<String, dynamic> j) => GitHubUser(
        id: (j['id'] as num).toInt(),
        login: j['login'] as String,
        name: j['name'] as String?,
        email: j['email'] as String?,
        avatarUrl: j['avatar_url'] as String?,
        bio: j['bio'] as String?,
      );
}

class GitHubRepository {
  final int id;
  final String name;
  final String fullName;
  final String? description;
  final bool isPrivate;
  final String? defaultBranch;
  final String? cloneUrl;
  final String? sshUrl;
  final DateTime? updatedAt;
  final int stargazersCount;
  final int forksCount;

  GitHubRepository({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    required this.isPrivate,
    this.defaultBranch,
    this.cloneUrl,
    this.sshUrl,
    this.updatedAt,
    this.stargazersCount = 0,
    this.forksCount = 0,
  });

  factory GitHubRepository.fromJson(Map<String, dynamic> j) => GitHubRepository(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String,
        fullName: j['full_name'] as String,
        description: j['description'] as String?,
        isPrivate: j['private'] as bool? ?? false,
        defaultBranch: j['default_branch'] as String?,
        cloneUrl: j['clone_url'] as String?,
        sshUrl: j['ssh_url'] as String?,
        updatedAt: DateTime.tryParse(j['updated_at'] as String? ?? ''),
        stargazersCount: (j['stargazers_count'] as num?)?.toInt() ?? 0,
        forksCount: (j['forks_count'] as num?)?.toInt() ?? 0,
      );
}

class PullRequestSummary {
  final int number;
  final String title;
  final String state;
  final String? body;
  final GitHubUser? user;
  final String headRef;
  final String baseRef;
  final bool draft;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool merged;

  PullRequestSummary({
    required this.number,
    required this.title,
    required this.state,
    this.body,
    this.user,
    required this.headRef,
    required this.baseRef,
    this.draft = false,
    this.createdAt,
    this.updatedAt,
    this.merged = false,
  });

  factory PullRequestSummary.fromJson(Map<String, dynamic> j) {
    final head = j['head'];
    final base = j['base'];
    return PullRequestSummary(
      number: (j['number'] as num).toInt(),
      title: j['title'] as String,
      state: j['state'] as String,
      body: j['body'] as String?,
      user: j['user'] != null
          ? GitHubUser.fromJson((j['user'] as Map).cast<String, dynamic>())
          : null,
      headRef: (head is Map ? head['ref'] : null) as String? ?? '',
      baseRef: (base is Map ? base['ref'] : null) as String? ?? '',
      draft: j['draft'] as bool? ?? false,
      createdAt: DateTime.tryParse(j['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(j['updated_at'] as String? ?? ''),
      merged: j['merged_at'] != null,
    );
  }
}

class GitHubApiClient {
  GitHubApiClient({Dio? dio, String? baseUrl})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl ?? AppConstants.githubApiBase,
              connectTimeout: AppConstants.defaultNetworkTimeout,
              receiveTimeout: AppConstants.defaultNetworkTimeout,
              headers: const {'Accept': 'application/vnd.github+json'},
            ));

  final Dio _dio;
  String? _token;

  set token(String? value) {
    _token = value;
  }

  Map<String, String> get _authHeaders => _token != null
      ? {'Authorization': 'Bearer $_token', 'X-GitHub-Api-Version': '2022-11-28'}
      : {'X-GitHub-Api-Version': '2022-11-28'};

  Future<DeviceCodeResponse> requestDeviceCode({
    required String clientId,
    required List<String> scopes,
    String? host,
  }) async {
    final base = host ?? AppConstants.githubApiBase;
    try {
      final r = await _dio.post<Map<String, dynamic>>(
        '$base/login/device/code',
        data: {'client_id': clientId, 'scope': scopes.join(' ')},
        options: Options(headers: const {'Accept': 'application/json'}),
      );
      final data = r.data;
      if (data == null) {
        throw NetworkException('Empty response from device code endpoint');
      }
      return DeviceCodeResponse.fromJson(data);
    } on DioException catch (e) {
      throw NetworkException('Failed to request device code: ${e.message}');
    }
  }

  Future<({String? token, DeviceFlowError? error})> pollDeviceCode({
    required String clientId,
    required String deviceCode,
    String? host,
  }) async {
    final base = host ?? AppConstants.githubApiBase;
    try {
      final r = await _dio.post<Map<String, dynamic>>(
        '$base/login/oauth/access_token',
        data: {
          'client_id': clientId,
          'device_code': deviceCode,
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        },
        options: Options(headers: const {'Accept': 'application/json'}),
      );
      final data = r.data;
      if (data == null) return (token: null, error: null);
      if (data.containsKey('access_token')) {
        return (token: data['access_token'] as String, error: null);
      }
      final err = data['error'] as String?;
      if (err == null) return (token: null, error: null);
      return (
        token: null,
        error: switch (err) {
          'authorization_pending' => DeviceFlowError.authorizationPending,
          'slow_down' => DeviceFlowError.slowDown,
          'expired_token' => DeviceFlowError.expiredToken,
          'access_denied' => DeviceFlowError.accessDenied,
          'incorrect_device_code' => DeviceFlowError.incorrectDeviceCode,
          _ => DeviceFlowError.network,
        },
      );
    } on DioException catch (e) {
      throw NetworkException('Failed to poll device code: ${e.message}');
    }
  }

  Future<GitHubUser> getCurrentUser() async {
    return _get<GitHubUser>('/user', (j) => GitHubUser.fromJson(j));
  }

  Future<List<GitHubRepository>> listUserRepositories({int perPage = 30, String? visibility}) async {
    final path = '/user/repos?per_page=$perPage&sort=updated${visibility != null ? '&visibility=$visibility' : ''}';
    return _get<List<GitHubRepository>>(
      path,
      (j) {
        final list = (j as List).cast<Map<String, dynamic>>();
        return list.map(GitHubRepository.fromJson).toList();
      },
    );
  }

  Future<GitHubRepository> getRepository(String owner, String repo) async {
    return _get<GitHubRepository>('/repos/$owner/$repo', (j) => GitHubRepository.fromJson(j));
  }

  Future<List<PullRequestSummary>> listPullRequests(
    String owner,
    String repo, {
    String state = 'open',
  }) async {
    return _get<List<PullRequestSummary>>(
      '/repos/$owner/$repo/pulls?state=$state&per_page=50',
      (j) {
        final list = (j as List).cast<Map<String, dynamic>>();
        return list.map(PullRequestSummary.fromJson).toList();
      },
    );
  }

  Future<PullRequestSummary> getPullRequest(String owner, String repo, int number) async {
    return _get<PullRequestSummary>(
      '/repos/$owner/$repo/pulls/$number',
      (j) => PullRequestSummary.fromJson(j),
    );
  }

  Future<PullRequestSummary> createPullRequest({
    required String owner,
    required String repo,
    required String title,
    required String head,
    required String base,
    String? body,
    bool draft = false,
  }) async {
    try {
      final r = await _dio.post<Map<String, dynamic>>(
        '/repos/$owner/$repo/pulls',
        data: {
          'title': title,
          'head': head,
          'base': base,
          'body': body,
          'draft': draft,
        },
        options: Options(headers: _authHeaders),
      );
      final data = r.data;
      if (data == null) throw NetworkException('Empty response');
      return PullRequestSummary.fromJson(data);
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  Future<void> mergePullRequest(
    String owner,
    String repo,
    int number, {
    String method = 'merge',
    String? commitMessage,
  }) async {
    try {
      await _dio.put<Map<String, dynamic>>(
        '/repos/$owner/$repo/pulls/$number/merge',
        data: {
          'commit_message': commitMessage,
          'merge_method': method,
        },
        options: Options(headers: _authHeaders),
      );
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  Future<void> closePullRequest(String owner, String repo, int number) async {
    try {
      await _dio.patch<Map<String, dynamic>>(
        '/repos/$owner/$repo/pulls/$number',
        data: {'state': 'closed'},
        options: Options(headers: _authHeaders),
      );
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  Future<T> _get<T>(String path, T Function(Map<String, dynamic>) parse) async {
    try {
      final r = await _dio.get<dynamic>(path, options: Options(headers: _authHeaders));
      final raw = r.data;
      if (raw is Map<String, dynamic>) return parse(raw);
      if (raw is Map) return parse(raw.cast<String, dynamic>());
      throw NetworkException('Unexpected response type: ${raw.runtimeType}');
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  Exception _toException(DioException e) {
    final status = e.response?.statusCode ?? 0;
    final data = e.response?.data;
    String msg = e.message ?? 'Request failed';
    if (data is Map && data['message'] is String) {
      msg = data['message'] as String;
    }
    if (status == 401 || status == 403) {
      return AuthException('GitHub API auth failed: $msg');
    }
    if (status == 404) {
      return NotFoundException('GitHub resource not found: $msg');
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return TimeoutException('GitHub API timeout: $msg');
    }
    return NetworkException('GitHub API error ($status): $msg');
  }
}