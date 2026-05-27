#!/usr/bin/env bash
# Cursor hook: sessionStart — 注入 Harness 路由提示（fail-open）
# 启用：复制 hooks.json.example -> hooks.json
set -euo pipefail

# 读取 stdin（Cursor hook JSON），本脚本不依赖具体字段
cat >/dev/null

cat <<'EOF'
{
  "additional_context": "Harness Kit：首句「Harness：<route>」；本阶段有 route skill 时次行 Skills: <slug>@<path> loaded。先 Load SKILL.md 再写产物；禁止用 artifact-templates/spec|plan 短模板代替 skill。spec/plan 写入后须暂停（阶段门禁）。详见 harness-kit/core/routing.md。"
}
EOF
exit 0
