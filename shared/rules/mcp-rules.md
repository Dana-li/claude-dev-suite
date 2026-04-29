# MCP (Model Context Protocol) 配置规范

## 1. MCP 概述

MCP 是一种用于扩展 Claude Code 能力的协议，通过标准化接口连接外部工具和数据源。

## 2. MCP Server 配置

### 2.1 配置位置
- **全局配置**：`~/.claude.json` 的 `mcpServers` 字段
- **项目配置**：`项目目录/.mcp.json`

### 2.2 配置格式
```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["@server/package"],
      "env": {
        "API_KEY": "your-api-key"
      }
    }
  }
}
```

### 2.3 Windows 配置
```json
{
  "mcpServers": {
    "server-name": {
      "command": "cmd",
      "args": ["/c", "npx", "@server/package"]
    }
  }
}
```

## 3. 推荐 MCP Servers

### 3.1 常用 Servers
| Server | 用途 | 官方包 |
|--------|------|--------|
| context7 | 库文档检索 | @context7/mcp |
| github | GitHub API | @modelcontextprotocol/server-github |
| filesystem | 文件操作 | @modelcontextprotocol/server-filesystem |
| playwright | 浏览器自动化 | @playwright/mcp |
| memory | 知识图谱 | @modelcontextprotocol/server-memory |

### 3.2 数据库相关
| Server | 用途 | 官方包 |
|--------|------|--------|
| sqlite | SQLite 操作 | @modelcontextprotocol/server-sqlite |
| postgres | PostgreSQL | @modelcontextprotocol/server-postgres |

### 3.3 云服务相关
| Server | 用途 | 配置方式 |
|--------|------|----------|
| aws | AWS 工具 | IAM 凭证 |
| docker | Docker 操作 | Docker Socket |

## 4. MCP 安全配置

### 4.1 环境变量
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### 4.2 安全原则
- ⚠️ API Key 使用环境变量，禁止硬编码
- ⚠️ 敏感配置使用 `~/.claude.json.local`
- ✅ 定期轮换 API Key
- ❌ 禁止在项目配置中存储密钥

## 5. MCP 命令

### 5.1 常用命令
```bash
# 查看 MCP 状态
claude mcp list

# 添加 MCP Server
claude mcp add server-name --command npx --args @server/package

# 移除 MCP Server
claude mcp remove server-name

# 重新加载 MCP
claude mcp reload
```

### 5.2 调试命令
```bash
# 查看 MCP 日志
claude mcp logs

# 测试 MCP 连接
claude mcp test server-name
```

## 6. MCP 开发规范

### 6.1 自定义 MCP Server
```json
{
  "mcpServers": {
    "my-custom-server": {
      "command": "node",
      "args": ["/path/to/server.js"],
      "env": {
        "PORT": "3000"
      }
    }
  }
}
```

### 6.2 Server 开发规范
- ✅ 使用官方 MCP SDK
- ✅ 实现标准化的 tool 接口
- ✅ 提供友好的错误处理
- ✅ 编写完整的使用文档

## 7. MCP 故障排查

### 7.1 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 连接失败 | 包未安装 | `npx -y @server/package` |
| 超时 | 网络问题 | 检查代理设置 |
| 权限错误 | 凭证失效 | 刷新 API Key |

### 7.2 调试步骤
1. 检查 `claude mcp list` 输出
2. 查看 `claude mcp logs`
3. 验证网络连接
4. 检查环境变量

## 8. 配置模板

### 8.1 完整配置示例
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem"],
      "env": {
        "allowedDirectories": "${HOME}"
      }
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp"]
    }
  }
}
```
