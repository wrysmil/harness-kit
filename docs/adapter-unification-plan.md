# 适配器统一优化方案

## Context

harness-kit 的五个平台适配器（cursor / claude / trae / agents）存在**文档与实际能力不匹配**的问题：
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

---

## 第二步：结构对齐 — 将平台无关逻辑下沉到 core

### 2.1 需要从 Cursor 适配器迁移到 core / 共享层的文件

| 文件 | 当前位置 | 目标位置 | 理由 |
|------|---------|---------|------|
| `context-budget.md` | `adapters/cursor/orchestration/` | `core/orchestration/` | 40% 规则、scope limits、monitoring 逻辑完全平台无关 |
| `continuous-loop.md` | `adapters/cursor/orchestration/` | `core/orchestration/` | 循环模式定义（single-pass / maintenance / continuous）是共享逻辑，只有 spawn/handoff 机制平台相关 |
| `model-routing.yaml` 结构 | `adapters/cursor/orchestration/` | `core/orchestration/` | 角色列表和并行度默认值是共享的；模型/agent 绑定语法是平台特定的 |
| `platform-adapters.zh.md` | `adapters/cursor/orchestration/` | `core/orchestration/` | 平台检测信号和角色映射是共享逻辑，补充 Trae 后移入 core |
| `git-xywh/` | `adapters/cursor/.cursor/skills/` | `adapters/agents/.agents/skills/` | 通用 Git 工作流 skill，无平台特定内容，应放在共享层供所有平台使用。注意：需一并迁移 `技能审查报告v1.md`、`技能审查报告v2.md`、`_meta.json` |

Cursor 平台特定文件迁移到 `.cursor/`：
| 文件 | 当前位置 | 目标位置 |
|------|---------|---------|
| `CURSOR-PRECHECK.md` | `adapters/cursor/orchestration/` | `adapters/cursor/.cursor/` |
| `VENDOR.md` | `adapters/cursor/orchestration/` | `adapters/cursor/`（根目录） |
| `config.defaults.yaml` | `adapters/cursor/orchestration/` | `adapters/cursor/.cursor/` |
| `hooks/README.md` | `adapters/cursor/orchestration/hooks/` | `adapters/cursor/.cursor/hooks/`（合并已有目录） |

**hooks 目录合并说明：** `.cursor/hooks/` 已存在（含 `harness-subagent-track-reminder.sh`），迁移时将 `orchestration/hooks/README.md` 合并到现有目录，不覆盖已有文件。

迁移完成后，**删除 `adapters/cursor/orchestration/` 目录**（含 `runtime/plan-progress-sync.md` stub）。

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
- **Trae**：补充 `.trae/rules/` 目录结构

### 2.3 修改后完整目录结构

```
harness-kit/
├── core/
│   ├── artifacts.md
│   ├── capabilities/
│   │   ├── primitives.md
│   │   └── registry.md
│   ├── harness.md
│   ├── orchestration/
│   │   ├── agents/
│   │   │   ├── coder.md
│   │   │   ├── debugger.md
│   │   │   ├── implementer.md
│   │   │   ├── leader.md
│   │   │   ├── reviewer.md
│   │   │   ├── test-engineer.md
│   │   │   └── web-investigator.md
│   │   ├── config.defaults.yaml
│   │   ├── context-budget.md          ★ 从 cursor/orchestration/ 迁移
│   │   ├── continuous-loop.md         ★ 从 cursor/orchestration/ 迁移
│   │   ├── dispatcher-workflow.md
│   │   ├── model-routing.yaml         ★ 从 cursor/orchestration/ 迁移（共享结构）
│   │   ├── platform-adapters.zh.md    ★ 从 cursor/orchestration/ 迁移
│   │   ├── roles.md
│   │   ├── runtime/
│   │   │   └── plan-progress-sync.md
│   │   ├── skill-preferences.md
│   │   └── tracking/
│   │       └── schema.md
│   ├── routing.md
│   ├── runbooks.md
│   └── verification.md
│
├── adapters/
│   ├── agents/
│   │   └── .agents/
│   │       ├── README.md              ★ 需要创建（目录说明）
│   │       ├── agents/                # 共享 agent 定义
│   │       │   ├── coder.md
│   │       │   ├── debugger.md
│   │       │   ├── explorer.md
│   │       │   ├── implementer.md
│   │       │   ├── reviewer.md
│   │       │   ├── test-engineer.md
│   │       │   └── web-investigator.md
│   │       └── skills/
│   │           ├── browser-testing-with-devtools/
│   │           ├── claude-orchestration/
│   │           ├── cursor-orchestration/
│   │           ├── document-review/
│   │           ├── frontend-design/
│   │           ├── git-xywh/          ★ 从 cursor/.cursor/skills/ 迁移（通用 skill）
│   │           │   ├── SKILL.md
│   │           │   ├── _meta.json
│   │           │   ├── advanced.md
│   │           │   ├── branching.md
│   │           │   ├── collaboration.md
│   │           │   ├── commands.md
│   │           │   ├── conflicts.md
│   │           │   ├── history.md
│   │           │   ├── workflow.md
│   │           │   ├── 技能审查报告v1.md
│   │           │   └── 技能审查报告v2.md
│   │           ├── receiving-code-review/
│   │           ├── requesting-code-review/
│   │           ├── systematic-debugging/
│   │           ├── test-driven-development/
│   │           ├── trae-orchestration/  ★ 新增 Trae 编排 skill
│   │           │   └── SKILL.md
│   │           ├── ui-ux-pro-max/
│   │           └── verification-before-completion/
│   │
│   ├── claude/
│   │   ├── .claude/                   ★ 补充平台原生配置目录
│   │   │   └── settings.example.json  # hooks 配置示例（可选）
│   │   ├── bindings.md
│   │   ├── capability-matrix.yaml     ★ 修正：structured-ask → supported
│   │   └── README.md                  ★ 修正差异表
│   │
│   ├── cursor/
│   │   ├── .cursor/
│   │   │   ├── hooks/
│   │   │   │   └── README.md          ★ 从 orchestration/hooks/ 迁移
│   │   │   ├── config.defaults.yaml   ★ 从 orchestration/ 迁移
│   │   │   ├── CURSOR-PRECHECK.md     ★ 从 orchestration/ 迁移
│   │   │   └── skills/
│   │   │       └── README.md          # 不再包含 git-xywh（已迁移）
│   │   ├── bindings.md
│   │   ├── capability-matrix.yaml
│   │   ├── README.md
│   │   └── VENDOR.md                  ★ 从 orchestration/ 迁移
│   │
│   └── trae/
│       ├── .trae/                     ★ 补充平台原生配置目录
│       │   └── rules/
│       ├── bindings.md                ★ 全面修正：去掉"待定义"
│       ├── capability-matrix.yaml     ★ 全面修正：degraded → 实际状态
│       └── README.md                  ★ 去掉"骨架"标记
│
├── artifact-templates/
│   └── ...
│
├── docs/
│   ├── adapter-unification-plan.md
│   └── ...
│
├── entrypoints/
│   └── ...
│
├── init/
│   └── ...
│
├── context-map.md
├── project.git.md
├── project.profile.md
├── project.verification.md
└── README.md
```

### 2.3 新增 Trae orchestration skill

文件：`adapters/agents/.agents/skills/trae-orchestration/SKILL.md`

参照 `cursor-orchestration` 和 `claude-orchestration` 的模式，创建 Trae 版本的编排 skill：
- 触发条件同其他平台
- 使用 Trae Agent 模式作为 spawn 机制
- 委托到 `core/orchestration/dispatcher-workflow.md`
- 引用 `adapters/trae/bindings.md`

---

## 第三步：更新共享层 references

### 3.1 更新 `core/orchestration/platform-adapters.zh.md`

先迁移文件到 `core/orchestration/`，再补充 Trae 平台的检测信号和角色映射。

### 3.2 更新 `adapters/agents/.agents/README.md`

当前不存在，需要创建。内容：共享 agents 和 skills 的目录说明。

### 3.3 core 编排层补充

`core/orchestration/` 新增（从 Cursor 迁移）：
- `context-budget.md` — 上下文预算规则
- `continuous-loop.md` — 循环模式定义
- `model-routing.yaml` — 共享结构（角色列表、并行度默认值）
- `platform-adapters.zh.md` — 平台检测信号和角色映射

---

## 实施顺序

1. **修正 capability-matrix.yaml**（claude / trae）
2. **修正对应的 README.md 和 bindings.md**
3. **迁移共享文件到 core/orchestration/**（context-budget.md、continuous-loop.md、platform-adapters.zh.md、model-routing.yaml 共享结构）
4. **迁移 git-xywh/ 到 adapters/agents/.agents/skills/**（含审查报告和 _meta.json）
5. **迁移 Cursor 平台特定文件到 .cursor/**（CURSOR-PRECHECK.md、config.defaults.yaml、hooks/README.md）
6. **迁移 VENDOR.md 到 adapters/cursor/ 根目录**
7. **扫描并更新所有外部引用**（见下方引用清单）
8. **删除 adapters/cursor/orchestration/ 目录**
9. **创建 trae-orchestration skill**
10. **更新 adapters/agents/.agents/README.md**（skills 计数更新为 12，新增 trae-orchestration）

### 需要更新的外部引用清单

迁移后必须更新以下文件中的旧路径引用：

| 文件 | 引用数量 | 说明 |
|------|---------|------|
| `README.md` | ~6 处 | 第 203、287、288、297、323、343、406 行 |
| `context-map.md` | 1 处 | 第 46 行 |
| `entrypoints/AGENTS.md` | 2 处 | 第 71、75 行 |
| `scripts/harness-check.sh` | ~8 处 | 第 84-109 行 |
| `scripts/install-ai-skills.sh` | 1 处 | 第 108 行（git-xywh 投影路径） |
| `artifact-templates/dispatch-track.md` | 1 处 | 第 7 行 |
| `artifact-templates/progress.md` | 1 处 | 第 7 行 |
| `artifact-templates/handoff.md` | 1 处 | 第 7 行 |
| `docs/communication-templates.md` | 1 处 | 第 100 行 |

---

## 验证

- 每个适配器的 `capability-matrix.yaml` 中不再有错误的 `degraded`/`manual` 标记
- `core/orchestration/` 包含所有平台无关的编排逻辑（含 platform-adapters.zh.md、model-routing.yaml）
- `adapters/agents/.agents/skills/git-xywh/` 存在且内容完整（含审查报告和 _meta.json）
- `adapters/cursor/orchestration/` 目录已删除
- Trae 适配器有完整的 bindings 和 orchestration skill
- 五个适配器目录结构符合统一最小公约数
- **无断链**：`grep -r "adapters/cursor/orchestration/" .` 返回空结果
- **scripts 可用**：`harness-check.sh` 和 `install-ai-skills.sh` 中的路径已全部更新
