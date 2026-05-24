import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../application/providers/git_providers.dart';
import '../../domain/entities/entities.dart';

class CloneScreen extends ConsumerStatefulWidget {
  const CloneScreen({super.key});

  @override
  ConsumerState<CloneScreen> createState() => _CloneScreenState();
}

class _CloneScreenState extends ConsumerState<CloneScreen> {
  final _urlController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _isCloning = false;
  double _progress = 0;

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _doClone() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final platform = GitPlatform.fromUrl(url);
    final token = _tokenController.text.trim();
    String fullUrl = url;

    // Token 注入
    if (token.isNotEmpty && platform == GitPlatform.github) {
      fullUrl = url.replaceFirst('github.com', '.$token@github.com');
    } else if (platform == GitPlatform.gitee) {
      fullUrl = url.replaceFirst('gitee.com', '$token@gitee.com');
    }

    setState(() => _isCloning = true);

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final repoName = url.split('/').last.replaceAll('.git', '');
      final localPath = '${appDir.path}/repos/$repoName';

      final git = ref.read(gitServiceProvider);
      await git.clone(
        url: fullUrl,
        localPath: localPath,
        onProgress: (p) => setState(() => _progress = p),
        onCancel: () {},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('克隆成功')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('克隆失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCloning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('克隆仓库')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: '仓库地址',
                hintText: 'https://github.com/user/repo.git',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tokenController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Token / 密码',
                hintText: '输入你的访问令牌',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Token 将用于认证，可到 GitHub/Gitee 设置页生成',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const Spacer(),
            if (_isCloning) ...[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
              Text('${(_progress * 100).toInt()}%', textAlign: TextAlign.center),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isCloning ? null : _doClone,
              child: _isCloning
                  ? const Text('克隆中...')
                  : const Text('开始克隆'),
            ),
          ],
        ),
      ),
    );
  }
}