---
description: Create a safe commit with validation and proper message format
argument-hint: Optional commit message (will prompt if not provided)
---

# Git Safe Commit

> **版本**: v1.0
> **用途**: 安全提交代码，遵循 Conventional Commits 规范

---

## 执行步骤

### 1. 检查工作区状态

```bash
git status
```

### 2. 检查变更内容

```bash
git diff --stat
```

### 3. 验证变更文件

**检查项**:
- [ ] 没有意外文件
- [ ] 没有敏感信息（密码、密钥、Token）
- [ ] 没有临时文件（*.tmp, *.log）
- [ ] 没有调试代码

### 4. 分阶段提交（如需要）

```bash
# 查看待提交文件
git diff --cached --name-only

# 交互式添加
git add -p
```

### 5. 生成 Commit 消息

遵循 Conventional Commits 格式：

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

**Type 类型**:
| Type | 说明 |
|------|------|
| feat | 新功能 |
| fix | 修复 bug |
| docs | 文档更新 |
| style | 格式调整 |
| refactor | 重构 |
| test | 测试 |
| chore | 工具/构建 |

### 6. 提交

```bash
git commit -m "your message"
```

---

## 安全检查清单

| 检查项 | 状态 |
|--------|------|
| 工作区干净 | ☐ |
| 变更内容正确 | ☐ |
| 无敏感信息 | ☐ |
| 遵循提交规范 | ☐ |
| 关联 Issue（可选） | ☐ |

---

**版本**: v1.0
**创建日期**: 2026-04-29
