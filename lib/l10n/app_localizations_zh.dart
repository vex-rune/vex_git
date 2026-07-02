// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Vex Git';

  @override
  String get navHome => '首页';

  @override
  String get navChanges => '变更';

  @override
  String get navHistory => '历史';

  @override
  String get navBranches => '分支';

  @override
  String get navPullRequests => '拉取请求';

  @override
  String get navSettings => '设置';

  @override
  String get authLoginTitle => '登录 GitHub';

  @override
  String get authLoginSubtitle => '连接你的 GitHub 账户以克隆、提交与协作。';

  @override
  String get authLoginButton => '使用 GitHub 登录';

  @override
  String get authEnterprise => '登录 GitHub Enterprise';

  @override
  String get authDeviceCode => '在 GitHub 上输入此代码';

  @override
  String get authOpenBrowser => '打开 GitHub';

  @override
  String get authAwaiting => '等待授权...';

  @override
  String get authSuccess => '登录成功';

  @override
  String get authFailed => '登录失败';

  @override
  String get authLogout => '退出登录';

  @override
  String get repoListTitle => '仓库';

  @override
  String get repoAdd => '添加仓库';

  @override
  String get repoClone => '克隆仓库';

  @override
  String get repoCreate => '新建本地仓库';

  @override
  String get repoAddExisting => '添加本地仓库';

  @override
  String get repoCloneUrl => '仓库地址';

  @override
  String get repoClonePath => '本地路径';

  @override
  String get repoCloneStart => '克隆';

  @override
  String get repoCreateName => '仓库名';

  @override
  String get repoCreatePath => '路径';

  @override
  String get repoCreateInit => '初始化';

  @override
  String get repoNoRepos => '还没有仓库';

  @override
  String get repoNoReposHint => '克隆一个仓库或添加本地仓库开始使用。';

  @override
  String repoAhead(int count) {
    return '领先 $count 个提交';
  }

  @override
  String repoBehind(int count) {
    return '落后 $count 个提交';
  }

  @override
  String repoChanges(int count) {
    return '$count 个变更';
  }

  @override
  String get repoRemove => '从列表移除';

  @override
  String get repoRename => '重命名';

  @override
  String get repoSetPath => '修改本地路径';

  @override
  String get repoOpen => '打开';

  @override
  String get branchCurrent => '当前分支';

  @override
  String get branchCreate => '新建分支';

  @override
  String get branchDelete => '删除';

  @override
  String get branchCheckout => '检出';

  @override
  String get branchMergeInto => '合并到当前';

  @override
  String get branchName => '分支名';

  @override
  String get branchFrom => '起点';

  @override
  String get branchLocal => '本地';

  @override
  String get branchRemote => '远程';

  @override
  String get branchNoBranches => '暂无分支';

  @override
  String get branchDefaultProtected => '受保护的默认分支';

  @override
  String get changesTitle => '变更';

  @override
  String get changesStage => '暂存';

  @override
  String get changesUnstage => '取消暂存';

  @override
  String get changesDiscard => '放弃';

  @override
  String get changesSelectAll => '全选';

  @override
  String get changesDeselectAll => '取消全选';

  @override
  String get changesCommit => '提交';

  @override
  String get changesCommitMessage => '提交信息';

  @override
  String get changesCommitDescription => '详细说明（可选）';

  @override
  String get changesCommitAmend => '修改上次提交';

  @override
  String get changesCommitCoAuthor => '合著者';

  @override
  String get changesStash => '储藏';

  @override
  String get changesStashPop => '弹出储藏';

  @override
  String get changesStashApply => '应用储藏';

  @override
  String get changesStashDrop => '丢弃储藏';

  @override
  String get changesNoChanges => '无变更';

  @override
  String get changesWorking => '工作区';

  @override
  String get changesStaged => '已暂存';

  @override
  String get historyTitle => '历史';

  @override
  String get historySearch => '搜索提交';

  @override
  String get historyNoCommits => '暂无提交';

  @override
  String get historyAuthor => '作者';

  @override
  String get historyDate => '日期';

  @override
  String get historyMessage => '信息';

  @override
  String get historyFiles => '变更文件';

  @override
  String get historyFileHistory => '文件历史';

  @override
  String get historyBlame => '追溯';

  @override
  String get syncFetch => '拉取';

  @override
  String get syncPull => '拉取合并';

  @override
  String get syncPush => '推送';

  @override
  String get syncForcePush => '强制推送';

  @override
  String syncInProgress(String operation) {
    return '$operation 进行中...';
  }

  @override
  String syncSuccess(String operation) {
    return '$operation 成功';
  }

  @override
  String syncFailed(String operation) {
    return '$operation 失败';
  }

  @override
  String get syncUncommittedWarn => '你有未提交的变更';

  @override
  String get syncUncommittedStash => '储藏后继续';

  @override
  String get syncUncommittedCancel => '取消';

  @override
  String get syncUncommittedDiscard => '放弃变更';

  @override
  String get syncForcePushWarn => '强制推送将覆盖远程历史';

  @override
  String get syncForcePushConfirm => '强制推送';

  @override
  String get syncConflicts => '检测到冲突';

  @override
  String get syncConflictsResolve => '解决冲突';

  @override
  String get conflictTitle => '解决冲突';

  @override
  String get conflictLocal => '本地';

  @override
  String get conflictRemote => '远程';

  @override
  String get conflictBase => '基础';

  @override
  String get conflictKeepLocal => '保留本地';

  @override
  String get conflictKeepRemote => '保留远程';

  @override
  String get conflictKeepBoth => '都保留';

  @override
  String get conflictManual => '手动编辑';

  @override
  String get conflictStageResolved => '标记为已解决';

  @override
  String get prTitle => '拉取请求';

  @override
  String get prOpen => '开放';

  @override
  String get prClosed => '已关闭';

  @override
  String get prMerged => '已合并';

  @override
  String get prNoPRs => '暂无拉取请求';

  @override
  String get prCreate => '创建拉取请求';

  @override
  String get prMerge => '合并';

  @override
  String get prSquash => '压缩合并';

  @override
  String get prRebase => '变基合并';

  @override
  String get prClose => '关闭';

  @override
  String get prReview => '审查';

  @override
  String get prChecks => '检查';

  @override
  String get prFiles => '文件';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsGit => 'Git';

  @override
  String get settingsDefaultBranchPrefix => '默认分支前缀';

  @override
  String get settingsCommitSigning => '提交签名';

  @override
  String get settingsSigningOff => '关闭';

  @override
  String get settingsSigningGpg => 'GPG';

  @override
  String get settingsSigningSsh => 'SSH';

  @override
  String get settingsSync => '同步';

  @override
  String get settingsAutoFetch => '提交前自动拉取';

  @override
  String get settingsShowAvatars => '显示头像';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsNotificationsEnabled => '启用通知';

  @override
  String get settingsStorage => '存储';

  @override
  String get settingsStoragePath => '仓库存储路径';

  @override
  String get settingsStoragePathHint => '新克隆的存放位置';

  @override
  String get settingsAutoScanInterval => '自动巡检周期';

  @override
  String get settingsAutoScan10 => '10 分钟';

  @override
  String get settingsAutoScan20 => '20 分钟';

  @override
  String get settingsAutoScanCustom => '自定义';

  @override
  String get settingsClearCache => '清除缓存';

  @override
  String get settingsResetConfig => '恢复默认';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsVersion => '版本';

  @override
  String get settingsExportLogs => '导出诊断日志';

  @override
  String get credentialsTitle => '凭据';

  @override
  String get credentialsHttps => 'HTTPS';

  @override
  String get credentialsUsername => '用户名';

  @override
  String get credentialsToken => '个人访问令牌';

  @override
  String get credentialsSsh => 'SSH';

  @override
  String get credentialsSshKey => 'SSH 密钥';

  @override
  String get credentialsSshGenerate => '生成新密钥';

  @override
  String get credentialsSshImport => '导入私钥';

  @override
  String get credentialsSshCopyPublic => '复制公钥';

  @override
  String get credentialsSshCopied => '公钥已复制到剪贴板';

  @override
  String get credentialsAddAccount => '添加账户';

  @override
  String get commonOk => '确定';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确认';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonRetry => '重试';

  @override
  String get commonLoading => '加载中...';

  @override
  String get commonError => '错误';

  @override
  String get commonNetworkError => '网络错误';

  @override
  String get commonAuthError => '认证失败';

  @override
  String get commonNotFound => '未找到';

  @override
  String get commonUnknown => '未知错误';
}
