<!-- Cursor Harness 覆盖层 — 投影到 AGENTS.md 或单独加载 -->

# Cursor 执行契约（Harness Kit）

本文件是 **Cursor Agent** 的补充契约。路由、阶段门禁以 `harness-kit/core/routing.md` 为准；文件写入与门禁见 `.cursor/rules/ai-entry.mdc` § 文件写入与阶段门禁；委派见 `cursor-subagent-routing.mdc`。

## 加载规则（Route-first）

1. **始终**：`harness-kit/core/routing.md`（含 § 按判定加载）
2. **按 routing 判定追加**（见 `routing.md` § 按判定加载；勿在会话开始预读 dispatcher / skill-preferences）：
   - 设计 / spec → **`brainstorming` skill** → `core/artifacts.md`
   - 计划 → **`writing-plans` skill** → `artifacts.md` + `artifact-templates/plan.harness-overlay.md`；并行时 `dispatch.harness-overlay.md`
   - 验证 / 跑命令 → **`verification-before-completion`** → `project.verification.md`
   - **尾盘 / GROUP 收尾** → 先 **`verification-before-completion`** → **`requesting-code-review`** → `core/orchestration/dispatcher-workflow.md` §3
   - Cursor 委派细则 → `.cursor/rules/cursor-subagent-routing.mdc`
   - 改代码前 → `project.profile.md`、`context-map.md`（设计阶段须在 brainstorming 澄清**之后**再读）
   - 编排产物 → `artifact-templates/`（execution-log、track、handoff 等，非 spec/plan 正文）
   - Git → **`git-xywh` skill** + `project.git.md`
   - 多 task 已实现 → `orchestration` → `core/orchestration/dispatcher-workflow.md`
   - 派发 WU（`wu_skills: auto`）→ `core/orchestration/skill-preferences.md`

## 平台判定

- **Cursor**：`.agents/agents/*.md` + `orchestration` skill

## 子 Agent

共享 subagent 位于 `.agents/agents/`（bootstrap 从 `harness-kit/.agents/agents/` 投影）：

- `coder` — 代码类 WU（plan 批准后）
- `implementer` — 轻量 WU（docs/chore/config）
- `reviewer` — 独立审查（readonly）
- `explorer` — 只读探查
- `debugger` — 缺陷调查
- `test-engineer` — 测试 / E2E（`wu_type: test | e2e`）
- `web-investigator` — 信息调研（`wu_type: research`）

薄壳 → 正文：`orchestration/agents/*.md`。路由表见 `core/routing.md`（不在此重复）。

调研产物：`.ai-runtime-artifacts/research/`（见 `core/artifacts.md`）。

## Git

- 组织规范：**`git-xywh` skill**（须 invoke）
- 项目差异：`project.git.md`
- **Leader** 执行 commit / push / MR

## 强制声明

首句 `「Harness：<route 或 Tier 0/1>」`；stage skill / Tier 1+ 次行 `Skills: slug@path loaded|skipped`（细则 `core/routing.md` § 阶段指定 skill 必用）。

## 沟通语言

对用户回复与子 Agent 协调（派发、整合、追踪）使用**中文**（见 `core/routing.md` § 沟通语言）。

## 产物落盘（强制）

**所有 AI 过程产物必须写入 `.ai-runtime-artifacts/` 对应子目录，禁止写入其他位置。**

**禁止：**
- 把产物写到 `docs/`、`项目根目录`、或其他任意位置
- 把 plan 写到平台私有目录（如 `~/.cursor/plans/`）
- 用 `docs/superpowers/` 代替 `.ai-runtime-artifacts/`
- 使用 Cursor 原生 Plan 模式（会绕过 `.ai-runtime-artifacts/plans/` 落盘）

**例外：** harness-kit 仓库自身（`.gitignore` 排除 `.ai-runtime-artifacts/`）的 closeout 示例可放 `docs/runtime/closeouts/`。

详见 `core/artifacts.md`。

**交付完成（Cursor）：** 本 GROUP / 批次 WU 全部返回后，须完成尾盘集体测试 + 集体审查并落盘（见 `docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md`）。**完成** ≠ 末个 WU 返回；高于 AGENTS.md「执行至完成」的狭义理解。

Cursor 规则 `ai-entry.mdc` 会在会话中加载；本文件供深读与人工审计。
