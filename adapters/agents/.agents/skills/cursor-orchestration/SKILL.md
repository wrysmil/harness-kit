---
name: cursor-orchestration
description: Cursor 多 subagent 并行编排，等价 omx ultrawork。已批准 plan +「开始实现」后并行派发 WU。触发：并行实现、多 task、开始实现、cursor 编排。
---

# Cursor Orchestration

**前置：** 已批准 plan；用户说「开始实现」。未批准不得激活。

**平台：** 仅 Cursor。Codex → omx；Claude → claude-orchestration。

## 激活后

1. 声明 `「Harness：cursor-orchestration:dispatcher-workflow」`
2. Read **`harness-kit/core/orchestration/dispatcher-workflow.md`**
3. Read `tracking/schema.md`、已批准 plan、`project.verification.md`
4. 委派写代码 WU：**WORKTREE-INIT** → 并行 subagent

## SpawnWorker（Cursor）

| agent_role | 机制 |
| --- | --- |
| coder / implementer / test-engineer / debugger / web-investigator | `harness-*` subagent |
| reviewer | `harness-reviewer` readonly |
| explorer | `harness-explorer` 或 Task `explore` |

绑定：`adapters/cursor/bindings.md`。`wu_skills: auto` → `core/orchestration/skill-preferences.md`。

**尾盘：** collective-test → harness-reviewer → Leader 落盘 code-review。

## 禁止

- 未过 plan 门禁；Leader 写业务代码（小改动除外）
- 实现与审查同实例；跳过 DISPATCH-TRACK / 尾盘产物
- omx CLI；末 WU 返回即声称完成
