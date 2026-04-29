# Changelog

所有重要的变更都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

## [1.0.0] - 2026-04-29

### 新增

#### dev-workflow
- 10阶段全栈开发工作流
- 全栈场景覆盖（10大场景）
- Java/Vue/MySQL/Docker/Kafka/Redis 支持
- 多Agent并行代码探索
- 架构设计多方案对比
- TDD 开发 + 覆盖率检查
- 三视角代码审查（简洁性/Bug/约定）
- 跨域集成验证（Phase 8）
- 部署上线流程（Phase 9）
- 热修复紧急修复流程（Phase 10）

#### dev-commands
- `/commit` - 安全提交命令
- `/push` - 安全推送命令
- `/merge` - 安全合并命令
- `/review` - 代码审查命令
- `/test` - 测试运行命令
- `/deploy` - 部署检查命令
- `/status` - 项目状态命令

#### dev-quality
- `bug-analyzer` - Bug分析与复盘
- `code-reviewer` - 全栈代码审查
- `design-reviewer` - 设计文档评审

#### 共享资源
- `rules/coding-java.md` - Java编码规范
- `rules/coding-vue.md` - Vue编码规范
- `rules/security.md` - 安全规则
- `rules/git-workflow.md` - Git工作流规范

### 技术细节

- 遵循 Claude Code 官方插件规范
- 插件命名：kebab-case
- Skills命名：SKILL.md（全大写）
- 完整 marketplace.json 配置
- 跨平台安装脚本（PowerShell + Bash）

---

## [0.0.1] - 2026-04-13

### 新增
- 初始版本创建
- feature-dev v1.0 基础框架
