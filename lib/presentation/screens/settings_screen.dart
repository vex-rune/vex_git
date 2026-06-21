import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../application/providers/settings_providers.dart';

const _scanIntervalKey = 'scan_interval';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _githubController = TextEditingController();
  final _giteeController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final config = ref.read(vexConfigProvider);
    await config.load();
    final interval = await SharedPreferences.getInstance()
        .then((p) => p.getInt(_scanIntervalKey) ?? 20);

    if (mounted) {
      setState(() {
        _githubController.text = config.githubToken ?? '';
        _giteeController.text = config.giteeToken ?? '';
        ref.read(scanIntervalProvider.notifier).setInterval(interval);
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGithubToken() async {
    final config = ref.read(vexConfigProvider);
    final token = _githubController.text.trim();
    config.githubToken = token.isEmpty ? null : token;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GitHub Token 已保存到 vex/vex.config')),
      );
    }
  }

  Future<void> _saveGiteeToken() async {
    final config = ref.read(vexConfigProvider);
    final token = _giteeController.text.trim();
    config.giteeToken = token.isEmpty ? null : token;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gitee Token 已保存到 vex/vex.config')),
      );
    }
  }

  Future<void> _saveScanInterval(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scanIntervalKey, minutes);
    ref.read(scanIntervalProvider.notifier).setInterval(minutes);
  }

  @override
  void dispose() {
    _githubController.dispose();
    _giteeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('设置')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          // HTTPS Token section
          _sectionHeader('HTTPS 令牌'),
          ListTile(
            title: const Text('GitHub Token'),
            subtitle: const Text('https://github.com/settings/tokens',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            trailing: SizedBox(
              width: 200,
              child: TextField(
                controller: _githubController,
                obscureText: true,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  hintText: 'ghp_xxx',
                ),
              ),
            ),
            onLongPress: _saveGithubToken,
          ),
          ListTile(
            title: const Text('Gitee Token'),
            subtitle: const Text('https://gitee.com/profile/personal_access_token',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            trailing: SizedBox(
              width: 200,
              child: TextField(
                controller: _giteeController,
                obscureText: true,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  hintText: '私人令牌',
                ),
              ),
            ),
            onLongPress: _saveGiteeToken,
          ),
          const Divider(),

          // SSH section
          _sectionHeader('SSH 密钥'),
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('SSH 密钥管理'),
            subtitle: const Text('查看 / 生成 / 导入 SSH 密钥',
                style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSshDialog(context),
          ),
          const Divider(),

          // Theme
          _sectionHeader('外观'),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('主题模式'),
            trailing: DropdownButton<ThemeMode>(
              value: ref.watch(themeModeProvider),
              items: const [
                DropdownMenuItem(value: ThemeMode.dark, child: Text('深色')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('浅色')),
                DropdownMenuItem(value: ThemeMode.system, child: Text('跟随系统')),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(v);
                }
              },
            ),
          ),
          const Divider(),

          // Language
          _sectionHeader('语言'),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: ref.watch(localeProvider).languageCode,
              items: const [
                DropdownMenuItem(value: 'zh', child: Text('中文')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(v));
                }
              },
            ),
          ),
          const Divider(),

          // Scan interval
          _sectionHeader('定时巡检'),
          ListTile(
            title: const Text('巡检周期'),
            subtitle: const Text('自动检测远程版本更新间隔',
                style: TextStyle(fontSize: 12)),
            trailing: DropdownButton<int>(
              value: ref.watch(scanIntervalProvider),
              items: const [
                DropdownMenuItem(value: 10, child: Text('10 分钟')),
                DropdownMenuItem(value: 20, child: Text('20 分钟')),
                DropdownMenuItem(value: 30, child: Text('30 分钟')),
                DropdownMenuItem(value: 60, child: Text('1 小时')),
              ],
              onChanged: (v) {
                if (v != null) _saveScanInterval(v);
              },
            ),
          ),
          const Divider(),

          // Cache
          _sectionHeader('存储'),
          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text('清除缓存'),
            subtitle: const Text('清理临时文件和缓存',
                style: TextStyle(fontSize: 12)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('确认清除'),
                  content: const Text('确定清除所有缓存数据？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('清除', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                // 清理 SharedPreferences（保留仓库列表）
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('scan_interval');
                await prefs.remove('theme_mode');
                // 清理 vex.config
                try {
                  final config = ref.read(vexConfigProvider);
                  config.githubToken = null;
                  config.giteeToken = null;
                } catch (_) {}
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('缓存已清除')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('恢复默认配置'),
            subtitle: const Text('重置所有设置为默认值',
                style: TextStyle(fontSize: 12)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('确认恢复'),
                  content: const Text('确定恢复所有设置为默认值？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('恢复', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                final config = ref.read(vexConfigProvider);
                config.githubToken = null;
                config.giteeToken = null;
                await _saveScanInterval(20);
                _githubController.clear();
                _giteeController.clear();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已恢复默认配置')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  void _showSshDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _SshKeyPage()),
    );
  }
}

class _SshKeyPage extends StatefulWidget {
  const _SshKeyPage();

  @override
  State<_SshKeyPage> createState() => _SshKeyPageState();
}

class _SshKeyPageState extends State<_SshKeyPage> {
  String? _publicKey;
  String? _privateKeyPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    try {
      final home = Platform.environment['HOME'] ??
          Platform.environment['USERPROFILE'] ??
          '';
      final sshDir = '$home/.ssh';
      final publicKeyFile = File('$sshDir/id_rsa.pub');
      if (await publicKeyFile.exists()) {
        final key = await publicKeyFile.readAsString();
        setState(() {
          _publicKey = key.trim();
          _privateKeyPath = '$sshDir/id_rsa';
          _loading = false;
        });
      } else {
        // 尝试 ed25519
        final ed25519File = File('$sshDir/id_ed25519.pub');
        if (await ed25519File.exists()) {
          final key = await ed25519File.readAsString();
          setState(() {
            _publicKey = key.trim();
            _privateKeyPath = '$sshDir/id_ed25519';
            _loading = false;
          });
        } else {
          setState(() => _loading = false);
        }
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SSH 密钥管理')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 公钥展示
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.key, size: 20),
                            const SizedBox(width: 8),
                            const Text('SSH 公钥', style: TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (_publicKey != null)
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18),
                                tooltip: '复制公钥',
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: _publicKey!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('公钥已复制到剪贴板')),
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_publicKey != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[850],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              _publicKey!,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                          )
                        else
                          const Text(
                            '未找到 SSH 公钥\n\n请先在终端执行：\nssh-keygen -t ed25519 -C "your@email.com"',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 使用说明
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('使用说明', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          '1. 将上方公钥添加到 GitHub/Gitee 的 SSH Keys 设置\n'
                          '2. 克隆时使用 SSH 地址（git@github.com:user/repo.git）\n'
                          '3. 私钥路径: ${_privateKeyPath ?? "未检测到"}',
                          style: const TextStyle(fontSize: 12, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}