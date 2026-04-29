---
description: Show project status with branch info and pending changes
argument-hint: Optional filter (e.g., short, branch, upstream)
---

# Git Project Status

> **版本**: v1.0
> **用途**: 查看项目当前状态

---

## 执行步骤

### 1. 基础状态

```bash
git status
```

### 2. 分支信息

```bash
git branch -vva
```

### 3. 变更统计

```bash
git diff --stat
git diff --cached --stat
```

### 4. 提交历史

```bash
git log --oneline -10
```

### 5. 待处理工作

```bash
# 未提交的变更
git stash list

# 未推送的提交
git log origin/main..HEAD --oneline
```

---

## 输出格式

```
当前分支: feature/new-login
状态: 工作区干净 / 有未提交的变更

📊 变更统计:
  3 files changed, 45 insertions(+), 12 deletions(-)

📤 待推送 (3):
  abc1234 feat: add login page
  def5678 fix: resolve auth bug
  ghi9012 docs: update README

📥 远程领先 (2):
  origin/main: abcdef1 chore: update dependencies
```

---

## 检查清单

| 检查项 | 说明 |
|--------|------|
| 分支 | 当前在哪个分支 |
| 状态 | 工作区是否干净 |
| 待推送 | 有多少提交未推送 |
| 远程差异 | 领先/落后远程多少 |

---

**版本**: v1.0
**创建日期**: 2026-04-29
