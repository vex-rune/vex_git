# GitVex

基于 Flutter 的移动端 Git 客户端，支持 GitHub & Gitee，采用纯 Dart 实现（git_on_dart）。

## 功能概览

### 仓库管理

- 新建本地仓库、克隆远程仓库、导入已有 Git 仓库
- 仓库列表持久化（重启后保留）
- 长按仓库 → 重命名 / 移除（仅解除绑定，不删文件）
- 仓库级凭证绑定（vex/vex.config）

### 文件浏览

- 递归文件树展示，支持目录展开/折叠
- 查看文件内容，支持代码高亮
- 变更文件行级预览（带冲突标记高亮）

### 提交管理

- 变更文件勾选、填写提交信息、生成本地提交记录
- 文件内容预览（底部弹窗，支持行号和冲突标记）

### 提交历史

- 查看提交日志，按时间倒序排列
- 提交详情页展示 SHA、作者、邮箱、时间、父提交

### 分支操作

- 查看分支列表、切换分支、新建分支、删除分支
- 合并分支（弹窗选择目标分支）

### 拉取 / 推送

- 一键拉取远端更新、推送本地提交至 origin
- 拉取前置校验：检测未提交改动，提示暂存/强制拉取
- 推送版本冲突检测：远程有新提交时弹窗提醒

### 冲突处理

- 冲突文件检测（扫描冲突标记）
- 冲突可视化编辑页面（标记高亮，支持手动编辑保存）

### 同步状态

- 实时显示工作区变更文件数量，角标快速跳转提交页
- 定时远程巡检（可配置周期：10/20/30 分钟，1 小时）
- 检测到远程更新时推送通知

### SSH 密钥

- 自动检测 ~/.ssh 下的 RSA / Ed25519 公钥
- 一键复制公钥，使用说明引导

### 系统设置

- 主题切换（深色 / 浅色 / 跟随系统）
- 中英文语言支持（基础 i18n）
- Token 管理（存储于 vex/vex.config）
- 巡检周期配置
- 缓存清除、恢复默认配置

### 提交统计

- 总提交数、贡献者数、近 7 天提交数
- 贡献者排行（进度条可视化）
- 最近 7 天提交趋势图

## 快速开始

### 环境要求

- Flutter >= 3.41.9
- Dart SDK >= 3.11.5

### 运行

```bash
# 获取依赖
flutter pub get

# 运行调试版
flutter run

# 构建 APK
flutter build apk --debug
```

## 配置文件

凭证和密钥存储在 App 文档目录下的 `vex/vex.config`：

```
<app_doc_dir>/vex/vex.config
```

格式为 JSON：

```json
{
  "github_token": "ghp_xxx",
  "gitee_token": "xxx"
}
```

## 项目结构

```
lib/
├── main.dart                          # 应用入口 & 路由配置
├── l10n/
│   └── app_localizations.dart         # 国际化
├── domain/
│   ├── entities/                      # 实体定义
│   │   ├── repository.dart            # 仓库实体（含 token 字段）
│   │   ├── git_commit.dart            # 提交实体
│   │   ├── git_branch.dart            # 分支实体
│   │   ├── file_change.dart           # 文件变更实体
│   │   ├── git_platform.dart          # Git 平台枚举
│   │   └── sync_status.dart           # 同步状态 & 异常类型
│   └── services/
│       └── git_service.dart           # Git 操作抽象接口
├── infrastructure/
│   └── git/
│       └── git_on_dart_impl.dart      # git_on_dart 具体实现
├── application/
│   ├── providers/
│   │   ├── git_providers.dart         # Git 状态管理
│   │   └── settings_providers.dart    # 设置 & 凭证管理
│   └── services/
│       └── remote_scanner.dart        # 定时远程巡检
├── presentation/
│   ├── screens/
│   │   ├── home_screen.dart           # 首页（仓库列表 + 汉堡菜单）
│   │   ├── clone_screen.dart          # 克隆仓库
│   │   ├── repo_detail_screen.dart    # 仓库详情（文件/提交/分支 Tab）
│   │   ├── commit_screen.dart         # 提交编辑 + 文件预览
│   │   ├── commit_detail_screen.dart  # 提交详情
│   │   ├── file_viewer_screen.dart    # 文件/目录浏览
│   │   ├── branch_screen.dart         # 分支管理
│   │   ├── conflict_screen.dart       # 冲突可视化处理
│   │   ├── stats_screen.dart          # 提交统计
│   │   └── settings_screen.dart       # 系统设置
│   └── widgets/
│       └── file_tree_widget.dart      # 递归文件树组件
└── core/
    └── errors/
        └── exceptions.dart            # 业务异常定义
```

## 技术栈

| 包 | 用途 |
|----|------|
| git_on_dart | 纯 Dart Git 实现 |
| flutter_riverpod | 状态管理 |
| go_router | 声明式路由导航 |
| path_provider | 应用目录路径 |
| shared_preferences | 轻量配置存储 |
| equatable | 实体相等性比较 |
| intl | 日期格式化 |
| flutter_localizations | 国际化支持 |

## 页面路由

| 路径 | 页面 |
|------|------|
| `/` | 首页（仓库列表） |
| `/clone` | 克隆仓库 |
| `/repo/:id` | 仓库详情 |
| `/repo/:id/commit` | 提交编辑 |
| `/repo/:id/commit/:sha` | 提交详情 |
| `/repo/:id/file?path=` | 文件浏览 |
| `/repo/:id/branch` | 分支管理 |
| `/repo/:id/conflict` | 冲突处理 |
| `/repo/:id/stats` | 提交统计 |
| `/settings` | 系统设置 |

## License

MIT
