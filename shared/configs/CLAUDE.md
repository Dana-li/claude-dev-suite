---
name: CLAUDE.md
description: Claude Code 全局主规则 - Dev Suite 核心配置
---

# Dev Suite 全局规则

> 本文件是 Claude Code 的全局主规则，定义了开发工作流的核心行为和最佳实践。

## 1. 工作流概览

### 1.1 10 阶段开发流程

```
┌─────────────────────────────────────────────────────────────────┐
│                    Dev Suite 10 阶段工作流                       │
├─────┬─────────────┬─────────────────────────────────────────────┤
│ #   │ 阶段         │ 核心任务                                    │
├─────┼─────────────┼─────────────────────────────────────────────┤
│ 1   │ Discovery   │ 需求发现、理解用户意图、确定范围              │
│ 2   │ Exploration │ 代码探索、阅读现有实现、分析依赖              │
│ 3   │ Clarification│ 需求澄清、补充缺失信息、消除歧义              │
│ 4   │ Architecture│ 架构设计、技术选型、模块划分                  │
│ 5   │ Implementation│ 开发实现、编码规范、单元测试               │
│ 6   │ Quality     │ 代码审查、质量检查、测试验证                  │
│ 7   │ Summary     │ 结果总结、文档更新、交接说明                  │
│ 8   │ Integration │ 跨域集成、接口对接、联调测试                  │
│ 9   │ Deployment  │ 部署上线、环境配置、监控告警                  │
│ 10  │ Hotfix      │ 紧急修复、Bug 分析、版本回滚                  │
└─────┴─────────────┴─────────────────────────────────────────────┘
```

### 1.2 触发命令

| 命令 | 场景 |
|------|------|
| `/dev` | 完整 10 阶段工作流 |
| `/dev-feature` | 新功能开发 |
| `/dev-bugfix` | Bug 修复 |
| `/dev-refactor` | 重构优化 |
| `/dev-review` | 代码审查 |
| `/dev-deploy` | 部署上线 |
| `/commit` | 安全提交 |
| `/push` | 安全推送 |
| `/close` | 任务关闭检查 |

## 2. 开发规范

### 2.1 代码规范

- 遵循项目已有的代码风格
- 使用项目目录下的 `rules/` 中的规范
- Java: 遵循 Spring Boot 最佳实践
- Vue: 使用 Composition API + TypeScript

### 2.2 文件组织

```
src/
├── main/
│   ├── java/com/example/
│   │   ├── controller/    # Controller 层
│   │   ├── service/       # Service 层
│   │   ├── mapper/        # Mapper 层
│   │   ├── model/         # 数据模型
│   │   └── config/        # 配置类
│   └── resources/
│       ├── mapper/        # MyBatis XML
│       └── application.yml
└── test/
    └── java/              # 测试代码
```

### 2.3 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| Java 类 | UpperCamelCase | `UserService` |
| Java 方法 | lowerCamelCase | `getUserById()` |
| Java 常量 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| Vue 组件 | PascalCase | `UserProfile.vue` |
| 数据库表 | 小写下划线 | `biz_user_order` |
| API 路径 | kebab-case | `/api/v1/user-order` |

## 3. 安全规则

### 3.1 必须遵守

- ⚠️ 所有用户输入必须校验
- ⚠️ SQL 使用参数化查询
- ⚠️ 禁止在代码中硬编码密钥
- ⚠️ 接口必须权限控制
- ⚠️ 敏感数据必须脱敏日志

### 3.2 禁止操作

- ❌ 删除生产数据库
- ❌ force push 到 main/master
- ❌ 在 commit 中包含密码/密钥
- ❌ 绕过安全检查

## 4. 质量保障

### 4.1 代码审查清单

- [ ] 代码逻辑正确性
- [ ] 边界条件处理
- [ ] 异常处理完整性
- [ ] 安全漏洞检查
- [ ] 性能考虑
- [ ] 代码可读性
- [ ] 单元测试覆盖

### 4.2 测试要求

| 类型 | 覆盖率目标 | 说明 |
|------|------------|------|
| 核心业务 | ≥80% | Service 层核心方法 |
| 新增功能 | 100% | 关键路径 |
| Bug 修复 | 必须有回归测试 | 防止复发 |

## 5. Git 工作流

### 5.1 分支命名

```
feature/功能名称        # 新功能
bugfix/问题描述         # Bug 修复
hotfix/紧急修复         # 紧急修复
```

### 5.2 提交规范

```
<type>(<scope>): <subject>

feat(user): 添加用户注册功能

- 支持手机号注册
- 添加验证码校验
```

### 5.3 安全操作

- ✅ commit 前运行测试
- ✅ push 前检查分支
- ✅ merge 前确认测试通过
- ✅ 使用 `--force-with-lease` 代替 `--force`

## 6. 文档要求

### 6.1 必须更新的文档

- API 接口文档（新增/修改时）
- README（重大变更时）
- CHANGELOG（版本发布时）

### 6.2 文档位置

| 类型 | 位置 |
|------|------|
| 项目文档 | `docs/` |
| API 文档 | `docs/api/` |
| 设计文档 | `docs/design/` |
| Bug 复盘 | `docs/bug-fix/` |

## 7. 环境配置

### 7.1 开发环境

- 数据库：本地 MySQL/PostgreSQL
- 缓存：本地 Redis
- 消息队列：本地 Kafka（Docker）

### 7.2 环境变量

```
DATABASE_URL=...
REDIS_URL=...
KAFKA_BROKERS=...
JWT_SECRET=...
```

## 8. 效率提示

### 8.1 常用快捷命令

```bash
# 快速运行测试
./mvnw test

# 代码格式化
./mvnw spotless:apply

# 查看依赖树
./mvnw dependency:tree
```

### 8.2 调试技巧

- 使用 `log.debug()` 输出调试信息
- IDEA 中使用 Evaluate Expression
- 使用 Postman/curl 测试 API

## 9. 参考资源

- 编码规范：`~/.claude/rules/`
- Skills：`~/.claude/skills/`
- Agents：`~/.claude/agents/`
- Hooks：`~/.claude/hooks/`
- MCP 配置：`~/.claude.json`
