---
name: skill-dev-worktree
description: "Git Worktree 隔离开发环境：为每个功能创建独立工作树，不在 main/master 上直接开发。自动检测目录、安全验证、清理流程。"
allowed-tools: Bash
---

# Git Worktree 隔离开发

> **核心原则：系统化目录选择 + 安全验证 = 可靠隔离**

---

## 铁律

> **`NO DIRECT DEVELOPMENT ON MAIN/MASTER BRANCH`**

每次开始需要与当前工作空间隔离的功能开发时，必须先创建 Git Worktree。

---

## 工作流程

```
开始功能开发
    │
    ▼
┌──────────────────────┐
│  Step 1: 目录选择     │
│  (检测已有 worktree   │
│   目录或询问用户)      │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  Step 2: 安全验证     │
│  (.gitignore 检查     │
│   + 目录确认)         │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  Step 3: 创建工作树   │
│  (git worktree add   │
│   + 分支创建)         │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  Step 4: 环境初始化   │
│  (安装依赖 +          │
│   运行测试确认基线)    │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  Step 5: 报告位置     │
│  (输出 worktree 路径  │
│   让用户确认)          │
└──────────────────────┘
```

---

## Step 1: 目录选择（优先级）

```
1. 检查是否存在 .worktrees/  目录 → 使用
2. 检查是否存在 worktrees/   目录 → 使用
3. 检查 CLAUDE.md 中是否有 worktree 目录配置 → 使用
4. 以上都不存在 → 询问用户: "请指定 worktree 存放目录"
```

## Step 2: 安全验证

```bash
# 检查 worktree 目录是否被 .gitignore 忽略
git check-ignore -q .worktrees 2>/dev/null
if [ $? -ne 0 ]; then
  git check-ignore -q worktrees 2>/dev/null
fi

# 如果未被忽略：添加到 .gitignore 并提交
if [ $? -ne 0 ]; then
  echo ".worktrees/" >> .gitignore
  echo "worktrees/" >> .gitignore
  git add .gitignore
  git commit -m "chore: add worktrees to .gitignore"
fi
```

## Step 3: 创建工作树

```bash
# 检测项目名称（从目录名/package.json/pom.xml 推断）
PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")
BRANCH_NAME="feature/$(date +%Y%m%d)-$(openssl rand -hex 4)"

# 创建工作树
git worktree add "$WORKTREE_DIR/$BRANCH_NAME" -b "$BRANCH_NAME"
```

## Step 4: 环境初始化

```bash
cd "$WORKTREE_DIR/$BRANCH_NAME"

# 自动检测项目类型并安装依赖
if [ -f "package.json" ]; then
  npm install 2>/dev/null || true
elif [ -f "pom.xml" ]; then
  mvn dependency:resolve 2>/dev/null || true
elif [ -f "requirements.txt" ]; then
  pip install -r requirements.txt 2>/dev/null || true
fi

# 运行测试确认基线
echo "运行测试确认基线..."
# （运行项目测试命令）
```

## Step 5: 报告位置

```markdown
**Worktree 已创建**

| 项目 | 值 |
|------|-----|
| 分支 | `feature/20260507-xxxx` |
| 工作树路径 | `/path/to/worktree` |
| 基础分支 | `main` |
| 测试基线 | 通过 |
```

---

## 其他常用命令

```bash
# 查看所有 worktrees
git worktree list

# 删除 worktree
git worktree remove <path>
git branch -d <branch-name>
```

---

## 使用方式

| 场景 | 触发方式 |
|------|----------|
| 功能开发 | `/dev-feature`（自动触发） |
| 独立使用 | `/skill-dev-worktree` |

## 版本

_版本: 1.0.0 | 更新: 2026-05-07_
