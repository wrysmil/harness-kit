<!-- Cursor Harness 覆盖层 — 投影到 AGENTS.md 或单独加载 -->
<!-- 与 OMX 专章并存；Cursor 会话以本文件为准，忽略 AGENTS.md 中的 omx/tmux/spawn 段落 -->

# Cursor 执行契约（Harness Kit）

本文件是 **Cursor Agent** 的补充契约。路由与阶段门禁以 `harness-kit/core/routing.md` 与 `.cursor/rules/cursor-subagent-routing.mdc` 为准。

## 阅读顺序（Cursor 会话）

1. `harness-kit/core/routing.md`（含阶段门禁）
2. `.cursor/rules/cursor-subagent-routing.mdc`
3. `harness-kit/project.profile.md`、`harness-kit/context-map.md`
4. `harness-kit/core/artifacts.md`
5. 任务相关：`harness-kit/adapters/cursor/orchestration/dispatcher-workflow.md`

## 平台判定

- **Cursor**：`.cursor/agents/harness-*` + `cursor-orchestration` skill；**不**调用 omx
- **Codex CLI**：`harness-kit/entrypoints/AGENTS.omx.md` + `omx ultrawork`

## 子 Agent

项目 subagent 位于 `.cursor/agents/`（bootstrap 从 `harness-kit/adapters/cursor/.cursor/agents/` 投影）：

- `harness-implementer` — 有界实现（plan 批准后）
- `harness-reviewer` — 独立审查（readonly）
- `harness-explorer` — 只读探查
- `harness-debugger` — 缺陷调查

路由表见 `harness-kit/core/routing.md`（不在此重复）。

## 强制声明

每个任务第一句：`「Harness：<route>」`

## 产物

统一写入 `.ai-runtime-artifacts/`（见 `harness-kit/core/artifacts.md`）。

Cursor 规则 `ai-entry.mdc` 会在会话中加载；本文件供深读与人工审计。
