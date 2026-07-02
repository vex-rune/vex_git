import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../infrastructure/github/github_api_client.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';

final _prsProvider = FutureProvider.family<List<PullRequestSummary>, _PrKey>((ref, key) async {
  return ref.read(listPrsProvider).call(key.owner, key.repo, state: key.state);
});

class _PrKey {
  final String owner;
  final String repo;
  final String state;
  const _PrKey(this.owner, this.repo, this.state);
  @override
  bool operator ==(Object other) =>
      other is _PrKey && owner == other.owner && repo == other.repo && state == other.state;
  @override
  int get hashCode => Object.hash(owner, repo, state);
}

class PullRequestListScreen extends ConsumerStatefulWidget {
  final String owner;
  final String repo;
  const PullRequestListScreen({super.key, required this.owner, required this.repo});

  @override
  ConsumerState<PullRequestListScreen> createState() => _PullRequestListScreenState();
}

class _PullRequestListScreenState extends ConsumerState<PullRequestListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.owner}/${widget.repo}'),
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: l.prOpen),
            Tab(text: l.prClosed),
            Tab(text: l.prMerged),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l.prCreate,
            onPressed: () => context.push('/pr/${widget.owner}/${widget.repo}/create'),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _PrList(owner: widget.owner, repo: widget.repo, state: 'open', label: l.prOpen),
          _PrList(owner: widget.owner, repo: widget.repo, state: 'closed', label: l.prClosed),
          _PrList(owner: widget.owner, repo: widget.repo, state: 'merged', label: l.prMerged, fetchAs: 'closed'),
        ],
      ),
    );
  }
}

class _PrList extends ConsumerWidget {
  final String owner;
  final String repo;
  final String state;
  final String label;
  final String? fetchAs;
  const _PrList({required this.owner, required this.repo, required this.state, required this.label, this.fetchAs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(_prsProvider(_PrKey(owner, repo, fetchAs ?? state)));
    return async.when(
      data: (list) {
        final filtered = fetchAs == 'closed' ? list.where((p) => p.merged).toList() : list;
        if (filtered.isEmpty) {
          return Center(child: Text(l.prNoPRs));
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(_prsProvider(_PrKey(owner, repo, fetchAs ?? state))),
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final p = filtered[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: p.merged
                      ? Colors.purple
                      : p.state == 'open'
                          ? Colors.green
                          : Colors.red,
                  child: Icon(
                    p.merged ? Icons.merge_outlined : Icons.call_split,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                title: Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '#${p.number}  ${p.user?.login ?? "?"}  •  ${p.baseRef} ← ${p.headRef}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () => context.push('/pr/$owner/$repo/${p.number}'),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l.commonError}: $e')),
    );
  }
}