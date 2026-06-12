#!/usr/bin/env bash
# Claude hook: SessionStart — Harness 路由提示注入（fail-open）
# 内容源: harness-kit/core/extensions/hooks/content/session-init.md
# 由 harness-project.sh 投影到 .claude/hooks/harness-session-init.sh
set -euo pipefail

cat >/dev/null  # 消耗 stdin

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
content_file="$script_dir/content/session-init.md"

if [[ ! -f "$content_file" ]]; then
  echo "harness-session-init: 内容文件不存在 $content_file" >&2
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
  "$py" -c "import json,sys; print(json.dumps({'hookSpecificOutput': {'hookEventName': 'SessionStart', 'additionalContext': open(sys.argv[1]).read()}}, ensure_ascii=False))" "$content_file"
else
  cat "$content_file"
fi
exit 0
