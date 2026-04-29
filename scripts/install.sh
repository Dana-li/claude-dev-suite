#!/bin/bash
# Dev Suite for Claude Code - 安装脚本 (Linux/Mac)
# 版本: 1.0.0
# 日期: 2026-04-29

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 函数定义
log_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# 显示帮助
show_help() {
    cat << EOF
Dev Suite for Claude Code - 安装脚本
用法: ./install.sh [-r <仓库>] [-s] [-h]

参数:
  -r        GitHub 仓库地址 (默认: Dana-li/claude-dev-suite)
  -s        跳过克隆步骤，使用当前目录
  -h        显示此帮助信息

示例:
  ./install.sh                                    # 默认安装
  ./install.sh -r "yourname/claude-dev-suite"     # 自定义仓库
  ./install.sh -s                                 # 从当前目录安装
EOF
}

# 解析参数
REPO="Dana-li/claude-dev-suite"
SKIP_CLONE=false

while getopts "r:sh" opt; do
    case $opt in
        r) REPO="$OPTARG" ;;
        s) SKIP_CLONE=true ;;
        h) show_help; exit 0 ;;
        *) show_help; exit 1 ;;
    esac
done

# 标题
echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Dev Suite for Claude Code - 安装程序 v1.0.0           ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 获取 Claude 配置目录
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
log_info "Claude 配置目录: $CLAUDE_DIR"

# 克隆或定位仓库
if [ "$SKIP_CLONE" = false ]; then
    TEMP_DIR=$(mktemp -d)
    log_info "克隆仓库..."
    log_info "来源: https://github.com/$REPO"

    if git clone --depth 1 "https://github.com/$REPO.git" "$TEMP_DIR"; then
        SOURCE_DIR="$TEMP_DIR"
        log_success "克隆完成"
    else
        log_error "克隆失败，请检查网络连接或手动克隆后使用 -s 参数"
        exit 1
    fi
else
    SOURCE_DIR=$(pwd)
fi

# 备份现有配置
BACKUP_DIR="$HOME/claude-dev-suite-backup-$(date +%Y%m%d-%H%M%S)"
log_info "备份现有配置到: $BACKUP_DIR"

if [ -d "$CLAUDE_DIR/plugins/dev-workflow" ]; then
    mkdir -p "$BACKUP_DIR"
    cp -r "$CLAUDE_DIR/plugins/dev-workflow" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$CLAUDE_DIR/plugins/dev-commands" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$CLAUDE_DIR/plugins/dev-quality" "$BACKUP_DIR/" 2>/dev/null || true
    log_warn "已备份现有插件到 $BACKUP_DIR"
fi

# 1. 安装 dev-workflow 插件
echo ""
log_info "安装 dev-workflow..."
if [ -d "$SOURCE_DIR/packages/dev-workflow" ]; then
    mkdir -p "$CLAUDE_DIR/plugins"
    cp -r "$SOURCE_DIR/packages/dev-workflow" "$CLAUDE_DIR/plugins/dev-workflow"
    log_success "dev-workflow 安装完成"
else
    log_warn "dev-workflow 源文件不存在，跳过"
fi

# 2. 安装 dev-commands 插件
log_info "安装 dev-commands..."
if [ -d "$SOURCE_DIR/packages/dev-commands" ]; then
    cp -r "$SOURCE_DIR/packages/dev-commands" "$CLAUDE_DIR/plugins/dev-commands"
    log_success "dev-commands 安装完成"
else
    log_warn "dev-commands 源文件不存在，跳过"
fi

# 3. 安装 dev-quality 插件
log_info "安装 dev-quality..."
if [ -d "$SOURCE_DIR/packages/dev-quality" ]; then
    cp -r "$SOURCE_DIR/packages/dev-quality" "$CLAUDE_DIR/plugins/dev-quality"
    log_success "dev-quality 安装完成"
else
    log_warn "dev-quality 源文件不存在，跳过"
fi

# 4. 安装共享 rules
echo ""
log_info "安装共享 rules..."
if [ -d "$SOURCE_DIR/shared/rules" ]; then
    mkdir -p "$CLAUDE_DIR/rules"
    cp -r "$SOURCE_DIR/shared/rules/"* "$CLAUDE_DIR/rules/"
    log_success "rules 安装完成"
else
    log_warn "rules 源文件不存在，跳过"
fi

# 5. 安装共享 agents
log_info "安装共享 agents..."
if [ -d "$SOURCE_DIR/shared/agents" ]; then
    mkdir -p "$CLAUDE_DIR/agents"
    cp -r "$SOURCE_DIR/shared/agents/"* "$CLAUDE_DIR/agents/"
    log_success "agents 安装完成"
else
    log_warn "agents 源文件不存在，跳过"
fi

# 6. 更新 settings.json
echo ""
log_info "更新 Claude Code 设置..."

SETTINGS_FILE="$CLAUDE_DIR/settings.json"
SETTINGS='{}'

if [ -f "$SETTINGS_FILE" ]; then
    SETTINGS=$(cat "$SETTINGS_FILE")
fi

# 清理临时目录
if [ "$SKIP_CLONE" = false ] && [ -n "$TEMP_DIR" ]; then
    echo ""
    log_info "清理临时文件..."
    rm -rf "$TEMP_DIR"
fi

# 完成
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    安装完成！                              ║${NC}"
echo -e "${GREEN}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║  请重启 Claude Code 使配置生效                            ║${NC}"
echo -e "${GREEN}║                                                            ║${NC}"
echo -e "${GREEN}║  快速开始:                                                 ║${NC}"
echo -e "${GREEN}║    /dev         - 启动开发工作流                          ║${NC}"
echo -e "${GREEN}║    /commit      - 安全提交代码                            ║${NC}"
echo -e "${GREEN}║    /bug-analyzer - 分析 Bug                              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
