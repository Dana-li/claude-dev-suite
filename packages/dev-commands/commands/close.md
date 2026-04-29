---
description: Task completion checklist and cleanup
argument-hint: Optional task ID or description
---

# Task Close

> **版本**: v1.0
> **用途**: 任务完成收尾检查

---

## 完成检查清单

### 1. 代码完成

| 检查项 | 状态 |
|--------|------|
| 功能实现完成 | ☐ |
| 单元测试通过 | ☐ |
| 代码审查通过 | ☐ |
| 文档已更新 | ☐ |

### 2. Git 状态

```bash
# 检查状态
git status

# 确保所有变更已提交
git log --oneline -5
```

### 3. 清理工作

```bash
# 清理临时文件
rm -rf target/
rm -rf node_modules/.cache/

# 清理分支（可选）
git branch -d feature/xxx
```

### 4. 总结报告

输出格式：

```
## 任务完成报告

### 基本信息
- 任务: 功能开发
- 分支: feature/new-login
- 完成时间: 2026-04-29

### 完成内容
- ✅ 用户登录页面
- ✅ OAuth2 集成
- ✅ 会话管理

### 修改文件
- src/pages/Login.vue
- src/api/auth.ts
- tests/auth.spec.ts

### 下一步
- [ ] 部署到测试环境
- [ ] UAT 测试
- [ ] 生产发布
```

---

## 提交总结

```bash
# 提交变更
git add .
git commit -m "feat(auth): add OAuth2 login

- Support WeChat OAuth2
- Add session management
- Integration with existing user system

Closes #123"
```

---

## 后续步骤

| 步骤 | 说明 | 状态 |
|------|------|------|
| 创建 PR | 提交代码审查 | ☐ |
| 合并代码 | 合并到主分支 | ☐ |
| 部署测试 | 发布到测试环境 | ☐ |
| 通知相关方 | 告知功能可用 | ☐ |

---

**版本**: v1.0
**创建日期**: 2026-04-29
