#!/usr/bin/env bash
# Claude hook: PreToolUse — 阻断 Claude Code 原生 EnterPlanMode / ExitPlanMode（fail-open）
# 内容源: harness-kit/core/extensions/hooks/content/block-native-plan-mode.md
# 由 harness-project.sh 投影到 .claude/hooks/block-native-plan-mode.sh
# 退出码: 0=放行；2=阻断（stderr 反馈给模型）
set -euo pipefail

# 读取 Claude 通过 stdin 传入的 JSON（包含 tool_name / tool_input）
payload="$(cat)"

# 跨平台 Python 查找：实际执行 --version 验证
py=""
for cand in python3 python python3.exe python.exe; do
  if command -v "$cand" >/dev/null 2>&1; then
    if "$cand" --version >/dev/null 2>&1; then
      py="$cand"
      break
    fi
  fi
done

if [[ -z "$py" ]]; then
  # 无 Python 退化为字符串匹配（macOS/Linux 多数有 python3）
  if printf '%s' "$payload" | grep -Eq '"tool_(name|input)":[[:space:]]*"(EnterPlanMode|ExitPlanMode)"' \
     || printf '%s' "$payload" | grep -Eq '"name":[[:space:]]*"(EnterPlanMode|ExitPlanMode)"'; then
    cat >&2 <<'EOF'
Harness 禁止 Claude Code 原生 EnterPlanMode / ExitPlanMode（plan 会落到 ~/.claude/plans/，绕开 .ai-runtime-artifacts/ 与 plan 门禁）。
请：Load `writing-plans` skill → Write .ai-runtime-artifacts/plans/YYYY-MM-DD-<topic>-plan.md。详见 harness-kit/core/routing.md § 平台原生 plan 工具。
EOF
    exit 2
  fi
  exit 0
fi

# 用 Python 安全解析 JSON、判断 tool_name
reason="$(
  "$py" - "$payload" <<'PY'
import json, sys
try:
    data = json.loads(sys.argv[1])
except Exception:
    sys.exit(0)
tool = data.get("tool_name") or data.get("name") or ""
if tool in ("EnterPlanMode", "ExitPlanMode"):
    print(tool)
    sys.exit(0)
sys.exit(0)
PY
)" || true

if [[ -n "$reason" ]]; then
  cat >&2 <<EOF
Harness 禁止 Claude Code 原生 ${reason}（plan 会落到 ~/.claude/plans/，绕开 .ai-runtime-artifacts/ 与 plan 门禁）。
请：Load \`writing-plans\` skill → Write .ai-runtime-artifacts/plans/YYYY-MM-DD-<topic>-plan.md（并行时另写同 stem *-dispatch.md）。
详见 harness-kit/core/routing.md § 平台原生 plan 工具 与 adapters/claude/bindings.md。
EOF
  exit 2
fi

exit 0
