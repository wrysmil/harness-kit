---
artifact: implementation-plan
route: superpowers:writing-plans
skills:
  - writing-plans
skills_evidence:
  - ~/.agents/skills/writing-plans/SKILL.md
dispatch: .ai-runtime-artifacts/plans/2026-05-28-cursor-worktree-isolation-dispatch.md
source:
  - docs/superpowers/specs/2026-05-28-cursor-git-worktree-isolation-for-subagents-design.md
  - harness-kit/adapters/cursor/orchestration/dispatcher-workflow.md
  - harness-kit/core/routing.md
created_at: 2026-05-28
platform: cursor
---

# Cursor 子 Agent Git worktree 隔离 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 Cursor 并行编排中引入“每个 coder WU 一个 Git worktree”的物理隔离，使 WU 级回滚变成“删 worktree 即回滚”，并通过中文标题字段保证人类可读。

**Architecture:** Leader 在派发同一轮 2+ 个 `coder` WU 时，为每个 WU 创建独立 worktree + 分支，子 Agent 只在该路径内读写；WU 完成后由 Leader 选择 merge/cherry-pick 整合回集成分支，最后仍走既有尾盘集体测试/审查门禁。

**Tech Stack:** Git worktree、Cursor `.cursor/agents/*` 派发、harness-kit `cursor-orchestration` 文档与模板。

**TDD Required:** YES (every task follows RED-GREEN-REFACTOR)

---

## 文件结构（将要改动/新增的文件）

**Modify:**
- `harness-kit/adapters/cursor/orchestration/dispatcher-workflow.md`（把 “Worktree 拆分”补充为“逻辑 WU + 物理 git worktree”）
- `harness-kit/artifact-templates/dispatch.harness-overlay.md`（执行图字段：`wu_title_zh`/`worktree_path`/`branch`/`workspace_scope`）
- `harness-kit/artifact-templates/dispatch-track.md`（日志条目中建议记录 worktree 创建/删除/整合事实）
- `harness-kit/adapters/cursor/orchestration/tracking/schema.md`（补充可选字段约定：worktree_path/branch/中文标题）
- （可选）`harness-kit/adapters/cursor/orchestration/agents/leader.md`（明确派发 prompt 必含 worktree 约束）

**Create:**
- `harness-kit/scripts/harness-worktree.sh`（worktree 创建/清理/列表的小工具，供 Leader 在派发前调用）
- `harness-kit/scripts/harness-worktree.test.sh`（无依赖 shell 测试：验证命名、忽略、创建/删除行为）

**Modify（仓库卫生，已做）:**
- `.gitignore`（包含 `.worktrees/`）

---

## Task 1: 定义执行图字段与追踪字段（文档/模板）

**Files:**
- Modify: `artifact-templates/dispatch.harness-overlay.md`
- Modify: `adapters/cursor/orchestration/dispatcher-workflow.md`
- Modify: `adapters/cursor/orchestration/tracking/schema.md`
- Modify: `artifact-templates/dispatch-track.md`

- [ ] **Step 1: Write the failing test**

新增一个 shell 测试文件来“锁定字段存在”（把模板/文档当作可测试输入），先写一个会失败的断言：

Create `scripts/harness-worktree.test.sh`（先只写最小失败用例）：

```bash
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
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
bash harness-kit/scripts/harness-worktree.test.sh
```

Expected: FAIL（因为这些字段尚未写入模板）。

- [ ] **Step 3: Write minimal implementation**

按 spec 把字段加到以下文件（最小可用）：

1) `artifact-templates/dispatch.harness-overlay.md` 的 WU 示例行升级为：

```markdown
WU-01: <描述> | 标题: <wu_title_zh> | 文件: a.ts, b.ts | 依赖: 无 | wu_type: feature | workspace_scope: wu|none | worktree_path: <path or n/a> | branch: <branch or n/a>
```

2) `dispatcher-workflow.md` 的步骤 1 明确：
- “2+ coder WU 同轮派发 ⇒ 强制 worktree”
- “默认仅 coder WU 启用；单 WU 默认不建（除非覆盖）”
- “中文可读：`wu_title_zh` 必填”

3) `tracking/schema.md` 的 DISPATCH 专用字段增加可选项：

```text
Worktree: <path or n/a> | Branch: <name or n/a> | Title(zh): <...>
```

4) `dispatch-track.md` 的示例条目补充（可选字段）：

```text
Detail: 创建 WU-02 worktree（修复可回滚）
Output: .worktrees/2026-05-28--...__WU-02__...__coder
```

- [ ] **Step 4: Run test to verify it passes**

Run:

```bash
bash harness-kit/scripts/harness-worktree.test.sh
```

Expected: PASS。

- [ ] **Step 5: Commit**

```bash
git add artifact-templates/dispatch.harness-overlay.md \
  adapters/cursor/orchestration/dispatcher-workflow.md \
  adapters/cursor/orchestration/tracking/schema.md \
  artifact-templates/dispatch-track.md \
  scripts/harness-worktree.test.sh
git commit -m "docs(harness-kit): add worktree fields to dispatch and tracking"
```

---

## Task 2: 实现 worktree 管理脚本（创建/清理/列表）

**Files:**
- Create: `scripts/harness-worktree.sh`
- Test: `scripts/harness-worktree.test.sh`

- [ ] **Step 1: Write the failing test**

为脚本行为写测试（先失败），覆盖 happy/edge/error：

在 `scripts/harness-worktree.test.sh` 追加：

```bash
# --- worktree tool tests ---

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

# Ensure .worktrees ignored
echo ".worktrees/" >> "$repo/.gitignore"
git -C "$repo" add .gitignore
git -C "$repo" commit -qm "ignore worktrees"

tool="$PWD/harness-kit/scripts/harness-worktree.sh"

# Error case: missing required args
if "$tool" create >/dev/null 2>&1; then
  fail "expected create to fail without args"
fi

# Happy path: create a worktree
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

# Edge: idempotency (should not create duplicate)
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

# Happy path: remove worktree
"$tool" remove --repo "$repo" --worktree "$wt" >/dev/null
[ ! -d "$wt" ] || fail "worktree dir still exists after remove"
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
bash harness-kit/scripts/harness-worktree.test.sh
```

Expected: FAIL（脚本不存在/未实现）。

- [ ] **Step 3: Write minimal implementation**

实现 `scripts/harness-worktree.sh`，最小 CLI：

- `create`：根据命名规范计算路径与分支名，执行 `git worktree add`（并验证 `.worktrees/` 被 ignore；否则报错）
- `remove`：执行 `git worktree remove -f <path>`
- `list`：列出 repo 下 `.worktrees/` 子目录与对应分支（尽力即可）

必须满足的错误处理：
- 参数缺失 → 非 0 退出码 + 可读错误
- worktree 已存在 → 非 0（避免覆盖）
- `.worktrees/` 未被 ignore → 非 0（防污染仓库）

- [ ] **Step 4: Run test to verify it passes**

Run:

```bash
bash harness-kit/scripts/harness-worktree.test.sh
```

Expected: PASS。

- [ ] **Step 5: Commit**

```bash
git add scripts/harness-worktree.sh scripts/harness-worktree.test.sh
git commit -m "feat(harness-kit): add git worktree helper script"
```

---

## Task 3: 把“2+ coder WU ⇒ 强制 worktree”的规则写入 Leader/编排文档

**Files:**
- Modify: `adapters/cursor/orchestration/dispatcher-workflow.md`
- (Optional) Modify: `adapters/cursor/orchestration/agents/leader.md`

- [ ] **Step 1: Write the failing test**

在 `scripts/harness-worktree.test.sh` 增加对规则文本的断言（先失败）：

```bash
must_contain "adapters/cursor/orchestration/dispatcher-workflow.md" "2 个及以上"
must_contain "adapters/cursor/orchestration/dispatcher-workflow.md" "coder"
must_contain "adapters/cursor/orchestration/dispatcher-workflow.md" "worktree"
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
bash harness-kit/scripts/harness-worktree.test.sh
```

Expected: FAIL。

- [ ] **Step 3: Write minimal implementation**

在 `dispatcher-workflow.md` “步骤 1：Worktree 拆分”小节下补充一段规则文字，包含：

- 判定单位：同一轮并行派发（dispatch_batch）
- 条件：`coder` WU 数量 ≥ 2
- 动作：为每个 coder WU 创建 worktree + 分支，并写入 `*-dispatch.md` 与 `DISPATCH-TRACK`

可选：在 `leader.md` 增加“派发 prompt 必含 worktree_path/branch + 禁止 worktree 外写”的 checklist。

- [ ] **Step 4: Run test to verify it passes**

```bash
bash harness-kit/scripts/harness-worktree.test.sh
```

Expected: PASS。

- [ ] **Step 5: Commit**

```bash
git add adapters/cursor/orchestration/dispatcher-workflow.md \
  adapters/cursor/orchestration/agents/leader.md \
  scripts/harness-worktree.test.sh
git commit -m "docs(harness-kit): enforce worktree isolation for parallel coder WUs"
```

---

## Task 4: 验收演练（本仓库自证）

**Files:**
- None (command-only)

- [ ] **Step 1: Write the failing test**

新增一个“演练用”的最小 repo 验证步骤写入 `scripts/harness-worktree.test.sh` 已覆盖（Task 2）。

- [ ] **Step 2: Run test to verify it fails**

这一任务不需要额外 fail（已在前序任务覆盖）。

- [ ] **Step 3: Write minimal implementation**

无。

- [ ] **Step 4: Run test to verify it passes**

在最终合并所有任务后运行：

```bash
bash harness-kit/scripts/harness-worktree.test.sh
```

Expected: PASS。

- [ ] **Step 5: Commit**

若 Task 1–3 已分别 commit，此任务不再额外 commit。

---

## Plan 自检（按 writing-plans）

- **Spec coverage**：本 plan 覆盖 spec 的命名（英文+中文展示）、启用判定（默认 coder；2+ coder WU 强制）、追踪字段、回滚策略与仓库卫生。
- **Placeholder scan**：无 TBD/TODO；每个代码/文档变更都有具体文件路径与最小实现要求。
- **TDD compliance**：所有会产生生产脚本/模板改动的任务均以测试开头，并包含 fail→pass 验证。

---

## 执行交接（门禁）

Plan 已写入 `.ai-runtime-artifacts/plans/2026-05-28-cursor-worktree-isolation-plan.md`，并配套 dispatch 见 `dispatch` 字段。

按门禁：请你先 review 本 plan。确认后再说「开始实现」。

