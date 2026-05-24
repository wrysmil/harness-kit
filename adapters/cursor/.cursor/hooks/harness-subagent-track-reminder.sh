#!/usr/bin/env bash
# Cursor hook: subagentStop — 提醒 Leader 追加 DISPATCH 追踪（fail-open）
set -euo pipefail

input="$(cat)"

if command -v python3 >/dev/null 2>&1; then
  python3 -c 'import json,sys; print(json.dumps({"followup_message": "Harness：子 Agent 已结束。请 Leader 向 .ai-runtime-artifacts/execution-logs/tracking/DISPATCH-TRACK-*.md append 一条记录，并确认 implementer 与 reviewer 为不同 Task 实例。"}, ensure_ascii=False))'
else
  printf '%s\n' '{"followup_message":"Harness: subagent stopped. Append DISPATCH-TRACK log and keep implementer/reviewer as separate Task instances."}'
fi
exit 0
