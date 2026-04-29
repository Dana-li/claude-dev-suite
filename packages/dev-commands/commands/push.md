---
description: Safe push with validation and upstream setup
argument-hint: Optional branch name (defaults to current branch)
---

# Git Safe Push

> **版本**: v1.0
> **用途**: 安全推送代码，防止意外覆盖

---

## 执行步骤

### 1. 检查当前状态

```bash
git status
git branch --show-current
```

### 2. 检查远程分支差异

```bash
git log origin/main..HEAD --oneline
```

### 3. 预发布检查

**检查项**:
- [ ] 工作区干净
- [ ] 最新代码已拉取
- [ ] 没有冲突待解决
- [ ] 测试通过

### 4. 推送

**首次推送（设置上游）**:
```bash
git push -u origin HEAD
```

**后续推送**:
```bash
git push
```

### 5. 验证

```bash
git log -1 --oneline
```

---

## 安全规则

| 规则 | 说明 |
|------|------|
| 禁止强制推送 | `push --force` 需要确认 |
| 保护分支 | main/develop 必须 PR 合并 |
| 推送前拉取 | 始终 `git pull --rebase` |

---

## 常见问题

### Q: 远程有更新？
```bash
git fetch origin
git rebase origin/main
git push
```

### Q: 冲突怎么办？
```bash
git status
# 解决冲突
git add .
git rebase --continue
git push
```

---

**版本**: v1.0
**创建日期**: 2026-04-29
