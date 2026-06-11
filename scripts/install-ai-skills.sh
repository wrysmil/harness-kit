#!/usr/bin/env bash
# 按当前平台选择性安装/检查 AI runtime 与 skill。
# codex: npm install -g oh-my-codex + omx setup/doctor + ~/.agents/skills/ 检查
# cursor: ~/.cursor/skills/ 检查
# claude: ~/.claude/skills/ 检查
# trae:   ~/.trae/skills/   检查
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PLATFORM=""
OH_MY_CODEX_PACKAGE="${OH_MY_CODEX_PACKAGE:-oh-my-codex}"

SUPERPOWERS_SKILLS=(brainstorming writing-plans systematic-debugging test-driven-development verification-before-completion)
ORG_SKILLS=(git-xywh)

usage() {
  cat <<'EOF'
用法: install-ai-skills.sh [--platform P]

平台: codex, cursor, claude, trae
默认: 自动检测（harness-project.sh detect；unknown 时回退到 `command -v omx`）

环境变量:
  STRICT_SUPERPOWERS=1   缺 superpowers skill 时退出码 2
  STRICT_ORG_SKILLS=1    缺 org skill（git-xywh）时退出码 2
  OH_MY_CODEX_PACKAGE    自定义 npm 包名（默认 oh-my-codex）
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform) PLATFORM="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知选项: $1" >&2; usage; exit 1 ;;
  esac
done

# ─── 平台检测 ───────────────────────────────────────────────

if [[ -z "$PLATFORM" ]]; then
  PLATFORM="$(bash "$SCRIPT_DIR/harness-project.sh" detect 2>/dev/null || echo unknown)"
  # 软信号: 装了 omx 但没项目标记 → 视为 codex（首次安装 codex runtime 的场景）
  if [[ "$PLATFORM" == "unknown" ]] && command -v omx >/dev/null 2>&1; then
    PLATFORM="codex"
  fi
fi

if [[ -z "$PLATFORM" || "$PLATFORM" == "unknown" ]]; then
  echo "无法自动检测平台，请用 --platform 指定: codex, cursor, claude, trae" >&2
  exit 1
fi

echo "==> 目标平台: $PLATFORM"

# ─── 公共: skill 存在性检查 ─────────────────────────────────

check_skill_set() {
  local set_name="$1"
  local search_dir="$2"
  shift 2
  local skills=("$@")
  local missing=0

  for skill in "${skills[@]}"; do
    if [[ -f "$search_dir/$skill/SKILL.md" ]]; then
      echo "ok: $search_dir/$skill/SKILL.md"
    else
      echo "missing: $skill"
      missing=1
    fi
  done

  [[ "$missing" -eq 0 ]] && return 0

  case "$set_name" in
    superpowers)
      cat <<'MSG' >&2

Some superpowers skills are missing. Install via:
  npx skills add obra/superpowers -g
MSG
      if [[ "${STRICT_SUPERPOWERS:-0}" == "1" ]]; then
        exit 2
      fi
      ;;
    org)
      cat <<MSG >&2

Organization skill git-xywh is missing. Install per team docs (slug: git-xywh), e.g. into:
  $search_dir/git-xywh/SKILL.md

Until installed, Git tasks must still read harness-kit/project.git.md and follow repo hooks/CI;
Harness routing expects Leader to invoke git-xywh before commit / branch / MR.
MSG
      if [[ "${STRICT_ORG_SKILLS:-0}" == "1" ]]; then
        exit 2
      fi
      ;;
  esac
}

# ─── codex: npm + omx + skill 检查 ─────────────────────────

install_codex() {
  echo "==> Installing ${OH_MY_CODEX_PACKAGE} globally"
  if ! npm install -g "$OH_MY_CODEX_PACKAGE"; then
    cat <<'MSG' >&2

Failed to install oh-my-codex.

Check npm registry access and permissions, then rerun:
  bash harness-kit/scripts/install-ai-skills.sh
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
  bash harness-kit/scripts/install-ai-skills.sh
MSG
    exit 1
  fi

  echo "==> Running omx doctor"
  if ! omx doctor; then
    cat <<'MSG' >&2

`omx doctor` reported problems. Fix the reported issues, then rerun:
  bash harness-kit/scripts/install-ai-skills.sh
MSG
    exit 1
  fi

  echo "==> Checking superpowers skills (codex path: ~/.agents/skills/)"
  check_skill_set superpowers "$HOME/.agents/skills" "${SUPERPOWERS_SKILLS[@]}"
  echo "==> Checking organization skills (git-xywh)"
  check_skill_set org "$HOME/.agents/skills" "${ORG_SKILLS[@]}"
}

# ─── 其他平台: 只做 skill 存在性检查 ───────────────────────

check_cursor() {
  echo "==> Checking skills (cursor path: ~/.cursor/skills/)"
  check_skill_set superpowers "$HOME/.cursor/skills" "${SUPERPOWERS_SKILLS[@]}"
  check_skill_set org "$HOME/.cursor/skills" "${ORG_SKILLS[@]}"
}

check_claude() {
  echo "==> Checking skills (claude path: ~/.claude/skills/)"
  check_skill_set superpowers "$HOME/.claude/skills" "${SUPERPOWERS_SKILLS[@]}"
  check_skill_set org "$HOME/.claude/skills" "${ORG_SKILLS[@]}"
}

check_trae() {
  echo "==> Checking skills (trae path: ~/.trae/skills/)"
  check_skill_set superpowers "$HOME/.trae/skills" "${SUPERPOWERS_SKILLS[@]}"
  check_skill_set org "$HOME/.trae/skills" "${ORG_SKILLS[@]}"
}

# ─── 分发 ──────────────────────────────────────────────────

case "$PLATFORM" in
  codex)  install_codex ;;
  cursor) check_cursor ;;
  claude) check_claude ;;
  trae)   check_trae ;;
  *)
    echo "未知平台: $PLATFORM" >&2
    exit 1
    ;;
esac

echo "==> AI skills 安装/检查完成（平台: $PLATFORM）"
