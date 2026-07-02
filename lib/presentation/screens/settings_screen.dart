import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/app_config.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _setTheme(AppThemeMode mode) async {
    await ref.read(updatePreferencesProvider).call(
          (p) => p.copyWith(themeMode: mode),
        );
  }

  Future<void> _setLanguage(AppLanguage lang) async {
    await ref.read(updatePreferencesProvider).call(
          (p) => p.copyWith(language: lang),
        );
  }

  Future<void> _setBranchPrefix(String prefix) async {
    await ref.read(updatePreferencesProvider).call(
          (p) => p.copyWith(defaultBranchPrefix: prefix),
        );
  }

  Future<void> _setAutoFetch(bool v) async {
    await ref.read(updatePreferencesProvider).call(
          (p) => p.copyWith(autoFetchBeforeCommit: v),
        );
  }

  Future<void> _setShowAvatars(bool v) async {
    await ref.read(updatePreferencesProvider).call(
          (p) => p.copyWith(showAvatars: v),
        );
  }

  Future<void> _setNotifications(bool v) async {
    await ref.read(updatePreferencesProvider).call(
          (p) => p.copyWith(notificationsEnabled: v),
        );
  }

  Future<void> _setSigning(CommitSigning mode) async {
    await ref.read(updatePreferencesProvider).call(
          (p) => p.copyWith(signingMode: mode),
        );
  }

  Future<void> _setAutoScan(int minutes) async {
    await ref.read(updatePreferencesProvider).call(
          (p) => p.copyWith(autoScanIntervalMinutes: minutes),
        );
  }

  Future<void> _resetPreferences() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context).settingsResetConfig),
        content: const Text('Reset all settings to defaults?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context).commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(AppLocalizations.of(context).commonConfirm)),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(resetPreferencesProvider).call();
    }
  }

  Future<void> _clearCache() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prefsAsync = ref.watch(configStreamProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: prefsAsync.when(
        data: (cfg) {
          final p = cfg.preferences;
          return ListView(
            children: [
              _sectionHeader(l.settingsAppearance),
              ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: Text(l.settingsTheme),
                subtitle: Text(_themeLabel(p.themeMode, l)),
                onTap: () => _pickTheme(p.themeMode),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l.settingsLanguage),
                subtitle: Text(_langLabel(p.language, l)),
                onTap: () => _pickLanguage(p.language),
              ),
              const Divider(),
              _sectionHeader(l.settingsGit),
              ListTile(
                leading: const Icon(Icons.account_tree_outlined),
                title: Text(l.settingsDefaultBranchPrefix),
                subtitle: Text(p.defaultBranchPrefix),
                onTap: () => _editBranchPrefix(p.defaultBranchPrefix),
              ),
              ListTile(
                leading: const Icon(Icons.verified_outlined),
                title: Text(l.settingsCommitSigning),
                subtitle: Text(_signingLabel(p.signingMode, l)),
                onTap: () => _pickSigning(p.signingMode),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.sync),
                title: Text(l.settingsAutoFetch),
                subtitle: const Text('Fetch before commit'),
                value: p.autoFetchBeforeCommit,
                onChanged: _setAutoFetch,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.face),
                title: Text(l.settingsShowAvatars),
                value: p.showAvatars,
                onChanged: _setShowAvatars,
              ),
              const Divider(),
              _sectionHeader(l.settingsNotifications),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: Text(l.settingsNotificationsEnabled),
                value: p.notificationsEnabled,
                onChanged: _setNotifications,
              ),
              const Divider(),
              _sectionHeader(l.settingsStorage),
              ListTile(
                leading: const Icon(Icons.folder_special),
                title: Text(l.settingsStoragePath),
                subtitle: Text(p.customRepoStorePath ?? AppConstants.storeDirName),
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(l.settingsAutoScanInterval),
                subtitle: Text('${p.autoScanIntervalMinutes} min'),
                onTap: () => _pickAutoScan(p.autoScanIntervalMinutes),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.cleaning_services_outlined),
                title: Text(l.settingsClearCache),
                onTap: _clearCache,
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: Text(l.settingsResetConfig),
                onTap: _resetPreferences,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l.settingsAbout),
                onTap: () => context.push(AppRoutes.about),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.commonError}: $e')),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  String _themeLabel(AppThemeMode mode, AppLocalizations l) {
    return switch (mode) {
      AppThemeMode.system => l.settingsThemeSystem,
      AppThemeMode.light => l.settingsThemeLight,
      AppThemeMode.dark => l.settingsThemeDark,
    };
  }

  String _langLabel(AppLanguage lang, AppLocalizations l) {
    return switch (lang) {
      AppLanguage.system => 'System',
      AppLanguage.en => 'English',
      AppLanguage.zh => '中文',
    };
  }

  String _signingLabel(CommitSigning s, AppLocalizations l) {
    return switch (s) {
      CommitSigning.off => l.settingsSigningOff,
      CommitSigning.gpg => l.settingsSigningGpg,
      CommitSigning.ssh => l.settingsSigningSsh,
    };
  }

  Future<void> _pickTheme(AppThemeMode current) async {
    final l = AppLocalizations.of(context);
    final v = await showModalBottomSheet<AppThemeMode>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioGroup<AppThemeMode>(
              groupValue: current,
              onChanged: (v) => Navigator.pop(context, v),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final m in AppThemeMode.values)
                    RadioListTile<AppThemeMode>(
                      value: m,
                      title: Text(_themeLabel(m, l)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (v != null) await _setTheme(v);
  }

  Future<void> _pickLanguage(AppLanguage current) async {
    final v = await showModalBottomSheet<AppLanguage>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioGroup<AppLanguage>(
              groupValue: current,
              onChanged: (v) => Navigator.pop(context, v),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final m in AppLanguage.values)
                    RadioListTile<AppLanguage>(
                      value: m,
                      title: Text(_langLabel(m, AppLocalizations.of(context))),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (v != null) await _setLanguage(v);
  }

  Future<void> _pickSigning(CommitSigning current) async {
    final l = AppLocalizations.of(context);
    final v = await showModalBottomSheet<CommitSigning>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioGroup<CommitSigning>(
              groupValue: current,
              onChanged: (v) => Navigator.pop(context, v),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final s in CommitSigning.values)
                    RadioListTile<CommitSigning>(
                      value: s,
                      title: Text(_signingLabel(s, l)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (v != null) await _setSigning(v);
  }

  Future<void> _editBranchPrefix(String current) async {
    final ctrl = TextEditingController(text: current);
    final v = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context).settingsDefaultBranchPrefix),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'feature/'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context).commonCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: Text(AppLocalizations.of(context).commonSave),
          ),
        ],
      ),
    );
    if (v != null && v.isNotEmpty) await _setBranchPrefix(v);
  }

  Future<void> _pickAutoScan(int current) async {
    final v = await showModalBottomSheet<int>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioGroup<int>(
              groupValue: current,
              onChanged: (v) => Navigator.pop(context, v),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final m in const [10, 20, 30, 60])
                    RadioListTile<int>(
                      value: m,
                      title: Text('$m min'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (v != null) await _setAutoScan(v);
  }
}