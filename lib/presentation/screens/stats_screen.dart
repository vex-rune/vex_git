import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/git_providers.dart';
import '../../domain/entities/entities.dart';

class StatsScreen extends ConsumerStatefulWidget {
  final String repoId;

  const StatsScreen({super.key, required this.repoId});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  List<GitCommit> _commits = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final repo = ref.read(currentRepoProvider);
    if (repo == null) return;

    try {
      final git = ref.read(gitServiceProvider);
      final log = await git.getLog(repo.localPath, limit: 200);
      setState(() {
        _commits = log;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('提交统计'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_commits.isEmpty) {
      return const Center(child: Text('暂无提交记录'));
    }

    // 按作者统计
    final authorMap = <String, int>{};
    for (final c in _commits) {
      authorMap[c.author] = (authorMap[c.author] ?? 0) + 1;
    }
    final sortedAuthors = authorMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = sortedAuthors.isNotEmpty ? sortedAuthors.first.value : 1;

    // 按日期统计（最近 7 天）
    final now = DateTime.now();
    final dailyMap = <String, int>{};
    for (var i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.month}/${day.day}';
      dailyMap[key] = 0;
    }
    for (final c in _commits) {
      final diff = now.difference(c.timestamp);
      if (diff.inDays < 7) {
        final key = '${c.timestamp.month}/${c.timestamp.day}';
        if (dailyMap.containsKey(key)) {
          dailyMap[key] = dailyMap[key]! + 1;
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 总览
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('总提交', '${_commits.length}'),
                _buildStatItem('贡献者', '${authorMap.length}'),
                _buildStatItem(
                  '最近 7 天',
                  '${dailyMap.values.fold<int>(0, (a, b) => a + b)}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 按作者统计
        const Text('贡献者排行', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...sortedAuthors.map((e) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blueGrey[700],
                  child: Text(
                    e.key.isNotEmpty ? e.key[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                title: Text(e.key, style: const TextStyle(fontSize: 13)),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: e.value / maxCount,
                        backgroundColor: Colors.grey[800],
                        color: Colors.blue,
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${e.value}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            )),

        const SizedBox(height: 16),

        // 最近 7 天趋势
        const Text('最近 7 天', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: dailyMap.entries.toList().reversed.map((e) {
                final barWidth = maxCount > 0 ? e.value / maxCount : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(e.key, style: const TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: barWidth,
                          backgroundColor: Colors.grey[800],
                          color: Colors.green,
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 24,
                        child: Text('${e.value}', style: const TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
      ],
    );
  }
}
