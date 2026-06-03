#!/usr/bin/env bash
# Cursor hook: sessionStart — 注入 Harness 路由提示（fail-open）
# 启用：复制 hooks.json.example -> hooks.json
set -euo pipefail

# 读取 stdin（Cursor hook JSON），本脚本不依赖具体字段
cat >/dev/null

cat <<'EOF'
{
  "additional_context": "Harness：首句「Harness：<route>」；有 route skill 时次行 Skills。spec/plan 写入后暂停，同轮不改业务代码。文本文件用 Write/StrReplace，禁止 Shell 写文件。见 ai-entry.mdc § 文件写入与阶段门禁。"
}
EOF
exit 0
