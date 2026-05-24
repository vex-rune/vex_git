import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/git_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reposAsync = ref.watch(repositoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitVex'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: reposAsync.when(
        data: (repos) => repos.isEmpty
            ? const Center(
                child: Text('暂无仓库，点击下方按钮克隆或新建',
                    style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                itemCount: repos.length,
                itemBuilder: (_, i) => ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(repos[i].name),
                  subtitle: Text(repos[i].localPath),
                  onTap: () => context.push('/repo/${repos[i].id}'),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('错误: $e')),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'clone',
            onPressed: () => context.push('/clone'),
            child: const Icon(Icons.download),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'new',
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}