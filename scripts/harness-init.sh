#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

PROMPT_FILE="cow-harness/init/project-profiler.prompt.md"

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "missing: $PROMPT_FILE" >&2
  exit 1
fi

cat <<MSG
This command is an AI handoff helper. It does not initialize the project by itself.

Give this task to your AI agent:

请先读取 cow-harness/README.md 和 cow-harness/init/bootstrap.prompt.md。
这是一个新项目刚接入 Agent Harness，请按 Harness 初始化流程处理：
1. 从 cow-harness/entrypoints/ 投影根目录 AI 入口文件。
2. 从 cow-harness/adapters/ 投影工具适配目录。
3. 创建 .ai-runtime-artifacts/ 及其子目录。
4. 如需安装或检查 AI runtime，请先说明会修改哪些本机环境，然后由你执行 cow-harness/scripts/install-ai-skills.sh。
5. 读取 cow-harness/init/project-profiler.prompt.md。
6. 扫描当前项目，生成或更新 cow-harness/project.profile.md、cow-harness/context-map.md、cow-harness/project.verification.md。
7. 由你运行 cow-harness/scripts/harness-check.sh。
8. 汇总推断项、待确认项和验证结果。

Prompt file:
  $PROMPT_FILE
MSG
