<!-- Cursor Harness 覆盖层 — 投影到 AGENTS.md 或单独加载 -->
<!-- 与 OMX 专章并存；Cursor 会话以本文件为准，忽略 AGENTS.md 中的 omx/tmux/spawn 段落 -->

# Cursor 执行契约（Harness Kit）

本文件是 **Cursor Agent** 的补充契约。路由、阶段门禁与按判定加载以 `harness-kit/core/routing.md` 为准；委派以 `.cursor/rules/cursor-subagent-routing.mdc` 为准。

## 加载规则（Route-first）

1. **始终**：`harness-kit/core/routing.md`（含 § 按判定加载）
2. **按 routing 判定追加**（见 routing 表；勿在会话开始预读 dispatcher / skill-preferences）：
   - Cursor 委派细则 → `.cursor/rules/cursor-subagent-routing.mdc`
   - 改代码前 → `project.profile.md`、`context-map.md`
   - 写产物 → `core/artifacts.md`
   - Git → `project.git.md` + **`git-xywh` skill**
   - 多 task 已实现 → `cursor-orchestration` skill → `orchestration/dispatcher-workflow.md`
   - 派发 WU（`wu_skills: auto`）→ `orchestration/skill-preferences.zh.md`

## 平台判定

- **Cursor**：`.cursor/agents/harness-*` + `cursor-orchestration` skill；**不**调用 omx
- **Codex CLI**：`harness-kit/entrypoints/AGENTS.omx.md` + `omx ultrawork`

## 子 Agent

项目 subagent 位于 `.cursor/agents/`（bootstrap 从 `harness-kit/adapters/cursor/.cursor/agents/` 投影）：

- `harness-coder` — 代码类 WU（plan 批准后）
- `harness-implementer` — 轻量 WU（docs/chore/config）
- `harness-reviewer` — 独立审查（readonly）
- `harness-explorer` — 只读探查
- `harness-debugger` — 缺陷调查
- `harness-test-engineer` — 测试 / E2E（`wu_type: test | e2e`）
- `harness-web-investigator` — 信息调研（`wu_type: research`）

薄壳 → 正文：`orchestration/agents/*.md`。路由表见 `core/routing.md`（不在此重复）。

调研产物：`.ai-runtime-artifacts/research/`（见 `core/artifacts.md`）。

## Git

- 组织规范：**`git-xywh` skill**（须 invoke）
- 项目差异：`project.git.md`
- **Leader** 执行 commit / push / MR

## 强制声明

首句 `「Harness：<route>」`；本阶段有 route skill 时次行 `Skills:`（细则 `core/routing.md` § 阶段指定 skill 必用）。

## 沟通语言

对用户回复与子 Agent 协调（派发、整合、追踪）使用**中文**（见 `core/routing.md` § 沟通语言）。

## 产物

统一写入 `.ai-runtime-artifacts/`（见 `core/artifacts.md`）。

Cursor 规则 `ai-entry.mdc` 会在会话中加载；本文件供深读与人工审计。
