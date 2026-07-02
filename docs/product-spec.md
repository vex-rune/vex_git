# Vex Git - 产品需求规格

> 移动端 Git 客户端，对标 GitHub Desktop 的全部核心功能。

## 一、产品定位

- **目标用户**：习惯用 GitHub Desktop 但偶尔需要在手机上处理 PR、审查代码、紧急 commit 的开发者
- **核心场景**：通勤路上、出差途中、手机收到 CI 失败通知时
- **差异化**：手机独有的能力——扫一扫克隆、Share Intent 接收、生物识别解锁

## 二、功能清单（对标 GitHub Desktop）

### 1. 账户与认证
- F1.1 GitHub.com OAuth 登录（Device Flow）
- F1.2 GitHub Enterprise Server 登录
- F1.3 多账户切换
- F1.4 退出登录
- F1.5 账户头像 / 用户名展示
- F1.6 Token 撤销

### 2. 凭据管理（独立页面）
- F2.1 HTTPS 凭据：用户名、PAT
- F2.2 SSH 凭据：查看本地公钥、一键生成密钥对、导入外部私钥、公钥复制到剪贴板
- F2.3 凭据可绑定到单个仓库

### 3. 仓库
- F3.1 仓库列表（卡片：路径、当前分支、ahead/behind、未提交数）
- F3.2 Clone（URL / 用户仓库列表）
- F3.3 新建本地仓库
- F3.4 添加已存在的本地仓库
- F3.5 仓库管理：重命名、移除（仅从列表移除，不删 .git）、修改本地存储路径

### 4. 仓库详情（首页）
- F4.1 顶部仓库信息栏：名称、分支选择器、远端指示
- F4.2 Tab：Changes / History / Branches
- F4.3 Changes：变更文件列表（按新增/修改/删除着色）、行级 diff
- F4.4 History：commit 列表（图形化 lane）、commit 详情
- F4.5 Branches：本地 + 远程分支、检出/创建/删除
- F4.6 文件树浏览：展开/折叠、点文件看内容、上下滑动

### 5. 变更与提交
- F5.1 Working directory 实时监控（轮询机制）
- F5.2 选择性 stage / unstage（hunk 粒度）
- F5.3 全选 / 取消全选
- F5.4 Commit 消息（首行 + 详情 + co-author）
- F5.5 Amend last commit
- F5.6 Discard 变更
- F5.7 Stash：保存 / 弹出 / 丢弃
- F5.8 提交成功后自动返回首页

### 6. 同步
- F6.1 Fetch
- F6.2 Pull（前置校验：未提交改动时给 stash / 取消 / 放弃三选项）
- F6.3 Push（首次 push 询问是否 set-upstream）
- F6.4 Force push（带警告）
- F6.5 拉取 / 推送进度条
- F6.6 冲突时自动跳转冲突处理页

### 7. 分支
- F7.1 查看所有分支（local + remote）
- F7.2 切换分支
- F7.3 新建分支（指定起点）
- F7.4 删除分支（本地 / 远端，force 选项）
- F7.5 跟踪远程分支（set-upstream）
- F7.6 检出 PR 为本地分支
- F7.7 默认分支保护提示

### 8. 协作（GitHub）
- F8.1 PR 列表（open / closed / merged 筛选）
- F8.2 PR 详情：标题、描述、commits、changed files、review status、checks
- F8.3 创建 PR
- F8.4 合并 PR（merge / squash / rebase 三选项）
- F8.5 关闭 PR
- F8.6 Issue 列表（轻量浏览）
- F8.7 通知中心（mentions / review requests / CI 失败）

### 9. 历史
- F9.1 Commit 列表（按时间线、graph lane）
- F9.2 Commit 详情：作者、日期、message、变更文件、行级 diff
- F9.3 File history
- F9.4 Blame（行级归属）
- F9.5 Search commits（按 message / 作者 / 路径）

### 10. 设置
- F10.1 主题：System / Light / Dark
- F10.2 默认分支前缀（如 `feature/`）
- F10.3 提交签名：off / GPG / SSH
- F10.4 拉取前自动 fetch 开关
- F10.5 显示头像开关
- F10.6 通知提醒开关
- F10.7 语言切换（中文 / English）
- F10.8 仓库存储路径
- F10.9 定时巡检周期（10 / 20 / 自定义）
- F10.10 清除缓存
- F10.11 恢复默认配置
- F10.12 关于 / 版本号
- F10.13 诊断日志导出

### 11. 移动端专属
- F11.1 扫一扫克隆（识别 GitHub URL）
- F11.2 分享接收（Android Share Intent / iOS Share Extension）
- F11.3 生物识别解锁应用
- F11.4 手势操作（左滑 stage、右滑 discard）
- F11.5 长按弹出操作表
- F11.6 推送通知（PR 状态、CI 失败）

## 三、配置与存储

### `.vex_git.config`（明文 JSON，不含密钥）
- 路径：`<项目工作根>/.vex_git.config`
- 内容：账户元数据、偏好、UI 状态

### `.vex_git_store/`（仓库存储）
- 路径：`<项目工作根>/.vex_git_store/`
- 子目录：`repos/`（clone 的仓库）、`cache/`（API 缓存）、`logs/`（应用日志）

### 密钥存储
- 走平台原生：`flutter_secure_storage`（iOS Keychain / Android Keystore）

## 四、非目标（v1 不做）

- 交互式 rebase
- Submodule 管理
- LFS 支持
- 复杂合并工具
- 多账户同时操作
- 插件 / 扩展