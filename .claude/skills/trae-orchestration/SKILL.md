---
name: trae-orchestration
description: Trae Agent 模式多任务并行编排。已批准 plan +「开始实现」后并行派发 WU。触发：并行实现、多 task、开始实现、trae 编排。
---

# Trae Orchestration

**前置：** 已批准 plan；用户说「开始实现」。未批准不得激活。

**平台：** 仅 Trae。Cursor → cursor-orchestration；Claude → claude-orchestration；Codex → omx。

## 激活后

1. 声明 `「Harness：trae-orchestration:dispatcher-workflow」`
2. Read **`harness-kit/core/orchestration/dispatcher-workflow.md`**
3. Read `tracking/schema.md`、已批准 plan、`project.verification.md`
4. 委派写代码 WU：**WORKTREE-INIT** → 并行 Trae Agent

## SpawnWorker（Trae）

| agent_role | 机制 |
| --- | --- |
| coder / implementer / test-engineer / debugger / web-investigator | Trae Agent 模式 + core agent 文件 |
| reviewer | Trae Agent readonly 实例 |
| explorer | Trae Agent readonly |

绑定：`adapters/trae/bindings.md`。`wu_skills: auto` → `core/orchestration/skill-preferences.md`。

**尾盘：** collective-test → reviewer Agent → Leader 落盘 code-review。

## 禁止

- 未过 plan 门禁；Leader 写业务代码（小改动除外）
- 实现与审查同实例；跳过 DISPATCH-TRACK / 尾盘产物
- 末 WU 返回即声称完成
