#!/usr/bin/env bash
# Cursor hook: subagentStop — 提醒 Leader 追加 DISPATCH 追踪（fail-open）
# 内容源: harness-kit/core/extensions/hooks/content/subagent-stop.md
# 由 harness-project.sh 投影到 .cursor/hooks/harness-subagent-stop.sh
set -euo pipefail

input="$(cat)"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
content_file="$script_dir/content/subagent-stop.md"

if [[ ! -f "$content_file" ]]; then
  echo "harness-subagent-stop: 内容文件不存在 $content_file" >&2
  exit 0
fi

# 跨平台 Python 查找：实际执行 --version 验证（Windows 的 python3 是 Store 跳转，要排除）
py=""
for cand in python3 python python3.exe python.exe; do
  if command -v "$cand" >/dev/null 2>&1; then
    if "$cand" --version >/dev/null 2>&1; then
      py="$cand"
      break
    fi
  fi
done

if [[ -n "$py" ]]; then
  "$py" -c "import json,sys; print(json.dumps({'followup_message': open(sys.argv[1]).read()}, ensure_ascii=False))" "$content_file"
else
  printf '%s\n' '{"followup_message":"Harness: subagent stopped. Leader followups (in order): (1) Update plan checkboxes (- [ ] -> - [√]) and append evidence lines under the plan item (WU-id/agent_role/verification proof) per core/orchestration/runtime/plan-progress-sync.md; (2) append .ai-runtime-artifacts/execution-logs/tracking/DISPATCH-TRACK-*.md if used; (3) if this was the last WU in the group, proceed to batch closeout (collective test -> write *-collective-test.md -> collective review -> write *-code-review.md). Responsibility: subagents must not edit plan; Leader verifies and writes."}'
fi
exit 0
