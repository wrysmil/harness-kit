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
  local src="$ADAPTERS_DIR/agents/.agents"
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

project_cursor() {
  local target_root="${1:-.}"
  local src="$ADAPTERS_DIR/cursor/.cursor"
  local count=0

  echo "==> 投影 Cursor 平台层: .cursor/"

  # rules
  if [[ -d "$src/rules" ]]; then
    mkdir -p "$target_root/.cursor/rules"
    for f in "$src/rules"/*.mdc; do
      [[ -f "$f" ]] || continue
      cp "$f" "$target_root/.cursor/rules/"
      count=$((count + 1))
    done
  fi

  # hooks
  if [[ -d "$src/hooks" ]]; then
    mkdir -p "$target_root/.cursor/hooks"
    for f in "$src/hooks"/*.sh; do
      [[ -f "$f" ]] || continue
      cp "$f" "$target_root/.cursor/hooks/"
      count=$((count + 1))
    done
    chmod +x "$target_root/.cursor/hooks/"*.sh 2>/dev/null || true
  fi

  # hooks.json.example
  [[ -f "$src/hooks.json.example" ]] && cp "$src/hooks.json.example" "$target_root/.cursor/" && count=$((count + 1))

  # skills (平台特有)
  if [[ -d "$src/skills" ]]; then
    for skill_dir in "$src/skills"/*/; do
      [[ -d "$skill_dir" ]] || continue
      local skill_name
      skill_name="$(basename "$skill_dir")"
      # 跳过空目录
      [[ -f "$skill_dir/SKILL.md" ]] || continue
      mkdir -p "$target_root/.cursor/skills/$skill_name"
      cp -R "$skill_dir"* "$target_root/.cursor/skills/$skill_name/"
      count=$((count + 1))
    done
  fi

  echo "   已投影 $count 项到 $target_root/.cursor/"
}

project_claude() {
  local target_root="${1:-.}"
  local src="$ADAPTERS_DIR/claude/.agents"
  local count=0

  echo "==> 投影 Claude 平台层"

  # Claude orchestration skill (合并到共享层)
  if [[ -d "$src/skills/claude-orchestration" ]]; then
    mkdir -p "$target_root/.agents/skills/claude-orchestration"
    cp -R "$src/skills/claude-orchestration/"* "$target_root/.agents/skills/claude-orchestration/"
    count=$((count + 1))
  fi

  echo "   已投影 $count 项"
}

project_trae() {
  local target_root="${1:-.}"
  local src="$ADAPTERS_DIR/trae"

  echo "==> 投影 Trae 平台层: .trae/"

  if [[ -d "$src" ]]; then
    mkdir -p "$target_root/.trae"
    # 当前 Trae 适配器为骨架，投影 README
    [[ -f "$src/README.md" ]] && cp "$src/README.md" "$target_root/.trae/"
    echo "   已投影 Trae 骨架（能力待定义）"
  else
    echo "   Trae 适配器不存在，跳过"
  fi
}

# ─── 主入口 ─────────────────────────────────────────────────

usage() {
  cat <<EOF
用法: harness-project.sh <命令> [选项]

命令:
  detect                     检测当前平台
  project [--platform P]     投影共享层 + 平台层（默认自动检测）
  shared                     仅投影共享层

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
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --platform) platform="$2"; shift 2 ;;
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

    # 共享层始终投影
    project_shared "$target_dir"

    # 平台层
    case "$platform" in
      cursor)  project_cursor "$target_dir" ;;
      claude)  project_claude "$target_dir" ;;
      trae)    project_trae "$target_dir" ;;
      all)
        project_cursor "$target_dir"
        project_claude "$target_dir"
        project_trae "$target_dir"
        ;;
      *)
        echo "未知平台: $platform" >&2
        exit 1
        ;;
    esac

    echo "==> 投影完成"
    ;;

  *)
    usage
    exit 1
    ;;
esac
