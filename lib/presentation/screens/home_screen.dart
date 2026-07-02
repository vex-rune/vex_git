import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/app_config.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';

final _reposProvider = StreamProvider<List<RepoConfig>>((ref) async* {
  final repo = ref.watch(appConfigRepoProvider);
  await for (final cfg in repo.watch()) {
    yield cfg.repositories;
  }
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final repos = ref.watch(_reposProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.repoListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l.settingsTitle,
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      drawer: const HomeDrawer(),
      body: repos.when(
        data: (list) {
          if (list.isEmpty) {
            return _EmptyState();
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(_reposProvider);
              await Future<void>.delayed(const Duration(milliseconds: 300));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _RepoCard(repo: list[i]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.commonError}: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add),
        label: Text(l.repoAdd),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.cloud_download_outlined),
              title: Text(l.repoClone),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.clone);
              },
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: Text(l.repoCreate),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.create);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: Text(l.repoAddExisting),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.addLocal);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan to clone'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.scan);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cfg = ref.watch(configStreamProvider).value;
    final activeId = cfg?.activeAccountId;
    final account = _findAccount(cfg, activeId);
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: (account != null && account.avatarUrl != null && account.avatarUrl!.isNotEmpty)
                        ? NetworkImage(account.avatarUrl!)
                        : null,
                    child: (account == null || account.avatarUrl == null || account.avatarUrl!.isEmpty)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account?.displayName ?? account?.login ?? 'Vex Git',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '@${account?.login ?? "Not signed in"}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: Text(l.navHome),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card_outlined),
              title: Text(l.credentialsTitle),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.credentials);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l.settingsTitle),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.settings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l.settingsAbout),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.about);
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l.authLogout),
              onTap: () async {
                Navigator.pop(context);
                if (activeId != null) {
                  await ref.read(logoutUseCaseProvider).call(activeId);
                  if (context.mounted) context.go(AppRoutes.auth);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  AccountConfig? _findAccount(AppConfig? cfg, String? activeId) {
    if (cfg == null || activeId == null) return null;
    final matches = cfg.accounts.where((a) => a.id == activeId);
    return matches.isNotEmpty ? matches.first : null;
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(l.repoNoRepos, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l.repoNoReposHint,
                style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _RepoCard extends StatelessWidget {
  final RepoConfig repo;
  const _RepoCard({required this.repo});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/repo/${repo.id}'),
        onLongPress: () => _showMore(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.book_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(repo.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              if (repo.remoteUrl != null) ...[
                const SizedBox(height: 4),
                Text(repo.remoteUrl!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  if (repo.defaultBranch != null) ...[
                    const Icon(Icons.account_tree_outlined, size: 14),
                    const SizedBox(width: 4),
                    Text(repo.defaultBranch!, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 12),
                  ],
                  const Icon(Icons.folder_outlined, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(repo.localPath,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMore(BuildContext context) {
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: Text(l.repoRename),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: Text(l.repoSetPath),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l.repoRemove),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}