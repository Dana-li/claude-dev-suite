# Git 工作流规则

## 1. 分支管理

### 1.1 分支命名
```
feature/功能名称        # 新功能
bugfix/问题描述         # Bug 修复
hotfix/紧急修复         # 紧急修复
release/v1.0.0         # 发布分支
chore/任务描述          # 杂项任务
```

### 1.2 分支策略
- ✅ main/master：主分支，始终保持可发布状态
- ✅ develop：开发分支，集成所有功能
- ✅ feature/*：功能分支，从 develop 创建
- ✅ bugfix/*：修复分支，从 develop 创建
- ✅ hotfix/*：紧急修复，从 main 创建

## 2. 提交规范

### 2.1 提交信息格式
```
<type>(<scope>): <subject>

<body>

<footer>
```

### 2.2 Type 类型
| Type | 说明 |
|------|------|
| feat | 新功能 |
| fix | Bug 修复 |
| docs | 文档更新 |
| style | 代码格式（不影响功能）|
| refactor | 重构（不是新功能或修复）|
| perf | 性能优化 |
| test | 测试相关 |
| chore | 构建/工具相关 |

### 2.3 示例
```
feat(user): 添加用户注册功能

- 支持手机号注册
- 添加验证码校验
- 返回 JWT Token

Closes #123
```

## 3. 安全操作

### 3.1 禁止操作
- ❌ 禁止 force push 到 main/master
- ❌ 禁止删除已合并的分支
- ❌ 禁止跳过 pre-commit hook
- ❌ 禁止在 commit 中包含密钥或密码

### 3.2 必须检查
- ✅ commit 前检查 `git status`
- ✅ push 前检查分支名称
- ✅ merge 前确保测试通过
- ✅ 删除分支前确认已合并

## 4. Hooks 配置

### 4.1 Pre-commit Hook
- ✅ 运行 lint 检查
- ✅ 运行格式校验
- ✅ 检查提交信息格式

### 4.2 Commit-msg Hook
- ✅ 验证提交信息格式
- ✅ 禁止提交信息为空

### 4.3 Pre-push Hook
- ✅ 运行单元测试
- ✅ 检查代码覆盖率

## 5. 合并流程

### 5.1 Merge 流程
```
1. 从 develop 创建 feature 分支
2. 开发并提交
3. 推送分支
4. 创建 Pull Request
5. 代码审查
6. 合并到 develop
7. 删除 feature 分支
```

### 5.2 合并策略
- ✅ 使用 `--no-ff` 创建合并提交
- ✅ squash merge 用于清理历史
- ✅ rebase 用于保持线性历史

## 6. 安全检查命令

### 6.1 提交前检查
```bash
# 检查状态
git status

# 检查差异
git diff --staged

# 运行测试
npm test
```

### 6.2 推送前检查
```bash
# 检查分支
git branch -vv

# 检查远程差异
git log origin/main..main

# 安全推送
git push --force-with-lease
```

## 7. 错误处理

### 7.1 撤销操作
```bash
# 撤销暂存
git reset HEAD <file>

# 撤销提交（保留修改）
git reset --soft HEAD~1

# 撤销提交（删除修改）
git reset --hard HEAD~1
```

### 7.2 恢复误删分支
```bash
# 查找丢失的提交
git reflog

# 恢复分支
git checkout -b <branch> <commit-hash>
```
