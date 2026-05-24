<!-- Cursor Harness 覆盖层 — 投影到 AGENTS.md 或单独加载 -->
<!-- 与 OMX 专章并存；Cursor 会话以本文件为准，忽略 AGENTS.md 中的 omx/tmux/spawn 段落 -->

# Cursor 执行契约（Harness Kit）

本文件是 **Cursor Agent** 的补充契约。完整 Harness 规范仍以 `harness-kit/core/` 为准。

## 阅读顺序（Cursor 会话）

1. `harness-kit/core/harness.md`
2. `harness-kit/project.profile.md`
3. `harness-kit/context-map.md`
4. `harness-kit/core/routing.md`（含 Cursor 等价路由列）
5. `harness-kit/core/artifacts.md`
6. `harness-kit/adapters/cursor/orchestration/platform-adapters.zh.md`
7. `.cursor/rules/cursor-subagent-routing.mdc`（投影后路径）

## 平台判定

- **Cursor**：使用 Task 工具 + `cursor-orchestration` skill；**不**调用 omx
- **Codex CLI**：使用 `AGENTS.md` 中 OMX 专章 + `omx ultrawork`

## Cursor 路由摘要

| 任务 | Route |
| --- | --- |
| 需求 / 设计 | `superpowers:brainstorming` |
| 计划 | `superpowers:writing-plans` |
| 多 task 实现 | `cursor-orchestration:dispatcher-workflow` |
| 验证 | `superpowers:verification-before-completion` |
| 小改动 | 直接处理 |

## 强制声明

每个任务第一句：`「Harness：<route>」`

## 子 Agent

- 机制：**Task 工具**（`explore` / `generalPurpose` / `shell` / `ci-investigator`）
- 并行上限：5（默认 3）
- Leader 整合 + 验证；Worker 只做分配切片

## 产物

统一写入 `.ai-runtime-artifacts/`（见 `harness-kit/core/artifacts.md`）。

## 与根 AGENTS.md 的关系

根 `AGENTS.md` 若含 oh-my-codex / OMX 全文：**Cursor 会话忽略**其中 CLI、tmux、spawn_agent 相关段落。  
Harness 覆盖层（`<!-- 项目 Harness 覆盖层 -->`）对 Cursor 与 Codex **均有效**。

## 投影说明

初始化时可选：

- 合并本文件段落进 `AGENTS.md` 末尾，或
- 保持独立：`harness-kit/entrypoints/AGENTS.cursor-overlay.md`（本模板源）

Cursor 规则 `ai-entry.mdc` 会在会话中加载 routing 规则；本文件供深读与人工审计。
