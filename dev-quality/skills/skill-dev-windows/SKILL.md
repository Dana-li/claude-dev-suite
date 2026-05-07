---
name: skill-dev-windows
version: 1.0.0
description: |
  Windows 桌面自动化 MCP 可选扩展
  
  适用场景（Windows Only）：
  - 文件操作（复制/移动/删除/重命名）
  - 窗口管理（激活/关闭/调整/截图）
  - 进程管理（启动/停止/监控）
  - 键盘鼠标自动化（表单填写/操作模拟）
  - 系统操作（环境变量/注册表/服务）
  
  核心原则：
  - ❗ 可选扩展，非必需
  - ❗ 需用户明确启用
  - ❗ 注意安全权限
  - ❌ 不侵入核心工作流
agent_created: true
created_date: 2026-05-07
tags: [windows, mcp, desktop-automation, optional]
---

# Windows 桌面自动化 MCP 扩展 (skill-dev-windows)

## 一、这是什么

**skill-dev-windows** 是 Dev Suite 的 Windows 平台可选扩展，通过集成 [mcp-windows-desktop-automation](https://github.com/mario-andreschak/mcp-windows-desktop-automation) MCP 服务器，让 AI 助手可以直接操作 Windows 桌面。

> **⚠️ 重要说明**：本技能是**可选扩展**，不会随 Dev Suite 核心插件自动启用。
> 只有 Windows 用户且在项目中明确配置后，才会生效。

---

## 二、触发条件

只有在以下条件**全部满足**时，才应使用本技能：

1. 当前操作系统是 **Windows**
2. 用户已明确配置 Windows MCP（详见第三章）
3. 任务涉及桌面级操作，如：
   - 文件管理（复制/移动/删除/重命名）
   - 窗口操作（激活特定窗口、截图）
   - 进程管理（启动/停止应用）
   - UI 自动化（填写表单、点击按钮）

---

## 三、安装与配置

### 3.1 安装 MCP 服务器

```bash
# 方式一：全局安装（推荐）
npm install -g @mario-andreschak/mcp-windows-desktop-automation

# 方式二：项目本地安装
npm install @mario-andreschak/mcp-windows-desktop-automation --save-dev
```

### 3.2 配置 MCP（两种方式）

#### 方式 A：项目级配置（推荐）

在项目根目录创建 `.workbuddy/mcp.json`：

```json
{
  "mcpServers": {
    "windows-desktop": {
      "command": "npx",
      "args": ["-y", "@mario-andreschak/mcp-windows-desktop-automation"],
      "env": {
        "WINDOWS_MCP_VERBOSE": "false"
      }
    }
  }
}
```

#### 方式 B：用户级全局配置

编辑 `~/.workbuddy/mcp.json`：

```json
{
  "mcpServers": {
    "windows-desktop": {
      "command": "npx",
      "args": ["-y", "@mario-andreschak/mcp-windows-desktop-automation"]
    }
  }
}
```

### 3.3 验证配置

配置完成后，重启 WorkBuddy 会话，输入以下命令验证：

```
/statu
```

查看输出中是否包含 `windows-desktop` MCP 服务器且状态为 `connected`。

---

## 四、可用工具速查

### 4.1 鼠标操作

| 工具 | 功能 | 示例 |
|------|------|------|
| `mouse_move` | 移动鼠标 | `{x: 500, y: 300}` |
| `mouse_click` | 点击左键 | `{x: 500, y: 300}` |
| `mouse_double_click` | 双击左键 | `{x: 500, y: 300}` |
| `mouse_right_click` | 右键点击 | `{x: 500, y: 300}` |
| `mouse_drag` | 拖拽 | `{x1: 100, y1: 100, x2: 500, y2: 500}` |
| `mouse_wheel` | 滚动滚轮 | `{direction: "down", clicks: 3}` |
| `mouse_get_pos` | 获取鼠标位置 | 无参数，返回当前坐标 |

### 4.2 键盘操作

| 工具 | 功能 | 示例 |
|------|------|------|
| `keyboard_send` | 发送按键序列 | `"Hello World!{ENTER}"` |
| `keyboard_write` | 写入文本 | `"This is text"` |
| `keyboard_hold` | 按住按键 | `"ctrl"` |
| `keyboard_release` | 释放按键 | `"ctrl"` |
| `clipboard_get` | 读取剪贴板 | 返回文本内容 |
| `clipboard_set` | 写入剪贴板 | `"要复制的文本"` |

### 4.3 窗口管理

| 工具 | 功能 | 示例 |
|------|------|------|
| `window_exists` | 检查窗口是否存在 | `{title: "计算器"}` |
| `window_activate` | 激活窗口 | `{title: "*.txt - 记事本"}` |
| `window_close` | 关闭窗口 | `{title: "无标题 - 记事本"}` |
| `window_move` | 移动窗口 | `{title: "计算器", x: 100, y: 100}` |
| `window_resize` | 调整窗口大小 | `{title: "计算器", width: 800, height: 600}` |
| `window_minimize` | 最小化 | `{title: "命令提示符"}` |
| `window_maximize` | 最大化 | `{title: "命令提示符"}` |
| `window_restore` | 恢复窗口 | `{title: "命令提示符"}` |
| `window_get_pos` | 获取窗口位置 | `{title: "计算器"}` |
| `window_show` | 显示隐藏窗口 | `{title: "任务管理器"}` |
| `window_hide` | 隐藏窗口 | `{title: "任务管理器"}` |
| `window_get_text` | 获取窗口文本 | `{title: "计算器"}` |
| `win_list_windows` | 列出所有窗口 | 无参数，返回窗口列表 |

### 4.4 控件操作

| 工具 | 功能 | 示例 |
|------|------|------|
| `control_click` | 点击控件 | `{title: "计算器", control: "Button1"}` |
| `control_set_text` | 设置控件文本 | `{title: "记事本", control: "Edit1", text: "Hello"}` |
| `control_get_text` | 获取控件文本 | `{title: "计算器", control: "Edit1"}` |
| `control_enable` | 启用控件 | `{title: "设置", control: "Button1"}` |
| `control_disable` | 禁用控件 | `{title: "设置", control: "Button1"}` |

### 4.5 进程管理

| 工具 | 功能 | 示例 |
|------|------|------|
| `process_run` | 运行程序 | `{command: "notepad.exe"}` |
| `process_close` | 关闭进程 | `{process: "notepad.exe"}` |
| `process_wait` | 等待进程启动 | `{process: "notepad.exe", timeout: 5}` |
| `process_exists` | 检查进程是否存在 | `{process: "notepad.exe"}` |
| `process_wait_close` | 等待进程结束 | `{process: "notepad.exe", timeout: 10}` |
| `process_list` | 列出所有进程 | 无参数 |

### 4.6 文件与系统操作

| 工具 | 功能 | 示例 |
|------|------|------|
| `file_read` | 读取文件内容 | `{path: "C:\\test.txt"}` |
| `file_write` | 写入文件 | `{path: "C:\\test.txt", content: "Hello"}` |
| `file_delete` | 删除文件 | `{path: "C:\\test.txt"}` |
| `dir_list` | 列目录 | `{path: "C:\\Windows"}` |
| `dir_create` | 创建目录 | `{path: "C:\\new_folder"}` |
| `shutdown` | 关机 | 无参数 |
| `sleep` | 系统休眠 | 无参数 |
| `tooltip` | 显示提示 | `{text: "Hello", x: 0, y: 0}` |

### 4.7 屏幕截图

| 工具 | 功能 | 示例 |
|------|------|------|
| `screenshot_capture` | 截取整个屏幕 | 无参数 |
| `screenshot_capture_window` | 截取指定窗口 | `{title: "计算器"}` |
| `screenshot_capture_region` | 截取指定区域 | `{x: 0, y: 0, width: 500, height: 400}` |

---

## 五、常用自动化模式

### 5.1 打开文件并编辑

```markdown
工作流：
1. process_run → notepad.exe "C:\\test.txt"
2. window_wait → "test.txt - 记事本"
3. control_set_text → "Edit1" → 写入内容
4. keyboard_send → "^s" (Ctrl+S 保存)
5. window_close → "test.txt - 记事本"
```

### 5.2 页面截图验证

```markdown
工作流：
1. window_activate → "Google Chrome"
2. window_resize → 1920x1080
3. screenshot_capture → 保存截图
4. 将截图传给 AI 分析
```

### 5.3 监控进程状态

```markdown
工作流：
1. process_exists → "java.exe"（检查 Java 进程）
2. 如果存在 → 继续
3. 如果不存在 → process_run → "java -jar app.jar"
4. process_wait → "java.exe"（等待启动完成）
5. window_activate → "Application"
6. screenshot_capture_window → 确认界面正常
```

---

## 六、安全与注意事项

### 6.1 安全检查清单

```markdown
### 使用前确认

- [ ] 确认当前在工作站环境（非服务器）
- [ ] 确认不操作敏感界面（密码输入、银行页面等）
- [ ] 确认关闭会影响自动化的弹窗（系统更新提示等）
- [ ] 确认屏幕不被共享/录屏（避免暴露）
```

### 6.2 风险等级

| 操作 | 风险 | 说明 |
|------|------|------|
| 读取文件 | 🟢 低 | 只读操作，不修改系统 |
| 截图 | 🟢 低 | 可能包含敏感信息 |
| 文件写入 | 🟡 中 | 可能覆盖重要文件 |
| 进程管理 | 🟡 中 | 可能关闭关键进程 |
| 按键模拟 | 🔴 高 | 可能误操作 |
| 注册表操作 | 🔴 高 | 可能影响系统稳定性 |
| 关机/休眠 | 🔴 高 | 中断工作 |

### 6.3 使用原则

1. **最小权限** — 只用必要的操作，不滥用自动化
2. **操作前确认** — 重要操作（关机、删除文件）必须经用户确认
3. **预览再执行** — 需要截图的操作，先取景再执行
4. **及时撤销** — 键盘鼠标模拟出错时，立即停止

---

## 七、与 Dev Suite 其他部分集成

### 7.1 与 dev.md 工作流

在 Phase 8（集成验证）和 Phase 9（部署）中，如果检测到 Windows 环境且有 MCP 配置：

```
可选操作：
- 自动验证本地服务状态（process_exists）
- 截图验证界面（screenshot_capture）
- 日志文件读取验证（file_read）
```

### 7.2 与 skill-dev-verification

验证阶段如果 Windows MCP 可用，可额外执行：

```markdown
- 验证服务进程运行状态
- 截图确认界面正常
- 读取日志文件确认无错误
```

---

## 八、常见问题

### Q: 配置后还是连不上？

```bash
# 检查 npx 是否可用
npx --version

# 直接测试 MCP 服务器
npx -y @mario-andreschak/mcp-windows-desktop-automation --verbose

# 检查防火墙是否阻止
# 开放 3000 端口（WebSocket 模式）
```

### Q: 安全提示/杀毒软件拦截？

AutoIt 行为可能被某些杀毒软件误报。如遇拦截：
- 添加信任白名单
- 使用签名版本
- 或更换为基于 PowerShell 的替代方案

### Q: 不想全局安装？

使用 `npx -y` 每次自动下载运行，无需本地安装。

---

## 九、卸载

```bash
# 移除全局安装
npm uninstall -g @mario-andreschak/mcp-windows-desktop-automation

# 删除 MCP 配置
rm ~/.workbuddy/mcp.json
# 或编辑文件删除 windows-desktop 条目

# 确认移除
npm list -g | grep windows
```
