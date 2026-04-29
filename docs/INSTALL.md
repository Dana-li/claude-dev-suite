# 安装指南

## 系统要求

- Claude Code 2.0.0 或更高版本
- Git
- 网络连接（用于克隆仓库）

## 安装方式

### 方式 1：Marketplace 安装（推荐）

```bash
# 1. 添加市场
claude plugin marketplace add Dana-li/claude-dev-suite

# 2. 安装插件
claude plugin install dev-workflow@dev-suite
claude plugin install dev-commands@dev-suite
claude plugin install dev-quality@dev-suite

# 3. 重启 Claude Code 使配置生效
```

### 方式 2：脚本安装

#### Windows

```powershell
# 克隆或下载本仓库后
.\scripts\install.ps1

# 或指定自定义仓库
.\scripts\install.ps1 -Repo "yourname/claude-dev-suite"
```

#### Linux / Mac

```bash
chmod +x scripts/install.sh
./scripts/install.sh

# 或指定自定义仓库
./scripts/install.sh -r "yourname/claude-dev-suite"
```

### 方式 3：手动安装

```bash
# 1. 克隆仓库
git clone https://github.com/Dana-li/claude-dev-suite.git

# 2. 复制插件
cp -r packages/dev-workflow ~/.claude/plugins/
cp -r packages/dev-commands ~/.claude/plugins/
cp -r packages/dev-quality ~/.claude/plugins/

# 3. 复制共享资源
cp -r shared/rules ~/.claude/rules/
cp -r shared/agents ~/.claude/agents/

# 4. 重启 Claude Code
```

## 验证安装

```bash
# 检查插件是否加载
claude plugin list

# 验证命令是否可用
/dev
```

## 卸载

```bash
# 删除插件
rm -rf ~/.claude/plugins/dev-workflow
rm -rf ~/.claude/plugins/dev-commands
rm -rf ~/.claude/plugins/dev-quality

# 删除共享资源
rm -rf ~/.claude/rules/coding-java.md
rm -rf ~/.claude/rules/coding-vue.md

# 重启 Claude Code
```

## 故障排除

### 插件未显示

1. 检查 Claude Code 版本：`claude --version`
2. 重启 Claude Code
3. 检查 `~/.claude/settings.json` 配置

### 命令不工作

1. 验证插件已安装：`ls ~/.claude/plugins/dev-workflow/commands/`
2. 检查命令文件格式
3. 重启 Claude Code

### 市场添加失败

```bash
# 设置 GitHub Token
export GITHUB_TOKEN=ghp_your_token_here

# 或使用完整的仓库地址
claude plugin marketplace add https://github.com/Dana-li/claude-dev-suite
```

## 常见问题

**Q: 安装后需要重启吗？**
A: 是的，需要重启 Claude Code 才能加载新插件。

**Q: 可以只安装部分插件吗？**
A: 可以，根据需要选择安装：
```bash
# 只安装工作流
claude plugin install dev-workflow@dev-suite

# 只安装命令
claude plugin install dev-commands@dev-suite

# 只安装质量工具
claude plugin install dev-quality@dev-suite
```