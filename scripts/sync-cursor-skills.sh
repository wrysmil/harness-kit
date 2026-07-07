#!/usr/bin/env bash
# 从本机全局 skill 目录同步能力副本到共享层 .agents/skills/
# （所有平台层从共享层 mirror 到各自平台目录；不再 vendor 到平台适配器）
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$(cd "$SCRIPT_DIR/../.agents/skills" && pwd)"

copy_skill() {
  local name="$1"
  local src="$2"
  if [[ ! -f "$src" ]]; then
    echo "skip (missing): $name <- $src" >&2
    return 0
  fi
  mkdir -p "$DEST/$name"
  cp "$src" "$DEST/$name/SKILL.md"
  echo "ok: $name"
}

copy_skill_dir() {
  local name="$1"
  local src_dir="$2"
  if [[ ! -f "$src_dir/SKILL.md" ]]; then
    echo "skip (missing): $name <- $src_dir" >&2
    return 0
  fi
  mkdir -p "$DEST/$name"
  rsync -a --delete --exclude '__pycache__' "$src_dir/" "$DEST/$name/"
  echo "ok: $name (directory)"
}

echo "==> Syncing vendored skills to $DEST"

copy_skill test-driven-development "$HOME/.agents/skills/test-driven-development/SKILL.md"
copy_skill verification-before-completion "$HOME/.agents/skills/verification-before-completion/SKILL.md"
copy_skill systematic-debugging "$HOME/.agents/skills/systematic-debugging/SKILL.md"
copy_skill_dir requesting-code-review "$HOME/.agents/skills/requesting-code-review"
copy_skill receiving-code-review "$HOME/.agents/skills/receiving-code-review/SKILL.md"
copy_skill frontend-design "$HOME/.cursor/skills/frontend-design/SKILL.md"
copy_skill agent-browser "$HOME/.agents/skills/agent-browser/SKILL.md"
copy_skill_dir ui-ux-pro-max "$HOME/.trae/skills/ui-ux-pro-max"

echo "==> Done (skill 偏好清单见 orchestration/skill-preferences.zh.md，非 skill 文件)"
