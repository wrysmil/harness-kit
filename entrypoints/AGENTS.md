<!-- 自主性指令 — 请勿删除 -->
你是一个自主编码代理。在**实现阶段**（用户已批准 spec/plan 并说「开始实现」或等价指令后）无需逐步征求许可，将任务执行至完成。
**Harness 阶段门禁优先：** 写入 spec / plan / decision 到 `.ai-runtime-artifacts/` 后须暂停，等用户审查并明确继续；此规则高于本段的 auto-continue。详见 `harness-kit/core/routing.md` § 阶段门禁 与 `.cursor/rules/cursor-subagent-routing.mdc`。
若受阻，尝试替代方案。仅在真正歧义或具有破坏性时才提问。
并行子任务：Codex 用原生子代理；Cursor 用 `.cursor/agents/harness-*` subagent（见 `harness-kit/adapters/cursor/`）。
<!-- 自主性指令结束 -->
<!-- omx:generated:agents-md -->

<!-- 项目 Harness 覆盖层 — 请勿删除 -->
在开展任务专项工作之前，按 **Route-first** 加载 `harness-kit/`（勿预读全集）。

## 加载规则

1. **始终**：`harness-kit/core/routing.md`（路由判定、阶段门禁、§ 按判定加载）
2. **按 routing 判定追加**（见 `routing.md` § 按判定加载；**先 stage skill，再 artifacts 契约**）：
   - 设计 / spec → Load **`brainstorming`** → `artifacts.md`（勿用 `artifact-templates/spec.md` 作正文）
   - 计划 → Load **`writing-plans`** → `artifacts.md` + `plan.harness-overlay.md`；并行时 `dispatch.harness-overlay.md`
   - 验证 → Load **`verification-before-completion`** → `project.verification.md`、`core/verification.md`
   - 编排产物（execution-log、track 等）→ `artifact-templates/` 对应文件
   - 改代码前 → `project.profile.md`、`context-map.md`（涉及模块时）
   - Git → **`git-xywh` skill** + `project.git.md`
   - runbook 任务 → `core/runbooks.md` 对应节
3. **架构总览（可选）**：`core/harness.md`

`harness-kit/` 层负责项目边界、产物契约、验证门禁与迁移可移植性。  
默认 harness 路由是强制基线。若用户指定技能或工具，将其视为对 `harness-kit/core/routing.md` 的附加项，除非用户明确要求跳过、禁用或仅使用其他路由。

当本 AGENTS.md 被 omx 重新生成时，**保留本覆盖层**；OMX 正文以 `harness-kit/entrypoints/AGENTS.omx.md` 为准重新合并或引用。
<!-- 项目 Harness 覆盖层结束 -->

# Agent Harness 顶层契约

本文件是**工具中立**的 Harness 入口。平台专章分列，避免 Cursor 误读 OMX/tmux 指令。

## 平台专章

| 平台 | 加载 |
| --- | --- |
| **Cursor** | `harness-kit/entrypoints/AGENTS.cursor-overlay.md`、`.cursor/rules/`、`.cursor/agents/`、`cursor-orchestration` skill |
| **Codex / OMX** | `harness-kit/entrypoints/AGENTS.omx.md`（或 omx setup 合并后的 OMX 段落） |
| **Claude Code** | `CLAUDE.md` |
| **Gemini** | `GEMINI.md` |

## 强制声明

每个任务第一句：`「Harness：<route 或 "小改动，直接处理">」`；route 列有 skill 时次行 `Skills:`（见 `routing.md` § 阶段指定 skill 必用）。  
路由表见 `harness-kit/core/routing.md`（含 Codex / Cursor 并列列）。

## 路由摘要

| 任务 | Codex | Cursor |
| --- | --- | --- |
| 设计 | `superpowers:brainstorming` | 同左 |
| 计划 | `superpowers:writing-plans` | 同左 |
| 多 task 实现 | `omx ultrawork` | `cursor-orchestration:dispatcher-workflow` |
| 验证 | `superpowers:verification-before-completion` | 同左 |
| 信息调研 / 网页搜索 | `harness-web-investigator` | `harness-web-investigator` |
| Git（提交 / 分支 / MR） | `git-xywh` + `project.git.md` | 同左 |

涉及提交、分支、MR 时由 **Leader** invoke `git-xywh`；子 Agent 默认不 commit。组织规范在 skill，项目差异在 `project.git.md`。

## 可选：Cursor Hooks

启用 Harness 路由提示 hook：见 `harness-kit/adapters/cursor/orchestration/hooks/README.md`。

## 可选：Continuous Loop

长期自治循环（opt-in）：见 `harness-kit/adapters/cursor/orchestration/continuous-loop.md`。

## OMX 正文

Codex / omx 会话的完整编排契约见 **`harness-kit/entrypoints/AGENTS.omx.md`**。  
`omx setup` 可能将 OMX 内容写回根 `AGENTS.md`；合并后须保留上文 Harness 覆盖层与平台专章表。
