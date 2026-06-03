#!/usr/bin/env bash
set -euo pipefail

fail() { echo "FAIL: $*" >&2; exit 1; }

must_contain() {
  local file="$1"
  local needle="$2"
  grep -F -- "$needle" "$file" >/dev/null || fail "$file missing: $needle"
}

must_contain "artifact-templates/dispatch.harness-overlay.md" "wu_title_zh"
must_contain "artifact-templates/dispatch.harness-overlay.md" "worktree_path"
must_contain "artifact-templates/dispatch.harness-overlay.md" "branch"
must_contain "artifact-templates/dispatch.harness-overlay.md" "workspace_scope"

must_contain "core/orchestration/dispatcher-workflow.md" "coder"
must_contain "core/orchestration/dispatcher-workflow.md" "WorktreeInit"
must_contain "core/orchestration/dispatcher-workflow.md" "worktree_path"
must_contain "core/orchestration/dispatcher-workflow.md" "ParallelBatch"

tmp="$(mktemp -d)"
cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT

repo="$tmp/repo"
mkdir -p "$repo"
git init -q "$repo"
git -C "$repo" config user.email "test@example.com"
git -C "$repo" config user.name "test"
echo "hello" > "$repo/README.md"
git -C "$repo" add README.md
git -C "$repo" commit -qm "init"

echo ".worktrees/" >> "$repo/.gitignore"
git -C "$repo" add .gitignore
git -C "$repo" commit -qm "ignore worktrees"

tool="$PWD/scripts/harness-worktree.sh"

if "$tool" create >/dev/null 2>&1; then
  fail "expected create to fail without args"
fi

"$tool" create \
  --repo "$repo" \
  --date "2026-05-28" \
  --topic "cursor-worktree-isolation" \
  --wu "WU-02" \
  --wu-type "bugfix" \
  --agent-role "coder" \
  --base-ref "main" >/dev/null

wt="$repo/.worktrees/2026-05-28--cursor-worktree-isolation__WU-02__bugfix__coder"
[ -d "$wt" ] || fail "worktree dir not created: $wt"
git -C "$wt" status --porcelain >/dev/null

if "$tool" create \
  --repo "$repo" \
  --date "2026-05-28" \
  --topic "cursor-worktree-isolation" \
  --wu "WU-02" \
  --wu-type "bugfix" \
  --agent-role "coder" \
  --base-ref "main" >/dev/null 2>&1; then
  fail "expected duplicate create to fail"
fi

"$tool" remove --repo "$repo" --worktree "$wt" >/dev/null
[ ! -d "$wt" ] || fail "worktree dir still exists after remove"

echo "PASS"

