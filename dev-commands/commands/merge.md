---
description: Safe merge with conflict resolution strategy
argument-hint: Source branch to merge from
---

# Git Safe Merge

> **版本**: v1.0
> **用途**: 安全合并分支，处理冲突

---

## 执行步骤

### 1. 确认分支状态

```bash
git branch --merged
git log --oneline -5
```

### 2. 更新目标分支

```bash
git checkout main
git pull origin main
```

### 3. 合并前检查

**检查项**:
- [ ] 测试通过
- [ ] 代码已审查
- [ ] 无未提交的变更

### 4. 执行合并

**快进合并**:
```bash
git merge feature-branch
```

**普通合并**:
```bash
git merge --no-ff feature-branch
```

**三方合并**:
```bash
git merge -X theirs feature-branch  # 保留对方
git merge -X ours feature-branch    # 保留我们
```

### 5. 冲突处理

```bash
# 查看冲突文件
git diff --name-only --diff-filter=U

# 解决冲突后
git add <resolved-files>
git commit
```

---

## 合并策略选择

| 场景 | 策略 | 命令 |
|------|------|------|
| 功能分支合并到 develop | --no-ff | 保留合并历史 |
| hotfix 合并到 main | --no-ff | 保留合并历史 |
| 快速修复 | 快进 | 自动合并 |
| 大型功能 | squash | 合并为一个提交 |

---

## 常见问题

### Q: 放弃合并？
```bash
git merge --abort
```

### Q: 合并后有问题？
```bash
# 查看合并前状态
git reflog
# 重置到合并前
git reset --hard HEAD@{N}
```

---

**版本**: v1.0
**创建日期**: 2026-04-29
