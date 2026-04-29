---
description: Run code review with pre-checks and best practices
argument-hint: Optional file path or commit range to review
---

# Code Review

> **版本**: v1.0
> **用途**: 规范化代码审查流程

---

## 执行步骤

### 1. 变更概览

```bash
# 查看变更文件
git diff --name-only

# 查看变更统计
git diff --stat

# 查看详细变更
git diff
```

### 2. 变更审查

**审查维度**:

| 维度 | 检查项 |
|------|--------|
| 功能 | 实现是否正确、完整 |
| 设计 | 架构是否合理、可扩展 |
| 代码 | 风格、命名、注释 |
| 测试 | 是否覆盖边界情况 |
| 安全 | 是否有漏洞、敏感信息 |
| 性能 | 是否有性能问题 |

### 3. 代码质量检查

**Java 检查项**:
- [ ] 遵循阿里 Java 规范
- [ ] 异常处理规范
- [ ] 日志规范
- [ ] 事务边界

**Vue 检查项**:
- [ ] 组件命名规范
- [ ] Composition API 使用
- [ ] TypeScript 类型
- [ ] 响应式最佳实践

### 4. 审查报告

输出格式：

```
## Code Review 报告

### 变更文件
- src/UserService.java
- src/UserController.java

### 优点
- ✅ 清晰的方法命名
- ✅ 完整的异常处理
- ✅ 单元测试覆盖

### 问题
- ⚠️ 建议：添加参数校验
- 🔴 严重：硬编码密码

### 建议
- 优化数据库索引
- 添加缓存策略
```

---

## 审查标准

| 级别 | 说明 | 行动 |
|------|------|------|
| 🔴 严重 | 必须修复 | 阻塞合并 |
| ⚠️ 建议 | 建议修复 | 讨论决定 |
| 💡 优化 | 可选改进 | 可延后 |

---

**版本**: v1.0
**创建日期**: 2026-04-29
