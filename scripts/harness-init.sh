#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

PROMPT_FILE="harness-kit/init/project-profiler.prompt.md"

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "missing: $PROMPT_FILE" >&2
  exit 1
fi

cat <<MSG
This command is an AI handoff helper. It does not initialize the project by itself.

Give this task to your AI agent:

请读取并执行 harness-kit/init/bootstrap.prompt.md 中的完整 Harness 初始化流程。
（可选先读 harness-kit/README.md 了解背景。）

Profiler prompt:
  $PROMPT_FILE
MSG
