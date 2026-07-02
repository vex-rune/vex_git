class AppConstants {
  AppConstants._();

  // 文件名
  static const String configFileName = '.vex_git.config';
  static const String storeDirName = '.vex_git_store';
  static const String storeReposDir = 'repos';
  static const String storeCacheDir = 'cache';
  static const String storeLogsDir = 'logs';

  // GitHub OAuth (Device Flow)
  static const String githubClientId = 'YOUR_GITHUB_OAUTH_CLIENT_ID';
  static const List<String> githubDefaultScopes = [
    'repo',
    'read:user',
    'user:email',
    'workflow',
  ];
  static const String githubApiBase = 'https://api.github.com';
  static const String githubWebBase = 'https://github.com';

  // 限制
  static const int defaultLogMaxLines = 5000;
  static const int defaultCommitLogPageSize = 50;
  static const Duration defaultNetworkTimeout = Duration(seconds: 30);
  static const Duration defaultLongOpTimeout = Duration(minutes: 10);

  // 默认分支前缀
  static const String defaultBranchPrefix = 'feature/';
}

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String repoDetail = '/repo/:id';
  static const String clone = '/clone';
  static const String create = '/create';
  static const String addLocal = '/add-local';
  static const String commit = '/commit/:id';
  static const String commitDetail = '/commit-detail/:id';
  static const String branch = '/branch/:id';
  static const String history = '/history/:id';
  static const String conflict = '/conflict/:id';
  static const String pr = '/pr/:owner/:repo';
  static const String prDetail = '/pr/:owner/:repo/:number';
  static const String prCreate = '/pr/:owner/:repo/create';
  static const String settings = '/settings';
  static const String credentials = '/credentials';
  static const String about = '/about';
  static const String scan = '/scan';
  static const String fileViewer = '/file/:id';
}