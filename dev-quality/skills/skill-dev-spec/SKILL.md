---
name: "skill-dev-spec"
version: "1.0.0"
description: "OpenSpec 规范驱动开发 - 生成/验证 spec.md，作为开发 source of truth"
agent_created: true
---

# OpenSpec 规范驱动开发技能

## 核心理念

> **在写代码前，先把事定义清楚** — 让 AI 按规范执行，而不是自由发挥。

`spec.md` 是 **source of truth**，所有后续开发必须与之对齐。

---

## 文件结构

```
openspec/
├── specs/                    # 系统正式规格（source of truth）
│   └── <domain>/
│       └── spec.md
├── changes/                  # 每次变更的工作区
│   └── <change-name>/
│       ├── proposal.md       # Why + What
│       ├── design.md        # 技术实现
│       ├── tasks.md         # 任务拆解
│       └── specs/           # delta specs（增量规格）
└── config.yaml               # 项目级配置（可选）
```

---

## spec.md 格式规范

### 完整模板

```markdown
# Spec: <domain>

## Why

<1-3 段描述为什么需要这个能力/领域>

## Capabilities

### <capability-id>

- **描述**: <一句话描述能力>
- **接口**: `<函数/API 签名>`
- **行为**:
  - <预期行为 1>
  - <预期行为 2>
- **边界**:
  - <不包含什么>
  - <不处理什么场景>

## Acceptance Scenarios

### <scenario-id>

- **Given**: <前置条件>
- **When**: <触发动作>
- **Then**: <预期结果>

### <scenario-id-2>

- **Given**: ...
- **When**: ...
- **Then**: ...
```

### 字段说明

| 字段 | 必填 | 说明 |
|------|------|------|
| `Why` | ✅ | 为什么需要这个能力 |
| `Capabilities` | ✅ | 能力列表，每个有明确 ID |
| `capability-id` | ✅ | kebab-case，如 `user-login` |
| `描述` | ✅ | 一句话说明能力 |
| `接口` | ⚠️ | API/函数签名（后端必填，前端可选） |
| `行为` | ✅ | 预期行为列表 |
| `边界` | ✅ | 明确不包含什么（防止 scope creep） |
| `Acceptance Scenarios` | ✅ | Given-When-Then 格式 |
| `scenario-id` | ✅ | kebab-case，如 `success-login` |

---

## 使用方式

### 场景 A：Phase 4 结束后生成 spec.md（首次）

**触发**: Phase 4 架构设计获得用户批准后

**步骤**:
1. 识别功能领域 `<domain>`（如 `auth`、`payment`、`todo`）
2. 基于 Phase 1-4 的结论生成 `openspec/specs/<domain>/spec.md`
3. 向用户展示 spec.md 内容并确认
4. 确认后将路径写入会话记忆

**生成规则**:
- `Why` 来自 Phase 1 需求 + Phase 3 澄清问题
- `Capabilities` 来自 Phase 4 架构方案
- `Acceptance Scenarios` 来自 Phase 3 边界条件 + Phase 4 设计决策

---

### 场景 B：Phase 4 结束后生成 delta spec（规格已存在）

**触发**: `openspec/specs/<domain>/spec.md` 已存在

**步骤**:
1. 读取已有 `specs/<domain>/spec.md`
2. 识别本次变更影响哪些 capability
3. 在 `openspec/changes/<change-name>/specs/<domain>/spec.md` 中生成 **delta spec**
4. Delta spec 格式：
```markdown
# Delta Spec: <change-name> → <domain>

## Modified Capabilities

### <existing-capability-id>
- **新增行为**: ...
- **修改行为**: ...
- **删除行为**: ...

## New Capabilities

### <new-capability-id>
（同完整模板）

## Removed Capabilities

- <capability-id>: <删除原因>
```
5. 向用户确认 delta spec
6. 确认后**不立即合并**到主 spec，等待 Phase 7 归档时合并

---

### 场景 C：Phase 5 中验证实现与 spec 对齐

**触发**: Phase 5 每完成一个 capability 实现

**检查清单**:
- [ ] capability 行为是否与 `specs/<domain>/spec.md` 描述一致？
- [ ] `Acceptance Scenarios` 是否通过（或有对应测试）？
- [ ] 是否引入了 spec.md 中未声明的能力（scope creep）？
- [ ] 接口签名是否与 spec.md 一致？

**违反处理**:
- 若发现不一致 → 停止实现 → 询问用户：修改代码 or 修改 spec？
- 若用户说"修改 spec" → 更新 `specs/<domain>/spec.md` 并注明原因

---

### 场景 D：Phase 7 归档时合并 delta specs

**触发**: Phase 7 用户确认归档

**步骤**:
1. 读取 `changes/<change-name>/specs/<domain>/spec.md`（delta spec）
2. 读取 `specs/<domain>/spec.md`（主规格）
3. 将 delta 中的变更合并到主 spec：
   - 新增 capability → 追加到 `## Capabilities`
   - 修改 capability → 更新对应描述/行为/边界
   - 删除 capability → 移到 `## Deprecated Capabilities`（不直接删除）
4. 将 `changes/<change-name>/` 移到 `changes/archive/<date>-<change-name>/`
5. 向用户报告归档结果

---

## 与 Dev-Suite 工作流集成

| Dev-Suite Phase | spec 操作 |
|----------------|-----------|
| Phase 1-3 | 收集需求，为 spec 做准备 |
| Phase 4 | 架构设计批准后 → **生成 spec.md（场景 A）或 delta spec（场景 B）** |
| Phase 4.5 | （新增）spec.md 生成与确认 |
| Phase 5 | 每完成一个任务 → **验证与 spec 对齐（场景 C）** |
| Phase 6 | 审查时额外检查：代码是否符合 spec.md |
| Phase 7 | 归档时 → **合并 delta specs（场景 D）** |

---

## 项目级配置（config.yaml）

可选文件，放在 `openspec/config.yaml`：

```yaml
# 技术栈约束
tech-stack:
  backend: spring-boot
  frontend: vue3
  database: mysql-8

# 架构边界
architecture:
  layers:
    - controller
    - service
    - repository
  forbidden-dependencies:
    - controller → repository  # 禁止 controller 直接访问 repository

# 命名规范
naming:
  api: kebab-case
  function: camelCase
  constant: UPPER_SNAKE_CASE

# 忽略路径
exclude:
  - "**/*.test.js"
  - "**/generated/**"
```

**使用方式**: 生成 spec.md 时自动读取 `config.yaml`，确保规范符合项目约束。

---

## 检查清单

### spec.md 生成检查（Phase 4.5）

- [ ] `Why` 描述清晰，说明为什么需要这个能力
- [ ] 每个 capability 有唯一 ID（kebab-case）
- [ ] 每个 capability 明确了边界（不包含什么）
- [ ] 至少有 2 个 Acceptance Scenarios
- [ ] 场景覆盖正常路径 + 边界条件

### spec 对齐检查（Phase 5）

- [ ] 实现行为 ≡ spec.md 描述
- [ ] 未引入 spec 未声明的能力
- [ ] Acceptance Scenarios 有对应测试

### 归档检查（Phase 7）

- [ ] delta spec 已合并到主 spec
- [ ] `changes/<change-name>/` 已移到 `archive/`
- [ ] 主 spec 版本号已更新（若有版本管理）

---

## 常见问题

### Q1: spec.md 和 design.md 有什么区别？

| 维度 | spec.md | design.md |
|------|----------|-----------|
| 目的 | 定义"做什么"（需求规格） | 定义"怎么做"（技术实现） |
| 读者 | 产品/测试/开发 | 开发 |
| 稳定性 | 高（source of truth） | 低（可随实现调整） |
| 格式 | OpenSpec 规范格式 | 自由格式 / ADR 格式 |

**原则**: design.md 可以引用 spec.md，但 spec.md 不依赖 design.md。

### Q2: 已有项目没有 spec.md，如何处理？

**建议路径**:
1. 先为**正在开发的功能**生成 spec.md（向前看）
2. 逐步为**核心模块**补 spec.md（按需）
3. 不需要为所有历史代码补 spec.md（投入产出比低）

### Q3: 用户临时改需求，spec.md 要不要改？

**分情况**:
- 小改动（不影响 capability 边界）→ 直接改代码，Phase 7 时同步 spec
- 大改动（新增/删除 capability）→ 先更新 spec.md，再改代码
- 实验性改动 → 在 `changes/` 下新建分支 spec，验证后再合并

---

## 参考资料

- OpenSpec 官方文档：https://radebit.github.io/OpenSpec-Docs-zh/
- OpenSpec GitHub：https://github.com/Fission-AI/OpenSpec
- Spec-Driven Development 理念：https://openspec.pro/
