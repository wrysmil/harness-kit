#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 检测布局：source = 本仓库（core/ 在根）；deployed = 已接入目标项目（harness-kit/ 子目录）
if [[ -f "$KIT_ROOT/core/harness.md" ]]; then
  LAYOUT="source"
  ROOT_DIR="$KIT_ROOT"
  HK="."
elif [[ -f "$KIT_ROOT/harness-kit/core/harness.md" ]]; then
  LAYOUT="deployed"
  ROOT_DIR="$KIT_ROOT"
  HK="harness-kit"
else
  echo "cannot detect harness-kit layout under $KIT_ROOT" >&2
  exit 1
fi

cd "$ROOT_DIR"
echo "==> layout: $LAYOUT (root: $ROOT_DIR)"

kit_path() {
  if [[ "$HK" == "." ]]; then
    echo "$1"
  else
    echo "$HK/$1"
  fi
}

required_kit_files=(
  "README.md"
  "core/harness.md"
  "project.profile.md"
  "context-map.md"
  "project.verification.md"
  "project.git.md"
  "core/routing.md"
  "core/capabilities/registry.md"
  "core/capabilities/primitives.md"
  "core/orchestration/dispatcher-workflow.md"
  "core/orchestration/roles.md"
  "core/orchestration/skill-preferences.md"
  "core/orchestration/config.defaults.yaml"
  "core/orchestration/tracking/schema.md"
  "core/orchestration/agents/leader.md"
  "core/orchestration/agents/coder.md"
  "core/artifacts.md"
  "core/verification.md"
  "core/runbooks.md"
  "init/bootstrap.prompt.md"
  "init/onboarding-handoff.txt"
  "init/project-profiler.prompt.md"
  "init/templates/project.profile.md"
  "init/templates/context-map.md"
  "init/templates/project.verification.md"
  "init/templates/project.git.md"
  "artifact-templates/spec.md"
  "artifact-templates/plan.md"
  "artifact-templates/spec.harness-overlay.md"
  "artifact-templates/plan.harness-overlay.md"
  "artifact-templates/dispatch.harness-overlay.md"
  "artifact-templates/verification.md"
  "artifact-templates/verification-lite.md"
  "artifact-templates/collective-test.md"
  "artifact-templates/code-review.md"
  "artifact-templates/document-review.md"
  "artifact-templates/decision.md"
  "artifact-templates/dispatch-track.md"
  "artifact-templates/handoff.md"
  "artifact-templates/progress.md"
  "artifact-templates/wu-checklist.md"
  "artifact-templates/research-report.md"
  "entrypoints/AGENTS.md"
  "entrypoints/HARNESS-PLATFORM-ENTRY.md"
  "entrypoints/CLAUDE.md"
  "entrypoints/GEMINI.md"
  "entrypoints/AGENTS.omx.md"
  "entrypoints/AGENTS.cursor-overlay.md"
  "adapters/cursor/.cursor/hooks.json.example"
  "adapters/cursor/.cursor/hooks/harness-session-init.sh"
  "adapters/cursor/.cursor/hooks/harness-subagent-track-reminder.sh"
  "adapters/cursor/orchestration/hooks/README.md"
  "adapters/cursor/orchestration/continuous-loop.md"
  "adapters/agents/.agents/README.md"
  "adapters/cursor/.cursor/rules/ai-entry.mdc"
  "adapters/cursor/.cursor/rules/cursor-subagent-routing.mdc"
  "adapters/cursor/.cursor/agents/harness-coder.md"
  "adapters/cursor/.cursor/agents/harness-implementer.md"
  "adapters/cursor/.cursor/agents/harness-reviewer.md"
  "adapters/cursor/.cursor/agents/harness-explorer.md"
  "adapters/cursor/.cursor/agents/harness-debugger.md"
  "adapters/cursor/.cursor/agents/harness-test-engineer.md"
  "adapters/cursor/.cursor/agents/harness-web-investigator.md"
  "adapters/cursor/.cursor/skills/test-driven-development/SKILL.md"
  "adapters/cursor/.cursor/skills/verification-before-completion/SKILL.md"
  "adapters/cursor/.cursor/skills/ui-ux-pro-max/SKILL.md"
  "adapters/cursor/.cursor/skills/ui-ux-pro-max/scripts/search.py"
  "adapters/cursor/orchestration/skill-preferences.zh.md"
  "adapters/cursor/orchestration/agents/test-engineer.md"
  "scripts/sync-cursor-skills.sh"
  "adapters/cursor/README.md"
  "adapters/cursor/orchestration/platform-adapters.zh.md"
  "adapters/cursor/orchestration/dispatcher-workflow.md"
  "adapters/cursor/orchestration/config.defaults.yaml"
  "adapters/cursor/orchestration/VENDOR.md"
  "adapters/cursor/orchestration/CURSOR-PRECHECK.md"
  "adapters/cursor/orchestration/context-budget.md"
  "adapters/cursor/orchestration/model-routing.yaml"
  "adapters/cursor/orchestration/agents/leader.md"
  "adapters/cursor/orchestration/agents/coder.md"
  "adapters/cursor/orchestration/agents/implementer.md"
  "adapters/cursor/orchestration/agents/reviewer.md"
  "adapters/cursor/orchestration/agents/debugger.md"
  "adapters/cursor/orchestration/agents/web-investigator.md"
  "adapters/cursor/orchestration/runtime/plan-progress-sync.md"
  "adapters/cursor/orchestration/tracking/schema.md"
  "adapters/agents/.agents/skills/cursor-orchestration/SKILL.md"
  "adapters/cursor/bindings.md"
  "adapters/cursor/capability-matrix.yaml"
  "adapters/claude/README.md"
  "adapters/claude/bindings.md"
  "adapters/claude/capability-matrix.yaml"
  "adapters/claude/.agents/skills/claude-orchestration/SKILL.md"
  "adapters/codex/bindings.md"
  "adapters/codex/capability-matrix.yaml"
  "scripts/install-ai-skills.sh"
  "scripts/harness-init.sh"
  "scripts/harness-check.sh"
)

required_deployed_files=(
  "AGENTS.md"
  "CLAUDE.md"
  "GEMINI.md"
  ".cursor/rules/ai-entry.mdc"
  ".cursor/rules/cursor-subagent-routing.mdc"
  ".cursor/agents/harness-coder.md"
  ".cursor/agents/harness-implementer.md"
  ".cursor/agents/harness-reviewer.md"
  ".cursor/agents/harness-explorer.md"
  ".cursor/agents/harness-debugger.md"
  ".cursor/agents/harness-test-engineer.md"
  ".cursor/agents/harness-web-investigator.md"
  ".agents/README.md"
  ".agents/skills/cursor-orchestration/SKILL.md"
  ".agents/skills/claude-orchestration/SKILL.md"
  ".ai-runtime-artifacts/README.md"
)

required_dirs=(
  ".ai-runtime-artifacts/specs"
  ".ai-runtime-artifacts/plans"
  ".ai-runtime-artifacts/reviews"
  ".ai-runtime-artifacts/verifications"
  ".ai-runtime-artifacts/decisions"
  ".ai-runtime-artifacts/retros"
  ".ai-runtime-artifacts/research"
  ".ai-runtime-artifacts/execution-logs"
  ".ai-runtime-artifacts/execution-logs/tracking"
)

missing=0
for rel in "${required_kit_files[@]}"; do
  file="$(kit_path "$rel")"
  if [[ -f "$file" ]]; then
    echo "ok: $file"
  else
    echo "missing: $file" >&2
    missing=1
  fi
done

if [[ "$LAYOUT" == "deployed" ]]; then
  for file in "${required_deployed_files[@]}"; do
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
else
  echo "skip: deployed-only projection checks (source layout)"
fi

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

echo "==> Checking harness subagent projection shells"
agent_errors=0
agents_dir="$(kit_path adapters/cursor/.cursor/agents)"
orch_dir="$(kit_path adapters/cursor/orchestration/agents)"
core_orch_dir="$(kit_path core/orchestration/agents)"
max_projection_lines=80

for projected in "$agents_dir"/harness-*.md; do
  [[ -f "$projected" ]] || continue
  rel_projected="${projected#"$ROOT_DIR"/}"
  rel_projected="${rel_projected#./}"
  lines="$(wc -l < "$projected" | tr -d ' ')"
  base="$(basename "$projected" .md)"
  canonical_name="${base#harness-}"
  canonical="$orch_dir/${canonical_name}.md"
  core_canonical="$core_orch_dir/${canonical_name}.md"
  if [[ -f "$canonical" ]] || [[ -f "$core_canonical" ]]; then
    if ! grep -qE 'orchestration/agents/|core/orchestration/agents/' "$projected" 2>/dev/null; then
      echo "missing orchestration/agents/ reference: $rel_projected" >&2
      agent_errors=1
    fi
    ref="$canonical"
    [[ -f "$core_canonical" ]] && ref="$core_canonical"
    canon_lines="$(wc -l < "$ref" | tr -d ' ')"
    max_allowed=$(( canon_lines * 12 / 10 ))
    if [[ "$lines" -gt "$max_allowed" ]]; then
      echo "projection too fat ($lines > $max_allowed vs canonical $canon_lines): $rel_projected" >&2
      agent_errors=1
    fi
  elif [[ "$lines" -gt "$max_projection_lines" ]]; then
    echo "projection exceeds ${max_projection_lines} lines ($lines): $rel_projected" >&2
    agent_errors=1
  fi
done

if [[ "$agent_errors" -ne 0 ]]; then
  exit 1
fi

echo "==> Checking orchestration stub redirects"
stub_errors=0
for stub in \
  "$(kit_path adapters/cursor/orchestration/dispatcher-workflow.md)" \
  "$(kit_path adapters/cursor/orchestration/skill-preferences.zh.md)"; do
  if [[ -f "$stub" ]]; then
    if ! grep -q 'core/orchestration/' "$stub" 2>/dev/null; then
      echo "stub missing core redirect: $stub" >&2
      stub_errors=1
    else
      echo "ok: stub redirect $stub"
    fi
  else
    echo "missing stub: $stub" >&2
    stub_errors=1
  fi
done

if [[ "$stub_errors" -ne 0 ]]; then
  exit 1
fi

echo "==> Checking capability matrix coverage"
matrix_errors=0
registry="$(kit_path core/capabilities/registry.md)"
if [[ ! -f "$registry" ]]; then
  echo "missing registry: $registry" >&2
  matrix_errors=1
else
  capability_ids=()
  while IFS= read -r cap_line; do
    [[ -n "$cap_line" ]] && capability_ids+=("$cap_line")
  done < <(grep -E '^### [a-z0-9.-]+$' "$registry" | sed 's/^### //')
  for platform in cursor claude codex; do
    matrix="$(kit_path "adapters/$platform/capability-matrix.yaml")"
    bindings="$(kit_path "adapters/$platform/bindings.md")"
    if [[ ! -f "$matrix" ]]; then
      echo "missing matrix: $matrix" >&2
      matrix_errors=1
      continue
    fi
    if [[ ! -f "$bindings" ]]; then
      echo "missing bindings: $bindings" >&2
      matrix_errors=1
    fi
    for cap_id in "${capability_ids[@]}"; do
      if ! grep -q "^  ${cap_id}:" "$matrix" 2>/dev/null; then
        echo "matrix missing capability $cap_id: $matrix" >&2
        matrix_errors=1
      fi
    done
    while IFS= read -r cap_key; do
      [[ -n "$cap_key" ]] || continue
      block="$(awk -v key="$cap_key" '
        $0 ~ "^  " key ":" { show=1; print; next }
        show && /^  [a-z]/ { exit }
        show { print }
      ' "$matrix")"
      if printf '%s\n' "$block" | grep -q 'status: degraded'; then
        if [[ -f "$bindings" ]] && ! grep -qE "${cap_key}|degraded" "$bindings" 2>/dev/null; then
          echo "degraded capability $cap_key lacks bindings note: $bindings" >&2
          matrix_errors=1
        fi
      fi
    done < <(grep -E '^  [a-z][a-z0-9.-]*:' "$matrix" 2>/dev/null | sed -n 's/^  \([a-z0-9.-]*\):.*/\1/p')
    echo "ok: matrix $platform (${#capability_ids[@]} capabilities)"
  done
fi

routing_file="$(kit_path core/routing.md)"
if [[ -f "$routing_file" ]]; then
  if ! grep -q 'claude-orchestration' "$routing_file" 2>/dev/null; then
    echo "routing missing claude-orchestration column/reference" >&2
    matrix_errors=1
  else
    echo "ok: routing claude-orchestration"
  fi
fi

if [[ "$matrix_errors" -ne 0 ]]; then
  exit 1
fi

echo "==> Checking unfinished markers"
scan_paths=()
if [[ "$LAYOUT" == "deployed" ]]; then
  scan_paths=(AGENTS.md CLAUDE.md GEMINI.md .cursor .agents)
fi
scan_paths+=("$(kit_path .)")
if [[ -d ".ai-runtime-artifacts" ]]; then
  scan_paths+=(".ai-runtime-artifacts")
fi

if rg -n "T[B]D|T[O]DO|FIX[M]E|待[定]|占[位]" "${scan_paths[@]}" 2>/dev/null; then
  echo "unfinished markers found" >&2
  exit 1
fi

if [[ -d ".ai-runtime-artifacts" ]]; then
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

    if printf '%s\n' "$front_matter" | rg -qi '^route:.*(brainstorming|writing-plans|verification-before-completion|git-xywh|cursor-orchestration)'; then
      skill_items="$(printf '%s\n' "$front_matter" | awk '
        /^skills:/ { f = 1; next }
        f && /^[A-Za-z0-9_.-]+:/ { exit }
        f && /^[[:space:]]*-[[:space:]]+/ { sub(/^[[:space:]]*-[[:space:]]+/, ""); print }
      ')"
      if [[ -z "$skill_items" ]] || printf '%s\n' "$skill_items" | rg -qx '<skill>'; then
        echo "empty or placeholder skills (route requires stage skill): $artifact_file" >&2
        artifact_errors=1
      fi
      evidence_items="$(printf '%s\n' "$front_matter" | awk '
        /^skills_evidence:/ { f = 1; next }
        f && /^[A-Za-z0-9_.-]+:/ { exit }
        f && /^[[:space:]]*-[[:space:]]+/ { sub(/^[[:space:]]*-[[:space:]]+/, ""); print }
      ')"
      if [[ -z "$evidence_items" ]] || printf '%s\n' "$evidence_items" | rg -q '^(<path|<skill>|\.{3})'; then
        echo "missing or placeholder skills_evidence (P1 required for stage-skill route): $artifact_file" >&2
        artifact_errors=1
      fi
    fi
  done < <(find .ai-runtime-artifacts -type f -name '*.md' ! -name 'README.md' 2>/dev/null | sort)

  if [[ "$artifact_errors" -ne 0 ]]; then
    exit 1
  fi
else
  echo "skip: .ai-runtime-artifacts (not initialized)"
fi

# P2: warn when execution-log looks like a Cursor batch run but omits batch-closeout artifacts (non-fatal)
if [[ -d ".ai-runtime-artifacts/execution-logs" ]]; then
  echo "==> Checking execution-log batch-closeout links (warn only)"
  closeout_warn=0
  while IFS= read -r elog; do
    [[ -f "$elog" ]] || continue
    base="$(basename "$elog")"
    [[ "$base" == "HANDOFF.md" ]] && continue
    [[ "$base" == README.md ]] && continue
    content="$(<"$elog")"
    if ! printf '%s' "$content" | rg -q 'cursor-orchestration|dispatcher-workflow'; then
      continue
    fi
    missing=()
    if ! printf '%s' "$content" | rg -q '尾盘门禁|collective-test'; then
      missing+=("尾盘门禁或 collective-test 链接")
    fi
    if ! printf '%s' "$content" | rg -q 'code-review'; then
      missing+=("code-review 链接")
    fi
    if [[ ${#missing[@]} -gt 0 ]]; then
      echo "warn: $elog — Cursor 编排 execution-log 建议含尾盘产物引用（${missing[*]}）。见 docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md" >&2
      closeout_warn=1
    fi
    if printf '%s' "$content" | rg -qi '批次交付完成|本 GROUP.*完成|GROUP 交付完成'; then
      if ! printf '%s' "$content" | rg -q 'collective-test.*PASS|verdict: PASS'; then
        echo "warn: $elog — 声称批次完成但未引用 collective-test PASS" >&2
        closeout_warn=1
      fi
      if ! printf '%s' "$content" | rg -q 'code-review|verdict: APPROVE|verdict: SKIPPED'; then
        echo "warn: $elog — 声称批次完成但未引用 code-review APPROVE/SKIPPED" >&2
        closeout_warn=1
      fi
    fi
  done < <(find .ai-runtime-artifacts/execution-logs -maxdepth 1 -type f -name '*.md' 2>/dev/null | sort)
  if [[ "$closeout_warn" -eq 0 ]]; then
    echo "ok: execution-log batch-closeout (no warnings)"
  fi
fi

if [[ -f package.json ]]; then
  echo "==> Checking package.json"
  node -e "JSON.parse(require('fs').readFileSync('package.json','utf8')); console.log('package-json-ok')"
else
  echo "skip: package.json (not present)"
fi

echo "==> Checking shell scripts"
bash -n "$(kit_path scripts/install-ai-skills.sh)"
bash -n "$(kit_path scripts/harness-init.sh)"
bash -n "$(kit_path scripts/harness-check.sh)"

echo "==> Harness check complete"
