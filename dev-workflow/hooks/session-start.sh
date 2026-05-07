#!/bin/bash
# ============================================================================
# Dev Suite: SessionStart Hook
# 每次会话启动时自动注入 skill-dev-using 元技能上下文
# 触发事件: startup / resume / clear / compact
# ============================================================================

set -e
set -u

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-}"
SKILL_FILE="${PLUGIN_ROOT}/../skills/skill-dev-using/SKILL.md"

# 如果 ${CLAUDE_PLUGIN_ROOT} 未设置，尝试从插件目录结构推断
if [ -z "$PLUGIN_ROOT" ]; then
  # 回退：检查标准路径
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  SKILL_FILE="${PLUGIN_ROOT}/skills/skill-dev-using/SKILL.md"
fi

if [ -f "$SKILL_FILE" ]; then
  echo "---[Dev Suite: 技能系统已就绪]---"
  # 读取元技能内容并注入到上下文
  # 使用 <EXTREMELY_IMPORTANT> 标签确保 Claude 重视此信息
  cat << 'INJECT_END'
<EXTREMELY_IMPORTANT>
你已获得 Dev Suite 技能系统的增强能力。

Dev Suite 为你提供了一套结构化的开发技能库，涵盖需求分析、方案设计、任务拆解、
测试驱动开发、代码审查、系统化调试、验证完成等全流程。

核心原则：
1. 只要有 1% 的可能性某个技能适用，你**必须**先调用技能再回应
2. 流程技能优先于实施技能
3. 违反铁律（跳过技能直接操作）是不被允许的

技能查找方式：使用 Skill tool 搜索 "skill-dev-" 前缀的技能即可找到所有可用技能。
</EXTREMELY_IMPORTANT>
INJECT_END

  # 读取并注入完整的元技能内容
  echo "---[Dev Suite 技能上下文开始]---"
  cat "$SKILL_FILE"
  echo "---[Dev Suite 技能上下文结束]---"
  echo "---[Dev Suite 技能系统就绪]---"
else
  echo "Dev Suite: 未找到技能文件 ($SKILL_FILE)，跳过元技能注入"
fi

exit 0
