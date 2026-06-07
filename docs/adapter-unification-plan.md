# 适配器统一优化方案

## Context

harness-kit 的五个平台适配器（cursor / claude / codex / trae / agents）存在**文档与实际能力不匹配**的问题：
- Claude Code 的 `hooks` 和 `structured-ask` 被错误标为 `manual`/`degraded`
- Trae 的能力被错误标为全部 `degraded` + `"待定义"`
- Cursor 的 `orchestration/` 目录包含大量**平台无关逻辑**（context-budget、continuous-loop），应该下沉到 `core/`
- 各适配器目录结构不统一，缺少共同的最小公约数

本方案分两步走：**修正能力矩阵** + **结构对齐**。

---

## 第一步：修正各适配器 capability-matrix.yaml

### 1.1 Claude 适配器修正

文件：`adapters/claude/capability-matrix.yaml`

| 能力项 | 当前状态 | 修正后 | 修正理由 |
|--------|---------|--------|---------|
| `interaction.structured-ask` | `degraded` | **`supported`** | Claude Code 有原生 `AskUserQuestion` 工具，支持单选/多选 + preview |
| `hooks.session-lifecycle` | `manual` | **`supported`** | Claude Code 原生支持 `PreToolUse`/`PostToolUse`/`AskUserQuestion`/`Stop` hooks，通过 `.claude/settings.json` 配置 |

同步修正 `adapters/claude/README.md` 中的差异表和 `adapters/claude/bindings.md` 中的降级标记。

### 1.2 Trae 适配器修正

文件：`adapters/trae/capability-matrix.yaml`

Trae 平台实际能力（基于调研）：
- `.trae/rules/` 目录支持项目级规则
- Agent 模式支持自主规划+执行
- 有 structured Ask 功能
- 有类似 hooks 的扩展机制

需要逐项将 `degraded` + `"待定义"` 替换为实际绑定：
- `routing.*` → 绑定到 `.trae/rules/` 规则文件
- `orchestration.dispatch` / `parallel-wu` → 绑定到 Trae Agent 模式
- `roles.*` → 绑定到共享 `.agents/agents/*.md` + Trae Agent
- `interaction.structured-ask` → 绑定到 Trae structured Ask
- `hooks.session-lifecycle` → 绑定到 Trae hooks 机制
- `skills.stage-load` → 已正确绑定 `Read SKILL.md`

同步修正 `adapters/trae/bindings.md` 和 `adapters/trae/README.md`（去掉"骨架"标记）。

### 1.3 Codex 适配器复核

文件：`adapters/codex/capability-matrix.yaml`

当前状态基本合理（大部分 `supported`，少数 `degraded`/`manual`），但需要确认：
- `interaction.structured-ask` 是否确实 `degraded`（Codex CLI 有无类似提问机制）
- `hooks.session-lifecycle` 是否确实 `manual`

---

## 第二步：结构对齐 — 将平台无关逻辑下沉到 core

### 2.1 需要从 Cursor 适配器迁移到 core 的文件

| 文件 | 当前位置 | 目标位置 | 理由 |
|------|---------|---------|------|
| `context-budget.md` | `adapters/cursor/orchestration/` | `core/orchestration/` | 40% 规则、scope limits、monitoring 逻辑完全平台无关 |
| `continuous-loop.md` | `adapters/cursor/orchestration/` | `core/orchestration/` | 循环模式定义（single-pass / maintenance / continuous）是共享逻辑，只有 spawn/handoff 机制平台相关 |
| `model-routing.yaml` 结构 | `adapters/cursor/orchestration/` | `core/orchestration/` | 角色列表和并行度默认值是共享的；模型/agent 绑定语法是平台特定的 |

迁移模式同 `plan-progress-sync.md`：原位置留重定向 stub，实际内容移到 core。

### 2.2 各适配器目录结构对齐

目标：每个适配器都有统一的最小结构。

```
adapters/<platform>/
  README.md                    # 适配器概述
  bindings.md                  # 原语 → 平台绑定映射
  capability-matrix.yaml       # 能力状态矩阵
  .<platform>/                 # 平台原生配置目录（可选）
    rules/                     # 平台规则文件
    hooks/                     # 平台 hooks（如适用）
    skills/                    # 平台特定 skill（如适用）
```

- **Cursor**：保持现有 `.cursor/` 结构，新增的 core 迁移文件留 stub
- **Claude**：补充 `.claude/` 目录（如需要放 hooks 配置示例）
- **Codex**：保持精简（三个标准文件），按需补充
- **Trae**：补充 `.trae/rules/` 目录结构

### 2.3 新增 Trae orchestration skill

文件：`adapters/agents/.agents/skills/trae-orchestration/SKILL.md`

参照 `cursor-orchestration` 和 `claude-orchestration` 的模式，创建 Trae 版本的编排 skill：
- 触发条件同其他平台
- 使用 Trae Agent 模式作为 spawn 机制
- 委托到 `core/orchestration/dispatcher-workflow.md`
- 引用 `adapters/trae/bindings.md`

---

## 第三步：更新共享层 references

### 3.1 更新 `adapters/cursor/orchestration/platform-adapters.zh.md`

补充 Trae 平台的检测信号和角色映射。

### 3.2 更新 `adapters/agents/.agents/README.md`

当前不存在，需要创建。内容：共享 agents 和 skills 的目录说明。

### 3.3 core 编排层补充

`core/orchestration/` 新增（从 Cursor 迁移）：
- `context-budget.md` — 上下文预算规则
- `continuous-loop.md` — 循环模式定义

---

## 实施顺序

1. **修正 capability-matrix.yaml**（claude / trae / codex 复核）
2. **修正对应的 README.md 和 bindings.md**
3. **迁移 context-budget.md 和 continuous-loop.md 到 core/**
4. **创建 adapters/cursor/orchestration/ 下的 stub 重定向**
5. **创建 trae-orchestration skill**
6. **创建 adapters/agents/.agents/README.md**
7. **更新 platform-adapters.zh.md**

---

## 验证

- 每个适配器的 `capability-matrix.yaml` 中不再有错误的 `degraded`/`manual` 标记
- `core/orchestration/` 包含所有平台无关的编排逻辑
- Cursor 适配器的迁移文件变为 stub 重定向
- Trae 适配器有完整的 bindings 和 orchestration skill
- 五个适配器目录结构符合统一最小公约数
