# Changelog

所有重要的变更都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

## [2.8.0] - 2026-05-09

### 新增

#### dev-workflow v4.9.0
- **多工作流支持（P2）**：支持 4 种预置工作流切换
  - `full-feature`：完整 11 阶段全流程（~125K tokens）
  - `lightweight`：轻量 5 阶段核心流程（~30K tokens）
  - `hotfix`：极速 3 阶段热修复（~20K tokens）
  - `research`：调研 4 阶段输出报告（~31K tokens）
- **工作流加载器**：`skill-dev-workflow-loader` 技能
- **工作流验证脚本**：`scripts/validate-workflow.py`
- **动态阶段执行**：根据工作流配置启用/禁用 Phase
- **工作流切换**：执行中可随时切换工作流
- **`--workflow` 参数**：`/dev --workflow <name>` 直接指定工作流

#### dev-quality v2.8.0
- 版本号同步至 v2.8.0

### 修改
- `dev.md` 支持 `--workflow` 参数和动态阶段执行
- 更新调用方式说明（含 `--workflow` 参数）

---

## [2.7.0] - 2026-05-08

### 新增

#### dev-quality v2.7.0
- **qiankun 微前端整合**：`skill-dev-micro-frontend`（主应用改造/子应用开发/多项目整合）
- **Superpowers 对比章节**：README 新增与 Superpowers 的功能对比

#### dev-workflow v4.8.0
- **Phase 4.5 Spec Generation**：借鉴 OpenSpec（P0/P1）
- **`skill-dev-spec` v1.0.0**：4 场景完整流程（生成/更新/版本管理/批量）
- **Phase 7 增强**：新增 7b 规范归档步骤
- **配置文件模板**：`config-template.yaml`
- **流程扩展**：10 → 11 阶段

---

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
