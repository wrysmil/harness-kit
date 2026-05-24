#!/usr/bin/env bash
# Cursor hook: sessionStart — 注入 Harness 路由提示（fail-open）
# 启用：复制 hooks.json.example -> hooks.json
set -euo pipefail

# 读取 stdin（Cursor hook JSON），本脚本不依赖具体字段
cat >/dev/null

cat <<'EOF'
{
  "additional_context": "Harness Kit：首句声明「Harness：<route>」。spec/plan 写入后须暂停等用户审查（阶段门禁）。实现阶段委派 .cursor/agents/harness-implementer，审查用 harness-reviewer。详见 harness-kit/core/routing.md 与 .cursor/rules/cursor-subagent-routing.mdc。"
}
EOF
exit 0
