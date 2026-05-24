#!/usr/bin/env bash
# Cursor hook: sessionStart — 注入 Harness 路由提示（fail-open）
# 启用：复制 hooks.json.example -> hooks.json
set -euo pipefail

# 读取 stdin（Cursor hook JSON），本脚本不依赖具体字段
cat >/dev/null

cat <<'EOF'
{
  "additional_context": "Harness Kit：每个任务首句声明「Harness：<route>」。Cursor 多 task 实现走 cursor-orchestration（Task 并行），不调用 omx。详见 harness-kit/core/routing.md 与 .cursor/rules/cursor-subagent-routing.mdc。"
}
EOF
exit 0
