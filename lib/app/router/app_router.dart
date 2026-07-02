import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/pr_create_screen.dart';
import '../../presentation/screens/pr_detail_screen.dart';
import '../../presentation/screens/pr_list_screen.dart';

import '../../presentation/screens/auth_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/repo_detail_screen.dart';
import '../../presentation/screens/clone_screen.dart';
import '../../presentation/screens/create_local_screen.dart';
import '../../presentation/screens/add_local_screen.dart';
import '../../presentation/screens/commit_screen.dart';
import '../../presentation/screens/commit_detail_screen.dart';
import '../../presentation/screens/branch_screen.dart';
import '../../presentation/screens/history_screen.dart';
import '../../presentation/screens/conflict_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/credentials_screen.dart';
import '../../presentation/screens/about_screen.dart';
import '../../presentation/screens/scan_screen.dart';
import '../../presentation/screens/file_viewer_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.auth, builder: (_, __) => const AuthScreen()),
      GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.repoDetail,
        builder: (_, st) => RepoDetailScreen(repoId: st.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.clone, builder: (_, __) => const CloneScreen()),
      GoRoute(path: AppRoutes.create, builder: (_, __) => const CreateLocalScreen()),
      GoRoute(path: AppRoutes.addLocal, builder: (_, __) => const AddLocalScreen()),
      GoRoute(
        path: AppRoutes.commit,
        builder: (_, st) => CommitScreen(repoId: st.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.commitDetail,
        builder: (_, st) {
          final params = st.pathParameters;
          return CommitDetailScreen(
            repoId: params['id']!,
            sha: params['sha']!,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.branch,
        builder: (_, st) => BranchScreen(repoId: st.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (_, st) => HistoryScreen(repoId: st.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.conflict,
        builder: (_, st) => ConflictScreen(repoId: st.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.pr,
        builder: (_, st) {
          final p = st.pathParameters;
          return PullRequestListScreen(owner: p['owner']!, repo: p['repo']!);
        },
      ),
      GoRoute(
        path: AppRoutes.prDetail,
        builder: (_, st) {
          final p = st.pathParameters;
          return PullRequestDetailScreen(
            owner: p['owner']!,
            repo: p['repo']!,
            number: int.parse(p['number']!),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.prCreate,
        builder: (_, st) {
          final p = st.pathParameters;
          return PullRequestCreateScreen(owner: p['owner']!, repo: p['repo']!);
        },
      ),
      GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsScreen()),
      GoRoute(path: AppRoutes.credentials, builder: (_, __) => const CredentialsScreen()),
      GoRoute(path: AppRoutes.about, builder: (_, __) => const AboutScreen()),
      GoRoute(path: AppRoutes.scan, builder: (_, __) => const ScanScreen()),
      GoRoute(
        path: AppRoutes.fileViewer,
        builder: (_, st) => FileViewerScreen(
          repoId: st.pathParameters['id']!,
          path: st.uri.queryParameters['path'] ?? '',
        ),
      ),
    ],
    redirect: (context, state) {
      // 这里做简单的登录态判断：未登录就跳 auth
      return null; // splash 自己决定
    },
    errorBuilder: (_, st) => Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(child: Text('Route not found: ${st.uri}')),
    ),
  );
});