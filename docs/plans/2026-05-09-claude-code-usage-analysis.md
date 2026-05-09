# Claude Code 实际使用分析 & dev-suite 改善建议

> **日期**: 2026-05-09
> **分析方法**: 基于 2026-05-08 ~ 2026-05-09 两次对话的实际观察
> **对话来源**: dev-suite 开发会话（压缩前 + 压缩后）

---

## 1. 分析方法说明

本次分析基于以下真实使用数据：

| 数据来源 | 内容 |
|----------|------|
| 本次对话 | P2 多工作流开发全流程观察 |
| 上次对话摘要 | P0/P1/P2 OpenSpec 借鉴全流程 |
| Git 提交记录 | `92c46eb`, `27a8260`, `9597664` |
| 工具调用记录 | Bash/PowerShell/Read/Write/Edit/AskUserQuestion 等 |

---

## 2. 好的模式（Good Patterns）

### ✅ G1：指令简洁明确

| 观察 | 说明 |
|------|------|
| "做" | 一句话确认实施 P2 |
| "方案1" | 快速选择代理配置方案 |
| "自动提交并推送至 github ，同步修改 readme 文档" | 一次性给出完整意图 |

**结论**：用户偏好短指令，不喜欢啰嗦的交互。dev-suite 应支持「短语触发」。

---

### ✅ G2：工作流执行顺畅

| 阶段 | 结果 |
|------|------|
| Research 工作流 | 4 阶段完整执行，输出报告 |
| 多工作流 P2 | 4 个 YAML + loader + 验证脚本全部完成 |
| Git 提交 | commit message 规范（feat: 前缀 + 中文描述） |

**结论**：工作流机制本身设计合理，Phase 按序执行、动态启用/禁用都有效。

---

### ✅ G3：验证脚本抓到真实错误

`validate-workflow.py` 抓到了 `full-feature.yaml` 的 `required` 字段缺失问题。

**结论**：自动化验证比人工检查可靠。应更多引入「保存前验证」机制。

---

### ✅ G4：代理配置决策快速

用户看到 3 个选项（127.0.0.1:7890 / 10809 / 10808），直接选方案 1，没有犹豫。

**结论**：提供选项时，把「最常见配置」放第一个，并标注 `(推荐)`。

---

## 3. 坏的模式（Bad Patterns / Pain Points）

### ❌ B1：上下文压缩频繁，用户需反复说「继续」

| 观察 | 影响 |
|------|------|
| 本次对话触发了 context compaction | 用户需要说「继续」恢复 |
| 压缩后丢失部分中间状态 | 需要重新读取文件 |

**根因**：
- 工具调用次数多（本次 > 30 次）
- 大文件内容（YAML/Markdown）占 token

**改善方向**：
1. 在工具调用 > 20 次时，主动触发「阶段小结」并写入记忆
2. `dev.md` 各 Phase 执行完后立即写记忆，不依赖最后统一写
3. 大文件（> 200 行）用 `read_file` 分段读，不一次全读

---

### ❌ B2：Git 推送不稳定，需要手动配置代理

| 尝试次数 | 结果 |
|----------|------|
| 第 1 次 | `OpenSSL SSL_read: Connection was reset` |
| 第 2 次 | `Failed to connect to github.com port 443 after 21125 ms: Timed out` |
| 第 3 次（配置代理后） | ✅ 成功 |

**根因**：网络环境需要代理，但 Git 未自动检测。

**改善方向**：
1. `dev.md` 或 `skill-dev-using` 中新增「Git 代理自动检测」
2. 推送失败时，自动尝试检测系统代理设置（Windows: `netsh winhttp show proxy`）
3. 提供交互式代理配置向导

---

### ❌ B3：文件路径混淆（E:\ vs C:\）

| 观察 | 影响 |
|------|------|
| 我在 `E:\AiCoding\dev-suit 持续改造\` 编辑文件 | Git 仓库实际在 `C:\Users\leedc\claude-dev-suite\` |
| 需要手动 `cp` 同步 | 浪费时间，容易遗漏 |

**根因**：工作区目录（`E:\`）和 Git 仓库目录（`C:\`）是两份独立拷贝。

**改善方向**：
1. **统一工作目录**：把 Git 仓库 clone 到 `E:\AiCoding\dev-suit\` ，以 `E:\` 为唯一工作目录
2. 或者：在 `E:\` 放一个 `sync-to-git.ps1` 脚本，一键同步到 `C:\`

---

### ❌ B4：Edit 工具字符串匹配脆弱

| 观察 | 影响 |
|------|------|
| `Edit` 工具找不到匹配字符串 | 需要使用 PowerShell `Add-Content` 绕过 |
| 中文字符串匹配尤其容易失败 | 降低自动化成功率 |

**根因**：`Edit` 工具依赖精确字符串匹配，文件中有不可见字符（CRLF vs LF）时失败。

**改善方向**：
1. 在技能文档中统一使用 LF 换行符
2. 对于「追加内容」场景，优先用 `PowerShell Add-Content`（已验证可行）
3. 或者：改用 `Write` 工具整体覆写（适合小文件）

---

### ❌ B5：记忆写入依赖提醒

| 观察 | 说明 |
|------|------|
| 系统 prompt 要求写记忆 | 但我经常忘记，需要 `<memory_and_skills_reminder>` 提醒 |
| 本次是用户说「继续」后才追加记忆 | 理想情况是每个 Phase 完成后自动写 |

**根因**：记忆写入不是「强制检查点」，容易被跳过。

**改善方向**：
1. 在 `dev.md` 每个 Phase 结束时，强制调用 `write_memory` 检查点
2. 新增 `skill-dev-memory-auto-write` 技能，专门负责阶段性记忆写入

---

## 4. 改善建议优先级

| 优先级 | 改善项 | 预计耗时 | 影响面 |
|--------|--------|----------|--------|
| **P0** | 统一工作目录（E:\ vs C:\） | 1 小时 | 消除文件同步麻烦 |
| **P1** | Git 代理自动检测 | 2 小时 | 减少推送失败 |
| **P1** | 上下文压缩前主动小结 | 3 小时 | 减少「继续」次数 |
| **P2** | Edit 工具替代方案（PowerShell Add-Content） | 1 小时 | 提高自动化成功率 |
| **P2** | 记忆写入强制检查点 | 2 小时 | 不丢上下文 |
| **P3** | 大文件分段读取 | 1 小时 | 节省 token |

---

## 5. 具体改善方案

### P0：统一工作目录

**方案**：把 Git 仓库迁移到 `E:\AiCoding\dev-suit\`

```powershell
# 在 E:\ 重新 clone
cd E:\AiCoding
git clone https://github.com/Dana-li/claude-dev-suite.git dev-suit

# 确认两个目录内容一致后，删除 C:\ 的旧仓库
Remove-Item -Recurse -Force C:\Users\leedc\claude-dev-suite\
```

**验证**：确认 WorkBuddy 项目目录指向 `E:\AiCoding\dev-suit\`

---

### P1：Git 代理自动检测

新增 `scripts/auto-proxy.ps1`：

```powershell
# auto-proxy.ps1 - 自动检测并配置 Git 代理
$proxy = netsh winhttp show proxy | Select-String "Proxy Server"
if ($proxy -match "https?://([\d\.]+):(\d+)") {
    $proxy_addr = $matches[0]
    git config --global http.proxy $proxy_addr
    git config --global https.proxy $proxy_addr
    Write-Host "✅ 已自动配置代理: $proxy_addr"
}
```

在 `dev.md` Phase 5（实现）之前自动执行。

---

### P1：上下文压缩前主动小结

修改 `dev.md`，在每个 Phase 结束时增加：

```markdown
### Phase X 收尾

**强制动作**：
1. 调用 `TaskUpdate` 标记当前 Phase 完成
2. 追加小结到 `memory/YYYY-MM-DD.md`
3. 检查上下文使用量，如果 > 80%，主动小结并建议压缩
```

---

## 6. 结论

| 维度 | 评价 | 建议 |
|------|------|------|
| 工作流设计 | ✅ 合理 | 保持，继续扩展 |
| 工具稳定性 | ⚠️ 有改进空间 | 优先解决路径混淆和 Edit 脆弱性 |
| Git 操作 | ⚠️ 需要代理 | 自动检测代理 |
| 上下文管理 | ❌ 需要改进 | 主动小结，减少压缩次数 |
| 记忆管理 | ⚠️ 依赖提醒 | 强制检查点 |

**下一步推荐**：先解决 P0（统一工作目录），再解决 P1（Git 代理自动检测 + 上下文主动小结）。

---

_报告生成：2026-05-09_  
_基于真实对话观察，非推测_
