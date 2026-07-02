import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _info = info);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        children: [
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Icon(Icons.code, size: 72, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text('Vex Git', style: Theme.of(context).textTheme.headlineSmall),
                Text(
                  _info == null
                      ? 'loading...'
                      : 'v${_info!.version} (build ${_info!.buildNumber})',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const ListTile(
            leading: Icon(Icons.link),
            title: Text('Website'),
            subtitle: Text('github.com/yourname/vex_git'),
          ),
          const ListTile(
            leading: Icon(Icons.bug_report_outlined),
            title: Text('Report an issue'),
          ),
          const ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text('Licenses'),
          ),
        ],
      ),
    );
  }
}