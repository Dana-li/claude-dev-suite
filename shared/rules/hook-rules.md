# Hooks 配置规范

## 1. Hooks 概述

Hooks 是 Claude Code 生命周期中的自动化脚本，用于在特定事件发生时执行自定义逻辑。

## 2. Hook 类型

### 2.1 可用 Hooks

| Hook | 时机 | 用途 |
|------|------|------|
| SessionStart | 会话开始 | 加载上下文、初始化状态 |
| SessionEnd | 会话结束 | 保存会话摘要、清理资源 |
| PreCompact | 压缩前 | 提取关键信息、生成快照 |
| PostCompact | 压缩后 | 恢复上下文、验证状态 |
| PreToolUse | 工具调用前 | 输入验证、权限检查 |
| PostToolUse | 工具调用后 | 日志记录、状态同步 |
| Stop | 停止命令前 | 完成验证、清理检查 |
| PostToolUseFailure | 工具失败后 | 错误分析、恢复建议 |

### 2.2 Hook 配置位置
- **全局 Hooks**：`~/.claude/settings.json`
- **项目 Hooks**：`项目目录/.claude/settings.json`

## 3. Hook 配置格式

### 3.1 settings.json 配置
```json
{
  "hooks": {
    "SessionStart": [
      {
        "command": "echo",
        "args": ["session started"]
      }
    ],
    "PreToolUse": [
      {
        "command": "path/to/hook.sh",
        "env": {
          "ALLOWED_COMMANDS": "git,node,npm"
        }
      }
    ]
  }
}
```

### 3.2 Hook 脚本位置
```
~/.claude/hooks/
├── session-start.sh
├── session-end.sh
├── pre-tool-use.sh
├── post-tool-use.sh
└── ...
```

## 4. 内置 Hooks 示例

### 4.1 SessionStart Hook
```bash
#!/bin/bash
# ~/.claude/hooks/session-start.sh

# 加载项目上下文
if [ -f ".claude/CLAUDE.md" ]; then
  echo "Loaded project context from .claude/CLAUDE.md"
fi

# 设置环境变量
export NODE_ENV=development

echo "Session initialized"
```

### 4.2 PreToolUse Hook（危险命令检查）
```bash
#!/bin/bash
# ~/.claude/hooks/pre-tool-use.sh

TOOL_NAME="$1"
COMMAND="$2"

# 检查危险命令
DANGEROUS_COMMANDS="rm -rf|format|dd|mkfs"
for cmd in $DANGEROUS_COMMANDS; do
  if [[ "$COMMAND" == *"$cmd"* ]]; then
    echo "⚠️ Warning: Potentially dangerous command detected: $cmd"
    echo "Command: $COMMAND"
    echo "Use --force to proceed anyway"
    exit 1
  fi
done

exit 0
```

### 4.3 PostToolUse Hook（操作日志）
```bash
#!/bin/bash
# ~/.claude/hooks/post-tool-use.sh

TOOL_NAME="$1"
ARGS="$2"
EXIT_CODE="$3"

# 记录操作日志
LOG_FILE="$HOME/.claude/logs/tool-use.log"
mkdir -p "$(dirname "$LOG_FILE")"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] $TOOL_NAME - Exit: $EXIT_CODE" >> "$LOG_FILE"

# 仅记录重要工具
if [[ "$TOOL_NAME" == "Bash" || "$TOOL_NAME" == "Write" ]]; then
  echo "  Args: $ARGS" >> "$LOG_FILE"
fi
```

### 4.4 SessionEnd Hook（会话摘要）
```bash
#!/bin/bash
# ~/.claude/hooks/session-end.sh

# 生成会话摘要
SESSION_DURATION="${CLAUDE_SESSION_DURATION:-0}"
TOOLS_USED="${CLAUDE_TOOLS_USED:-0}"

echo "Session Summary:"
echo "  Duration: ${SESSION_DURATION}s"
echo "  Tools used: $TOOLS_USED"

# 保存到历史
echo "$(date): Duration=${SESSION_DURATION}s, Tools=${TOOLS_USED}" >> "$HOME/.claude/logs/history.log"
```

## 5. Windows Hooks

### 5.1 PowerShell 格式
```powershell
# ~/.claude/hooks/session-start.ps1

Write-Host "Session starting..."

# Load project context
if (Test-Path ".claude\CLAUDE.md") {
    Write-Host "Loaded project context"
}

# Set environment
$env:NODE_ENV = "development"

Write-Host "Session initialized"
```

### 5.2 PreToolUse Hook (PowerShell)
```powershell
# ~/.claude/hooks/pre-tool-use.ps1

param(
    [string]$ToolName,
    [string]$Command
)

$DangerousCommands = @("rm -rf", "format", "dd", "mkfs")

foreach ($cmd in $DangerousCommands) {
    if ($Command -match $cmd) {
        Write-Host "Warning: Dangerous command detected: $cmd"
        Write-Host "Command: $Command"
        exit 1
    }
}

exit 0
```

## 6. Hooks 开发规范

### 6.1 脚本要求
- ✅ 使用 shebang (`#!/bin/bash` 或 `#!/usr/bin/pwsh`)
- ✅ 设置可执行权限 (`chmod +x`)
- ✅ 返回正确的退出码
- ✅ 输出友好的错误信息

### 6.2 错误处理
```bash
#!/bin/bash
set -e  # 遇到错误立即退出
set -u  # 使用未定义变量时报错

# 安全的命令执行
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed"
    exit 1
fi
```

### 6.3 性能考虑
- ⚠️ Hook 执行时间计入总响应时间
- ⚠️ 避免在 Hook 中执行耗时操作
- ✅ 使用缓存减少重复计算

## 7. 环境变量

### 7.1 内置变量
| 变量 | 说明 |
|------|------|
| CLAUDE_SESSION_ID | 会话 ID |
| CLAUDE_SESSION_DURATION | 会话持续时间（秒）|
| CLAUDE_TOOLS_USED | 使用的工具数量 |
| CLAUDE_CURRENT_DIR | 当前工作目录 |

### 7.2 自定义变量
```json
{
  "hooks": {
    "SessionStart": [{
      "command": "echo",
      "env": {
        "PROJECT_NAME": "my-project",
        "DEBUG": "true"
      }
    }]
  }
}
```

## 8. 调试 Hooks

### 8.1 启用调试
```bash
# 设置调试模式
export CLAUDE_HOOKS_DEBUG=true

# 运行 Claude Code
claude
```

### 8.2 日志查看
```bash
# 查看 Hook 日志
cat ~/.claude/logs/hooks.log

# 实时查看
tail -f ~/.claude/logs/hooks.log
```

## 9. 推荐的 Hooks 组合

### 9.1 安全增强组合
- PreToolUse：危险命令检查
- PreToolUse：权限验证
- PostToolUse：操作日志

### 9.2 上下文增强组合
- SessionStart：加载项目上下文
- PreCompact：提取关键信息
- PostCompact：恢复上下文

### 9.3 质量保障组合
- SessionEnd：会话摘要
- PostToolUse：代码统计
- Stop：完成验证
