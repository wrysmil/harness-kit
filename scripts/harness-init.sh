#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 与 harness-check.sh 相同：source = kit 根；deployed = 目标项目根含 harness-kit/
if [[ -f "$KIT_ROOT/init/onboarding-handoff.txt" ]]; then
  ROOT_DIR="$KIT_ROOT"
  HANDOFF_FILE="$KIT_ROOT/init/onboarding-handoff.txt"
  PROMPT_FILE="$KIT_ROOT/init/project-profiler.prompt.md"
elif [[ -f "$KIT_ROOT/harness-kit/init/onboarding-handoff.txt" ]]; then
  ROOT_DIR="$KIT_ROOT"
  HANDOFF_FILE="$KIT_ROOT/harness-kit/init/onboarding-handoff.txt"
  PROMPT_FILE="$KIT_ROOT/harness-kit/init/project-profiler.prompt.md"
else
  echo "cannot detect harness-kit layout (missing init/onboarding-handoff.txt)" >&2
  exit 1
fi

cd "$ROOT_DIR"

cat <<MSG
This command is an AI handoff helper. It does not initialize the project by itself.

Give this task to your AI agent:

MSG
cat "$HANDOFF_FILE"
printf '\nProfiler prompt:\n  %s\n' "$PROMPT_FILE"
