<!-- 自主性指令 — 请勿删除 -->
你是一个自主编码代理。无需征求许可，将任务执行至完成。
不要停下来问「是否继续？」—— 直接继续。不要等待对明显下一步的确认。
若受阻，尝试替代方案。仅在真正歧义或具有破坏性时才提问。
并行子任务：Codex 用原生子代理；Cursor 用 Task 工具（见 `harness-kit/adapters/cursor/`）。
<!-- 自主性指令结束 -->
<!-- omx:generated:agents-md -->

<!-- 项目 Harness 覆盖层 — 请勿删除 -->
在开展任务专项工作之前，加载 `harness-kit/` 中的项目 harness。

项目 harness 阅读顺序：
1. `harness-kit/core/harness.md`
2. `harness-kit/project.profile.md`
3. `harness-kit/context-map.md`
4. `harness-kit/core/routing.md`
5. `harness-kit/core/artifacts.md`
6. `harness-kit/project.verification.md`
7. `harness-kit/core/verification.md`
8. 当任务匹配 runbook 时，阅读 `harness-kit/core/runbooks.md`

`harness-kit/` 层负责项目边界、产物契约、验证门禁与迁移可移植性。  
默认 harness 路由是强制基线。若用户指定技能或工具，将其视为对 `harness-kit/core/routing.md` 的附加项，除非用户明确要求跳过、禁用或仅使用其他路由。

当本 AGENTS.md 被 omx 重新生成时，**保留本覆盖层**；OMX 正文以 `harness-kit/entrypoints/AGENTS.omx.md` 为准重新合并或引用。
<!-- 项目 Harness 覆盖层结束 -->

# Agent Harness 顶层契约

本文件是**工具中立**的 Harness 入口。平台专章分列，避免 Cursor 误读 OMX/tmux 指令。

## 平台专章

| 平台 | 加载 |
| --- | --- |
| **Cursor** | `harness-kit/entrypoints/AGENTS.cursor-overlay.md`、`.cursor/rules/`、`cursor-orchestration` skill |
| **Codex / OMX** | `harness-kit/entrypoints/AGENTS.omx.md`（或 omx setup 合并后的 OMX 段落） |
| **Claude Code** | `CLAUDE.md` |
| **Gemini** | `GEMINI.md` |

## 强制声明

每个任务第一句：`「Harness：<route 或 "小改动，直接处理">」`  
路由表见 `harness-kit/core/routing.md`（含 Codex / Cursor 并列列）。

## 路由摘要

| 任务 | Codex | Cursor |
| --- | --- | --- |
| 设计 | `superpowers:brainstorming` | 同左 |
| 计划 | `superpowers:writing-plans` | 同左 |
| 多 task 实现 | `omx ultrawork` | `cursor-orchestration:dispatcher-workflow` |
| 验证 | `superpowers:verification-before-completion` | 同左 |

## 可选：Cursor Hooks

启用 Harness 路由提示 hook：见 `harness-kit/adapters/cursor/orchestration/hooks/README.md`。

## 可选：Continuous Loop

长期自治循环（opt-in）：见 `harness-kit/adapters/cursor/orchestration/continuous-loop.md`。

## OMX 正文

Codex / omx 会话的完整编排契约见 **`harness-kit/entrypoints/AGENTS.omx.md`**。  
`omx setup` 可能将 OMX 内容写回根 `AGENTS.md`；合并后须保留上文 Harness 覆盖层与平台专章表。
