import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../infrastructure/github/github_api_client.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  DeviceCodeResponse? _device;
  bool _loading = false;
  String? _error;
  String _host = 'github.com';
  final _hosts = const ['github.com', 'GitHub Enterprise'];

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final useCase = ref.read(startDeviceLoginProvider);
      final device = await useCase.call(
        clientId: AppConstants.githubClientId,
        scopes: AppConstants.githubDefaultScopes,
        host: _host == 'github.com' ? null : _host,
      );
      setState(() => _device = device);
      // ignore: discarded_futures
      unawaited(_pollAndComplete(device));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pollAndComplete(DeviceCodeResponse device) async {
    try {
      final useCase = ref.read(completeDeviceLoginProvider);
      await useCase.call(
        clientId: AppConstants.githubClientId,
        device: device,
        host: _host == 'github.com' ? null : _host,
      );
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _device = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isWaiting = _device != null;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(Icons.code, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(l.authLoginTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(l.authLoginSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),
              if (!isWaiting) ...[
                DropdownButtonFormField<String>(
                  initialValue: _host,
                  decoration: InputDecoration(labelText: l.authEnterprise),
                  items: _hosts
                      .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                      .toList(),
                  onChanged: _loading ? null : (v) => setState(() => _host = v ?? 'github.com'),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _loading ? null : _start,
                  icon: const Icon(Icons.login),
                  label: Text(l.authLoginButton),
                ),
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(l.authDeviceCode,
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 12),
                        SelectableText(
                          _device!.userCode,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 4,
                                fontFamily: 'monospace',
                              ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => launchUrl(
                              Uri.parse(_device!.verificationUri),
                              mode: LaunchMode.externalApplication),
                          icon: const Icon(Icons.open_in_new),
                          label: Text(l.authOpenBrowser),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l.authAwaiting,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
              if (_error != null) ...[
                const SizedBox(height: 24),
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}