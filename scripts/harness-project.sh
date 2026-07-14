#!/usr/bin/env bash
# harness-project.sh — 平台检测 + 项目级目录投影
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 检测布局
if [[ -f "$KIT_ROOT/core/harness.md" ]]; then
  LAYOUT="source"
  ROOT_DIR="$KIT_ROOT"
  HK="."
elif [[ -f "$KIT_ROOT/harness-kit/core/harness.md" ]]; then
  LAYOUT="deployed"
  ROOT_DIR="$KIT_ROOT"
  HK="harness-kit"
else
  echo "错误: 无法检测 harness-kit 布局 ($KIT_ROOT)" >&2
  exit 1
fi

ADAPTERS_DIR="$KIT_ROOT/adapters"

# ─── 平台检测 ───────────────────────────────────────────────

detect_platform() {
  local platforms=()

  # 从当前工作目录检测（用户在项目根目录运行此脚本）
  local project_root
  project_root="$(pwd)"

  # 如果在 harness-kit 内部，往上找
  if [[ -f "$project_root/core/harness.md" ]] || [[ -f "$project_root/harness-kit/core/harness.md" ]]; then
    if [[ "$LAYOUT" == "deployed" ]]; then
      project_root="$ROOT_DIR"
    else
      project_root="$(cd "$ROOT_DIR/.." && pwd)"
    fi
  fi

  [[ -d "$project_root/.cursor" ]] && platforms+=("cursor")
  [[ -f "$project_root/CLAUDE.md" || -d "$project_root/.claude" ]] && platforms+=("claude")
  [[ -d "$project_root/.trae" ]] && platforms+=("trae")

  if [[ ${#platforms[@]} -eq 0 ]]; then
    echo "unknown"
  else
    # 返回第一个检测到的平台（主平台）
    echo "${platforms[0]}"
  fi
}

# ─── 投影函数 ───────────────────────────────────────────────

project_shared() {
  local target_root="${1:-.}"
  local src="$ROOT_DIR/$HK/.agents"
  local count=0

  echo "==> 投影共享层: .agents/"

  # skills
  if [[ -d "$src/skills" ]]; then
    mkdir -p "$target_root/.agents/skills"
    for skill_dir in "$src/skills"/*/; do
      [[ -d "$skill_dir" ]] || continue
      local skill_name
      skill_name="$(basename "$skill_dir")"
      cp -R "$skill_dir" "$target_root/.agents/skills/$skill_name"
      count=$((count + 1))
    done
    # 复制 _vendor-sources.yaml
    [[ -f "$src/skills/_vendor-sources.yaml" ]] && cp "$src/skills/_vendor-sources.yaml" "$target_root/.agents/skills/"
  fi

  # agents
  if [[ -d "$src/agents" ]]; then
    mkdir -p "$target_root/.agents/agents"
    for agent_file in "$src/agents"/*.md; do
      [[ -f "$agent_file" ]] || continue
      cp "$agent_file" "$target_root/.agents/agents/"
      count=$((count + 1))
    done
  fi

  # README
  [[ -f "$src/README.md" ]] && cp "$src/README.md" "$target_root/.agents/"

  echo "   已投影 $count 项到 $target_root/.agents/"
}

project_hooks() {
  local target_root="${1:-.}"
  local platform="${2:-}"
  local ext_root="$KIT_ROOT/core/extensions/hooks"

  if [[ ! -d "$ext_root" ]] || [[ -z "$platform" ]]; then
    return 0
  fi

  case "$platform" in
    cursor)
      mkdir -p "$target_root/.cursor/hooks/content"
      cp "$ext_root/content/session-init.md"     "$target_root/.cursor/hooks/content/"
      cp "$ext_root/content/subagent-stop.md"    "$target_root/.cursor/hooks/content/"
      cp "$ext_root/scripts/cursor/harness-session-init.sh"     "$target_root/.cursor/hooks/"
      cp "$ext_root/scripts/cursor/harness-subagent-stop.sh"    "$target_root/.cursor/hooks/"
      chmod +x "$target_root/.cursor/hooks/harness-"*.sh 2>/dev/null || true

      cat > "$target_root/.cursor/hooks.json.example" <<'EOF'
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      { "command": ".cursor/hooks/harness-session-init.sh" }
    ],
    "subagentStop": [
      { "command": ".cursor/hooks/harness-subagent-stop.sh" }
    ]
  }
}
EOF
      echo "   已投影 hooks 脚本 + content + hooks.json.example 到 .cursor/hooks/"
      ;;

    claude)
      mkdir -p "$target_root/.claude/hooks/content"
      cp "$ext_root/content/session-init.md"     "$target_root/.claude/hooks/content/"
      cp "$ext_root/content/subagent-stop.md"    "$target_root/.claude/hooks/content/"
      cp "$ext_root/content/block-native-plan-mode.md" "$target_root/.claude/hooks/content/" 2>/dev/null || true
      cp "$ext_root/scripts/claude/harness-session-init.sh"     "$target_root/.claude/hooks/"
      cp "$ext_root/scripts/claude/harness-subagent-stop.sh"    "$target_root/.claude/hooks/"
      cp "$ext_root/scripts/claude/block-native-plan-mode.sh"   "$target_root/.claude/hooks/" 2>/dev/null || true
      chmod +x "$target_root/.claude/hooks/harness-"*.sh 2>/dev/null || true
      chmod +x "$target_root/.claude/hooks/block-native-plan-mode.sh" 2>/dev/null || true

      cat > "$target_root/.claude/settings.json.example" <<'EOF'
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/harness-session-init.sh" }
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": "*",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/harness-subagent-stop.sh" }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "EnterPlanMode|ExitPlanMode",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/block-native-plan-mode.sh" }
        ]
      }
    ]
  },
  "permissions": {
    "allow": [],
    "deny": []
  }
}
EOF
      echo "   已投影 hooks 脚本 + content + settings.json.example 到 .claude/（含 PreToolUse 阻断原生 plan）"
      ;;
  esac
}

project_platform_skills() {
  local target_root="$1"
  local platform_dir="$2"
  local force="${3:-0}"
  local src="$KIT_ROOT/.agents"
  local added=0
  local skipped=0

  if [[ ! -d "$src" ]]; then
    return 0
  fi

  # skills（共享层 → 平台层 mirror）
  if [[ -d "$src/skills" ]]; then
    mkdir -p "$target_root/$platform_dir/skills"
    for skill_dir in "$src/skills"/*/; do
      [[ -d "$skill_dir" ]] || continue
      [[ -f "$skill_dir/SKILL.md" ]] || continue
      local skill_name
      skill_name="$(basename "$skill_dir")"
      if [[ "$force" != "1" && -f "$target_root/$platform_dir/skills/$skill_name/SKILL.md" ]]; then
        echo "   skip: $platform_dir/skills/$skill_name（已存在，--force 覆盖）"
        skipped=$((skipped + 1))
        continue
      fi
      mkdir -p "$target_root/$platform_dir/skills/$skill_name"
      cp -R "$skill_dir"* "$target_root/$platform_dir/skills/$skill_name/"
      added=$((added + 1))
    done
  fi

  if [[ "$added" -gt 0 || "$skipped" -gt 0 ]]; then
    echo "   $platform_dir/skills: +$added 跳过 $skipped"
  fi
}

project_mcp() {
  local target_root="${1:-.}"
  local mcp_template="$KIT_ROOT/core/extensions/mcp/mcp.servers.template.json"
  local target_mcp="$target_root/.mcp.json"

  if [[ ! -f "$mcp_template" ]]; then
    return 0
  fi

  if [[ -f "$target_mcp" ]]; then
    echo "   .mcp.json 已存在，跳过（避免覆盖用户配置）"
    return 0
  fi

  cp "$mcp_template" "$target_mcp"
  echo "   已投影 .mcp.json（mcpServers: {}，按需编辑）"
}

project_cursor() {
  local target_root="${1:-.}"
  local force="${2:-0}"
  local src="$ADAPTERS_DIR/cursor/.cursor"
  local added=0
  local skipped=0

  echo "==> 投影 Cursor 平台层: .cursor/"

  # 共享层迁移后的残留清理：旧版 cursor 适配器把 agents 放在 .cursor/agents/，
  # 新版已统一到 .agents/agents/（共享层），这里一次性清掉。
  if [[ -d "$target_root/.cursor/agents" ]]; then
    rm -rf "$target_root/.cursor/agents"
    echo "   已清理残留 .cursor/agents/（旧版 cursor 平台层 agents 已迁到共享层）"
  fi

  # rules（用户可定制：默认 skip-if-exists，--force 覆盖）
  if [[ -d "$src/rules" ]]; then
    mkdir -p "$target_root/.cursor/rules"
    for f in "$src/rules"/*.mdc; do
      [[ -f "$f" ]] || continue
      local name
      name="$(basename "$f")"
      if [[ "$force" != "1" && -f "$target_root/.cursor/rules/$name" ]]; then
        echo "   skip: .cursor/rules/$name（已存在，--force 覆盖）"
        skipped=$((skipped + 1))
        continue
      fi
      cp "$f" "$target_root/.cursor/rules/"
      added=$((added + 1))
    done
  fi

  # skills（共享层 → 平台层 mirror）
  project_platform_skills "$target_root" ".cursor" "$force"

  # hooks（从 core/extensions 投影；脚本 + content + config 示例，非用户文件，始终覆盖）
  project_hooks "$target_root" "cursor"

  echo "   已投影 $added 项到 $target_root/.cursor/（含 hooks 扩展），跳过 $skipped 项"
}

project_claude() {
  local target_root="${1:-.}"
  local force="${2:-0}"
  local claude_src="$ROOT_DIR/$HK/.claude"
  local added=0
  local skipped=0

  echo "==> 投影 Claude 平台层: .claude/"

  # rules（用户可定制：默认 skip-if-exists，--force 覆盖；与 .cursor/rules/ 对齐）
  if [[ -d "$claude_src/rules" ]]; then
    mkdir -p "$target_root/.claude/rules"
    for f in "$claude_src/rules"/*.md; do
      [[ -f "$f" ]] || continue
      local name
      name="$(basename "$f")"
      if [[ "$force" != "1" && -f "$target_root/.claude/rules/$name" ]]; then
        echo "   skip: .claude/rules/$name（已存在，--force 覆盖）"
        skipped=$((skipped + 1))
        continue
      fi
      cp "$f" "$target_root/.claude/rules/"
      added=$((added + 1))
    done
  fi

  # skills（共享层 → 平台层 mirror）
  project_platform_skills "$target_root" ".claude" "$force"

  # hooks（从 core/extensions 投影；脚本 + content + settings.json.example）
  project_hooks "$target_root" "claude"

  echo "   已投影 $added 项到 $target_root/.claude/rules/（+ hooks 扩展），跳过 $skipped 项"
}

project_trae() {
  local target_root="${1:-.}"
  local force="${2:-0}"
  local src="$ADAPTERS_DIR/trae"
  local trae_src="$src/.trae"
  local ext_root="$ROOT_DIR/core/extensions/hooks"
  local added=0
  local skipped=0

  echo "==> 投影 Trae 平台层: .trae/"

  if [[ ! -d "$src" ]]; then
    echo "   Trae 适配器不存在，跳过"
    return 1
  fi

  mkdir -p "$target_root/.trae"

  # rules（用户可定制：默认 skip-if-exists，--force 覆盖）
  if [[ -d "$trae_src/rules" ]]; then
    mkdir -p "$target_root/.trae/rules"
    for f in "$trae_src/rules"/*.md; do
      [[ -f "$f" ]] || continue
      local name
      name="$(basename "$f")"
      if [[ "$force" != "1" && -f "$target_root/.trae/rules/$name" ]]; then
        echo "   skip: .trae/rules/$name（已存在，--force 覆盖）"
        skipped=$((skipped + 1))
        continue
      fi
      cp "$f" "$target_root/.trae/rules/"
      added=$((added + 1))
    done
  fi

  # skills（共享层 → 平台层 mirror）
  project_platform_skills "$target_root" ".trae" "$force"

  # hooks（从 core/extensions 投影；脚本 + content + settings.json.example）
  if [[ -d "$ext_root" ]]; then
    mkdir -p "$target_root/.trae/hooks/content"
    cp "$ext_root/content/session-init.md"     "$target_root/.trae/hooks/content/"
    cp "$ext_root/content/subagent-stop.md"   "$target_root/.trae/hooks/content/"
    cp "$ext_root/scripts/trae/harness-session-init.sh"     "$target_root/.trae/hooks/"
    cp "$ext_root/scripts/trae/harness-subagent-stop.sh"   "$target_root/.trae/hooks/"
    chmod +x "$target_root/.trae/hooks/harness-"*.sh 2>/dev/null || true

    cat > "$target_root/.trae/settings.json.example" <<'EOF'
{
  "hooks": {
    "sessionStart": [
      { "command": ".trae/hooks/harness-session-init.sh" }
    ],
    "subagentStop": [
      { "command": ".trae/hooks/harness-subagent-stop.sh" }
    ]
  }
}
EOF
    echo "   已投影 hooks 脚本 + content + settings.json.example 到 .trae/"
  fi

  echo "   已投影 $added 项到 $target_root/.trae/rules/（+ hooks 扩展），跳过 $skipped 项"
}

# ─── 主入口 ─────────────────────────────────────────────────

usage() {
  cat <<EOF
用法: harness-project.sh <命令> [选项]

命令:
  detect                              检测当前平台
  project [--platform P] [--force]    投影共享层 + 平台层（默认自动检测）
                                      --force 覆盖已存在的 cursor rules/skills（默认 skip-if-exists）
  shared                              仅投影共享层

平台: cursor, claude, trae, all
EOF
}

cmd="${1:-}"
shift || true

case "$cmd" in
  detect)
    platform="$(detect_platform)"
    echo "$platform"
    ;;

  shared)
    project_shared "$ROOT_DIR"
    ;;

  project)
    platform=""
    force=0
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --platform) platform="$2"; shift 2 ;;
        --force) force=1; shift ;;
        *) echo "未知选项: $1" >&2; exit 1 ;;
      esac
    done

    if [[ -z "$platform" ]]; then
      platform="$(detect_platform)"
      echo "自动检测平台: $platform"
    fi

    if [[ "$platform" == "unknown" ]]; then
      echo "无法自动检测平台。请用 --platform 指定: cursor, claude, trae, all" >&2
      exit 1
    fi

    # 投影目标：当前工作目录（用户项目根）
    target_dir="$(pwd)"

    # MCP 投影（所有平台共用，标准 .mcp.json；用户已有则跳过）
    project_mcp "$target_dir"

    # 平台层
    case "$platform" in
      cursor)  project_cursor "$target_dir" "$force" ;;
      claude)  project_claude "$target_dir" "$force" ;;
      trae)    project_trae "$target_dir" "$force" ;;
      all)
        project_cursor "$target_dir" "$force"
        project_claude "$target_dir" "$force"
        project_trae "$target_dir" "$force"
        ;;
      *)
        echo "未知平台: $platform" >&2
        exit 1
        ;;
    esac

    echo "==> 投影完成"
    echo

    # 根据实际投影的平台显示检查清单
    case "$platform" in
      cursor)
        echo "==> ✅ Cursor 平台层预期文件清单（缺失即投影失败）："
        echo "    [rules]   $(test -f "$target_dir/.cursor/rules/ai-entry.mdc" && echo "OK .cursor/rules/ai-entry.mdc" || echo "MISSING .cursor/rules/ai-entry.mdc")"
        _rules_count="$(ls "$target_dir/.cursor/rules/"*.mdc 2>/dev/null | wc -l | tr -d ' ')"
        echo "    [rules]   共 ${_rules_count} 个 .mdc"
        echo "    [hooks]   $(test -x "$target_dir/.cursor/hooks/harness-session-init.sh" && echo "OK harness-session-init.sh" || echo "MISSING harness-session-init.sh")"
        echo "    [hooks]   $(test -x "$target_dir/.cursor/hooks/harness-subagent-stop.sh" && echo "OK harness-subagent-stop.sh" || echo "MISSING harness-subagent-stop.sh")"
        echo "    [hooks]   $(test -f "$target_dir/.cursor/hooks.json.example" && echo "OK hooks.json.example" || echo "MISSING hooks.json.example")"
        ;;
      claude)
        echo "==> ✅ Claude 平台层预期文件清单（缺失即投影失败）："
        echo "    [rules]   $(test -f "$target_dir/.claude/rules/ai-entry.md" && echo "OK .claude/rules/ai-entry.md" || echo "MISSING .claude/rules/ai-entry.md")"
        _rules_count="$(ls "$target_dir/.claude/rules/"*.md 2>/dev/null | wc -l | tr -d ' ')"
        echo "    [rules]   共 ${_rules_count} 个 .md（应 ≥1）"
        _skills_count="$(ls -d "$target_dir/.claude/skills/"*/ 2>/dev/null | wc -l | tr -d ' ')"
        echo "    [skills]  共 ${_skills_count} 个 skill"
        echo "    [hooks]   $(test -x "$target_dir/.claude/hooks/harness-session-init.sh" && echo "OK harness-session-init.sh" || echo "MISSING harness-session-init.sh")"
        echo "    [hooks]   $(test -x "$target_dir/.claude/hooks/harness-subagent-stop.sh" && echo "OK harness-subagent-stop.sh" || echo "MISSING harness-subagent-stop.sh")"
        echo "    [hooks]   $(test -f "$target_dir/.claude/settings.json.example" && echo "OK settings.json.example" || echo "MISSING settings.json.example")"
        ;;
      trae)
        echo "==> ✅ Trae 平台层预期文件清单（缺失即投影失败）："
        echo "    [rules]   $(test -f "$target_dir/.trae/rules/ai-entry.md" && echo "OK .trae/rules/ai-entry.md" || echo "MISSING .trae/rules/ai-entry.md")"
        echo "    [rules]   $(test -f "$target_dir/.trae/rules/trae-subagent-routing.md" && echo "OK .trae/rules/trae-subagent-routing.md" || echo "MISSING .trae/rules/trae-subagent-routing.md")"
        _rules_count="$(ls "$target_dir/.trae/rules/"*.md 2>/dev/null | wc -l | tr -d ' ')"
        echo "    [rules]   共 ${_rules_count} 个 .md（应 ≥2）"
        _skills_count="$(ls -d "$target_dir/.trae/skills/"*/ 2>/dev/null | wc -l | tr -d ' ')"
        echo "    [skills]  共 ${_skills_count} 个 skill"
        echo "    [hooks]   $(test -x "$target_dir/.trae/hooks/harness-session-init.sh" && echo "OK harness-session-init.sh" || echo "MISSING harness-session-init.sh")"
        echo "    [hooks]   $(test -x "$target_dir/.trae/hooks/harness-subagent-stop.sh" && echo "OK harness-subagent-stop.sh" || echo "MISSING harness-subagent-stop.sh")"
        echo "    [hooks]   $(test -f "$target_dir/.trae/settings.json.example" && echo "OK settings.json.example" || echo "MISSING settings.json.example")"
        ;;
      all)
        echo "==> ✅ Cursor 平台层："
        echo "    [rules]   $(test -f "$target_dir/.cursor/rules/ai-entry.mdc" && echo "OK" || echo "MISSING") .cursor/rules/ai-entry.mdc"
        echo "    [skills]  $(ls -d "$target_dir/.cursor/skills/"*/ 2>/dev/null | wc -l | tr -d ' ') 个 skill"
        echo "    [hooks]   $(test -x "$target_dir/.cursor/hooks/harness-session-init.sh" && echo "OK" || echo "MISSING") harness-session-init.sh"
        echo "==> ✅ Claude 平台层："
        echo "    [rules]   $(test -f "$target_dir/.claude/rules/ai-entry.md" && echo "OK" || echo "MISSING") .claude/rules/ai-entry.md"
        echo "    [skills]  $(ls -d "$target_dir/.claude/skills/"*/ 2>/dev/null | wc -l | tr -d ' ') 个 skill"
        echo "    [hooks]   $(test -f "$target_dir/.claude/settings.json.example" && echo "OK" || echo "MISSING") settings.json.example"
        echo "==> ✅ Trae 平台层："
        echo "    [rules]   $(test -f "$target_dir/.trae/rules/ai-entry.md" && echo "OK" || echo "MISSING") .trae/rules/ai-entry.md"
        echo "    [rules]   $(test -f "$target_dir/.trae/rules/trae-subagent-routing.md" && echo "OK" || echo "MISSING") .trae/rules/trae-subagent-routing.md"
        echo "    [skills]  $(ls -d "$target_dir/.trae/skills/"*/ 2>/dev/null | wc -l | tr -d ' ') 个 skill"
        echo "    [hooks]   $(test -f "$target_dir/.trae/settings.json.example" && echo "OK" || echo "MISSING") settings.json.example"
        ;;
    esac

    echo
    echo "==> 复制以下 3 行到 init 后的回复中（AI 必读）："
    echo "    1) 检测到平台: $platform"
    echo "    2) 平台层投影完成（skills + rules + hooks）"
    echo "    3) 运行 'bash harness-kit/scripts/harness-project.sh project --platform $platform --force' 可强制覆盖"
    ;;

  *)
    usage
    exit 1
    ;;
esac
