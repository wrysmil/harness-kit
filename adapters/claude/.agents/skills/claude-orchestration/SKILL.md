---
name: claude-orchestration
description: Claude Code 多 Task 并行编排，等价 omx ultrawork。已批准 plan +「开始实现」后并行派发 WU。触发：并行实现、多 task、开始实现、claude 编排。
---

# Claude Orchestration

**前置：** 已批准 plan；用户说「开始实现」。未批准不得激活。

**平台：** Claude Code（Codex → omx；Cursor → cursor-orchestration）。

## 激活后

1. 声明 `「Harness：claude-orchestration:dispatcher-workflow」`
2. Read **`harness-kit/core/orchestration/dispatcher-workflow.md`**（唯一步骤源）
3. Read `tracking/schema.md`、已批准 plan、`project.verification.md`
4. 将委派写代码 WU：**WORKTREE-INIT** → 并行 Task

## SpawnWorker（Claude）

| agent_role | Task |
| --- | --- |
| coder / implementer / test-engineer / debugger / web-investigator | `generalPurpose` + `core/orchestration/agents/<role>.md` |
| reviewer | 新 Task + readonly |
| explorer | `explore` 或 readonly Task |

**并行：** 同 GROUP 文件不相交；≤3（硬顶 5）；不传 Leader 全历史。

**Prompt 必含：** WU id、wu_type、agent_role、文件列表、禁止项、done criteria、Skills 路径、worktree_path（沙箱）、返回格式（`wu_status`、`### Skills 使用`）。

**尾盘：** collective-test → reviewer Task → Leader 落盘 code-review → execution-log。

## 禁止

- 未过 plan 门禁实现；Leader 写业务代码（小改动除外）
- 实现与审查同 Task 实例；跳过 DISPATCH-TRACK / 尾盘产物
- 末 WU 返回即声称完成；Leader 自动 push

绑定详情：`harness-kit/adapters/claude/bindings.md`
