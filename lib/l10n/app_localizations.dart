import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  bool get isZh => locale.languageCode == 'zh';

  // Common
  String get appName => isZh ? 'GitVex' : 'GitVex';
  String get cancel => isZh ? '取消' : 'Cancel';
  String get confirm => isZh ? '确认' : 'Confirm';
  String get save => isZh ? '保存' : 'Save';
  String get delete => isZh ? '删除' : 'Delete';
  String get close => isZh ? '关闭' : 'Close';
  String get error => isZh ? '错误' : 'Error';
  String get loading => isZh ? '加载中...' : 'Loading...';

  // Home
  String get homeTitle => isZh ? '仓库列表' : 'Repositories';
  String get noRepos => isZh ? '暂无仓库' : 'No repositories';
  String get noReposHint => isZh ? '点击右上角 + 克隆或新建仓库' : 'Tap + to clone or create a repository';
  String get repoList => isZh ? '仓库列表' : 'Repository List';
  String get newRepo => isZh ? '新建仓库' : 'New Repository';
  String get cloneRepo => isZh ? '克隆仓库' : 'Clone Repository';
  String get importRepo => isZh ? '导入本地仓库' : 'Import Local Repository';
  String get switchBranch => isZh ? '切换分支' : 'Switch Branch';
  String get settings => isZh ? '设置' : 'Settings';
  String get rename => isZh ? '重命名' : 'Rename';
  String get removeRepo => isZh ? '移除仓库' : 'Remove Repository';

  // Repo Detail
  String get files => isZh ? '文件' : 'Files';
  String get commits => isZh ? '提交' : 'Commits';
  String get branches => isZh ? '分支' : 'Branches';
  String get browseFiles => isZh ? '浏览文件' : 'Browse Files';
  String get merge => isZh ? '合并' : 'Merge';
  String get stats => isZh ? '统计' : 'Statistics';
  String get pull => isZh ? '拉取' : 'Pull';
  String get push => isZh ? '推送' : 'Push';

  // Commit
  String get commitTitle => isZh ? '提交标题' : 'Commit Title';
  String get commitBody => isZh ? '详细说明（可选）' : 'Description (optional)';
  String get commitButton => isZh ? '提交' : 'Commit';
  String get commitSuccess => isZh ? '提交成功' : 'Committed successfully';
  String get noChanges => isZh ? '工作区干净，无变更' : 'Working tree clean';

  // Branch
  String get branchManage => isZh ? '分支管理' : 'Branch Management';
  String get newBranch => isZh ? '新建分支' : 'New Branch';
  String get deleteBranch => isZh ? '删除分支' : 'Delete Branch';
  String get currentBranch => isZh ? '当前' : 'Current';
  String get localBranch => isZh ? '本地分支' : 'Local branch';
  String get remoteBranch => isZh ? '远程分支' : 'Remote branch';

  // Settings
  String get settingsTitle => isZh ? '设置' : 'Settings';
  String get httpsToken => isZh ? 'HTTPS 令牌' : 'HTTPS Tokens';
  String get sshKey => isZh ? 'SSH 密钥' : 'SSH Keys';
  String get theme => isZh ? '外观' : 'Appearance';
  String get themeMode => isZh ? '主题模式' : 'Theme Mode';
  String get dark => isZh ? '深色' : 'Dark';
  String get light => isZh ? '浅色' : 'Light';
  String get system => isZh ? '跟随系统' : 'System';
  String get scanInterval => isZh ? '巡检周期' : 'Scan Interval';
  String get clearCache => isZh ? '清除缓存' : 'Clear Cache';
  String get resetDefaults => isZh ? '恢复默认配置' : 'Reset to Defaults';

  // Sync
  String get uncommittedChanges => isZh ? '存在未提交的改动' : 'Uncommitted Changes';
  String get forcePull => isZh ? '强制拉取' : 'Force Pull';
  String get stashChanges => isZh ? '暂存修改' : 'Stash Changes';
  String get remoteHasNewCommits => isZh ? '远程有新提交' : 'Remote Has New Commits';
  String get forcePush => isZh ? '继续推送' : 'Push Anyway';

  // Conflict
  String get conflictResolve => isZh ? '冲突处理' : 'Conflict Resolution';
  String get noConflicts => isZh ? '没有冲突文件' : 'No conflict files';
  String get conflictHint => isZh ? '编辑文件移除冲突标记后保存' : 'Edit file to remove conflict markers, then save';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['zh', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
