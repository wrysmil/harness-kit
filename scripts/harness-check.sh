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
  "core/extensions/README.md"
  "core/extensions/hooks/README.md"
  "core/extensions/hooks/hooks.spec.yaml"
  "core/extensions/hooks/content/session-init.md"
  "core/extensions/hooks/content/subagent-stop.md"
  "core/extensions/hooks/scripts/cursor/harness-session-init.sh"
  "core/extensions/hooks/scripts/cursor/harness-subagent-stop.sh"
  "core/extensions/hooks/scripts/claude/harness-session-init.sh"
  "core/extensions/hooks/scripts/claude/harness-subagent-stop.sh"
  "core/extensions/mcp/README.md"
  "core/extensions/mcp/mcp.servers.template.json"
  "core/orchestration/continuous-loop.md"
  "core/orchestration/claude-continuous-loop.md"
  "adapters/agents/.agents/README.md"
  "adapters/cursor/.cursor/rules/ai-entry.mdc"
  "adapters/cursor/.cursor/rules/cursor-subagent-routing.mdc"
  "adapters/agents/.agents/agents/coder.md"
  "adapters/agents/.agents/agents/implementer.md"
  "adapters/agents/.agents/agents/reviewer.md"
  "adapters/agents/.agents/agents/explorer.md"
  "adapters/agents/.agents/agents/debugger.md"
  "adapters/agents/.agents/agents/test-engineer.md"
  "adapters/agents/.agents/agents/web-investigator.md"
  "adapters/agents/.agents/skills/test-driven-development/SKILL.md"
  "adapters/agents/.agents/skills/verification-before-completion/SKILL.md"
  "adapters/agents/.agents/skills/ui-ux-pro-max/SKILL.md"
  "adapters/agents/.agents/skills/ui-ux-pro-max/scripts/search.py"
  "scripts/sync-cursor-skills.sh"
  "scripts/harness-project.sh"
  "adapters/cursor/README.md"
  "core/orchestration/platform-adapters.zh.md"
  "adapters/cursor/.cursor/config.defaults.yaml"
  "adapters/cursor/VENDOR.md"
  "adapters/cursor/.cursor/CURSOR-PRECHECK.md"
  "core/orchestration/context-budget.md"
  "core/orchestration/model-routing.yaml"
  "core/orchestration/runtime/plan-progress-sync.md"
  "adapters/agents/.agents/skills/cursor-orchestration/SKILL.md"
  "adapters/cursor/bindings.md"
  "adapters/cursor/capability-matrix.yaml"
  "adapters/claude/README.md"
  "adapters/claude/bindings.md"
  "adapters/claude/capability-matrix.yaml"
  "adapters/agents/.agents/skills/claude-orchestration/SKILL.md"
  "adapters/trae/bindings.md"
  "adapters/trae/capability-matrix.yaml"
  "adapters/codex/bindings.md"
  "adapters/codex/capability-matrix.yaml"
  "scripts/install-ai-skills.sh"
  "scripts/harness-init.sh"
  "scripts/harness-check.sh"
)

# 共享层 deployed 文件（所有平台都需要）
required_deployed_shared=(
  "AGENTS.md"
  "CLAUDE.md"
  "GEMINI.md"
  ".agents/README.md"
  ".agents/agents/coder.md"
  ".agents/agents/implementer.md"
  ".agents/agents/reviewer.md"
  ".agents/agents/explorer.md"
  ".agents/agents/debugger.md"
  ".agents/agents/test-engineer.md"
  ".agents/agents/web-investigator.md"
  ".agents/skills/cursor-orchestration/SKILL.md"
  ".agents/skills/claude-orchestration/SKILL.md"
  ".agents/skills/test-driven-development/SKILL.md"
  ".agents/skills/verification-before-completion/SKILL.md"
  ".ai-runtime-artifacts/README.md"
  ".mcp.json"
)

# Cursor 平台层 deployed 文件
required_deployed_cursor=(
  ".cursor/rules/ai-entry.mdc"
  ".cursor/rules/cursor-subagent-routing.mdc"
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

# ─── 平台检测 ───────────────────────────────────────────────

detect_deployed_platform() {
  local platforms=()
  [[ -d ".cursor" ]] && platforms+=("cursor")
  [[ -f "CLAUDE.md" || -d ".claude" ]] && platforms+=("claude")
  [[ -d ".trae" ]] && platforms+=("trae")
  if [[ ${#platforms[@]} -eq 0 ]]; then
    echo "unknown"
  else
    echo "${platforms[0]}"
  fi
}

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
  # 检测平台
  PLATFORM="$(detect_deployed_platform)"
  echo "==> detected platform: $PLATFORM"

  # 共享层文件
  for file in "${required_deployed_shared[@]}"; do
    if [[ -f "$file" ]]; then
      echo "ok: $file"
    else
      echo "missing: $file" >&2
      missing=1
    fi
  done

  # Cursor 平台层文件（仅 Cursor 平台检查）
  if [[ "$PLATFORM" == "cursor" || "$PLATFORM" == "unknown" ]]; then
    for file in "${required_deployed_cursor[@]}"; do
      if [[ -f "$file" ]]; then
        echo "ok: $file"
      else
        echo "missing: $file" >&2
        missing=1
      fi
    done
  fi

  # Claude 平台层 hooks 推荐检查（warn only；不阻塞）
  if [[ "$PLATFORM" == "claude" || "$PLATFORM" == "unknown" ]]; then
    if [[ -d ".claude" ]]; then
      claude_hook_warn=0
      if [[ ! -f ".claude/hooks/harness-session-init.sh" ]] || [[ ! -f ".claude/hooks/harness-subagent-stop.sh" ]]; then
        echo "warn: .claude/hooks/harness-*.sh 缺失；运行 bash harness-kit/scripts/harness-project.sh project --platform claude 重新投影" >&2
        claude_hook_warn=1
      elif [[ -f ".claude/settings.json" ]] && ! grep -q '"hooks"' ".claude/settings.json" 2>/dev/null; then
        echo "warn: .claude/settings.json 未启用 hooks；将 .claude/settings.json.example 的 hooks 段合并到 .claude/settings.json 启用 harness-session-init / harness-subagent-stop（opt-in）" >&2
        claude_hook_warn=1
      elif [[ -f ".claude/settings.json" ]] && ! grep -q 'block-native-plan-mode' ".claude/settings.json" 2>/dev/null; then
        echo "warn: .claude/settings.json 未启用 block-native-plan-mode PreToolUse 钩子；将示例 PreToolUse 段合并到 settings.json 阻断 EnterPlanMode/ExitPlanMode（见 core/routing.md § 平台原生 plan 工具）" >&2
        claude_hook_warn=1
      fi
      if [[ "$claude_hook_warn" -eq 0 ]]; then
        echo "ok: .claude/ hooks projection"
      fi
    fi
  fi

  # 目录
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
agents_dir="$(kit_path adapters/agents/.agents/agents)"
core_orch_dir="$(kit_path core/orchestration/agents)"
max_projection_lines=80

for projected in "$agents_dir"/*.md; do
  [[ -f "$projected" ]] || continue
  rel_projected="${projected#"$ROOT_DIR"/}"
  rel_projected="${rel_projected#./}"
  lines="$(wc -l < "$projected" | tr -d ' ')"
  base="$(basename "$projected" .md)"
  core_canonical="$core_orch_dir/${base}.md"
  if [[ -f "$core_canonical" ]]; then
    if ! grep -qE 'orchestration/agents/|core/orchestration/agents/' "$projected" 2>/dev/null; then
      echo "missing orchestration/agents/ reference: $rel_projected" >&2
      agent_errors=1
    fi
    canon_lines="$(wc -l < "$core_canonical" | tr -d ' ')"
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

echo "==> Checking orchestration stub redirects (skipped — stubs deleted after shared layer migration)"

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
  for platform in cursor claude codex trae; do
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

# 检查 artifact-templates/*.md 的 front matter 路径是否真实存在
# 目的：挡 gap #3、#4、#5 —— 模板自身 FM 写错路径此前无人发现
echo "==> Checking artifact-templates FM paths"
tmpl_errors=0
for tmpl in artifact-templates/*.md; do
  [[ -f "$tmpl" ]] || continue
  base="$(basename "$tmpl")"
  [[ "$base" == "README.md" ]] && continue

  front_matter="$(awk '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---" { exit }
    in_fm { print }
  ' "$tmpl")"

  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    # 启发式：跳过明显非仓库内路径（纯 bash glob，不依赖 rg）
    case "$path" in
      /*|~*) continue ;;                # 绝对路径 / 用户全局
      *\<*|*\>*) continue ;;            # 含占位符
      *' '*|*'（'*|*'）'*|*'，'*) continue ;;  # 含空格 / 全角标点
      *[!A-Za-z0-9._/-]*) continue ;;   # 含其他非路径字符（含中文自由文本）
      */*/.*|*.md|*/*/*.md) ;;           # 像仓库内 .md 路径
      *) continue ;;                     # 不像路径的占位符（如 user-query）
    esac
    if [[ ! -e "$path" ]]; then
      echo "warn: missing skills_evidence path: $path (in $tmpl)" >&2
      tmpl_warn=1
    fi
  done < <(printf '%s\n' "$front_matter" | awk '
    /^skills_evidence:/ { f = 1; next }
    f && /^[A-Za-z0-9_.-]+:/ { exit }
    f && /^[[:space:]]*-[[:space:]]+/ { sub(/^[[:space:]]*-[[:space:]]+/, ""); print }
  ')

  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    case "$path" in
      /*|~*) continue ;;
      *\<*|*\>*) continue ;;
      *' '*|*'（'*|*'）'*|*'，'*) continue ;;
      *[!A-Za-z0-9._/-]*) continue ;;
      */*/.*|*.md|*/*/*.md) ;;
      *) continue ;;
    esac
    if [[ ! -e "$path" ]]; then
      echo "warn: missing source path: $path (in $tmpl)" >&2
      tmpl_warn=1
    fi
  done < <(printf '%s\n' "$front_matter" | awk '
    /^source:/ { f = 1; next }
    f && /^[A-Za-z0-9_.-]+:/ { exit }
    f && /^[[:space:]]*-[[:space:]]+/ { sub(/^[[:space:]]*-[[:space:]]+/, ""); print }
  ')
done
if [[ "$tmpl_warn" -eq 0 ]]; then
  echo "ok: artifact-templates FM paths"
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
bash -n "$(kit_path scripts/harness-project.sh)"

echo "==> Harness check complete"
