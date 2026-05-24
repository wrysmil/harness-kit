#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

required_files=(
  "AGENTS.md"
  "CLAUDE.md"
  "GEMINI.md"
  ".cursor/rules/ai-entry.mdc"
  ".agents/README.md"
  "harness-kit/README.md"
  "harness-kit/core/harness.md"
  "harness-kit/project.profile.md"
  "harness-kit/context-map.md"
  "harness-kit/project.verification.md"
  "harness-kit/core/routing.md"
  "harness-kit/core/artifacts.md"
  "harness-kit/core/verification.md"
  "harness-kit/core/runbooks.md"
  "harness-kit/init/bootstrap.prompt.md"
  "harness-kit/init/project-profiler.prompt.md"
  "harness-kit/init/templates/project.profile.md"
  "harness-kit/init/templates/context-map.md"
  "harness-kit/init/templates/project.verification.md"
  "harness-kit/artifact-templates/spec.md"
  "harness-kit/artifact-templates/plan.md"
  "harness-kit/artifact-templates/verification.md"
  "harness-kit/artifact-templates/decision.md"
  "harness-kit/entrypoints/AGENTS.md"
  "harness-kit/entrypoints/CLAUDE.md"
  "harness-kit/entrypoints/GEMINI.md"
  "harness-kit/adapters/agents/.agents/README.md"
  "harness-kit/adapters/cursor/.cursor/rules/ai-entry.mdc"
  "harness-kit/adapters/codex/README.md"
  "harness-kit/scripts/install-ai-skills.sh"
  "harness-kit/scripts/harness-init.sh"
  "harness-kit/scripts/harness-check.sh"
  ".ai-runtime-artifacts/README.md"
)

required_dirs=(
  ".ai-runtime-artifacts/specs"
  ".ai-runtime-artifacts/plans"
  ".ai-runtime-artifacts/reviews"
  ".ai-runtime-artifacts/verifications"
  ".ai-runtime-artifacts/decisions"
  ".ai-runtime-artifacts/retros"
)

missing=0
for file in "${required_files[@]}"; do
  if [[ -f "$file" ]]; then
    echo "ok: $file"
  else
    echo "missing: $file" >&2
    missing=1
  fi
done

for dir in "${required_dirs[@]}"; do
  if [[ -d "$dir" ]]; then
    echo "ok: $dir"
  else
    echo "missing: $dir" >&2
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

echo "==> Checking unfinished markers"
if rg -n "T[B]D|T[O]DO|FIX[M]E|待[定]|占[位]" \
  AGENTS.md CLAUDE.md GEMINI.md .cursor .agents harness-kit .ai-runtime-artifacts; then
  echo "unfinished markers found" >&2
  exit 1
fi

echo "==> Checking AI runtime artifact front matter"
artifact_errors=0
while IFS= read -r artifact_file; do
  if [[ "$(sed -n '1p' "$artifact_file")" != "---" ]]; then
    echo "missing front matter: $artifact_file" >&2
    artifact_errors=1
    continue
  fi

  front_matter="$(awk '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---" { exit }
    in_fm { print }
  ' "$artifact_file")"
  for key in artifact route skills source created_at; do
    if ! printf '%s\n' "$front_matter" | rg -q "^${key}:"; then
      echo "missing front matter key '$key': $artifact_file" >&2
      artifact_errors=1
    fi
  done
done < <(find .ai-runtime-artifacts -type f -name '*.md' ! -name 'README.md' | sort)

if [[ "$artifact_errors" -ne 0 ]]; then
  exit 1
fi

echo "==> Checking package.json"
node -e "JSON.parse(require('fs').readFileSync('package.json','utf8')); console.log('package-json-ok')"

echo "==> Checking shell scripts"
bash -n harness-kit/scripts/install-ai-skills.sh
bash -n harness-kit/scripts/harness-init.sh
bash -n harness-kit/scripts/harness-check.sh

echo "==> Harness check complete"
