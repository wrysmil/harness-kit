#!/usr/bin/env bash
# Cursor hook: sessionStart — 注入 Harness 路由提示（fail-open）
# 启用：复制 hooks.json.example -> hooks.json
set -euo pipefail

# 读取 stdin（Cursor hook JSON），本脚本不依赖具体字段
cat >/dev/null

cat <<'EOF'
{
  "additional_context": "Harness：首行「Harness：<route>」；stage skill / Tier 1+ 次行 Skills: slug@path loaded|skipped。spec/plan 写入后暂停（组合指令「然后执行」不跳过）。Tier 1 须 verification-lite。文本用 Write/StrReplace。见 routing.md § 组合指令、§ 任务 Tier。"
}
EOF
exit 0
