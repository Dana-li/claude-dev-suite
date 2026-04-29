# 贡献指南

感谢你考虑为 Dev Suite 贡献代码！

## 如何贡献

### 报告问题

使用 GitHub Issues 报告：
- Bug 报告
- 功能请求
- 文档改进

### 提交代码

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/your-feature`
3. 提交更改：`git commit -m 'Add some feature'`
4. 推送到分支：`git push origin feature/your-feature`
5. 创建 Pull Request

## 开发规范

### 插件命名

- 使用 kebab-case：`dev-my-plugin`
- 不超过 50 字符
- 具有描述性

### Skills 命名

- 目录名：kebab-case
- 文件名：**必须为 `SKILL.md`（全大写）**

### 命令文件

- 文件名：kebab-case.md
- 必须包含 YAML frontmatter：
```yaml
---
description: 命令描述
argument-hint: 可选参数描述
---
```

### plugin.json 规范

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "简短描述",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  }
}
```

## 代码审查清单

- [ ] 插件名称符合规范
- [ ] plugin.json 包含 version/author
- [ ] README.md 已更新
- [ ] CHANGELOG.md 已更新
- [ ] 所有命令有 YAML frontmatter
- [ ] 所有 Skills 有 `SKILL.md`
- [ ] Hooks 脚本退出码为 0
- [ ] 路径使用 `${CLAUDE_PLUGIN_ROOT}`

## 版本号规范

遵循语义化版本 (SemVer)：
- MAJOR.MINOR.PATCH
- MAJOR: 不兼容的 API 变更
- MINOR: 向后兼容的功能添加
- PATCH: 向后兼容的问题修复

## 许可

通过贡献，你同意你的代码将在 MIT 许可证下发布。