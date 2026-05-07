---
name: skill-dev-subagent
description: "子 Agent 驱动开发：将计划拆解为任务，每个任务派发独立子 Agent 执行，两阶段审查（规格合规→代码质量），不通过自动重试。"
allowed-tools: Read,Grep,Glob,Write,Bash,Agent
---

# 子 Agent 驱动开发

> **核心原则：每任务独立子 Agent + 两阶段审查 = 高质量并行开发**

---

## 铁律

> **`NO CODE WITHOUT A PLAN FIRST`**
> **`NO TASK WITHOUT A DEDICATED SUBAGENT`**

---

## 工作流程

```
                        ┌───────────────┐
                        │  实现计划文档    │
                        │(writing-plans) │
                        └───────┬───────┘
                                │
                    ┌───────────▼───────────┐
                    │  为每个任务创建子Agent  │
                    │  (并行执行独立任务)     │
                    └───────────┬───────────┘
                                │
                    ┌───────────▼───────────┐
                    │  子 Agent 执行任务      │
                    │  (TDD: RED→GREEN→     │
                    │   REFACTOR→自审查)     │
                    └───────────┬───────────┘
                                │
                    ┌───────────▼───────────┐
                    │  Stage 1: 规格审查     │
                    │  (spec-reviewer)       │
                    └───────┬───────────────┘
                            │
                 ┌──────────▼──────────┐
                 │      通过?           │
                 └──┬──────────────┬───┘
                    │ 是           │ 否
                    │              ▼
                    │       ┌──────────────┐
                    │       │ 自动重试循环   │◄────
                    │       │ 创建修复Agent │      │
                    │       └──────────────┘      │
                    │              │              │
                    └──────────────┘──────────────┘
                           │
                    ┌──────▼───────┐
                    │  Stage 2:    │
                    │  代码质量审查  │
                    │(quality-     │
                    │ reviewer)    │
                    └──────┬───────┘
                           │
                 ┌─────────▼────────┐
                 │      通过?        │
                 └──┬────────────┬──┘
                    │ 是         │ 否
                    │            ▼
                    │      ┌───────────┐
                    │      │ 自动重试   │
                    │      └───────────┘
                    │
                    ▼
          ┌─────────────────┐
          │  标记任务完成     │
          │  进入下一个任务   │
          └─────────────────┘
```

---

## 前置条件

在执行此技能前，必须先有：
1. 一份**实现计划**（由 skill-dev-writing-plans 生成）
2. 计划中包含**任务清单**，每个任务标注了文件路径、前置依赖、验证步骤

---

## 执行步骤

### Step 1: 选择执行模式

根据任务依赖关系选择模式：

| 模式 | 适用场景 | 说明 |
|------|----------|------|
| **子 Agent 模式** | 任务间无依赖或弱依赖 | 每任务派发独立子 Agent，自动审查 |
| **串行模式** | 任务强依赖（B 依赖 A） | 串行执行，每步后人工确认 |

### Step 2: 创建任务列表

使用 `TaskCreate` 为计划中的每个任务创建跟踪项：

```
任务 1: 实现 [功能A]
  依赖: 无
  文件: [文件路径]
  子 Agent: implementer

任务 2: 实现 [功能B]
  依赖: 任务 1
  文件: [文件路径]
  子 Agent: implementer
```

### Step 3: 派发子 Agent（核心）

每个独立任务调用 `Agent` tool 派发子 Agent：

```
调用: Agent
参数:
  description: "实现 [功能名]"
  subagent_type: "general-purpose"  # 或自定义 implementer
  prompt: |
    [任务描述 - 来自计划]
    
    [需要修改的文件路径及内容]
    
    [验证命令]
    
    请遵循 TDD 铁律：先写失败测试 → 实现最简代码 → 重构 → 自审查
```

### Step 4: 两阶段审查（自动）

子 Agent 完成任务后，顺序执行两个审查步骤：

**Stage 1 — 规格合规审查：**
```
调用: Agent
参数:
  description: "规格审查: [功能名]"
  subagent_type: "spec-reviewer"
  prompt: |
    检查以下实现是否与规格一致。
    
    规格：[任务描述]
    实现文件：[文件路径]
```

**Stage 2 — 代码质量审查：**
```
调用: Agent
参数:
  description: "质量审查: [功能名]"
  subagent_type: "quality-reviewer"
  prompt: |
    检查以下代码的质量。
    
    文件：[文件路径]
```

### Step 5: 处理审查结果

| 审查结果 | 行动 |
|----------|------|
| Stage 1 不通过 | → 创建修复子 Agent → 重新审查 |
| Stage 2 有 Critical/Important | → 创建修复子 Agent → 重新审查 |
| Stage 2 只有 Minor | → 记录，继续 |
| 两阶段都通过 | → 标记任务完成 |

### Step 6: 完成所有任务

全部任务完成后：
```
1. 运行完整测试套件
2. 要求 skill-dev-verification 执行完成验证
3. 输出最终摘要
```

---

## 领域专业知识注入

### 自动注入（推荐）

子 Agent 的 prompt 中自动包含 `CLAUDE.md` 和项目上下文，子 Agent 能自动理解项目技术栈。

### 手动注入（专有领域）

对于**特有领域知识**（如 GB28181 SIP 协议、FFmpeg 参数等），在派发子 Agent 时：

**模板 1：通过 prompt 注入**
```
prompt: |
  任务：[任务描述]
  
  ## 领域上下文
  [在此粘贴领域知识、协议规范、配置规则等]
  
  请遵循 TDD 铁律。
```

**模板 2：通过领域技能文件**
```
prompt: |
  任务：[任务描述]
  
  ## 领域参考
  以下是项目的领域规则文件，请严格遵循：
  
  [引用 .claude/rules/ 下的领域规则文件]
```

### 用户如何提供领域知识

当技能检测到需要领域专业知识时，会询问用户：

```
>>> 检测到 [SIP/FFmpeg/...] 相关的任务。
>>> 你有以下选择：
>>> 1. [自动] 给我一段领域说明，我会在子 Agent 中引用
>>> 2. [模板] 使用我在 .claude/rules/ 下已有的领域规则文件
>>> 3. [跳过] 不需要领域专用指导
```

---

## 示例：GB28181 SIP 领域任务

### 用户输入
```
为 GbSimulatorInstance 实体添加 portUniquenessValidator
```

### 子 Agent prompt（自动注入领域上下文）
```
任务：为 GbSimulatorInstance 添加端口唯一性校验注解

领域上下文：
- 项目使用 Spring Boot Validation + H2
- sipPort 和 adminPort 不能重复
- 已有端口字段：localSipPort, adminPort
- 团队规范：端口范围 1024-65535

文件：
- src/main/java/.../entity/GbSimulatorInstance.java
- src/main/java/.../controller/InstanceController.java

验证命令：mvn test

请遵循 TDD 铁律。
```

---

## 子 Agent 定义模板（供用户自定义）

如果用户需要创建专用子 Agent（如 SIP 专家），可以在 `.claude/agents/` 下添加：

```markdown
---
name: sip-expert
description: GB28181 SIP 协议专家。处理 SIP 配置、注册流程、信令交互相关任务。
tools: Read,Grep,Glob,Write,Edit,Bash
model: inherit
---

# SIP Agent

你是一个 GB/T 28181-2016 协议专家。
...
```

---

## 使用方式

| 场景 | 触发方式 |
|------|----------|
| 开发流程 | `/dev-feature`（Phase 4-5 自动触发） |
| 独立使用 | `/skill-dev-subagent [计划文件路径]` |
| 自然语言 | "帮我把这个计划用子 Agent 并行执行" |

---

## 版本

_版本: 1.0.0 | 更新: 2026-05-07_
