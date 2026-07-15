# Claude Code 适配实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 Harness Kit 的 Cursor 平台能力完整迁移至 Claude Code，使 Claude Code 成为 Harness Kit 的**主平台**（即 Claude 路径补齐至与 Cursor 同等 parity，并把部分 Cursor 不支持的 capability 升级为 supported）。

**Architecture:** 三层策略——
1. **核心层** (`core/`、`core/orchestration/`、`core/capabilities/`) 已平台无关，无需改动语义，只在文档交叉引用处标注「平台无关」。
2. **Claude 适配层** (`adapters/claude/`) 补齐六大投影：agents/、rules/、hooks/、skills/、orchestration/、bindings。
3. **Cursor 适配层** (`adapters/cursor/`) **保留**作历史兼容，但 README 明确「Claude 为主，Cursor 为参考实现」。

物理原语映射见各任务内 `bindings.md` 增量。Tier 路由门禁（`core/routing.md`）沿用。

**Tech Stack:** Markdown, YAML, Bash (hooks), Python 3 (可选 hook 内 JSON 解析), `git worktree`, Claude Code `Task` tool, Claude Code `AskUserQuestion`, Claude Code `Skill`, Claude Code `settings.json` (`SessionStart` / `SubagentStop` / `PreToolUse` / `PostToolUse` 钩子), Claude Code `.claude/skills/` 自动发现, Claude Code `CLAUDE.md` 入口, Claude Code `general-purpose` / `Explore` subagent 类型.

---

## 范围与命名

**分支：** `feature/claude-code-adaptation`

**计划文件：** `docs/superpowers/plans/2026-06-12-claude-code-adaptation.md`

**完工标志：**

- `bash harness-kit/scripts/harness-check.sh` 通过
- `adapters/claude/capability-matrix.yaml` 中所有 `status: degraded` / `status: manual` 项升级为 `supported`（除 Claude 平台客观不支持的少数）
- `harness-check.sh` 新增 Claude 段（hooks/settings 检测、CLAUDE.md 检测、`.claude/skills/` 检测）
- `README.md` §「支持的工具」中 Claude Code 行扩展为「主平台」

**反模式（不要做）：**

- 不删除 `adapters/cursor/`；仅在 README 标注「参考实现」
- 不改 `core/orchestration/` 语义；仅在文档交叉引用处补充
- 不引入新依赖；hook 脚本仅用 bash + 可选 python3
- 不动 `core/routing.md` 路由表本身，只更新「加载路径」注释

---

## 文件结构（增量概览）

| 目录 / 文件 | 职责 |
| --- | --- |
| `adapters/claude/.claude/settings.json` | 投影用 Claude 平台配置（钩子、permissions） |
| `adapters/claude/.claude/settings.local.json.example` | 接入项目时可覆盖的 local 模板 |
| `adapters/claude/.claude/skills/<slug>/SKILL.md` | 10 个能力副本：TDD / verification / debugging / code-review / receiving-code-review / ui-ux-pro-max / frontend-design / browser-testing-with-devtools / git-xywh / document-review |
| `adapters/claude/.claude/hooks/session-init.sh` | 注入 Harness 首行提示（SessionStart 钩子） |
| `adapters/claude/.claude/hooks/subagent-track-reminder.sh` | 提醒 Leader 同步 plan/tracking（SubagentStop 钩子） |
| `adapters/claude/agents/harness-<role>.md` | 7 个角色薄壳（`harness-coder` / `implementer` / `reviewer` / `explorer` / `debugger` / `test-engineer` / `web-investigator`），指向 core 正文 |
| `adapters/claude/orchestration/` | 镜像 cursor 编排目录：agents/、hooks/、runtime/、tracking/、VENDOR.md、continuous-loop.md、context-budget.md、CLAUDE-PRECHECK.md、config.defaults.yaml、model-routing.yaml |
| `adapters/claude/bindings.md` | 升级：所有原语 → Claude Code 工具映射（含 AskUserQuestion、settings.json 钩子、general-purpose Task、worktree、.claude/skills/） |
| `adapters/claude/capability-matrix.yaml` | 升级：degraded → supported；新增 claude 独有 capability 行 |
| `adapters/claude/README.md` | 改写为「主平台」文档；与 Cursor 差异表改为「与 Cursor parity」 |
| `entrypoints/CLAUDE.md` | 升级：注入所有 7 角色薄壳、钩子配置、`.claude/skills/` 列表 |
| `entrypoints/AGENTS.md` | §「支持的工具」更新 Claude Code 为主平台 |
| `entrypoints/HARNESS-PLATFORM-ENTRY.md` | 增加 Claude 段；项目背景占位 |
| `core/orchestration/skill-preferences.md` | 加载顺序表新增 `.claude/skills/` 第 0 优先 |
| `core/orchestration/config.defaults.yaml` | 注释新增「Claude 为默认平台」 |
| `core/routing.md` | §「阶段门禁」补充 Claude 钩子触发点 |
| `core/harness.md` | 顶部声明「主平台：Claude Code」 |
| `init/bootstrap.prompt.md` | 投影步骤新增 Claude 段；`.claude/skills/` 同步脚本 |
| `init/templates/` | 新增 `project.claude.md`、`project.claude.verification.md` 模板（可选） |
| `scripts/install-ai-skills.sh` | 升级：同步 `.claude/skills/`（`sync-claude-skills.sh`） |
| `scripts/sync-cursor-skills.sh` | **改名/克隆**为 `sync-claude-skills.sh`（保留旧脚本加 deprecation 提示） |
| `scripts/harness-check.sh` | 新增 Claude 段：检测 `CLAUDE.md` / `.claude/settings.json` / 7 个 harness 薄壳 / `.claude/skills/` 完整性 |
| `README.md` | §「支持的工具」重排：Claude Code 居首，标注「主平台」；§「推荐阅读顺序」开头改为 Claude 视角；§「新项目接入」Claude 段优先 |
| `adapters/cursor/README.md` | 顶部加「> Claude 为主平台；本目录保留作历史参考」横幅 |
| `adapters/cursor/capability-matrix.yaml` | **不动**（作 parity 对照基准） |
| `adapters/cursor/bindings.md` | **不动** |
| `adapters/agents/.agents/skills/cursor-orchestration/SKILL.md` | 加顶部横幅「参考实现，主平台为 Claude」 |

---

## Task 1：升级 `adapters/claude/capability-matrix.yaml`（基线审计）

**Files:**
- Modify: `adapters/claude/capability-matrix.yaml`

- [ ] **Step 1.1：先记录当前 matrix 的 `degraded` / `manual` 行**

运行：

```bash
grep -E 'status: (degraded|manual)' adapters/claude/capability-matrix.yaml
```

期望输出（实际可能有差异）：

```text
  interaction.structured-ask:
    status: degraded
  hooks.session-lifecycle:
    status: manual
  orchestration.continuous-loop:
    status: manual
```

- [ ] **Step 1.2：在 `matrix_version` 注释中标注基线日期**

修改文件首部 `matrix_version: 1` 之下加注释（YAML 支持 `#` 注释）。在 `matrix_version: 1` 后插入：

```yaml
# baseline_after_phase: claude-code-adaptation
# parity_target: cursor
# degraded_remaining: []   # 任务完成后应为空（除客观不支持项）
```

- [ ] **Step 1.3：暂不改 status（后续任务逐项升级）**

保留 `degraded` / `manual` 占位；本任务只做基线记录。

- [ ] **Step 1.4：本地提交**

```bash
git add adapters/claude/capability-matrix.yaml
git commit -m "feat(claude-adapter): phase 1 — capability matrix baseline audit"
```

---

## Task 2：升级 `adapters/claude/bindings.md`（原语全映射）

**Files:**
- Modify: `adapters/claude/bindings.md`

- [ ] **Step 2.1：当前 bindings 记录 8 个原语；扩展为与 cursor 适配器对称的 14 个**

读 `adapters/cursor/bindings.md` 列出全部原语表头（`DetectPlatform()`、`SpawnWorker(coder)` 等共 14 个），逐项写 Claude 绑定。

将 `adapters/claude/bindings.md` 完整替换为：

```markdown
# Claude Code 平台绑定

逻辑原语 → Claude Code API。语义以 `core/capabilities/primitives.md` 与 `core/orchestration/` 为准。**主平台（参考实现）：** `adapters/claude/`。

| 原语 | Claude 绑定 |
| --- | --- |
| `DetectPlatform()` | `CLAUDE.md` 会话 + Skill 工具 + 无 `.cursor/` → `claude` |
| `SpawnWorker(coder)` | `Task(subagent_type=general-purpose, prompt=<inline: agents/coder.md + WU 字段>)` |
| `SpawnWorker(implementer)` | `Task(general-purpose) + agents/implementer.md` |
| `SpawnWorker(reviewer)` | 新 `Task(general-purpose)` 实例 + readonly 约束 + agents/reviewer.md |
| `SpawnWorker(test-engineer)` | `Task(general-purpose) + agents/test-engineer.md` |
| `SpawnWorker(explorer)` | `Task(subagent_type=Explore)` 或 `Task(general-purpose)` readonly |
| `SpawnWorker(debugger)` | `Task(general-purpose) + agents/debugger.md` |
| `SpawnWorker(web-investigator)` | `Task(general-purpose) + agents/web-investigator.md` |
| `ParallelBatch` | 并行 `Task` 多次调用；不传 Leader 全历史；≤3（硬顶 5） |
| `WorktreeInit` | `bash harness-kit/scripts/harness-worktree.sh` 或裸 `git worktree add` |
| `StructuredAsk` | `AskUserQuestion`（多选 2–4 项；header ≤12 字符） |
| `EmitHook` | `.claude/settings.json` 钩子：`SessionStart` / `PostToolUse` / `SubagentStop` |
| `LoadCapability(orchestration.dispatch)` | `claude-orchestration` skill → `core/orchestration/dispatcher-workflow.md` |
| `LoadCapability(skill.<slug>)` | 优先 `.claude/skills/<slug>/SKILL.md`（Claude 自动发现）；fallback `~/.claude/skills/`、`~/.agents/skills/` |

**委派 prompt 必含：** WU id、wu_type、agent_role、允许文件、禁止项、done criteria、worktree_path（若启用）、本 WU Skills（slug + 路径，**禁**只写 `auto`）、返回格式（`wu_status` + `### Skills 使用`）。

**降级记录：** matrix 为 `degraded` 时，DISPATCH-TRACK 写 `Detail: capability <id> degraded`。

**与 Cursor 差异（已消解的）：**
- `StructuredAsk` — `AskUserQuestion` 原生支持（2026+）
- `EmitHook` — `.claude/settings.json` 原生钩子
```

- [ ] **Step 2.2：本地提交**

```bash
git add adapters/claude/bindings.md
git commit -m "feat(claude-adapter): upgrade bindings to 14-primitive parity"
```

---

## Task 3：迁移 7 个 `harness-*` 角色薄壳

**Files:**
- Create: `adapters/claude/agents/harness-coder.md`
- Create: `adapters/claude/agents/harness-implementer.md`
- Create: `adapters/claude/agents/harness-reviewer.md`
- Create: `adapters/claude/agents/harness-explorer.md`
- Create: `adapters/claude/agents/harness-debugger.md`
- Create: `adapters/claude/agents/harness-test-engineer.md`
- Create: `adapters/claude/agents/harness-web-investigator.md`

- [ ] **Step 3.1：读源文件**

读取 `adapters/cursor/.cursor/agents/harness-coder.md` 作为基线，提取 front matter 与正文。

- [ ] **Step 3.2：创建 `adapters/claude/agents/harness-coder.md`**

```markdown
---
name: harness-coder
description: Harness 资深开发 Coder。代码类 WU：实现、单元测试、自测、轻量审查、开发者自检。Leader 在 feature/bugfix/refactor/ui/review-fix 时委派。Claude Code 平台薄壳；正文见 `core/orchestration/agents/coder.md`。
model: sonnet
readonly: false
---

# Harness Coder（Claude 薄壳）

## 加载顺序

1. **必读** `harness-kit/core/orchestration/agents/coder.md`（正文与返回格式）
2. 读 `harness-kit/core/orchestration/skill-preferences.md` § 默认路由表（仅当 `wu_skills: auto`）
3. 读 Leader prompt 中列出的 WU Skills 路径（slug + 路径），按需 Read

## 委派机制

Claude Code 主 Agent 用 `Task` 工具委派：

```yaml
Task:
  subagent_type: general-purpose
  description: "WU-<id> <role>"
  prompt: |
    <core/orchestration/agents/coder.md 正文>
    ---
    ## WU-<id> 上下文
    - wu_type: <feature|bugfix|refactor|ui|review-fix>
    - agent_role: coder
    - 允许文件: <列表>
    - 禁止: 范围外文件 / git commit / push
    - done_criteria: <3-5 条可验证>
    - Skills: <slug>@<path> loaded|skipped
    - worktree_path: <abs | n/a>
    ---
    ## 返回格式
    wu_status: done|blocked
    ### Skills 使用
    code_review: PASS|FAIL
    self_check: PASS|FAIL
```

## 纪律（与 Cursor 版一致）

- 改 WU 允许文件；不写 plan / tracking
- 单元测试 / 自测 / 轻量审查 / 开发者自检
- `self_check: FAIL` 不得报完成
- 不用 Shell 写文本

## 禁止

- 委派时遗漏 `wu_type` / `agent_role` / 允许文件 / done criteria
- 在 Claude Code 中使用 `.cursor/agents/harness-*`（仅 `.claude/agents/` 或 `core/orchestration/agents/`）
- 与 `harness-reviewer` 同 Task 实例
```

- [ ] **Step 3.3：创建 `adapters/claude/agents/harness-implementer.md`**

同样结构，正文引用 `core/orchestration/agents/implementer.md`；`description`：「Harness 轻量 WU：docs/chore/config。Leader 在 docs/chore/config 时委派。」`model: haiku`（轻量任务降本）。

- [ ] **Step 3.4：创建 `adapters/claude/agents/harness-reviewer.md`**

`readonly: true`；`model: opus`（高难度审查）。正文引用 `core/orchestration/agents/reviewer.md`。额外纪律：

- 不读 `/root`、`/etc`、`~/.ssh/`、`~/.aws/` 等敏感目录
- 只读文件系统操作；不改任何文件
- 返回 `review_verdict: APPROVE|REQUEST_CHANGES|COMMENT`

- [ ] **Step 3.5：创建 `adapters/claude/agents/harness-explorer.md`**

`readonly: true`；`model: haiku`；`subagent_type: Explore`（Claude Code 内置）。description：「Harness 只读探查：跨模块摸底、文件定位、依赖分析。」允许 Task 用 `Explore` 而非 `general-purpose`。

- [ ] **Step 3.6：创建 `adapters/claude/agents/harness-debugger.md`**

`model: sonnet`；正文引用 `core/orchestration/agents/debugger.md`。必 Load `systematic-debugging`。

- [ ] **Step 3.7：创建 `adapters/claude/agents/harness-test-engineer.md`**

`model: sonnet`；正文引用 `core/orchestration/agents/test-engineer.md`。E2E 必 Load `browser-testing-with-devtools`。

- [ ] **Step 3.8：创建 `adapters/claude/agents/harness-web-investigator.md`**

`model: sonnet`；正文引用 `core/orchestration/agents/web-investigator.md`。允许 `WebFetch` / `WebSearch` / 截图。

- [ ] **Step 3.9：本地提交**

```bash
git add adapters/claude/agents/
git commit -m "feat(claude-adapter): add 7 harness-* role thin shells"
```

---

## Task 4：迁移 2 个规则文件 → `.claude/rules/`

**Files:**
- Create: `adapters/claude/.claude/rules/ai-entry.md`
- Create: `adapters/claude/.claude/rules/claude-subagent-routing.md`

> 注：Claude Code 用 `.claude/rules/` 目录存放规则（与 Cursor 的 `.cursor/rules/*.mdc` 类似）。本任务产出 markdown，bootstrap 时由 `init/bootstrap.prompt.md` § 投影工具适配 投影到项目根 `.claude/rules/`。

- [ ] **Step 4.1：读源 `adapters/cursor/.cursor/rules/ai-entry.mdc`**

记录 front matter 与正文。

- [ ] **Step 4.2：创建 `adapters/claude/.claude/rules/ai-entry.md`**

```markdown
---
description: 统一 AI 入口（Claude Code 平台）
---

# Claude Code 统一入口

## 规范优先级

1. `harness-kit/core/routing.md` — 路由、阶段门禁、按判定加载（强制）
2. 本文件 § 文件写入与阶段门禁（强制）
3. `.claude/rules/claude-subagent-routing.md` — Task 委派
4. 根目录 `AGENTS.md` / `CLAUDE.md` — Harness 覆盖层有效

## 文件写入与阶段门禁

细则：`harness-kit/core/routing.md` § 阶段门禁、§ 用户话术 → Route。

**文件写入**

- 改仓库内文本（源码、配置、`.ai-runtime-artifacts/`）**只用** `Write` / `Edit`；改前先 `Read`。
- **Shell 仅用于** 测试、lint、构建、git、只读查询。
- **禁止** Shell 写文本：`Set-Content`、`Out-File`、`echo … >`、`type … >`、Python/Node 一行写文件。

**阶段门禁**

| 用户说 | Route | 禁止（未获继续指令前） |
| --- | --- | --- |
| 写方案 / 出方案 / 设计 | `brainstorming` | 改业务代码、写 plan、派子 Agent、WORKTREE-INIT |
| 写计划 / 实施计划 | `writing-plans` | 同上 |
| 开始实现 / 直接做 / 并行执行 | 已过门禁后实现 | — |
| 写计划然后执行 / 出方案并直接做 | **仅** writing-plans 或 brainstorming | 同轮禁止实现（见 `routing.md` § 组合指令） |

- **同轮禁止：** Write 了 `specs/` / `plans/` / `decisions/` → **结束本轮**；不得同轮改业务代码、派发、WORKTREE-INIT。
- **实现前置：** 用户**单独**说「开始实现 / 直接做 / 并行执行」；或 spec/plan `approved: true` 且非组合指令；或 Tier 0 / Tier 1。
- **Tier 1 完成：** 须 Write `verifications/*-verification-lite.md`。
- **暂停回复须含：** 产物路径、摘要、`## Next` 选项。
- **产物 FM：** `status: draft`、`approved: false`；用户确认后改为 `approved: true`。

## 每任务（必做）

1. 首行：`「Harness：<route 或 "Tier 0 小改动" | "Tier 1 Leader 直做">」`
2. 次行（stage skill / Tier 1+）：`Skills: <slug>@<path> loaded|skipped` — **先 Load 再交付**
3. **沟通语言：** 对用户回复与子 Agent 派发/整合使用**中文**
4. **非 Tier 0**：Read `routing.md` 按 § 追加加载

## 按 routing 判定加载（勿在会话开始预读）

| 判定 | 再读（按序） |
| --- | --- |
| 设计 / spec | `brainstorming` skill → `core/artifacts.md` |
| 计划 | `writing-plans` skill → `artifacts.md` → `artifact-templates/plan.harness-overlay.md`；并行时 `dispatch.harness-overlay.md` |
| 验证 / 跑命令 | `verification-before-completion` → `project.verification.md`、`core/verification.md` |
| 尾盘 / GROUP 收尾 | `verification-before-completion` → `collective-test.md` → `requesting-code-review` → `code-review.md` → `core/orchestration/dispatcher-workflow.md` §3 |
| 决策 | `artifacts.md` + `artifact-templates/decision.md` |
| 多 task / 已批准 plan + 委派 | `claude-orchestration` → `core/orchestration/dispatcher-workflow.md`（**硬触发**） |
| Leader 直做 / Tier 1 | `verification-before-completion` → Write `verification-lite.md` |
| 派发 WU（`wu_skills: auto`） | `core/orchestration/skill-preferences.md` |
| Git | `git-xywh` + `project.git.md` + `core/runbooks.md` § Git 协作 |
| 文档审查 | `document-review` skill |
| 改代码 / 验证（实现阶段） | `project.profile.md`、`context-map.md`（涉及模块时） |

## 与 Cursor 差异

- 不再使用 `StrReplace`；用 Claude Code 的 `Edit` 工具
- 钩子由 `.claude/settings.json` 配置（`SessionStart` / `SubagentStop`），不是 `.cursor/hooks.json`
- 结构化提问用 `AskUserQuestion`（Leader 必用）；Cursor 的 `AskQuestion` 弃用
```

- [ ] **Step 4.3：创建 `adapters/claude/.claude/rules/claude-subagent-routing.md`**

参照 `adapters/cursor/.cursor/rules/cursor-subagent-routing.mdc` 内容，替换所有：

| Cursor 机制 | Claude 机制 |
| --- | --- |
| `.cursor/agents/harness-*.md` | `core/orchestration/agents/<role>.md`（薄壳见 `adapters/claude/agents/harness-*.md`） |
| `Use harness-coder subagent` | `Task(subagent_type=general-purpose, prompt=<inline 薄壳+agents/*.md>)` |
| `harness-explorer` | `Task(subagent_type=Explore)` |
| `Task(explore)` | `Task(subagent_type=Explore)` |
| `Task(ci-investigator)` | `Task(general-purpose, readonly=true)` + `systematic-debugging` |
| `AskQuestion` | `AskUserQuestion` |
| `.cursor/hooks.json` | `.claude/settings.json` |
| `.cursor/rules/*.mdc` | `.claude/rules/*.md` |

并在「禁止」一节增加一条：**禁止**在 Claude Code 中调用 `cursor-*` 系列 subagent 名称。

- [ ] **Step 4.4：本地提交**

```bash
git add adapters/claude/.claude/rules/
git commit -m "feat(claude-adapter): port ai-entry + subagent-routing rules"
```

---

## Task 5：迁移 2 个 hook 脚本与 `.claude/settings.json`

**Files:**
- Create: `adapters/claude/.claude/hooks/session-init.sh`
- Create: `adapters/claude/.claude/hooks/subagent-track-reminder.sh`
- Create: `adapters/claude/.claude/settings.json`

- [ ] **Step 5.1：读源 hook 脚本**

读 `adapters/cursor/.cursor/hooks/harness-session-init.sh` 与 `harness-subagent-track-reminder.sh`。

- [ ] **Step 5.2：创建 `adapters/claude/.claude/hooks/session-init.sh`**

```bash
#!/usr/bin/env bash
# Claude Code hook: SessionStart — 注入 Harness 路由提示（fail-open）
# 启用：复制此文件到项目根 .claude/hooks/ 并在 .claude/settings.json 引用
set -euo pipefail

# Claude Code 钩子从 stdin 读 JSON；本脚本不依赖具体字段
cat >/dev/null

# Claude Code SessionStart 钩子支持 JSON 输出（additionalContext 字段）
# 与 Cursor 的 hooks.json 输出格式不同
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Harness：首行「Harness：<route>」；stage skill / Tier 1+ 次行 Skills: slug@path loaded|skipped。spec/plan 写入后暂停（组合指令「然后执行」不跳过）。Tier 1 须 verification-lite。文本用 Write/Edit（不要 Shell 写）。结构化提问用 AskUserQuestion。Task 委派须含 wu_type/agent_role/允许文件/done criteria。详见 .claude/rules/ai-entry.md 与 harness-kit/core/routing.md。"
  }
}
EOF
exit 0
```

chmod +x。

- [ ] **Step 5.3：创建 `adapters/claude/.claude/hooks/subagent-track-reminder.sh`**

```bash
#!/usr/bin/env bash
# Claude Code hook: SubagentStop — 提醒 Leader 同步 plan/tracking（fail-open）
# 启用：在 .claude/settings.json 的 SubagentStop 引用
set -euo pipefail

input="$(cat)"

# Claude Code PostToolUse / SubagentStop 钩子：followup_message 字段提醒 Leader
if command -v python3 >/dev/null 2>&1; then
  python3 -c 'import json,sys; print(json.dumps({"followup": "Harness：子 Agent 已结束。请 Leader 按顺序执行：\n\n(1) 先更新 plan 勾选：在对应 plan 条目将 `- [ ]` → `- [√]`，并在该条目下追加证据行（见 `adapters/claude/orchestration/runtime/plan-progress-sync.md`），明确：哪个 WU-id/Agent(role) 完成了哪些条目 + 验证证据。\n    - 推荐证据行：`  - evidence: WU-<id> | agent_role=<role> | verified_by=<Leader> | proof=<tests|lint|manual>`\n\n(2) 再做追踪落盘：向 `.ai-runtime-artifacts/execution-logs/tracking/DISPATCH-TRACK-*.md` append（如启用 tracking）。\n\n(3) 最后判断是否进入尾盘（仅当本 GROUP 末 WU 已完成）：集体测试 → Write `*-collective-test.md` → 集体审查 → Write `*-code-review.md`。\n\n责任边界：子 Agent 不改 plan；由 Leader 验证后落盘。"}, ensure_ascii=False))'
else
  printf '%s\n' '{"followup":"Harness: subagent stopped. Leader followups (in order): (1) update plan checkboxes + evidence lines; (2) append DISPATCH-TRACK; (3) if last WU, batch closeout (collective test -> review -> code-review)."}'
fi
exit 0
```

chmod +x。

- [ ] **Step 5.4：创建 `adapters/claude/.claude/settings.json`**

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/harness-session-init.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/harness-subagent-track-reminder.sh",
            "timeout": 5
          }
        ]
      }
    ]
  },
  "permissions": {
    "allow": [
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git branch *)",
      "Bash(git diff *)",
      "Bash(git status *)",
      "Bash(git log *)",
      "Bash(git worktree *)",
      "Bash(bash harness-kit/scripts/*)",
      "Bash(bash scripts/*)"
    ]
  }
}
```

- [ ] **Step 5.5：本地提交**

```bash
git add adapters/claude/.claude/hooks/ adapters/claude/.claude/settings.json
git commit -m "feat(claude-adapter): add SessionStart + SubagentStop hooks + settings.json"
```

---

## Task 6：迁移 10 个能力 skill 副本到 `.claude/skills/`

**Files:**
- Create: `adapters/claude/.claude/skills/test-driven-development/SKILL.md`
- Create: `adapters/claude/.claude/skills/verification-before-completion/SKILL.md`
- Create: `adapters/claude/.claude/skills/systematic-debugging/SKILL.md`
- Create: `adapters/claude/.claude/skills/requesting-code-review/SKILL.md`
- Create: `adapters/claude/.claude/skills/receiving-code-review/SKILL.md`
- Create: `adapters/claude/.claude/skills/ui-ux-pro-max/SKILL.md`
- Create: `adapters/claude/.claude/skills/frontend-design/SKILL.md`
- Create: `adapters/claude/.claude/skills/browser-testing-with-devtools/SKILL.md`
- Create: `adapters/claude/.claude/skills/git-xywh/SKILL.md`
- Create: `adapters/claude/.claude/skills/document-review/SKILL.md`
- Create: `adapters/claude/.claude/skills/_vendor-sources.yaml`
- Create: `adapters/claude/.claude/skills/README.md`

- [ ] **Step 6.1：复制同名目录**

对每个 skill：

```bash
cp -r adapters/cursor/.cursor/skills/<slug> adapters/claude/.claude/skills/<slug>
```

（`git-xywh` 的 11 个子文件一并复制。）

- [ ] **Step 6.2：批量改 front matter 路径引用**

对每个复制过来的 `SKILL.md`，将正文中的 `.cursor/skills/<slug>/SKILL.md` 替换为 `.claude/skills/<slug>/SKILL.md`。脚本：

```bash
grep -rl '\.cursor/skills/' adapters/claude/.claude/skills/ | xargs sed -i 's|\.cursor/skills/|\.claude/skills/|g'
```

- [ ] **Step 6.3：创建 `adapters/claude/.claude/skills/_vendor-sources.yaml`**

复制 `adapters/cursor/.cursor/skills/_vendor-sources.yaml`，头部加注释 `# Claude Code 主平台副本；源见 _vendor-sources.yaml`，正文不改。

- [ ] **Step 6.4：创建 `adapters/claude/.claude/skills/README.md`**

```markdown
# Harness 项目内置 Skills（`.claude/skills/`）

Bootstrap 将 `harness-kit/adapters/claude/.claude/skills/` 投影到项目根 `.claude/skills/`，本目录由 **Claude Code 自动发现**。

## 内容

仅 **能力副本**（TDD、verification、systematic-debugging、ui-ux-pro-max 等），从本机全局 skill 复制，供子 Agent 按需加载。

**不包含** Leader 阶段 skill：`brainstorming`、`writing-plans`、`git-xywh` 在 `~/.claude/skills/` 或 `~/.agents/skills/`（Leader 须 Read，见 `routing.md`）。WU 级 skill 查 **`core/orchestration/skill-preferences.md`**（`wu_skills: auto`）。

## 同步

```bash
bash harness-kit/scripts/sync-claude-skills.sh
```

登记见 `_vendor-sources.yaml`。
```

- [ ] **Step 6.5：本地提交**

```bash
git add adapters/claude/.claude/skills/
git commit -m "feat(claude-adapter): port 10 capability skills to .claude/skills/"
```

---

## Task 7：迁移 `orchestration/` 目录

**Files:**
- Create: `adapters/claude/orchestration/agents/coder.md`（薄壳指针）
- Create: `adapters/claude/orchestration/agents/implementer.md`
- Create: `adapters/claude/orchestration/agents/reviewer.md`
- Create: `adapters/claude/orchestration/agents/debugger.md`
- Create: `adapters/claude/orchestration/agents/test-engineer.md`
- Create: `adapters/claude/orchestration/agents/web-investigator.md`
- Create: `adapters/claude/orchestration/agents/leader.md`
- Create: `adapters/claude/orchestration/agents/explorer.md`
- Create: `adapters/claude/orchestration/VENDOR.md`
- Create: `adapters/claude/orchestration/CLAUDE-PRECHECK.md`
- Create: `adapters/claude/orchestration/config.defaults.yaml`
- Create: `adapters/claude/orchestration/model-routing.yaml`
- Create: `adapters/claude/orchestration/continuous-loop.md`
- Create: `adapters/claude/orchestration/context-budget.md`
- Create: `adapters/claude/orchestration/dispatcher-workflow.md`
- Create: `adapters/claude/orchestration/skill-preferences.md`（薄壳指针）
- Create: `adapters/claude/orchestration/runtime/plan-progress-sync.md`
- Create: `adapters/claude/orchestration/tracking/schema.md`
- Create: `adapters/claude/orchestration/hooks/README.md`

> 大量薄壳文件指向 `core/orchestration/`；本任务主体是搬运 + 路径重写。

- [ ] **Step 7.1：创建 `adapters/claude/orchestration/agents/` 7 个薄壳**

每个文件结构（以 `coder.md` 为例）：

```markdown
# Cursor 角色薄壳

正文：**`harness-kit/core/orchestration/agents/coder.md`**

Claude Code 投影薄壳：`harness-kit/adapters/claude/agents/harness-coder.md`
```

对其他 6 个角色同理。每个文件 1-3 行即可。

- [ ] **Step 7.2：创建 `adapters/claude/orchestration/VENDOR.md`**

复制 `adapters/cursor/orchestration/VENDOR.md` 内容；标题改 `Vendor: Claude Code Adapter`；描述写「Claude Code 是 harness-kit 的主平台；本目录保留 cursor 同构以保持文档/流程一致。」

- [ ] **Step 7.3：创建 `adapters/claude/orchestration/CLAUDE-PRECHECK.md`**

```markdown
# Claude Code 平台预检（非阻塞）

接入 Claude Code 后，运行：

- [ ] `CLAUDE.md` 在项目根
- [ ] `.claude/settings.json` 在项目根（含 SessionStart / SubagentStop 钩子）
- [ ] `.claude/agents/harness-*.md` 7 个角色薄壳
- [ ] `.claude/rules/ai-entry.md` + `claude-subagent-routing.md`
- [ ] `.claude/skills/` 至少含 `test-driven-development` / `verification-before-completion` / `requesting-code-review` / `git-xywh` / `claude-orchestration`
- [ ] `bash harness-kit/scripts/harness-check.sh` 通过

可选：

- [ ] `.claude/settings.local.json` 覆盖本机偏好
- [ ] `Bash` 权限 allowlist 已含 `git worktree *`、`bash harness-kit/scripts/*`

跑 `harness-check.sh` 自动检测上述项；FAIL 项按提示修复。
```

- [ ] **Step 7.4：创建 `adapters/claude/orchestration/config.defaults.yaml`**

复制 `core/orchestration/config.defaults.yaml` 内容；顶部加注释：

```yaml
# Claude Code 主平台默认配置
# 平台无关默认值见 harness-kit/core/orchestration/config.defaults.yaml

platform: claude

runtime:
  max_parallel_agents: 3
  loop_mode: single-pass

orchestration:
  dispatcher_doc: harness-kit/core/orchestration/dispatcher-workflow.md
  skill_preferences: harness-kit/core/orchestration/skill-preferences.md
  roles: harness-kit/core/orchestration/roles.md
  bindings: harness-kit/adapters/claude/bindings.md

artifacts:
  execution_logs: .ai-runtime-artifacts/execution-logs/
  tracking: .ai-runtime-artifacts/execution-logs/tracking/
  handoff: .ai-runtime-artifacts/execution-logs/HANDOFF.md
```

- [ ] **Step 7.5：创建 `adapters/claude/orchestration/model-routing.yaml`**

```yaml
# Claude Code 角色 → 模型路由
# Claude Code 支持 per-task model override；默认 sonnet

claude-code:
  defaults:
    model: sonnet
  routing:
    harness-coder:
      model: sonnet
      rationale: 代码生成 + 测试 + 轻量审查，性价比最优
    harness-implementer:
      model: haiku
      rationale: docs/chore/config 轻量任务
    harness-reviewer:
      model: opus
      rationale: 高难度独立审查
    harness-explorer:
      model: haiku
      subagent_type: Explore
      rationale: 只读探查
    harness-debugger:
      model: sonnet
      rationale: 根因调查
    harness-test-engineer:
      model: sonnet
      rationale: 测试/E2E
    harness-web-investigator:
      model: sonnet
      rationale: 信息检索
  fallback:
    on_rate_limit: haiku
    on_overload: opus
```

- [ ] **Step 7.6：创建 `adapters/claude/orchestration/continuous-loop.md`**

复制 `adapters/cursor/orchestration/continuous-loop.md`，全篇替换：

| Cursor | Claude |
| --- | --- |
| `cursor-orchestration` | `claude-orchestration` |
| `harness-coder` subagent | `Task(general-purpose)` + `agents/coder.md` |
| `.cursor/hooks.json` | `.claude/settings.json` |
| `AskQuestion` | `AskUserQuestion` |
| `CURSOR-PRECHECK.md` | `CLAUDE-PRECHECK.md` |

在「continuous 循环摘要」表中加一列「Claude 钩子」：`SessionStart 注入提示 / SubagentStop 提醒 Leader`。

- [ ] **Step 7.7：创建 `adapters/claude/orchestration/context-budget.md`**

复制 `adapters/cursor/orchestration/context-budget.md`，替换：

| Cursor | Claude |
| --- | --- |
| subagent | Task / `general-purpose` |
| 后台 Task | Task（无后台语义；改为长上下文 + 轮询） |

末尾加 1 段「Claude Code 特别说明」：

> Claude Code 的 `general-purpose` Task 不会返回长输出至 Leader；建议子 Agent 写产物到 `.ai-runtime-artifacts/` 由 Leader 读取，避免 Leader 上下文被大输出填满。

- [ ] **Step 7.8：创建 `adapters/claude/orchestration/dispatcher-workflow.md`**

```markdown
# 已迁移

正文：**`harness-kit/core/orchestration/dispatcher-workflow.md`**

Claude Code 物理绑定见 `harness-kit/adapters/claude/bindings.md`。

本路径保留 1 个 release 周期以兼容旧链接。
```

- [ ] **Step 7.9：创建 `adapters/claude/orchestration/skill-preferences.md`**

```markdown
# 已迁移

正文：**`harness-kit/core/orchestration/skill-preferences.md`**

加载顺序补充：`.claude/skills/<slug>/SKILL.md` 优先于 `.cursor/skills/`。
```

- [ ] **Step 7.10：创建 `adapters/claude/orchestration/runtime/plan-progress-sync.md`**

复制 `adapters/cursor/orchestration/runtime/plan-progress-sync.md`，将「`harness-coder` 委派示例」改为 `Task(general-purpose) + agents/coder.md` 委派示例。

- [ ] **Step 7.11：创建 `adapters/claude/orchestration/tracking/schema.md`**

复制 `adapters/cursor/orchestration/tracking/schema.md`，所有「harness-」保留；「Cursor subagent」改为「Claude Task」；其余不变。

- [ ] **Step 7.12：创建 `adapters/claude/orchestration/hooks/README.md`**

```markdown
# Claude Code 钩子说明

Claude Code 钩子由项目根 `.claude/settings.json` 声明；脚本在项目根 `.claude/hooks/`（或 `harness-kit/adapters/claude/.claude/hooks/` 由 bootstrap 投影）。

## 已提供

| 事件 | 脚本 | 作用 |
| --- | --- | --- |
| `SessionStart` | `harness-session-init.sh` | 注入 Harness 首行提示 |
| `SubagentStop` | `harness-subagent-track-reminder.sh` | 提醒 Leader 同步 plan/tracking |

## 启用

1. 复制 `harness-kit/adapters/claude/.claude/hooks/*.sh` 到 `<project>/.claude/hooks/`
2. 复制 `harness-kit/adapters/claude/.claude/settings.json` 到 `<project>/.claude/settings.json`
3. `chmod +x .claude/hooks/*.sh`
4. 验证：`bash harness-kit/scripts/harness-check.sh` § Claude Code 段

## 失败语义

所有 hook 脚本 `set -euo pipefail`；超时 5s（`timeout: 5`）。失败不阻塞主流程（fail-open）。
```

- [ ] **Step 7.13：本地提交**

```bash
git add adapters/claude/orchestration/
git commit -m "feat(claude-adapter): port orchestration/ directory"
```

---

## Task 8：升级 `core/orchestration/skill-preferences.md` 加载顺序

**Files:**
- Modify: `core/orchestration/skill-preferences.md`

- [ ] **Step 8.1：定位「加载顺序」一节**

读 `core/orchestration/skill-preferences.md` §「加载顺序（路径）」。

- [ ] **Step 8.2：在最前插入 Claude 优先项**

将原表（`.cursor/skills/` → `~/.cursor/skills/` → `~/.agents/skills/`）改为：

```markdown
1. `.claude/skills/<slug>/SKILL.md`        # Claude Code 主平台，Claude 自动发现
2. `.cursor/skills/<slug>/SKILL.md`        # Cursor 历史
3. `~/.claude/skills/<slug>/SKILL.md`      # 本机全局（Claude）
4. `~/.cursor/skills/<slug>/SKILL.md`      # 本机全局（Cursor 历史）
5. `~/.agents/skills/<slug>/SKILL.md`      # 本机全局（generic）
```

- [ ] **Step 8.3：同步更新 §「`wu_skills: auto` 怎么解析」步骤 6**

将「对列表中每一项 **按需** invoke / Read `.cursor/skills/<slug>/SKILL.md`」改为「按上述加载顺序查找」。

- [ ] **Step 8.4：本地提交**

```bash
git add core/orchestration/skill-preferences.md
git commit -m "feat(core): skill loading order — Claude Code 1st"
```

---

## Task 9：升级 `core/orchestration/config.defaults.yaml` + `core/harness.md`

**Files:**
- Modify: `core/orchestration/config.defaults.yaml`
- Modify: `core/harness.md`

- [ ] **Step 9.1：在 `config.defaults.yaml` 顶部加注释**

```yaml
# 默认平台：Claude Code
# 适配器：adapters/claude/（主），adapters/cursor/（参考实现）
```

- [ ] **Step 9.2：在 `core/harness.md` § 顶部声明加一行**

```markdown
> **主平台：Claude Code**（`adapters/claude/`）。Cursor 适配器保留作历史参考。
```

- [ ] **Step 9.3：本地提交**

```bash
git add core/orchestration/config.defaults.yaml core/harness.md
git commit -m "feat(core): declare Claude Code as primary platform"
```

---

## Task 10：升级 `core/routing.md`（仅注释补充，不改表）

**Files:**
- Modify: `core/routing.md`

- [ ] **Step 10.1：定位「平台检测」段**

在文件中找到说明 `platform: cursor | claude | generic` 的位置。

- [ ] **Step 10.2：在「平台检测」一节顶部加注**

```markdown
> **检测顺序（2026-06+）：** Claude Code 优先于 Cursor。`CLAUDE.md` 会话 + Skill 工具 + AskUserQuestion → `claude`；否则 Cursor 工作区 + `.cursor/agents/harness-*` → `cursor`。
```

- [ ] **Step 10.3：在「阶段门禁」表的 Tier 1 行加列「Claude 钩子」**

在 Tier 1 一行末尾追加：` | Claude 钩子（`verification-before-completion` → Write `verification-lite.md`）`。

若表格不适合改，另起一节「§ 平台钩子触发点」：

```markdown
| 平台 | 钩子事件 | 行为 |
| --- | --- | --- |
| Claude Code | `SessionStart` | 注入 Harness 首行提示 |
| Claude Code | `SubagentStop` | 提醒 Leader 同步 plan/tracking |
| Cursor | `sessionStart` | 同上 |
| Cursor | `subagentStop` | 同上 |
```

- [ ] **Step 10.4：本地提交**

```bash
git add core/routing.md
git commit -m "feat(core): routing — Claude Code first + platform hook table"
```

---

## Task 11：升级 `entrypoints/CLAUDE.md` + `entrypoints/AGENTS.md`

**Files:**
- Modify: `entrypoints/CLAUDE.md`
- Modify: `entrypoints/AGENTS.md`
- Modify: `entrypoints/HARNESS-PLATFORM-ENTRY.md`

- [ ] **Step 11.1：读现有 `entrypoints/CLAUDE.md`**

记录现有内容（仅 1093 字节，需要大幅扩展）。

- [ ] **Step 11.2：完整重写 `entrypoints/CLAUDE.md`**

```markdown
# Claude Code 入口（harness-kit）

> **主平台**。本文件由 `harness-kit/init/bootstrap.prompt.md` 投影到目标项目根 `CLAUDE.md`。
> 修订时改源文件，**不**直接改目标项目。

## 必读

1. `harness-kit/README.md` § Cursor 编程协作模式（适用 Claude，语义同）
2. `harness-kit/core/routing.md`（路由 / 门禁 / 加载判定）
3. `harness-kit/core/harness.md`（总契约）
4. 本项目 `project.profile.md` / `context-map.md` / `project.verification.md` / `project.git.md`

## 平台识别

- **本平台：** Claude Code
- **钩子：** `.claude/settings.json`（`SessionStart` / `SubagentStop`）
- **规则：** `.claude/rules/ai-entry.md` + `claude-subagent-routing.md`
- **Skill 副本：** `.claude/skills/`
- **子 Agent 角色：** `Task(subagent_type=general-purpose) + agents/<role>.md`

## 每任务（必做）

1. 首行：`「Harness：<route 或 "Tier 0/1">」`
2. 次行（stage skill / Tier 1+）：`Skills: <slug>@<path> loaded|skipped`
3. 沟通语言：**中文**（对用户回复 + 委派 prompt + 整合）
4. 改仓库内文本：**Write / Edit**；改前先 **Read**

## 阶段门禁

细则：`harness-kit/core/routing.md` § 阶段门禁。摘要：

| 用户说 | Route |
| --- | --- |
| 写方案 / 出方案 / 设计 | `brainstorming` |
| 写计划 / 实施计划 | `writing-plans` |
| 开始实现 / 直接做 | 已过门禁后实现 |
| 写计划然后执行 | 同轮禁止实现 |

## 多 task 编排

激活 `claude-orchestration` skill → 读 `harness-kit/core/orchestration/dispatcher-workflow.md`。

委派 prompt 必含：WU id / wu_type / agent_role / 允许文件 / 禁止项 / done criteria / Skills（slug+路径）/ worktree_path / 返回格式。

## 角色映射

| Harness 角色 | Claude 机制 |
| --- | --- |
| Leader | 主会话 |
| coder / implementer / test-engineer / debugger / web-investigator | `Task(general-purpose)` + `agents/<role>.md` |
| reviewer | 新 `Task(general-purpose)` readonly + `agents/reviewer.md` |
| explorer | `Task(Explore)` 或 `Task(general-purpose)` readonly |

## 钩子事件

| 事件 | 行为 |
| --- | --- |
| `SessionStart` | 注入 Harness 首行提示 |
| `SubagentStop` | 提醒 Leader 同步 plan/tracking |

## 禁止

- 同轮写完 spec/plan/decision 又改业务代码
- Leader 主线程写业务代码（非小改动）
- 实现与审查同 Task 实例
- 用 `.cursor/agents/harness-*`（Cursor 平台专用）

## 投影路径

| 类型 | 路径 |
| --- | --- |
| 入口 | `CLAUDE.md`（本文件） |
| 钩子 + settings | `.claude/settings.json` |
| 规则 | `.claude/rules/*.md` |
| 角色薄壳 | `.claude/agents/harness-*.md` |
| Skill 副本 | `.claude/skills/<slug>/SKILL.md` |
| 编排 skill | `.agents/skills/claude-orchestration/SKILL.md` |
```

- [ ] **Step 11.3：更新 `entrypoints/AGENTS.md`**

在 §「支持的工具」表中把 Claude Code 行扩展：

```markdown
| Claude Code | `CLAUDE.md`、`.claude/rules/`、`.claude/agents/harness-*`、`.claude/skills/`、`.claude/settings.json`（**主平台**） |
```

并把表格顺序改为：Claude Code → Cursor。

- [ ] **Step 11.4：更新 `entrypoints/HARNESS-PLATFORM-ENTRY.md`**

加一节「## Claude Code（主平台）」，包含：投影路径、钩子、Skill、角色薄壳、AskUserQuestion 用法。其它平台段落保留。

- [ ] **Step 11.5：本地提交**

```bash
git add entrypoints/CLAUDE.md entrypoints/AGENTS.md entrypoints/HARNESS-PLATFORM-ENTRY.md
git commit -m "feat(entrypoints): declare Claude Code as primary platform entry"
```

---

## Task 12：升级 `init/bootstrap.prompt.md`（接入流程补 Claude 段）

**Files:**
- Modify: `init/bootstrap.prompt.md`

- [ ] **Step 12.1：读源文件**

读 `init/bootstrap.prompt.md` 全文。

- [ ] **Step 12.2：投影步骤 § 加 Claude 段**

在「3. 从 harness-kit/adapters/ 投影工具适配目录」一节后，**新增**一节：

```markdown
### 3.5 Claude Code 投影（主平台）

- `harness-kit/adapters/claude/.claude/` → `<project>/.claude/`
  - `settings.json` → 钩子配置（须含 `SessionStart` + `SubagentStop`）
  - `hooks/*.sh` → `chmod +x`
  - `rules/*.md` → 规则
  - `agents/harness-*.md` → 7 个角色薄壳
  - `skills/<slug>/SKILL.md` → 10 个能力副本
- `harness-kit/adapters/claude/.agents/skills/claude-orchestration/SKILL.md` → `<project>/.agents/skills/`
- 同步能力副本：`bash harness-kit/scripts/sync-claude-skills.sh`
- 验证：`bash harness-kit/scripts/harness-check.sh` § Claude Code 段
```

- [ ] **Step 12.3：本地提交**

```bash
git add init/bootstrap.prompt.md
git commit -m "feat(init): add Claude Code projection step 3.5"
```

---

## Task 13：升级 `scripts/sync-cursor-skills.sh` → `sync-claude-skills.sh`

**Files:**
- Create: `scripts/sync-claude-skills.sh`
- Modify: `scripts/sync-cursor-skills.sh`（加 deprecation 横幅）

- [ ] **Step 13.1：读源 `scripts/sync-cursor-skills.sh`**

- [ ] **Step 13.2：创建 `scripts/sync-claude-skills.sh`**

复制源文件，修改：
- 替换 `adapters/cursor/.cursor/skills/` → `adapters/claude/.claude/skills/`
- 替换 `<project>/.cursor/skills/` → `<project>/.claude/skills/`
- 顶部加注释：`# Claude Code 主平台 Skill 同步脚本`

- [ ] **Step 13.3：在 `scripts/sync-cursor-skills.sh` 顶部加 deprecation 横幅**

```bash
#!/usr/bin/env bash
# ⚠️ DEPRECATED: 改用 sync-claude-skills.sh（Claude Code 主平台）
# 本脚本保留 1 个 release 周期以兼容历史调用。
# 详见 harness-kit/adapters/claude/README.md
```

- [ ] **Step 13.4：`chmod +x scripts/sync-claude-skills.sh`**

- [ ] **Step 13.5：本地提交**

```bash
git add scripts/sync-claude-skills.sh scripts/sync-cursor-skills.sh
git commit -m "feat(scripts): add sync-claude-skills.sh; deprecate cursor variant"
```

---

## Task 14：升级 `scripts/harness-check.sh`（新增 Claude 段）

**Files:**
- Modify: `scripts/harness-check.sh`

- [ ] **Step 14.1：读源脚本**

读 `scripts/harness-check.sh` 全文（15864 字节）。

- [ ] **Step 14.2：定位 main 段**

找主检查函数或 `main()` 入口。

- [ ] **Step 14.3：新增 `check_claude_adapter()` 函数**

```bash
check_claude_adapter() {
  local fail=0
  section "Claude Code Adapter (主平台)"

  # 1. CLAUDE.md
  if [[ -f "CLAUDE.md" ]]; then
    ok "CLAUDE.md 存在"
  else
    err "CLAUDE.md 缺失；运行 init/bootstrap.prompt.md"
    fail=1
  fi

  # 2. .claude/settings.json
  if [[ -f ".claude/settings.json" ]]; then
    ok ".claude/settings.json 存在"
    if grep -q "SessionStart" ".claude/settings.json" && grep -q "SubagentStop" ".claude/settings.json"; then
      ok "  - 钩子事件 SessionStart + SubagentStop 已声明"
    else
      err "  - 钩子事件不全；需 SessionStart + SubagentStop"
      fail=1
    fi
  else
    err ".claude/settings.json 缺失"
    fail=1
  fi

  # 3. 7 个 harness-* 角色薄壳
  local missing=0
  for role in coder implementer reviewer explorer debugger test-engineer web-investigator; do
    if [[ ! -f "adapters/claude/agents/harness-${role}.md" ]]; then
      err "adapters/claude/agents/harness-${role}.md 缺失"
      missing=1
    fi
  done
  [[ $missing -eq 0 ]] && ok "  - 7 个 harness-* 角色薄壳齐全"

  # 4. .claude/rules/
  for f in ai-entry.md claude-subagent-routing.md; do
    if [[ -f "adapters/claude/.claude/rules/${f}" ]]; then
      ok "  - .claude/rules/${f}"
    else
      err "  - .claude/rules/${f} 缺失"
      fail=1
    fi
  done

  # 5. .claude/skills/ 关键 skill
  for slug in test-driven-development verification-before-completion requesting-code-review claude-orchestration; do
    if [[ -d "adapters/claude/.claude/skills/${slug}" ]]; then
      ok "  - .claude/skills/${slug}/"
    else
      err "  - .claude/skills/${slug}/ 缺失"
      fail=1
    fi
  done

  # 6. hooks 可执行
  if [[ -f "adapters/claude/.claude/hooks/session-init.sh" ]]; then
    if [[ -x "adapters/claude/.claude/hooks/session-init.sh" ]]; then
      ok "  - session-init.sh 可执行"
    else
      warn "  - session-init.sh 不可执行；chmod +x"
    fi
  fi

  return $fail
}
```

- [ ] **Step 14.4：在 main 段注册 `check_claude_adapter`**

在主检查列表中（其它平台检测后）调用 `check_claude_adapter`。

- [ ] **Step 14.5：本地运行验证**

```bash
bash harness-kit/scripts/harness-check.sh 2>&1 | head -100
```

期望：Claude 段全 `ok` 或只剩 deprecation warn。

- [ ] **Step 14.6：本地提交**

```bash
git add scripts/harness-check.sh
git commit -m "feat(scripts): harness-check.sh — Claude Code adapter check"
```

---

## Task 15：升级 `README.md`（主平台横幅 + 表格重排）

**Files:**
- Modify: `README.md`

- [ ] **Step 15.1：在 §「支持的工具」表中加 Claude 主平台标注**

原表行：

```markdown
| Claude Code | `CLAUDE.md` |
```

改为：

```markdown
| **Claude Code**（**主平台**） | `CLAUDE.md`、`.claude/rules/`、`.claude/agents/harness-*`、`.claude/skills/`、`.claude/settings.json` |
```

并把表格顺序改为 Claude 居首。

- [ ] **Step 15.2：在 §「Cursor 编程协作模式」标题下加横幅**

```markdown
> **Claude Code 是 harness-kit 的主平台。** 协作模式（Leader + 子 Agent + WU + 阶段门禁 + 尾盘）对 Claude Code 与 Cursor 等价，物理绑定见 `adapters/claude/bindings.md`。
```

- [ ] **Step 15.3：§「推荐阅读顺序」开头改为 Claude 视角**

```markdown
1. 本 README § Cursor 编程协作模式（注：Claude Code 主平台，语义同）
2. `core/routing.md`
3. `adapters/claude/README.md`（Claude Code 主适配器）
4. `adapters/claude/bindings.md`（Claude 原语映射）
```

- [ ] **Step 15.4：§「新项目接入」加 Claude 优先段**

在「## 新项目接入」标题下加：

```markdown
**Claude Code 接入（主平台）：** 步骤 1-5 同下；其中：

- 步骤 2「从 `adapters/` 投影」改为：先 `adapters/claude/.claude/` → `<project>/.claude/`，再 `adapters/agents/.agents/skills/claude-orchestration/` → `<project>/.agents/skills/`
- 步骤 3「安装 AI runtime」改用 `bash harness-kit/scripts/sync-claude-skills.sh`
- 步骤 5「运行 harness-check」会自动检查 Claude Code 段
```

- [ ] **Step 15.5：§「改造 Harness Kit」通用话术加 Claude 段**

通用话术后追加：

```markdown
### 改造 Claude Code 适配器

请同时改：

- `harness-kit/adapters/claude/bindings.md`（原语映射）
- `harness-kit/adapters/claude/capability-matrix.yaml`（parity 状态）
- `harness-kit/adapters/claude/agents/harness-<role>.md`（薄壳）
- `harness-kit/entrypoints/CLAUDE.md`（入口）
- `harness-kit/core/orchestration/skill-preferences.md`（加载顺序）

不要改 `core/orchestration/agents/*.md` 角色正文；只改 bindings。
```

- [ ] **Step 15.6：本地提交**

```bash
git add README.md
git commit -m "feat(README): declare Claude Code as primary platform"
```

---

## Task 16：升级 `adapters/claude/README.md`（主平台文档重写）

**Files:**
- Modify: `adapters/claude/README.md`

- [ ] **Step 16.1：读源**

- [ ] **Step 16.2：完整重写**

```markdown
# Claude Code Adapter（**主平台**）

> harness-kit 的 **主平台**。Cursor 适配器保留作历史参考；新项目、新能力、新 CI 默认走 Claude Code 路径。

## 投影层

bootstrap 复制到项目根：

- `CLAUDE.md`（入口）
- `.claude/settings.json`（钩子 + permissions）
- `.claude/hooks/*.sh`（SessionStart / SubagentStop）
- `.claude/rules/*.md`（ai-entry / claude-subagent-routing）
- `.claude/agents/harness-*.md`（7 个角色薄壳）
- `.claude/skills/<slug>/SKILL.md`（10 个能力副本）
- `.agents/skills/claude-orchestration/SKILL.md`（编排 skill）

## 绑定层

留 `harness-kit/adapters/claude/`：

- `bindings.md`（14 个原语 → Claude Code API）
- `capability-matrix.yaml`（parity 状态）
- `agents/harness-*.md`（薄壳源）
- `orchestration/`（CLAUDE-PRECHECK、continuous-loop、context-budget、config.defaults、model-routing）

## 平台检测

`CLAUDE.md` 会话 + Skill 工具 + `AskUserQuestion` 可用 + 无 `.cursor/` → `platform: claude`。

## 关键文档

| 文档 | 用途 |
| --- | --- |
| `../../core/orchestration/dispatcher-workflow.md` | 编排唯一步骤源 |
| `bindings.md` | Claude 原语映射（14 项） |
| `capability-matrix.yaml` | parity 审计 |
| `orchestration/CLAUDE-PRECHECK.md` | 平台预检清单 |
| `orchestration/continuous-loop.md` | opt-in 多周期循环 |
| `orchestration/model-routing.yaml` | 角色 → 模型路由 |
| `../../entrypoints/CLAUDE.md` | Claude Code 入口契约 |
| `../../core/routing.md` | 路由权威 |

## 接入

```bash
# 1. 投影 .claude/ 到项目根
cp -r harness-kit/adapters/claude/.claude/ .claude/
chmod +x .claude/hooks/*.sh

# 2. 投影编排 skill
cp -r harness-kit/adapters/agents/.agents/skills/claude-orchestration/ .agents/skills/

# 3. 同步能力副本
bash harness-kit/scripts/sync-claude-skills.sh

# 4. 验证
bash harness-kit/scripts/harness-check.sh
```

## 与 Cursor parity（2026-06+）

| 能力 | 状态 |
| --- | --- |
| `interaction.structured-ask` | **supported**（`AskUserQuestion`） |
| `hooks.session-lifecycle` | **supported**（`.claude/settings.json`） |
| `orchestration.continuous-loop` | **supported**（`continuous-loop.md` + 钩子） |
| Task `ci-investigator` | **supported**（`general-purpose` readonly + `systematic-debugging`） |
| 其它 17 项 | **supported**（同 Cursor） |

详见 `capability-matrix.yaml`。
```

- [ ] **Step 16.3：本地提交**

```bash
git add adapters/claude/README.md
git commit -m "feat(claude-adapter): rewrite README as primary platform"
```

---

## Task 17：升级 `capability-matrix.yaml`（degraded → supported）

**Files:**
- Modify: `adapters/claude/capability-matrix.yaml`

- [ ] **Step 17.1：修改 `interaction.structured-ask`**

```yaml
  interaction.structured-ask:
    status: supported
    binding: "AskUserQuestion"
    notes: "2-4 options, header ≤12 chars, multiSelect 显式"
```

- [ ] **Step 17.2：修改 `hooks.session-lifecycle`**

```yaml
  hooks.session-lifecycle:
    status: supported
    binding: ".claude/settings.json — SessionStart + SubagentStop"
    notes: "钩子脚本在 adapters/claude/.claude/hooks/；bootstrap 投影"
```

- [ ] **Step 17.3：修改 `orchestration.continuous-loop`**

```yaml
  orchestration.continuous-loop:
    status: supported
    binding: "claude-orchestration + adapters/claude/orchestration/continuous-loop.md"
    notes: "HANDOFF 衔接多会话；SessionStart 钩子辅助"
```

- [ ] **Step 17.4：删 `web-investigator` 注释行（Task `ci-investigator` 改为 supported）**

注：原 `Task ci-investigator` 不是 yaml 顶层 key；如有引用，更新 `notes`。

- [ ] **Step 17.5：矩阵底部加 parity 声明**

```yaml
parity_with_cursor: 21/21   # 2026-06+ 目标
last_audit: 2026-06-12
```

- [ ] **Step 17.6：本地提交**

```bash
git add adapters/claude/capability-matrix.yaml
git commit -m "feat(claude-adapter): capability matrix — degraded → supported"
```

---

## Task 18：标注 Cursor 为「参考实现」（不删不改内容）

**Files:**
- Modify: `adapters/cursor/README.md`
- Modify: `adapters/agents/.agents/skills/cursor-orchestration/SKILL.md`

- [ ] **Step 18.1：在 `adapters/cursor/README.md` 顶部加横幅**

```markdown
> **注意：Claude Code 是 harness-kit 的主平台。** 本目录保留作历史参考；新项目请走 `adapters/claude/`。本目录下文件**不再更新能力**，仅维护 parity 对照。
```

- [ ] **Step 18.2：在 `cursor-orchestration/SKILL.md` 顶部加横幅**

```markdown
> **注意：参考实现。** 主平台为 Claude Code（`claude-orchestration`）。本 skill 保留作 parity 验证与历史项目迁移。
```

- [ ] **Step 18.3：本地提交**

```bash
git add adapters/cursor/README.md adapters/agents/.agents/skills/cursor-orchestration/SKILL.md
git commit -m "docs(cursor): mark as reference implementation"
```

---

## Task 19：运行 harness-check.sh 全量验证

**Files:**
- (no file changes; verification only)

- [ ] **Step 19.1：跑全量检查**

```bash
bash harness-kit/scripts/harness-check.sh 2>&1 | tee /tmp/harness-check-2026-06-12.log
```

期望：

- Claude Code 段全 `ok`
- Cursor 段全 `ok`（无 regression）
- 总体退出码 0

- [ ] **Step 19.2：若失败则修复**

按 `/tmp/harness-check-2026-06-12.log` 中的 `err` 项定位，逐项修复后重跑。

- [ ] **Step 19.3：跑 git status 确认无未提交**

```bash
git status
```

期望：`nothing to commit, working tree clean`（`.idea/` 等已忽略或保留为 untracked）。

- [ ] **Step 19.4：跑 git log 检视提交序列**

```bash
git log --oneline -20
```

期望：18 个 task 提交按 Task 1–18 顺序排列，每个 commit 主题清晰。

---

## Task 20：编写完成报告（retrospective）

**Files:**
- Create: `docs/superpowers/retros/2026-06-12-claude-code-adaptation-retro.md`

- [ ] **Step 20.1：创建文件，填写结构**

```markdown
# Claude Code 适配 retrospective（2026-06-12）

## 完成情况

- 18 个任务全部完成（见 git log）
- `harness-check.sh` 全段通过
- `capability-matrix.yaml` parity 21/21

## 变更文件清单

| 类型 | 数量 | 路径示例 |
| --- | --- | --- |
| Create | ~40 | `adapters/claude/agents/`, `.claude/hooks/`, `.claude/rules/`, `.claude/skills/`, `orchestration/` |
| Modify | ~10 | `adapters/claude/bindings.md`, `capability-matrix.yaml`, `README.md`, `core/routing.md`, `core/harness.md`, `core/orchestration/skill-preferences.md`, `entrypoints/CLAUDE.md`, `init/bootstrap.prompt.md`, `scripts/harness-check.sh` |
| 横幅 | 2 | `adapters/cursor/README.md`, `cursor-orchestration/SKILL.md` |

## 行为差异

- 之前：Claude Code 适配器仅有 1 个 skill；3 个能力 degraded/manual
- 之后：Claude Code 适配器 14 原语全映射；21 能力全 supported；主平台

## 已接入项目的影响

- 旧接入项目（仅 Cursor）：无影响；继续走 Cursor
- 旧接入项目（混合）：可二选一；推荐切到 Claude
- 新接入项目：必须走 Claude 路径

## 待用户确认

- [ ] `entrypoints/CLAUDE.md` 是否需要纳入 git hook 防直改
- [ ] `.claude/settings.json` permissions allowlist 是否需要更精细
- [ ] `model-routing.yaml` 默认值（sonnet/haiku/opus）是否调整
- [ ] 是否同步更新 `core/routing.md` 路由表（目前只加注释，未改表）
```

- [ ] **Step 20.2：本地提交**

```bash
git add docs/superpowers/retros/2026-06-12-claude-code-adaptation-retro.md
git commit -m "docs(retro): claude-code-adaptation retrospective"
```

---

## 自检清单

完成后逐项核对：

- [ ] `adapters/claude/capability-matrix.yaml` 中无 `status: degraded` / `status: manual`（除非 Claude 平台客观不支持）
- [ ] `adapters/claude/bindings.md` 列出 14 个原语映射
- [ ] `adapters/claude/agents/harness-*.md` 共 7 个
- [ ] `adapters/claude/.claude/rules/ai-entry.md` + `claude-subagent-routing.md` 存在
- [ ] `adapters/claude/.claude/hooks/session-init.sh` + `subagent-track-reminder.sh` 存在且可执行
- [ ] `adapters/claude/.claude/settings.json` 引用两个钩子
- [ ] `adapters/claude/.claude/skills/` 含 10 个 skill 副本
- [ ] `adapters/claude/orchestration/` 镜像 cursor 编排目录结构
- [ ] `core/orchestration/skill-preferences.md` 加载顺序 `.claude/skills/` 优先
- [ ] `core/harness.md` 顶部声明「主平台：Claude Code」
- [ ] `core/routing.md` 检测顺序 Claude 优先
- [ ] `entrypoints/CLAUDE.md` 含完整主平台入口
- [ ] `entrypoints/AGENTS.md` 表格 Claude 居首
- [ ] `entrypoints/HARNESS-PLATFORM-ENTRY.md` 含 Claude 段
- [ ] `init/bootstrap.prompt.md` 含 step 3.5 Claude 投影
- [ ] `scripts/sync-claude-skills.sh` 存在；`sync-cursor-skills.sh` 有 deprecation
- [ ] `scripts/harness-check.sh` 含 `check_claude_adapter()` 且全 ok
- [ ] `README.md` Claude Code 标「主平台」并居首
- [ ] `adapters/cursor/README.md` 顶部有参考实现横幅
- [ ] `cursor-orchestration/SKILL.md` 顶部有参考实现横幅
- [ ] `bash harness-kit/scripts/harness-check.sh` 退出码 0
- [ ] `docs/superpowers/retros/2026-06-12-claude-code-adaptation-retro.md` 存在

---

## 反模式（再次提醒）

- **不**删 `adapters/cursor/`（仅横幅标注）
- **不**改 `core/orchestration/agents/*.md` 正文（仅 orchestration 目录结构迁移）
- **不**改 `core/routing.md` 路由表本身（仅注释）
- **不**改 `core/capabilities/primitives.md` 语义
- **不**自动 push；`git push` 等用户明确指令

---

**计划完成。** 提交序列预计 20 个 commit（Task 1-20 各一）。
