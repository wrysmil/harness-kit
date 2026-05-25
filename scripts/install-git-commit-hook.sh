#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if git -C "$(pwd)" rev-parse --git-dir >/dev/null 2>&1; then
  REPO_ROOT="$(git -C "$(pwd)" rev-parse --show-toplevel)"
else
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
fi
install -m 755 "$SCRIPT_DIR/git-prepare-commit-msg.sh" "$REPO_ROOT/.git/hooks/prepare-commit-msg"
echo "installed: $REPO_ROOT/.git/hooks/prepare-commit-msg"
