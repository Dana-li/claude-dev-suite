# context-warning.ps1 - 上下文使用预警脚本
# 当工具调用次数超过阈值时，主动提醒小结

param(
    [int]$ToolCallCount = 0,
    [int]$WarningThreshold = 20,
    [int]$ForceThreshold = 35
)

# 读取工具调用次数（从环境变量或参数）
$count = $env:TOOL_CALL_COUNT
if (-not $count) {
    $count = $ToolCallCount
}

$count = [int]$count

# 判断预警级别
if ($count -ge $ForceThreshold) {
    Write-Host "============================================="
    Write-Host "⚠️  上下文使用较多（工具调用 $count 次）"
    Write-Host "============================================="
    Write-Host ""
    Write-Host "建议立即执行以下操作："
    Write-Host "  1. 小结当前进度（我会自动写入记忆）"
    Write-Host "  2. 输入 /compact 压缩上下文"
    Write-Host "  3. 或输入「继续」继续执行"
    Write-Host ""
    Write-Host "正在自动写入阶段性记忆..."
    # 触发记忆写入（由调用方负责实际写入）
    exit 1  # 返回非零，提示需要关注
}
elseif ($count -ge $WarningThreshold) {
    Write-Host "⚠️  提示：工具调用已 $count 次，建议适时小结并压缩上下文。"
    exit 0
}
else {
    exit 0
}
