# Vex Git - 路线图

## Phase 0：脚手架 ✅ 当前阶段
- [x] flutter create 初始化
- [x] Clean Architecture 目录结构
- [x] 规划文档（product-spec / architecture / roadmap）
- [ ] pubspec.yaml 完整依赖
- [ ] main.dart 入口
- [ ] 主题、路由占位
- [ ] flutter analyze 通过

## Phase 1：核心基础设施
- [ ] 配置加载器（.vex_git.config）
- [ ] Secure Storage 封装
- [ ] GitClient 接口（基于 libgit2 FFI）
- [ ] 错误体系
- [ ] Riverpod 全局 provider
- [ ] 主题（Material 3 + 自定义色板）
- [ ] 国际化（中/英）

## Phase 2：账户与认证
- [ ] GitHub Device Flow OAuth
- [ ] 多账户切换
- [ ] 凭据管理（PAT / SSH）
- [ ] 登录页 / 账户页 UI

## Phase 3：仓库管理
- [ ] 仓库列表页
- [ ] Clone（URL + 用户仓库）
- [ ] 新建本地仓库
- [ ] 添加本地仓库
- [ ] 仓库管理（重命名 / 移除 / 修改路径）

## Phase 4：变更与提交
- [ ] 实时变更监控
- [ ] Changes 页（文件列表 + 行级 diff）
- [ ] Stage / Unstage（Hunk 粒度）
- [ ] Commit（含 amend、co-author）
- [ ] Discard / Stash
- [ ] 提交详情页

## Phase 5：同步
- [ ] Fetch / Pull / Push
- [ ] 进度条 + 取消
- [ ] 冲突检测 + 跳转
- [ ] Force push 警告

## Phase 6：分支
- [ ] 分支列表 + 切换
- [ ] 创建 / 删除分支
- [ ] 跟踪远程
- [ ] 默认分支保护

## Phase 7：协作
- [ ] PR 列表 / 详情
- [ ] 创建 / 合并 / 关闭 PR
- [ ] Issue 列表
- [ ] 通知中心

## Phase 8：历史
- [ ] Commit 列表（lane 图形）
- [ ] File history / Blame
- [ ] Search commits

## Phase 9：设置
- [ ] 主题 / 语言 / 路径
- [ ] 通知开关
- [ ] 清除缓存
- [ ] 诊断日志

## Phase 10：移动端专属
- [ ] 扫一扫克隆
- [ ] 分享接收
- [ ] 生物识别
- [ ] 手势操作
- [ ] 推送通知

## Phase 11：质量与发布
- [ ] 单元测试覆盖率 > 60%
- [ ] Widget 测试覆盖关键页
- [ ] Crash 上报
- [ ] Android / iOS 构建配置