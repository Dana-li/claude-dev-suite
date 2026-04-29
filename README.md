# Dev Suite for Claude Code

> 全栈开发工作流套件：需求 → 设计 → 开发 → 审查 → 部署 → 热修复

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/Dana-li/claude-dev-suite)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## ✨ 特性

- 🚀 **10 阶段工作流**：Discovery → Hotfix 全生命周期覆盖
- 🛠️ **全栈支持**：Java/Vue/MySQL/Docker/Kafka/Redis
- ✅ **质量保障**：TDD/审查/测试/安全/性能
- 📦 **一键安装**：开箱即用，跨平台支持
- 🔒 **安全命令**：防止常见 Git 操作失误
- 📚 **完整文档**：示例丰富，上手即用

## 📦 包含插件

### 1. dev-workflow
10阶段全栈开发工作流

| Phase | 名称 | 说明 |
|-------|------|------|
| 1 | Discovery | 需求发现与确认 |
| 2 | Exploration | 代码库探索（多Agent并行） |
| 3 | Clarification | 澄清问题 + 风险评估 |
| 4 | Architecture | 架构设计（多方案对比） |
| 5 | Implementation | 开发实现（TDD + 覆盖率） |
| 6 | Quality Review | 质量审查（三视角 + 安全） |
| 7 | Summary | 总结归档 |
| 8 | Integration | 跨域集成（API/队列/缓存） |
| 9 | Deployment | 部署上线（CI/CD + 监控） |
| 10 | Hotfix | 紧急修复（生产问题） |

### 2. dev-commands
Git 开发辅助命令集

| 命令 | 功能 |
|------|------|
| `/commit` | 安全提交（检查+格式化+提交） |
| `/push` | 安全推送（检查+强制推送警告） |
| `/merge` | 安全合并（冲突检查+回滚方案） |
| `/review` | 代码审查 |
| `/test` | 运行测试 |
| `/deploy` | 部署检查 |
| `/status` | 项目状态 |

### 3. dev-quality
代码审查与质量保障

| Skill | 功能 |
|-------|------|
| bug-analyzer | Bug 分析与复盘 |
| code-reviewer | 全栈代码审查 |
| design-reviewer | 设计文档评审 |

## 🚀 安装

### 方式 1：Marketplace 安装（推荐）

```bash
# 添加市场
claude plugin marketplace add Dana-li/claude-dev-suite

# 安装插件
claude plugin install dev-workflow@dev-suite
claude plugin install dev-commands@dev-suite
claude plugin install dev-quality@dev-suite
```

### 方式 2：手动安装

```bash
# 克隆仓库
git clone https://github.com/Dana-li/claude-dev-suite.git

# Windows 安装脚本
.\scripts\install.ps1

# Linux/Mac 安装脚本
chmod +x scripts/install.sh
./scripts/install.sh
```

## 📖 快速开始

### 新功能开发

```bash
/dev
# 选择 dev-workflow 开始 10 阶段工作流
```

### Bug 修复

```bash
/bug-analyzer
# 分析 Bug 并生成修复方案
```

### 安全提交

```bash
/commit
# 安全的 Git 提交流程
```

## 🛠️ 全栈场景覆盖

| 场景 | 技术栈 | Skills |
|------|--------|--------|
| 后端开发 | Java/Spring Boot | design-generator, spring-boot-reviewer |
| 前端开发 | Vue 3/Ant Design | vue-reviewer, vue-testing-best-practices |
| 数据库操作 | MySQL/PostgreSQL | MySQL Administration |
| API 集成 | REST/SOAP | design-reviewer |
| 消息队列 | Kafka/RabbitMQ | spring-boot-reviewer |
| 缓存策略 | Redis | research |
| DevOps | Docker/K8s | dev-workflow Phase 9 |
| 安全审计 | OWASP | security-audit |

## 📚 文档

- [安装指南](./docs/INSTALL.md)
- [使用示例](./packages/dev-workflow/docs/examples/)
- [贡献指南](./docs/CONTRIBUTING.md)
- [变更日志](./CHANGELOG.md)

## 🔄 版本历史

详见 [CHANGELOG.md](./CHANGELOG.md)

## 📄 许可证

MIT License - 详见 [LICENSE](./LICENSE) 文件

## 🙏 致谢

- 基于 [LedgerHQ/ledger-live feature-dev](https://github.com/LedgerHQ/ledger-live) 增强
- 遵循 [Claude Code 官方最佳实践](https://code.claude.com/docs/en/best-practices)
- 插件规范参考 [jaan.to Claude Code Plugin Patterns](https://docs.jaan.to)

## 👤 作者

**LeeDC**
- GitHub: [@Dana-li](https://github.com/Dana-li)

---

⭐ 如果对你有帮助，请给个 Star！
