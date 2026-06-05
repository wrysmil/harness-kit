---
artifact: spec
title: "跨平台 Harness Capability Kernel（Core-first，Cursor 能力共享至 Claude Code 等）"
date: 2026-06-03
status: draft
platform: harness-kit
route: superpowers:brainstorming
approved: false
related:
  - harness-kit/core/routing.md
  - harness-kit/core/harness.md
  - harness-kit/adapters/cursor/orchestration/dispatcher-workflow.md
  - harness-kit/adapters/cursor/orchestration/platform-adapters.zh.md
  - harness-kit/adapters/agents/.agents/skills/cursor-orchestration/SKILL.md
  - harness-kit/docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md
  - harness-kit/docs/superpowers/specs/2026-05-29-git-worktree-isolation-design.md
---

# 跨平台 Harness Capability Kernel

## 1. 背景与问题

Harness Kit 已在实践中验证：**工具中立层**（`core/routing.md`、产物契约、阶段门禁）+ **平台适配层**（`adapters/cursor/`、`adapters/codex/`）可让同一仓库在 Cursor 与 Codex 间迁移规则。

当前缺口：

| 现象 | 影响 |
| --- | --- |
| 编排语义集中在 `adapters/cursor/orchestration/` | Claude Code 只能读入口 `CLAUDE.md`，**无**与 `cursor-orchestration:dispatcher-workflow` 对等的绑定 |
| 路由表「多 task 实现」列只有 Codex / Cursor | Claude Code 会话落入 **generic**（顺序执行 + 人工确认），无法享受 WU 并行、尾盘、DISPATCH-TRACK |
| 角色 prompt 与 dispatcher 步骤与 Cursor 投影耦合 | 新平台接入需复制大段 MD，**违反**高内聚低耦合 |
| 无能力级 parity 清单 | 「尽量全量」（范围 D）无法审计哪些已等价、哪些降级 |

**诉求：** 以 **Core-first** 建立 Capability Kernel；各平台 **一个适配器目录** 只做运行时绑定；**并行 Agent、worktree、尾盘、阶段门禁** 等语义在 Core 定义一次，Cursor / Claude Code / Codex 分别映射。

## 2. 决策摘要（已确认）

| 项 | 选择 |
| --- | --- |
| 范围 | **D**：Cursor Harness 能力尽量全量语义等价；平台不具备时 **显式降级**（`degraded` / `manual`），禁止静默省略 |
| 真相源 | **A — Core-first**：能力契约与编排语义在 `core/`；适配器仅映射 |
| 架构 | **方案 1 + 轻量 capability-matrix**：编排上提 Core；`adapters/*/capability-matrix.yaml` 做 parity 审计 |
| 参考实现 | Cursor 保持首个完整 binding；**Claude Code 为第二实现**；Codex 对齐既有 `omx ultrawork` |

## 3. 目标与非目标

### 3.1 目标

1. **单一编排语义**：Leader、WU、GROUP、依赖、派发、整合、尾盘（集体测试 → 集体审查）在 `core/orchestration/` 定义，与 IDE 无关。
2. **能力可枚举**：每项能力有稳定 ID（如 `orchestration.parallel-wu`），契约说明输入/输出/门禁/产物。
3. **适配器可替换**：新增平台 = 新增 `adapters/<platform>/` + matrix 行，**不** fork routing 或 dispatcher 正文。
4. **Claude Code 可跑通主路径**：已批准 plan → WORKTREE-INIT（若委派写代码）→ 并行 WU → DISPATCH-TRACK → 尾盘两产物 → execution-log 关闭。
5. **产物不变**：`.ai-runtime-artifacts/` 路径与 front matter 规则保持；`platform: cursor | claude | codex | generic` 区分运行时。

### 3.2 非目标（首版）

- 独立 npm 包、HTTP 编排服务、可视化控制台
- 替换各平台原生 UI / 模型路由
- Gemini、Copilot CLI 适配器实现（matrix 可预留行）
- 全自动 parity 测试矩阵（首版：`harness-check` 静态检查 + 人工维护 matrix）
- 在 worktree 内强制子 Agent commit（仍由 `git-xywh` + Leader 负责）

## 4. 架构总览

```text
┌──────────────────────────────────────────────────────────────────┐
│  Layer 0 — Project Overlay（已有）                                 │
│  project.*.md · context-map · .ai-runtime-artifacts/              │
└───────────────────────────────┬──────────────────────────────────┘
                                │
┌───────────────────────────────▼──────────────────────────────────┐
│  Layer 1 — Capability Kernel（本 spec 新增/强化）                   │
│  core/capabilities/registry.md    能力 ID、契约、产物、门禁          │
│  core/capabilities/primitives.md  抽象运行时原语                     │
│  core/orchestration/              Leader、角色、dispatcher、tracking │
│  core/routing.md                  路由表 → capability ID（非工具名）  │
└───────────────────────────────┬──────────────────────────────────┘
                                │ implements
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
 adapters/cursor/        adapters/claude/         adapters/codex/
 bindings.md             bindings.md              bindings.md
 capability-matrix.yaml  capability-matrix.yaml   capability-matrix.yaml
 投影 .cursor/*           CLAUDE 专章 + skills      omx / AGENTS.omx
```

**依赖方向（强制）：**

- `core/*` **不得** import 平台路径（无 `adapters/cursor` 字样除「见适配器」指针表）。
- `adapters/*` **必须** 引用 `core/capabilities/*` 与 `core/orchestration/*`。
- `entrypoints/` 只保留平台检测与「加载哪个 adapter 专章」。

## 5. Core 能力模型

### 5.1 能力 ID 命名

`<domain>.<name>`，全小写，连字符分词。示例：

| 能力 ID | 说明 |
| --- | --- |
| `routing.stage-gate` | spec/plan/decision 写入后暂停 |
| `routing.harness-declare` | 首句 `「Harness：…」` + `Skills:` |
| `orchestration.leader` | Leader 职责与禁止项 |
| `orchestration.parallel-wu` | GROUP 内无依赖 WU 并行 |
| `orchestration.dispatch-track` | DISPATCH-TRACK append-only |
| `orchestration.worktree-sandbox` | 委派写代码前隔离工区 |
| `orchestration.collective-closeout` | 集体测试 + 集体审查尾盘 |
| `roles.coder` | 代码 WU：实现+单测+轻量审查+自检 |
| `roles.implementer` | docs/chore/config |
| `roles.reviewer` | 独立审查实例 |
| `roles.test-engineer` | test/e2e WU |
| `roles.explorer` | 只读探查 |
| `roles.debugger` | 缺陷调查 |
| `roles.web-investigator` | 调研 / 网页取证 |
| `artifacts.runtime-layout` | `.ai-runtime-artifacts/` 树与 FM |
| `skills.stage-load` | 阶段 skill 必须先 Load |
| `interaction.structured-ask` | 澄清优先结构化提问 |
| `hooks.session-lifecycle` | 可选：会话 init / 尾盘提醒 |
| `git.worktree-script` | `scripts/harness-worktree.sh` |

完整列表以 `core/capabilities/registry.md` 为单一真相源（实现阶段从现有 Cursor 编排反推登记，首版 ≥ 上述表）。

### 5.2 抽象原语（Primitives）

平台适配器将下列原语映射到本地 API；**禁止**在适配器内重定义语义。

| 原语 | 契约摘要 | 典型产物/副作用 |
| --- | --- | --- |
| `DetectPlatform()` | 返回 `cursor \| claude \| codex \| generic` | execution-log FM `platform` |
| `LoadCapability(id)` | 按 routing 判定加载 core 文档 / stage skill | 回复次行 `Skills:` |
| `StageGate(phase)` | 写入 specs/plans/decisions 后暂停 | 模板 `## Next` |
| `SpawnWorker(role, wu, context)` | 隔离上下文；不得继承 Leader 全历史 | WU 返回 `wu_status` + `### Skills 使用` |
| `ParallelBatch(workers[])` | 仅当 WU 文件集不相交；上限可配置 | DISPATCH-TRACK `Sub-agents: N` |
| `WorktreeInit(batch)` | 委派写代码类 WU 前执行 | tracking `WORKTREE-INIT` |
| `Integrate(results[])` | Leader 合并；禁止子 Agent 自声称批次完成 | plan 勾选、execution-log |
| `CollectiveTest()` | 按 `project.verification.md` | `*-collective-test.md` |
| `CollectiveReview()` | 审查实例 ≠ 任一实现实例 | `*-code-review.md` |
| `StructuredAsk(question)` | 一次一问；优先选择题 | 无文件 |
| `EmitHook(event)` | 可选；失败不阻断主路径 | 本地 hook 日志 |

### 5.3 能力契约模板（registry 每条）

```markdown
### orchestration.parallel-wu

- **Requires:** 已批准 plan；`*-dispatch.md` 或等效执行图
- **Produces:** DISPATCH-TRACK 条目；子 Agent 返回
- **Forbidden:** 并行 WU 修改同一文件；实现与审查同一实例
- **Parameters:** `max_parallel`（默认 3，硬顶 5）
- **Degraded:** 平台无并行 → 顺序 SpawnWorker，matrix 标 `degraded`，track 记 `Detail: parallel degraded, sequential`
```

## 6. 编排与并行 Agent 模型

### 6.1 逻辑层（Core，平台无关）

沿用并上提现有 `dispatcher-workflow.md` 语义：

```text
用户「开始实现」
    → Leader 判定 routing（已过 plan 门禁）
    → [可选] WORKTREE-INIT（将委派写代码 harness-*）
    → 从 plan 生成执行图（GROUP / WU）
    → 对每个 GROUP：
          并行派发无依赖 WU → 等待返回 → Integrate
          有依赖则下一 GROUP
    → 全部 WU 完成 → CollectiveTest → CollectiveReview → 更新 execution-log
```

**WU 最小字段（Core schema）：**

| 字段 | 必填 | 说明 |
| --- | --- | --- |
| `wu_id` | 是 | 如 `WU-01` |
| `wu_type` | 是 | feature/bugfix/…/e2e |
| `agent_role` | 是 | coder/implementer/… |
| `files` | 是 | 允许修改路径列表 |
| `done_criteria` | 是 | 可验证 |
| `depends_on` | 否 | 同 plan 内 WU id |
| `wu_skills` | 否 | `auto` 或显式 slug 列表 |
| `wu_title_zh` | 推荐 | 追踪与 worktree 展示 |

**角色 → 能力映射：** 见 `core/orchestration/roles.md`（由 `orchestration/agents/*.md` 合并迁移）。

### 6.2 物理层（Adapter 绑定）

| 逻辑原语 | Cursor | Claude Code | Codex |
| --- | --- | --- | --- |
| `SpawnWorker(coder)` | `Use harness-coder subagent` | `Task` + `core/orchestration/agents/coder.md` 正文作 prompt | omx worker / 等价 |
| `SpawnWorker(reviewer)` | `harness-reviewer`（readonly） | 新 Task 实例 + readonly 约束 | omx reviewer 路由 |
| `ParallelBatch` | 并行 Task，≤5 | 并行 `Task`（`dispatching-parallel-agents` 对齐） | `omx ultrawork` |
| `WorktreeInit` | `scripts/harness-worktree.sh` | **同一脚本** | 同左或 routing 跳过 |
| `StructuredAsk` | `AskQuestion` | 对话式选择题（degraded） | 对话 |
| `EmitHook` | `.cursor/hooks.json` | manual / 无 | manual |

**并行策略（Core 统一）：**

1. **文件不相交**方可同 GROUP 并行；否则拆 GROUP 或顺序。
2. **审查实例隔离**：执行批次内任一代码 WU 的 worker 实例不得担任 `CollectiveReview` 审查者。
3. **Leader 不写业务代码**（routing 小改动除外）；整合与落盘由 Leader 完成。
4. **完成定义**：末 WU 返回 ≠ 批次完成；必须 `CollectiveTest` + `CollectiveReview` 产物（见 batch-closeout spec）。

### 6.3 与 Superpowers skills 的关系

| 阶段 | Core route | 平台无关 skill | Adapter 叠加 |
| --- | --- | --- | --- |
| 设计 | `brainstorming` | superpowers | StructuredAsk 绑定 |
| 计划 | `writing-plans` | superpowers | — |
| 多 task 实现 | `orchestration.dispatch` | — | `cursor-orchestration` / **`claude-orchestration`** / omx |
| 验证 | `verification-before-completion` | superpowers | — |
| 审查 | `requesting-code-review` | superpowers | SpawnWorker(reviewer) |

实现阶段新增：`adapters/claude/.agents/skills/claude-orchestration/SKILL.md`（或投影到项目 `.agents/skills/`），正文仅含 **激活条件 + 读 core dispatcher + Claude 绑定表**。

## 7. 目录结构（目标态）

```text
harness-kit/
├── core/
│   ├── capabilities/
│   │   ├── registry.md          # 能力 ID 全表 + 契约
│   │   └── primitives.md        # 原语定义与禁止项
│   ├── orchestration/
│   │   ├── dispatcher-workflow.md   # 从 cursor 迁出；平台无关步骤
│   │   ├── roles.md                 # 角色索引
│   │   ├── agents/
│   │   │   ├── leader.md
│   │   │   ├── coder.md
│   │   │   └── …                    # 原 orchestration/agents/*
│   │   ├── tracking/
│   │   │   └── schema.md
│   │   ├── skill-preferences.md     # 原 skill-preferences.zh.md（中立）
│   │   └── config.defaults.yaml     # max_parallel 等
│   └── routing.md                   # Route 列改为 capability / core path
├── adapters/
│   ├── cursor/
│   │   ├── bindings.md              # Cursor 原语映射（薄）
│   │   ├── capability-matrix.yaml
│   │   └── .cursor/                 # 投影层保留；agents 薄壳指向 core
│   ├── claude/                      # 新增
│   │   ├── README.md
│   │   ├── bindings.md
│   │   ├── capability-matrix.yaml
│   │   └── .agents/skills/claude-orchestration/SKILL.md
│   └── codex/
│       ├── bindings.md
│       └── capability-matrix.yaml
└── entrypoints/
    ├── HARNESS-PLATFORM-ENTRY.md    # 增加 claude 专章指针
    └── AGENTS.md                    # 路由表四列 → capability ID
```

**迁移原则：** 搬迁后 `adapters/cursor/orchestration/` 改为 **stub 重定向**（保留路径 1 个 release 周期），避免已接入项目链接失效。

## 8. capability-matrix.yaml（轻量审计）

每个适配器一份，结构固定：

```yaml
# adapters/claude/capability-matrix.yaml
platform: claude
matrix_version: 1
capabilities:
  orchestration.parallel-wu:
    status: supported          # supported | degraded | manual | unsupported
    binding: "Parallel Task() per WU; max 3"
    notes: ""
  interaction.structured-ask:
    status: degraded
    binding: "对话式单选；无 AskQuestion"
    degraded_reason: "Claude Code 无 AskQuestion 工具"
  hooks.session-lifecycle:
    status: manual
    binding: "依赖用户本地 hook；文档见 adapters/claude/README.md"
```

`scripts/harness-check.sh` 扩展（实现阶段）：

- 检查 matrix 中每个 `registry.md` 列出的能力均有条目
- `unsupported` 能力不得出现在该平台 routing 默认路径
- `degraded` 须在 `bindings.md` 有降级操作说明

## 9. 路由表演进

`core/routing.md` 路由表增加 **Capability** 列（工具名列保留为「当前默认 binding」）：

| 任务类型 | Capability | Cursor binding | Claude binding | Codex binding |
| --- | --- | --- | --- | --- |
| 多 task 编码 | `orchestration.dispatch` | `cursor-orchestration` | `claude-orchestration` | `omx ultrawork` |
| … | … | … | … | … |

**平台检测（统一）：**

| 信号 | platform |
| --- | --- |
| Cursor 工作区 + `.cursor/agents/harness-*` | cursor |
| `CLAUDE.md` 会话 + Skill 工具 + 无 Cursor | claude |
| Codex CLI + `omx` | codex |
| 否则 | generic（顺序 + manual 标注） |

## 10. Claude Code 适配器（首版交付重点）

### 10.1 入口

- `entrypoints/CLAUDE.md`：增加「多 task 实现 → Load `claude-orchestration`」
- `entrypoints/HARNESS-PLATFORM-ENTRY.md`：与 Cursor overlay 对称的 **Claude 专章**（指针 `adapters/claude/bindings.md`）
- bootstrap 投影：`adapters/claude/.agents/skills/` → 项目 `.agents/skills/`

### 10.2 派发 prompt 契约（与 Cursor 对齐）

委派时必须包含（来自 core，不得删减）：

- WU id、wu_type、agent_role、允许文件、禁止项、done criteria
- `worktree_path`（若启用）
- **本 WU Skills**（`auto` 或列表）
- 要求返回：`wu_status`、`### Skills 使用`、`code_review` / `self_check`（coder）

### 10.3 并行示例（物理层）

```text
# 逻辑：GROUP-1 内 WU-01、WU-02 并行
Task("WU-01: …", subagent_type=generalPurpose, …)  # 绑定 coder 正文
Task("WU-02: …", …)                                 # 并行发起
# Leader 轮询完成 → Integrate → DISPATCH-TRACK 追加
```

与 `superpowers:dispatching-parallel-agents` 对齐：**不**向 worker 传递 Leader 完整会话史。

### 10.4 预期 degraded 项（首版）

| 能力 | Claude 首版状态 | 说明 |
| --- | --- | --- |
| `interaction.structured-ask` | degraded | 无 AskQuestion |
| `hooks.session-lifecycle` | manual | 无 `.cursor/hooks.json` 等价 |
| `orchestration.continuous-loop` | manual | 多会话 HANDOFF 人工衔接 |
| Task 类型 `ci-investigator` | degraded | 用 generalPurpose + 只读约束替代 |

## 11. 错误处理与降级协议

1. **绑定失败**（如无 Task 工具）：Leader 标 `platform: generic`，顺序执行并在 execution-log 记 `Error: spawn unavailable`。
2. **并行中单 WU blocked**：DISPATCH-TRACK `Status: blocked`；Leader 决策跳过 / 重派 / 丢弃 worktree（见 worktree spec）。
3. **降级可见性**：凡 matrix 为 `degraded`，派发前在 DISPATCH-TRACK 写 `Detail: capability <id> degraded`。
4. **禁止静默**：不得在未写 collective-test / code-review 产物时更新 execution-log 为「批次完成」。

## 12. 迁移计划（分阶段）

| 阶段 | 内容 | 风险 |
| --- | --- | --- |
| **P0** | 新增 `core/capabilities/*` + `registry` 从现状反推登记 | 低 |
| **P1** | 搬迁 `dispatcher-workflow`、`agents/*`、`tracking/schema` → `core/orchestration/`；cursor 留 stub | 中：链接更新 |
| **P2** | `adapters/cursor/bindings.md` + matrix；瘦身 `.cursor/agents` 为薄壳 | 中：投影需重跑 |
| **P3** | 新增 `adapters/claude/` + `claude-orchestration` skill；更新 routing / README | 目标交付 |
| **P4** | `adapters/codex/bindings.md` + matrix 与 omx 对齐审计 | 低 |
| **P5** | `harness-check` matrix 校验；废弃 cursor/orchestration stub | 低 |

**不阻塞 P3：** P1/P2 可并行；Claude 绑定可读 core 新路径，即使 cursor stub 仍在。

## 13. 验证与测试计划

| 类型 | 方法 |
| --- | --- |
| 静态 | `harness-check.sh`：matrix 覆盖、stub 重定向存在、routing 含 claude 列 |
| 契约 | 人工走查：同一 plan 在 Cursor vs Claude 产出 FM 字段一致 |
| 并行 | 2 WU 改不同文件：DISPATCH-TRACK 显示并行 started；文件无交叉冲突 |
| 隔离 | worktree 路径仅子 worker 写入；主 checkout 无业务 diff |
| 尾盘 | 无 collective-test 不得进入 review；无 code-review 不得关闭 log |
| 降级 | 将 matrix 中一项标 degraded，检查 track 有 `degraded` 记录 |

## 14. 开放问题（实现前需确认）

1. Claude Code 子 Agent 是否稳定支持 **readonly** 审查角色（与 Cursor `harness-reviewer` 同效）？
2. Claude 并行 `Task` 上限是否沿用 `max_parallel: 3`？
3. bootstrap 是否默认投影 `adapters/claude/`，还是 opt-in（`project.profile.md` 开关）？

## 15. 附录：现状 → Core 迁移映射

| 现路径 | 目标路径 |
| --- | --- |
| `adapters/cursor/orchestration/dispatcher-workflow.md` | `core/orchestration/dispatcher-workflow.md` |
| `adapters/cursor/orchestration/agents/*.md` | `core/orchestration/agents/*.md` |
| `adapters/cursor/orchestration/tracking/schema.md` | `core/orchestration/tracking/schema.md` |
| `adapters/cursor/orchestration/skill-preferences.zh.md` | `core/orchestration/skill-preferences.md` |
| `adapters/cursor/orchestration/platform-adapters.zh.md` | 拆为 `adapters/cursor/bindings.md` + `core/capabilities/registry.md` |
| `adapters/agents/.../cursor-orchestration/SKILL.md` | 薄壳 → 指向 `core/orchestration/dispatcher-workflow.md` |

---

## Next

- 请 review 本 spec；确认或修改后回复「批准 spec」或给出修改意见。
- 批准后进入 **`writing-plans`** 生成实施计划（建议按 §12 P0→P5 拆 WU）。
- 实现前勿改 `core/` 大规模搬迁，除非用户明确「直接做」。
