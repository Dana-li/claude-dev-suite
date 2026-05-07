---
name: skill-dev-using
description: "Dev Suite 元技能入口：每个会话自动注入。定义了如何查找、选择和使用所有 Dev Suite 技能。只要有 1% 的可能性某个技能适用，必须先调用技能再回应。"
allowed-tools: Read,Grep,Glob
---

# Dev Suite 元技能入口

> **Dev Suite 技能系统的第一入口 —— 每个会话自动注入**

---

## 核心铁律

### 铁律 1：1% 规则

> 如果你认为哪怕只有 **1% 的可能性** 某个 Dev Suite 技能可能适用，你必须先调用技能检查，再回应。

这是**不可协商的**规则。原因：

| 你的想法 | 现实 |
|----------|------|
| "这只是个简单问题" | 问题也是任务，检查技能 |
| "我需要更多上下文" | 技能检查在回应前，不是之后 |
| "让我先探索代码库" | 技能告诉你如何探索，先检查 |
| "我能快速检查一下" | 文件缺少对话上下文，检查技能 |
| "这不需要正式技能" | 如果技能存在，就使用它 |
| "我记得这个技能的内容" | 技能会演进，读当前版本 |
| "技能太重了" | 简单事情会变复杂，使用它 |
| "我先做这一件事" | 做任何事前先检查 |
| "先快速修复一下" | 无纪律行动浪费时间，技能防止这个 |
| "我知道那是什么意思" | 知道概念 ≠ 使用技能，调用它 |

### 铁律 2：技能优先级

多个技能同时适用时，按以下顺序处理：

```
第一梯队（流程技能 — 决定"做什么"）
─────────────────────────────────────
1. systematic-debugging    → 遇到 Bug/异常时
2. brainstorming           → 需求不明确/需要设计方案时
3. writing-plans           → 需要拆解任务时

第二梯队（实施技能 — 决定"怎么做"）
─────────────────────────────────────
4. test-driven-development → 实现功能/修复 Bug 时
5. code-review             → 代码审查/合并前
6. verification            → 任务完成/声称完成前
7. git-worktree            → 需要隔离开发环境时

第三梯队（元技能 — 决定"用什么"）
─────────────────────────────────────
8. skill-dev-bug           → Bug 复盘分析
9. skill-dev-design        → 详细设计文档生成
10. skill-dev-using        → （当前元技能）
```

---

## 可用技能总览

### 🔧 开发流程类

| 技能 | 触发场景 | 核心铁律 |
|------|----------|----------|
| **brainstorming** | 编码前/方案选型 | 至少 3 个方案，输出设计文档到 `docs/plans/` |
| **writing-plans** | 多步任务实现前 | 任务粒度 2-5 分钟，标注文件路径 |
| **test-driven-development** | 功能实现/bug 修复 | 无失败测试不写生产代码 |
| **code-review** | 合并前/PR 前 | 两阶段审查（规格合规 → 代码质量） |
| **verification** | 声称完成前 | 无新鲜验证证据不声称完成 |
| **git-worktree** | 需要隔离开发 | 不在 main/master 上直接开发 |

### 🐛 分析与修复类

| 技能 | 触发场景 | 核心铁律 |
|------|----------|----------|
| **systematic-debugging** | 遇到 Bug/异常 | 无根因不修复 |
| **skill-dev-bug** | Bug 复盘 | 输出复盘文档到 `docs/bug-fix/` |

### 📐 设计类

| 技能 | 触发场景 | 核心铁律 |
|------|----------|----------|
| **brainstorming** | 方案选型/架构设计 | 多方案对比+权衡分析 |
| **skill-dev-design** | 详细设计/数据库设计 | 输出设计文档到 `docs/design/` |

### ✅ 质量类

| 技能 | 触发场景 | 核心铁律 |
|------|----------|----------|
| **test-driven-development** | 实现前 | RED→GREEN→REFACTOR |
| **code-review** | 代码合并前 | 两阶段审查循环 |
| **verification** | 完成前 | 5 步验证流程 |

---

## 技能查找方式

使用 Claude Code 的 Skill tool 搜索技能：

```
搜索 skill-dev-bug        → Bug 分析
搜索 skill-dev-design     → 详细设计
搜索 skill-dev-review     → 代码审查
搜索 skill-dev-test       → TDD 测试
搜索 skill-dev-writing-plans  → 编写计划
搜索 skill-dev-verification   → 完成验证
搜索 skill-dev-worktree   → Git Worktree
```

---

## 工作流集成

Dev Suite 10 阶段工作流 (`/dev`) 自动集成以下技能：

| 阶段 | 关联技能 | 说明 |
|------|----------|------|
| Phase 1-3 (Discovery/Exploration/Clarification) | brainstorming | 需求澄清与方案设计 |
| Phase 4 (Architecture) | brainstorming + writing-plans | 架构设计与任务拆解 |
| Phase 5 (Implementation) | test-driven-development | TDD 开发 |
| Phase 6 (Quality) | code-review | 两阶段代码审查 |
| Phase 7 (Summary) | verification | 完成前验证 |
| Phase 8-10 (Integration/Deployment/Hotfix) | systematic-debugging | 调试与集成 |

---

## 版本

_版本: 1.0.0 | 更新: 2026-05-07_
