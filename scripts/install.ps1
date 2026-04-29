# Dev Suite for Claude Code - 安装脚本 (Windows)
# 版本: 1.0.0
# 日期: 2026-04-29

param(
    [string]$Repo = "Dana-li/claude-dev-suite",
    [switch]$SkipClone,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# 颜色定义
function Write-Success($msg) { Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Info($msg) { Write-Host "ℹ️  $msg" -ForegroundColor Cyan }
function Write-Warn($msg) { Write-Host "⚠️  $msg" -ForegroundColor Yellow }
function Write-Err($msg) { Write-Host "❌ $msg" -ForegroundColor Red }

# 显示帮助
if ($Help) {
    Write-Host @"
Dev Suite for Claude Code - 安装脚本
用法: .\install.ps1 [-Repo <仓库>] [-SkipClone] [-Help]

参数:
  -Repo        GitHub 仓库地址 (默认: Dana-li/claude-dev-suite)
  -SkipClone   跳过克隆步骤，使用当前目录
  -Help        显示此帮助信息

示例:
  .\install.ps1                                    # 默认安装
  .\install.ps1 -Repo "yourname/claude-dev-suite" # 自定义仓库
  .\install.ps1 -SkipClone                        # 从当前目录安装
"@
    exit 0
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Dev Suite for Claude Code - 安装程序 v1.0.0           ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# 获取 Claude 配置目录
$ClaudeDir = $env:CLAUDE_DIR
if (-not $ClaudeDir) {
    $ClaudeDir = "$HOME\.claude"
}

Write-Info "Claude 配置目录: $ClaudeDir"

# 克隆或定位仓库
if (-not $SkipClone) {
    $TempDir = "$env:TEMP\claude-dev-suite-$((Get-Date).Ticks)"
    Write-Info "克隆仓库..."
    Write-Info "来源: https://github.com/$Repo"

    try {
        git clone --depth 1 "https://github.com/$Repo.git" $TempDir
        $SourceDir = $TempDir
        Write-Success "克隆完成"
    }
    catch {
        Write-Err "克隆失败: $_"
        Write-Host "请检查网络连接或手动克隆后使用 -SkipClone 参数"
        exit 1
    }
}
else {
    $SourceDir = Get-Location
}

# 备份现有配置
$BackupDir = "$HOME\claude-dev-suite-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Write-Info "备份现有配置到: $BackupDir"

if (Test-Path "$ClaudeDir\plugins\dev-workflow") {
    New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
    Copy-Item -Path "$ClaudeDir\plugins\dev-workflow" -Destination "$BackupDir\dev-workflow" -Recurse -ErrorAction SilentlyContinue
    Copy-Item -Path "$ClaudeDir\plugins\dev-commands" -Destination "$BackupDir\dev-commands" -Recurse -ErrorAction SilentlyContinue
    Copy-Item -Path "$ClaudeDir\plugins\dev-quality" -Destination "$BackupDir\dev-quality" -Recurse -ErrorAction SilentlyContinue
    Write-Warn "已备份现有插件到 $BackupDir"
}

# 1. 安装 dev-workflow 插件
Write-Host ""
Write-Info "安装 dev-workflow..."
if (Test-Path "$SourceDir\packages\dev-workflow") {
    Copy-Item -Path "$SourceDir\packages\dev-workflow" -Destination "$ClaudeDir\plugins\dev-workflow" -Recurse -Force
    Write-Success "dev-workflow 安装完成"
}
else {
    Write-Warn "dev-workflow 源文件不存在，跳过"
}

# 2. 安装 dev-commands 插件
Write-Info "安装 dev-commands..."
if (Test-Path "$SourceDir\packages\dev-commands") {
    Copy-Item -Path "$SourceDir\packages\dev-commands" -Destination "$ClaudeDir\plugins\dev-commands" -Recurse -Force
    Write-Success "dev-commands 安装完成"
}
else {
    Write-Warn "dev-commands 源文件不存在，跳过"
}

# 3. 安装 dev-quality 插件
Write-Info "安装 dev-quality..."
if (Test-Path "$SourceDir\packages\dev-quality") {
    Copy-Item -Path "$SourceDir\packages\dev-quality" -Destination "$ClaudeDir\plugins\dev-quality" -Recurse -Force
    Write-Success "dev-quality 安装完成"
}
else {
    Write-Warn "dev-quality 源文件不存在，跳过"
}

# 4. 安装共享 rules
Write-Host ""
Write-Info "安装共享 rules..."
if (Test-Path "$SourceDir\shared\rules") {
    New-Item -ItemType Directory -Force -Path "$ClaudeDir\rules" | Out-Null
    Copy-Item -Path "$SourceDir\shared\rules\*" -Destination "$ClaudeDir\rules\" -Recurse -Force
    Write-Success "rules 安装完成"
}
else {
    Write-Warn "rules 源文件不存在，跳过"
}

# 5. 安装共享 agents
Write-Info "安装共享 agents..."
if (Test-Path "$SourceDir\shared\agents") {
    New-Item -ItemType Directory -Force -Path "$ClaudeDir\agents" | Out-Null
    Copy-Item -Path "$SourceDir\shared\agents\*" -Destination "$ClaudeDir\agents\" -Recurse -Force
    Write-Success "agents 安装完成"
}
else {
    Write-Warn "agents 源文件不存在，跳过"
}

# 6. 安装 Skills
Write-Host ""
Write-Info "安装 dev-quality/skills..."
if (Test-Path "$SourceDir\packages\dev-quality\skills") {
    New-Item -ItemType Directory -Force -Path "$ClaudeDir\skills" | Out-Null
    Copy-Item -Path "$SourceDir\packages\dev-quality\skills\*" -Destination "$ClaudeDir\skills\" -Recurse -Force
    Write-Success "skills 安装完成"
}
else {
    Write-Warn "skills 源文件不存在，跳过"
}

# 7. 安装 hooks
Write-Info "安装 hooks..."
if (Test-Path "$SourceDir\configs\hooks") {
    New-Item -ItemType Directory -Force -Path "$ClaudeDir\hooks" | Out-Null
    Copy-Item -Path "$SourceDir\configs\hooks\*" -Destination "$ClaudeDir\hooks\" -Recurse -Force
    Write-Success "hooks 安装完成"
}
else {
    Write-Warn "hooks 源文件不存在，跳过"
}

# 8. 更新 settings.json
Write-Host ""
Write-Info "更新 Claude Code 设置..."

$SettingsFile = "$ClaudeDir\settings.json"
$Settings = @{}

if (Test-Path $SettingsFile) {
    try {
        $Settings = Get-Content $SettingsFile -Raw | ConvertFrom-Json -AsHashtable
    }
    catch {
        Write-Warn "无法读取现有 settings.json，将创建新文件"
    }
}

# 添加自定义市场
if (-not $Settings.extraKnownMarketplaces) {
    $Settings.extraKnownMarketplaces = @{}
}
$Settings.extraKnownMarketplaces.devSuite = @{
    source = @{ source = "github"; repo = $Repo }
}

# 启用插件
if (-not $Settings.enabledPlugins) {
    $Settings.enabledPlugins = @{}
}
$Settings.enabledPlugins["dev-workflow@devSuite"] = $true
$Settings.enabledPlugins["dev-commands@devSuite"] = $true
$Settings.enabledPlugins["dev-quality@devSuite"] = $true

# 保存设置
$Settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile -Encoding UTF8
Write-Success "settings.json 更新完成"

# 清理临时目录
if (-not $SkipClone -and $TempDir) {
    Write-Host ""
    Write-Info "清理临时文件..."
    Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
}

# 完成
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    安装完成！                              ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║  请重启 Claude Code 使配置生效                            ║" -ForegroundColor Green
Write-Host "║                                                            ║" -ForegroundColor Green
Write-Host "║  快速开始:                                                 ║" -ForegroundColor Green
Write-Host "║    /dev         - 启动开发工作流                          ║" -ForegroundColor Green
Write-Host "║    /commit      - 安全提交代码                            ║" -ForegroundColor Green
Write-Host "║    /bug-analyzer - 分析 Bug                              ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
