---
name: claude-orchestration
description: Claude Code 多 Task 并行编排。已批准 plan +「开始实现」后并行派发 WU。触发：并行实现、多 task、开始实现、claude 编排。
---

# Claude Orchestration

**前置：** 已批准 plan；用户说「开始实现」。未批准不得激活。

**平台：** 仅 Claude Code。Cursor → cursor-orchestration；Codex → omx。

## 激活后

1. 声明 `「Harness：claude-orchestration:dispatcher-workflow」`
2. Read **`harness-kit/core/orchestration/dispatcher-workflow.md`**
3. Read `tracking/schema.md`、已批准 plan、`project.verification.md`
4. 委派写代码 WU：**WORKTREE-INIT** → 并行 Task

## SpawnWorker（Claude Code）

| agent_role | 机制 |
| --- | --- |
| coder / implementer / test-engineer / debugger / web-investigator | `Task(subagent_type=generalPrompt)` + core agent 文件为 prompt |
| reviewer | 新 Task readonly 实例 |
| explorer | `Task(subagent_type=generalPurpose)` readonly |

绑定：`adapters/claude/bindings.md`。`wu_skills: auto` → `core/orchestration/skill-preferences.md`。

**尾盘：** collective-test → reviewer Task → Leader 落盘 code-review。

## 禁止

- 未过 plan 门禁；Leader 写业务代码（小改动除外）
- 实现与审查同实例；跳过 DISPATCH-TRACK / 尾盘产物
- 末 WU 返回即声称完成
