import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'application/providers/git_providers.dart';
import 'application/providers/settings_providers.dart';
import 'application/services/remote_scanner.dart';
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
      // 启动远程巡检
      ref.read(remoteScanProvider).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final notification = ref.watch(syncNotificationProvider);

    return MaterialApp.router(
      title: 'GitVex',
      locale: locale,
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
      builder: (context, child) {
        // 巡检通知横幅
        if (notification != null && child != null) {
          return Stack(
            children: [
              child,
              Positioned(
                top: MediaQuery.of(context).padding.top + 4,
                left: 12,
                right: 12,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.green[700],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_download, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notification.message,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            ref.read(syncNotificationProvider.notifier).state = null;
                          },
                          child: const Icon(Icons.close, color: Colors.white70, size: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return child ?? const SizedBox.shrink();
      },
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}