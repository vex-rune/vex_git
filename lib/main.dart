import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'application/providers/git_providers.dart';
import 'application/providers/settings_providers.dart';
import 'l10n/app_localizations.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/clone_screen.dart';
import 'presentation/screens/repo_detail_screen.dart';
import 'presentation/screens/commit_screen.dart';
import 'presentation/screens/commit_detail_screen.dart';
import 'presentation/screens/file_viewer_screen.dart';
import 'presentation/screens/branch_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/conflict_screen.dart';
import 'presentation/screens/stats_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/clone', builder: (_, _) => const CloneScreen()),
    GoRoute(
      path: '/repo/:id',
      builder: (_, state) => RepoDetailScreen(
        repoId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/repo/:id/commit',
      builder: (_, state) => CommitScreen(
        repoId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/repo/:id/commit/:sha',
      builder: (_, state) => CommitDetailScreen(
        repoId: state.pathParameters['id']!,
        sha: state.pathParameters['sha']!,
      ),
    ),
    GoRoute(
      path: '/repo/:id/file',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return FileViewerScreen(
          repoId: state.pathParameters['id']!,
          filePath: state.uri.queryParameters['path'] ?? '',
          isDir: extra?['isDir'] ?? false,
        );
      },
    ),
    GoRoute(
      path: '/repo/:id/branch',
      builder: (_, state) => BranchScreen(
        repoId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/repo/:id/conflict',
      builder: (_, state) => ConflictScreen(
        repoId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/repo/:id/stats',
      builder: (_, state) => StatsScreen(
        repoId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
  ],
);

void main() {
  runApp(const ProviderScope(child: GitVexApp()));
}

class GitVexApp extends ConsumerStatefulWidget {
  const GitVexApp({super.key});

  @override
  ConsumerState<GitVexApp> createState() => _GitVexAppState();
}

class _GitVexAppState extends ConsumerState<GitVexApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(repositoriesProvider.notifier).loadRepos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'GitVex',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'),
        Locale('en'),
      ],
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}