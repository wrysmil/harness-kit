<!-- 自主性指令 — 请勿删除 -->
你是一个自主编码代理。**自主性仅适用于实现阶段**，且须满足全部条件：
1. 用户在本会话**已单独说过**「开始实现 / 直接做 / 并行执行」（或等价），**或** spec/plan FM 已 `approved: true` 且引用该授权原话；
2. **不**含同句组合指令里的「然后执行」（见 `routing.md` § 组合指令）；
3. 当前任务 **非**「写方案 / 写计划」阶段。
满足后无需逐步征求许可，执行至完成（Tier 2+ 仍须尾盘产物）。
**Harness 阶段门禁优先：** 写入 spec / plan / decision 后须暂停；「写方案」「写计划」不属于实现阶段，未获用户继续指令前不得 auto-continue 改代码。详见 `routing.md` § 阶段门禁。Cursor 平台额外见 `.cursor/rules/ai-entry.mdc` § 文件写入与阶段门禁。
**Harness 尾盘优先（Cursor）：** 「完成」指本 GROUP / 批次已通过**集体测试**与**集体审查**并落盘（`collective-test` + `code-review`），而非末个 WU 返回即可停。见 `harness-kit/docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md`。
**Tier 1 Leader 直做：** 须 Write `verifications/*-verification-lite.md`，不得零落盘。见 `routing.md` § 任务 Tier。
若受阻，尝试替代方案。仅在真正歧义或具有破坏性时才提问。
并行子任务：Cursor 用 `.agents/agents/<role>.md` 共享 subagent（见 `harness-kit/.agents/`）；Claude / Trae 同理。
<!-- 自主性指令结束 -->

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


<!-- 项目 Harness 覆盖层结束 -->

# Agent Harness 顶层契约

本文件是**工具中立**的 Harness 入口。平台专章分列，避免 Cursor 误读其他平台指令。

## 平台专章

| 平台 | 加载 |
| --- | --- |
| **Cursor** | `harness-kit/entrypoints/AGENTS.cursor-overlay.md`、`.cursor/rules/`、`.agents/agents/`、`orchestration` skill |
| **Claude Code** | `CLAUDE.md`、`orchestration` skill、`adapters/claude/bindings.md` |

## 强制声明

每个任务第一句：`「Harness：<route 或 Tier 0/1>」`；stage skill / Tier 1+ 次行 `Skills:`（见 `routing.md` § 阶段指定 skill 必用）。  
路由表见 `harness-kit/core/routing.md`（含 Capability / Cursor / Claude 列）。

## 路由摘要

| 任务 | Cursor | Claude |
| --- | --- | --- |
| 设计 | `superpowers:brainstorming` | 同左 |
| 计划 | `superpowers:writing-plans` | 同左 |
| 多 task 实现 | `orchestration` | `orchestration` |
| 验证 / 集体测试 | `superpowers:verification-before-completion` | 同左 |
| 尾盘（批次收尾） | `verification-before-completion` → `requesting-code-review` | 同左 |
| 信息调研 | `web-investigator` | Task + web-investigator |
| Git（提交 / 分支 / MR） | `git-xywh` + `project.git.md` | 同左 |

涉及提交、分支、MR 时由 **Leader** invoke `git-xywh`；子 Agent 默认不 commit。组织规范在 skill，项目差异在 `project.git.md`。

## 可选：Cursor Hooks

启用 Harness 路由提示 hook：见 `harness-kit/adapters/cursor/.cursor/hooks/README.md`。

## 参考资料索引

以下参考资料统一存放在 `harness-kit/references/`（集中式）。**不是"按需参考"，而是对应阶段路由的强制门禁。** Leader 进入路由时必须 Read 关联 references 并逐项对照执行（见 `routing.md` § 参考资料强制加载）。

| 文件 | 用途 | 被引用的 skill |
|------|------|---------------|
| `harness-kit/references/definition-of-done.md` | 项目级完成定义（20+ 检查项） | `verification-before-completion`, `incremental-implementation`, `shipping-and-launch` |
| `harness-kit/references/testing-patterns.md` | 测试模式（AAA、Mock 层次、反模式） | `test-driven-development`, `debugging-and-error-recovery` |
| `harness-kit/references/security-checklist.md` | Web 安全 + OWASP/LLM Top 10 | `security-and-hardening`, `code-review-and-quality`, `shipping-and-launch` |
| `harness-kit/references/performance-checklist.md` | Web 性能（CWV、前后端清单） | `performance-optimization`, `code-review-and-quality`, `shipping-and-launch` |
| `harness-kit/references/orchestration-patterns.md` | 编排模式 + 反模式 + 决策流 | `orchestration`, `doubt-driven-development` |
| `harness-kit/references/observability-checklist.md` | 可观测性（RED/USE、日志/指标/告警） | `observability-and-instrumentation` |
| `harness-kit/references/accessibility-checklist.md` | WCAG 2.1 AA 无障碍检查 | `frontend-ui-engineering`, `shipping-and-launch` |

**违反：** 未 Read references 即声称完成 → 无效；产物无 `### References 检查` → 退回。

## 可选：Continuous Loop

长期自治循环（opt-in）：见 `harness-kit/core/orchestration/continuous-loop.md`。
