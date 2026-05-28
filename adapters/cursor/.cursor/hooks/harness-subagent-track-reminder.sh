#!/usr/bin/env bash
# Cursor hook: subagentStop — 提醒 Leader 追加 DISPATCH 追踪（fail-open）
set -euo pipefail

input="$(cat)"

if command -v python3 >/dev/null 2>&1; then
  python3 -c 'import json,sys; print(json.dumps({"followup_message": "Harness：子 Agent 已结束。请 Leader：(1) 向 execution-logs/tracking/DISPATCH-TRACK-*.md append；(2) 确认 implementer 与 reviewer 为不同实例；(3) 若本 GROUP 末 WU 已完成，进入尾盘：集体测试 → Write *-collective-test.md → 集体审查 → Write *-code-review.md（见 spec 2026-05-28-batch-closeout）。"}, ensure_ascii=False))'
else
  printf '%s\n' '{"followup_message":"Harness: subagent stopped. Append DISPATCH-TRACK log and keep implementer/reviewer as separate Task instances."}'
fi
exit 0
