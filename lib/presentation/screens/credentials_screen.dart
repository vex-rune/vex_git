import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_config.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';

class CredentialsScreen extends ConsumerWidget {
  const CredentialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cfg = ref.watch(configStreamProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l.credentialsTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l.credentialsHttps,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
          if (cfg == null || cfg.accounts.isEmpty)
            ListTile(
              title: Text(l.credentialsAddAccount),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).maybePop(),
            )
          else
            ...cfg.accounts.map((a) => _AccountTile(account: a)),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l.credentialsSsh,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('Generate new key'),
            subtitle: const Text('ed25519 (recommended)'),
            onTap: () => _showSshInfo(context),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text(l.credentialsSshImport),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Coming soon')),
            ),
          ),
        ],
      ),
    );
  }

  void _showSshInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('SSH key'),
        content: const Text(
          'To generate an SSH key pair, run the following command on your computer:\n\n'
          'ssh-keygen -t ed25519 -C "your_email@example.com"\n\n'
          'Then add the contents of ~/.ssh/id_ed25519.pub to your GitHub account.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends ConsumerWidget {
  final AccountConfig account;
  const _AccountTile({required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: account.avatarUrl != null && account.avatarUrl!.isNotEmpty
            ? NetworkImage(account.avatarUrl!)
            : null,
        child: account.avatarUrl == null ? const Icon(Icons.person) : null,
      ),
      title: Text('@${account.login}'),
      subtitle: Text(account.host),
      trailing: IconButton(
        icon: const Icon(Icons.copy),
        tooltip: 'Copy public info',
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: '@${account.login} (${account.host})'));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied')),
            );
          }
        },
      ),
    );
  }
}