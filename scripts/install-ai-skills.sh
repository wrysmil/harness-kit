#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

OH_MY_CODEX_PACKAGE="${OH_MY_CODEX_PACKAGE:-oh-my-codex}"

echo "==> Installing ${OH_MY_CODEX_PACKAGE} globally"
if ! npm install -g "$OH_MY_CODEX_PACKAGE"; then
  cat <<'MSG' >&2

Failed to install oh-my-codex.

Check npm registry access and permissions, then rerun:
  bash cow-harness/scripts/install-ai-skills.sh
MSG
  exit 1
fi

if ! command -v omx >/dev/null 2>&1; then
  cat <<'MSG' >&2

oh-my-codex installed, but `omx` is not on PATH.
Check your npm global bin directory, then rerun:
  omx setup
  omx doctor
MSG
  exit 1
fi

echo "==> Running omx setup"
if ! omx setup; then
  cat <<'MSG' >&2

`omx setup` failed. Fix the reported setup issue, then rerun:
  bash cow-harness/scripts/install-ai-skills.sh
MSG
  exit 1
fi

echo "==> Running omx doctor"
if ! omx doctor; then
  cat <<'MSG' >&2

`omx doctor` reported problems. Fix the reported issues, then rerun:
  bash cow-harness/scripts/install-ai-skills.sh
MSG
  exit 1
fi

echo "==> Checking superpowers skills"

SUPERPOWERS_SKILLS=(brainstorming writing-plans systematic-debugging test-driven-development verification-before-completion)
SEARCH_DIRS=("$HOME/.claude/skills" "$HOME/.agents/skills")

find_skill() {
  local skill="$1"
  for dir in "${SEARCH_DIRS[@]}"; do
    if [[ -f "$dir/$skill/SKILL.md" ]]; then
      echo "$dir/$skill/SKILL.md"
      return 0
    fi
  done
  return 1
}

missing=0
for skill in "${SUPERPOWERS_SKILLS[@]}"; do
  if path=$(find_skill "$skill"); then
    echo "ok: $path"
  else
    echo "missing: $skill"
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  cat <<'MSG' >&2

Some superpowers skills are missing. Install via:
  npx skills add obra/superpowers -g

oh-my-codex passed setup and doctor, and the project can still use omx workflows.
MSG
  if [[ "${STRICT_SUPERPOWERS:-0}" == "1" ]]; then
    exit 2
  fi
fi

echo "==> AI skills installation check complete"
