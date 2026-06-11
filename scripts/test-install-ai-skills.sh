#!/usr/bin/env bash
# 测试 install-ai-skills.sh 的平台分发
set -uo pipefail
KIT=/d/workspace/ai/harness-kit

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# 准备 fake HOME，两个 skill 已装
mkdir -p "$tmp/home/.claude/skills/verification-before-completion"
mkdir -p "$tmp/home/.claude/skills/git-xywh"
echo stub > "$tmp/home/.claude/skills/verification-before-completion/SKILL.md"
echo stub > "$tmp/home/.claude/skills/git-xywh/SKILL.md"

# stub npm/omx 避免真装
mkdir -p "$tmp/bin"
cat > "$tmp/bin/npm" <<'EOF'
#!/usr/bin/env bash
echo "(stub npm)"
exit 0
EOF
cat > "$tmp/bin/omx" <<'EOF'
#!/usr/bin/env bash
echo "(stub omx: $*)"
exit 0
EOF
chmod +x "$tmp/bin/npm" "$tmp/bin/omx"

export HOME="$tmp/home"
export PATH="$tmp/bin:$PATH"

pass=0
fail=0
check() {
  local name="$1"
  local cond="$2"
  if eval "$cond"; then
    echo "PASS: $name"
    pass=$((pass+1))
  else
    echo "FAIL: $name"
    fail=$((fail+1))
  fi
}

echo "=== 1. claude path: 1 superpowers skill pre-installed ==="
mkdir -p "$tmp/sb1/.claude"
cd "$tmp/sb1"
out=$(bash "$KIT/scripts/install-ai-skills.sh" --platform claude 2>&1)
echo "$out" | grep -q "目标平台: claude" && check "claude detected" true || check "claude detected" false
echo "$out" | grep -q "ok: .*verification-before-completion/SKILL.md" && check "pre-installed skill marked ok" true || check "pre-installed skill marked ok" false
echo "$out" | grep -q "missing: brainstorming" && check "other superpowers still missing" true || check "other superpowers still missing" false
echo "$out" | grep -q "==> AI skills 安装/检查完成" && check "reached final echo" true || check "reached final echo" false

echo ""
echo "=== 2. cursor path: no skills, only check (no npm/omx call) ==="
mkdir -p "$tmp/sb2/.cursor"
cd "$tmp/sb2"
out=$(bash "$KIT/scripts/install-ai-skills.sh" --platform cursor 2>&1)
echo "$out" | grep -q "目标平台: cursor" && check "cursor detected" true || check "cursor detected" false
echo "$out" | grep -q "cursor path: ~/.cursor/skills/" && check "cursor path only" true || check "cursor path only" false
echo "$out" | grep -q "Installing" && check "FAIL: no npm install" false || check "PASS: no npm install" true
echo "$out" | grep -q "==> AI skills 安装/检查完成" && check "reached final echo" true || check "reached final echo" false

echo ""
echo "=== 3. trae path ==="
mkdir -p "$tmp/sb3/.trae"
cd "$tmp/sb3"
out=$(bash "$KIT/scripts/install-ai-skills.sh" --platform trae 2>&1)
echo "$out" | grep -q "trae path: ~/.trae/skills/" && check "trae path" true || check "trae path" false
echo "$out" | grep -q "==> AI skills 安装/检查完成" && check "reached final echo" true || check "reached final echo" false

echo ""
echo "=== 4. codex auto-detect via .codex marker (stub npm/omx) ==="
mkdir -p "$tmp/sb4/.codex"
cd "$tmp/sb4"
out=$(bash "$KIT/scripts/install-ai-skills.sh" 2>&1)
echo "$out" | grep -q "目标平台: codex" && check "codex auto-detected" true || check "codex auto-detected" false
echo "$out" | grep -q "Installing oh-my-codex" && check "npm install called" true || check "npm install called" false
echo "$out" | grep -q "omx setup" && check "omx setup called" true || check "omx setup called" false
echo "$out" | grep -q "omx doctor" && check "omx doctor called" true || check "omx doctor called" false
echo "$out" | grep -q "==> AI skills 安装/检查完成" && check "reached final echo" true || check "reached final echo" false

echo ""
echo "=== 5. unknown platform with no omx on PATH → fail ==="
mkdir -p "$tmp/sb5"
cd "$tmp/sb5"
# 用最小 PATH 排除 omx 软信号
out=$(env -i HOME="$HOME" PATH="/usr/bin:/bin" bash "$KIT/scripts/install-ai-skills.sh" 2>&1 || true)
echo "$out" | grep -q "无法自动检测平台" && check "error message shown" true || check "error message shown" false

echo ""
echo "=== 6. unknown platform with omx on PATH → codex soft signal ==="
# Put fake omx in PATH so the soft-signal kicks in
mkdir -p "$tmp/sb6"
cd "$tmp/sb6"
out=$(PATH="$tmp/bin:$PATH" bash "$KIT/scripts/install-ai-skills.sh" 2>&1)
echo "$out" | grep -q "目标平台: codex" && check "omx-soft-signal → codex" true || check "omx-soft-signal → codex" false

echo ""
echo "=== 7. --platform codex with STRICT_SUPERPOWERS=1, missing → exit 2 ==="
mkdir -p "$tmp/sb7/.codex"
cd "$tmp/sb7"
export STRICT_SUPERPOWERS=1
set +e
out=$(bash "$KIT/scripts/install-ai-skills.sh" --platform codex 2>&1)
ec=$?
set -e
echo "$out" | grep -q "missing: brainstorming" && check "missing reported" true || check "missing reported" false
check "exit code is 2" "[ $ec -eq 2 ]"

echo ""
echo "============================================="
echo "Passed: $pass  Failed: $fail"
[ $fail -eq 0 ]
