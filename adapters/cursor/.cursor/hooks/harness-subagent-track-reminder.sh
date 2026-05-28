#!/usr/bin/env bash
# Cursor hook: subagentStop — 提醒 Leader 追加 DISPATCH 追踪（fail-open）
set -euo pipefail

input="$(cat)"

if command -v python3 >/dev/null 2>&1; then
  python3 -c 'import json,sys; print(json.dumps({"followup_message": "Harness：子 Agent 已结束。请 Leader 按顺序执行：\n\n(1) 先更新 plan 勾选：在对应 plan 条目将 `- [ ]` → `- [√]`，并在该条目下追加证据行（见 `adapters/cursor/orchestration/runtime/plan-progress-sync.md`），明确：哪个 WU-id/Agent(role) 完成了哪些条目 + 验证证据。\n    - 推荐证据行：`  - evidence: WU-<id> | agent_role=<role> | verified_by=<Leader> | proof=<tests|lint|manual>`\n\n(2) 再做追踪落盘：向 `.ai-runtime-artifacts/execution-logs/tracking/DISPATCH-TRACK-*.md` append（如启用 tracking）。\n\n(3) 最后判断是否进入尾盘（仅当本 GROUP 末 WU 已完成）：集体测试 → Write `*-collective-test.md` → 集体审查 → Write `*-code-review.md`（见 spec 2026-05-28-batch-closeout）。\n\n责任边界：子 Agent 不改 plan；由 Leader 验证后落盘。"}, ensure_ascii=False))'
else
  printf '%s\n' '{"followup_message":"Harness: subagent stopped. Leader followups (in order): (1) Update plan checkboxes (- [ ] -> - [√]) and append evidence lines under the plan item (WU-id/agent_role/verification proof) per adapters/cursor/orchestration/runtime/plan-progress-sync.md; (2) append .ai-runtime-artifacts/execution-logs/tracking/DISPATCH-TRACK-*.md if used; (3) if this was the last WU in the group, proceed to batch closeout (collective test -> write *-collective-test.md -> collective review -> write *-code-review.md). Responsibility: subagents must not edit plan; Leader verifies and writes."}'
fi
exit 0
