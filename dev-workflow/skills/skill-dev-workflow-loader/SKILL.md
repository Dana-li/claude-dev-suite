---
name: "skill-dev-workflow-loader"
version: "1.0.0"
description: "多工作流加载器 — 支持 full-feature/lightweight/hotfix/research 四种预置工作流，支持自定义工作流"
author: "LeeDC"
---

# skill-dev-workflow-loader

> 多工作流加载器 — 根据用户选择加载对应的工作流配置，动态启用/禁用 Phase

**触发条件**：
- 用户在 `/dev` 时指定 `--workflow <name>` 参数
- 用户在 Phase 1 被询问工作流选择
- 需要查看可用工作流列表时

---

## 支持的工作流

| 工作流 | 阶段数 | 适用场景 | Token 预算 |
|--------|--------|----------|------------|
| `full-feature` | 11 | 新功能/架构变更/跨模块改造 | ~125K |
| `lightweight` | 5 | 小功能/Bug修复/局部优化 | ~30K |
| `hotfix` | 3 | 生产环境紧急问题 | ~20K |
| `research` | 4 | 技术调研/方案评估 | ~31K |
| `custom` | 自定义 | 用户自定义阶段组合 | 按配置 |

---

## 工作流程

### 1. 列出可用工作流

```bash
# 读取 workflows/ 目录下所有 yaml 文件
ls dev-workflow/workflows/*.yaml
```

输出格式：
```
可用工作流：

1. full-feature  — 完整功能开发（11 阶段，~125K tokens）
   适用：新功能、架构变更、跨模块改造
   触发：/dev --workflow full-feature

2. lightweight  — 轻量开发（5 阶段，~30K tokens）
   适用：小功能、Bug 修复、局部优化
   触发：/dev --workflow lightweight

3. hotfix  — 热修复（3 阶段，~20K tokens）
   适用：生产环境紧急问题
   触发：/dev --workflow hotfix

4. research  — 技术调研（4 阶段，~31K tokens）
   适用：技术调研、方案评估、架构决策
   触发：/dev --workflow research
```

### 2. 加载指定工作流

```python
import yaml
import json

def load_workflow(workflow_name):
    """加载工作流配置"""
    workflow_path = f"dev-workflow/workflows/{workflow_name}.yaml"
    
    with open(workflow_path, 'r', encoding='utf-8') as f:
        config = yaml.safe_load(f)
    
    return config
```

**验证规则**：
1. 必须有 `name`、`version`、`phases` 字段
2. `phases` 每个元素必须有 `id`、`name`、`required`
3. `phases` 按 `id` 顺序排列
4. 如果有 `depends_on`，验证依赖的 phase id 存在

### 3. 动态生成 dev.md

根据加载的工作流配置，动态生成要执行的 Phase 列表：

```python
def generate_phase_list(config):
    """根据工作流配置生成阶段列表"""
    phases = []
    for phase in config['phases']:
        if phase.get('required', False) or not phase.get('optional', False):
            phases.append({
                'id': phase['id'],
                'name': phase['name'],
                'skill': phase.get('skill', ''),
                'description': phase.get('description', '')
            })
    return phases
```

### 4. 工作流切换

在执行过程中，用户可以要求切换工作流：

```
用户：切换到 lightweight 工作流
Agent：
  - 保存当前进度
  - 加载 lightweight 配置
  - 跳过已禁用的阶段
  - 继续执行
```

---

## 自定义工作流

用户可以通过创建 `dev-workflow/workflows/custom.yaml` 定义自己的工作流：

```yaml
name: "custom"
description: "自定义工作流"
version: "1.0.0"

phases:
  - id: "1"
    name: "Custom Phase 1"
    required: true
    description: "..."

# 更多阶段...
```

**自定义工作流验证**：
- 运行 `scripts/validate-workflow.py` 验证 YAML 格式
- 检查 phase id 是否连续
- 检查 depends_on 引用是否存在

---

## 与 dev.md 集成

修改 `dev.md` 的调用方式，支持 `--workflow` 参数：

```markdown
---
description: Guided feature development with workflow selection
argument-hint: [--workflow <name>] [feature description]
---
```

在 Phase 1 开始时：

1. 检查是否有 `--workflow` 参数
2. 如果有，加载对应的工作流配置
3. 如果没有，展示工作流选择菜单
4. 根据用户选择加载配置
5. 按配置执行对应阶段

---

## 示例：执行 lightweight 工作流

```
用户输入：/dev --workflow lightweight 修复登录页面样式问题

Phase 1: Discovery
  - 简要理解需求和范围
  - ✅ 完成

Phase 2: Quick Exploration（可选）
  - 快速定位相关文件
  - 用户选择：跳过

Phase 3: Implementation
  - TDD 实现（RED→GREEN→REFACTOR）
  - ✅ 完成

Phase 4: Quick Review
  - 单轮代码审查
  - ✅ 完成

Phase 5: Summary
  - 完成验证，输出变更摘要
  - ✅ 完成

工作流执行完毕，共消耗 ~8K tokens（预估）
```

---

## 文件清单

| 文件 | 路径 | 说明 |
|------|------|------|
| full-feature.yaml | dev-workflow/workflows/ | 完整 11 阶段工作流 |
| lightweight.yaml | dev-workflow/workflows/ | 轻量 5 阶段工作流 |
| hotfix.yaml | dev-workflow/workflows/ | 热修复 3 阶段工作流 |
| research.yaml | dev-workflow/workflows/ | 调研 4 阶段工作流 |
| SKILL.md | dev-workflow/skills/skill-dev-workflow-loader/ | 本技能文档 |
| validate-workflow.py | scripts/ | 工作流配置验证脚本 |

---

**版本**：v1.0.0  
**创建日期**：2026-05-09  
**作者**：LeeDC
