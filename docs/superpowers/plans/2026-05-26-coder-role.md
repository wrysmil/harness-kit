---
artifact: implementation-plan
route: cursor-orchestration:dispatcher-workflow
skills:
  - cursor-orchestration
source:
  - docs/superpowers/specs/2026-05-26-coder-role-design.md
  - harness-kit/core/routing.md
created_at: 2026-05-26
platform: cursor
status: implemented
---

# Harness Coder 角色 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 harness-kit Cursor 编排中落地 `harness-coder` 子 Agent，使代码类 WU 具备实现+单测+自测+开发者自检闭环；`harness-implementer` 专用于 docs/chore/config；Leader 支持小 WU 跳过 Reviewer 与对甲方汇报。

**Architecture:** 新增 `coder.md` + `harness-coder.md` 双文件（参考 implementer 模式）；通过 `skill-preferences.zh.md` 与 `dispatcher-workflow.md` 按 `wu_type` 路由；全局文档与 `.cursor/rules` 同步，避免仍写「五套角色、代码走 implementer」。

**Tech Stack:** Markdown / YAML / Cursor `.mdc` rules；无应用运行时代码变更。

**Spec:** `docs/superpowers/specs/2026-05-26-coder-role-design.md`

---

## 文件结构（锁定）

| 文件 | 动作 | 职责 |
| --- | --- | --- |
| `adapters/cursor/orchestration/agents/coder.md` | 新增 | Coder 详细参考、Task Prompt、返回格式 |
| `adapters/cursor/.cursor/agents/harness-coder.md` | 新增 | Cursor subagent 投影 |
| `adapters/cursor/orchestration/agents/implementer.md` | 修改 | 收窄为轻量 Worker；`wu_type` 示例改为 docs/chore |
| `adapters/cursor/.cursor/agents/harness-implementer.md` | 修改 | description 与职责收窄 |
| `adapters/cursor/orchestration/agents/leader.md` | 修改 | Coder 路由、汇报、跳过 Reviewer |
| `adapters/cursor/orchestration/dispatcher-workflow.md` | 修改 | WU 表、步骤 3 门禁 |
| `adapters/cursor/orchestration/platform-adapters.zh.md` | 修改 | 第六套 subagent |
| `adapters/cursor/orchestration/skill-preferences.zh.md` | 修改 | `agent_role: coder` 路由表 |
| `adapters/cursor/orchestration/model-routing.yaml` | 修改 | `harness_coder` 条目 |
| `artifact-templates/wu-checklist.md` | 修改 | Coder 自检节 |
| `adapters/cursor/.cursor/rules/cursor-subagent-routing.mdc` | 修改 | 委派 coder/implementer 分流 |
| `adapters/cursor/.cursor/rules/ai-entry.mdc` | 修改 | 会话开始提及 coder |
| `core/routing.md` | 修改 | 实现阶段委派 coder（代码 WU） |
| `core/runbooks.md` | 修改 | 新功能 runbook 委派表 |
| `adapters/cursor/orchestration/CURSOR-PRECHECK.md` | 修改 | 六套角色 |
| `adapters/agents/.agents/skills/cursor-orchestration/SKILL.md` | 修改 | 触发描述含 coder |
| `README.md` | 修改 | Worker 表与套数 |
| `entrypoints/AGENTS.cursor-overlay.md` | 修改 | 角色列表 |
| `init/bootstrap.prompt.md` | 修改 | bootstrap 清单含 harness-coder |
| `adapters/cursor/README.md` | 修改 | agents 列表 |
| `adapters/cursor/.cursor/agents/harness-reviewer.md` | 修改 | 与 coder 不同实例（措辞） |
| `adapters/cursor/orchestration/agents/reviewer.md` | 修改 | review-fix 派 coder |
| `docs/superpowers/specs/2026-05-26-coder-role-design.md` | 修改 | `status: approved`（实现启动时） |

---

## 执行图（建议）

```markdown
GROUP-1（可并行）:
  WU-01: 新增 coder.md | 文件: orchestration/agents/coder.md
  WU-02: 新增 harness-coder.md | 文件: .cursor/agents/harness-coder.md

GROUP-2（依赖 GROUP-1）:
  WU-03: skill-preferences + model-routing | wu_type: chore | wu_skills: 无
  WU-04: leader + dispatcher + platform-adapters | wu_type: chore

GROUP-3（依赖 GROUP-2）:
  WU-05: rules + core routing/runbooks | wu_type: chore
  WU-06: implementer 收窄 + reviewer 措辞 | wu_type: chore
  WU-07: 模板 + README + bootstrap + SKILL + PRECHECK | wu_type: docs

GROUP-4（依赖 GROUP-3）:
  WU-08: 全库一致性 grep + spec status | wu_type: chore
```

---

## 任务

### Task 1: 新增 `coder.md`（详细参考）

**Files:**
- Create: `adapters/cursor/orchestration/agents/coder.md`

**Spec 来源:** `docs/superpowers/specs/2026-05-26-coder-role-design.md` § Coder、§ 提示词规范（Leader→Coder 模板）

- [ ] **Step 1: 创建文件骨架**

复制 `implementer.md` 的章节结构，改写为 Coder 定位。必须包含章节：

1. 角色（资深开发者、WU 质量闭环）
2. 上下文纪律（同 implementer + 工程化默认）
3. 实现前检查（含 CHECKLIST）
4. WU Skills（`agent_role: coder` + Leader 列表为**指令**）
5. 实现纪律（5 步闭环：读→实现→单测→自测→自检）
6. 工程化默认（日志、错误处理、单测、`test_exempt`）
7. 开发者自检（硬门槛字段）
8. 工具使用
9. Task Prompt 前缀 — **从 spec § Leader→Coder 模板完整粘贴**
10. 返回格式 — **含「开发者自检」「测试资产」节**

- [ ] **Step 2: 修正 implementer 交叉引用**

在「禁止」中写明：不重规划、不派发子 Agent；**允许且必须**开发者自检（区别于 implementer「不要审查自己」）。

- [ ] **Step 3: 验证**

```bash
test -f adapters/cursor/orchestration/agents/coder.md
rg -n "self_check|skip_reviewer_eligible|agent_role" adapters/cursor/orchestration/agents/coder.md
```

Expected: 文件存在；至少匹配 `self_check`、`agent_role`。

- [ ] **Step 4: Commit**

```bash
git add adapters/cursor/orchestration/agents/coder.md
git commit -m "feat(harness-kit): 新增 Coder agent 详细参考文档"
```

---

### Task 2: 新增 `harness-coder.md`（Cursor 投影）

**Files:**
- Create: `adapters/cursor/.cursor/agents/harness-coder.md`

**Spec 来源:** spec § `harness-coder.md` 投影要点

- [ ] **Step 1: 写入 YAML front matter**

```yaml
---
name: harness-coder
description: Harness 资深开发 Coder。执行代码类 WU：实现、单测、自测、开发者自检。Leader 在 feature/bugfix/refactor/ui/review-fix 时必须委派。触发词：coder、代码 WU、开始实现。
model: inherit
readonly: false
---
```

- [ ] **Step 2: 正文对齐 `harness-implementer.md` 结构**

必须段落：

- 首段：遵循 `orchestration/agents/coder.md`
- 职责（5 步闭环 + 禁止派发子 Agent）
- WU Skills：`auto` → Read `skill-preferences.zh.md`（`agent_role: coder`）
- 禁止加载 skill 列表（与 implementer 相同全局禁止）
- 实现纪律 + 工程化默认
- 开发者自检硬门槛
- 返回格式（与 coder.md 一致）

- [ ] **Step 3: 验证**

```bash
test -f adapters/cursor/.cursor/agents/harness-coder.md
head -8 adapters/cursor/.cursor/agents/harness-coder.md | rg "name: harness-coder"
```

- [ ] **Step 4: Commit**

```bash
git add adapters/cursor/.cursor/agents/harness-coder.md
git commit -m "feat(harness-kit): 新增 harness-coder Cursor subagent 投影"
```

---

### Task 3: 更新 `skill-preferences.zh.md` 与 `model-routing.yaml`

**Files:**
- Modify: `adapters/cursor/orchestration/skill-preferences.zh.md`
- Modify: `adapters/cursor/orchestration/model-routing.yaml`

- [ ] **Step 1: 在 § 默认路由表 增加 coder 行**

在 `implementer | feature, bugfix, refactor` **之前**插入（或替换 implementer 的 code 类行）：

| agent_role | wu_type | 建议加载的 skill（按序） |
| --- | --- | --- |
| coder | feature, bugfix, refactor | test-driven-development, verification-before-completion |
| coder | ui | ui-ux-pro-max, frontend-design, test-driven-development, verification-before-completion |
| coder | review-fix | receiving-code-review, test-driven-development, verification-before-completion |

将原 `implementer | feature, bugfix, refactor` 与 `implementer | ui` 与 `implementer | review-fix` **删除**（避免双路由）。

保留 `implementer | chore | **无**`；新增 `implementer | docs, config | **无**`（若无则添加）。

- [ ] **Step 2: 更新 § 按 Harness 角色速查 与 § 按任务类型**

- 代码 WU → `harness-coder` + `coder + wu_type`
- review-fix → `harness-coder`
- docs/chore/config → `harness-implementer`
- `agent_role` 枚举追加 `coder`

- [ ] **Step 3: `model-routing.yaml` 增加**

```yaml
  harness_coder:
    description: 代码类 WU：实现、单测、自测、开发者自检
    subagent: harness-coder
    model: inherit
```

- [ ] **Step 4: 验证**

```bash
rg "agent_role: coder|harness-coder" adapters/cursor/orchestration/skill-preferences.zh.md
rg "harness_coder" adapters/cursor/orchestration/model-routing.yaml
rg "implementer \| feature" adapters/cursor/orchestration/skill-preferences.zh.md && echo "FAIL: implementer still owns feature" && exit 1 || echo "OK"
```

- [ ] **Step 5: Commit**

```bash
git add adapters/cursor/orchestration/skill-preferences.zh.md adapters/cursor/orchestration/model-routing.yaml
git commit -m "feat(harness-kit): Coder 的 skill 自动路由与 model-routing"
```

---

### Task 4: 更新 Leader 与 Dispatcher 工作流

**Files:**
- Modify: `adapters/cursor/orchestration/agents/leader.md`
- Modify: `adapters/cursor/orchestration/dispatcher-workflow.md`
- Modify: `adapters/cursor/orchestration/platform-adapters.zh.md`

- [ ] **Step 1: `leader.md`**

在「职责」中：

- 派发：`harness-coder`（feature/bugfix/refactor/ui/review-fix）+ `harness-implementer`（docs/chore/config）+ test-engineer
- 新增：对甲方汇报（链到 spec 或内联 5 条最小汇报）
- 新增：brainstorming 阶段 Ask 工具优先
- 新增：步骤 3 整合后 — 按 spec「小 WU 跳过 Reviewer」判定；否则派 `harness-reviewer`
- 禁止：与 **coder/implementer** 同实例审查

- [ ] **Step 2: `dispatcher-workflow.md`**

- 步骤 2 表：`代码实现（feature/bugfix/refactor/ui/review-fix）` → **`harness-coder`**
- 新增行：`docs/chore/config` → `harness-implementer`
- 步骤 2 委派 prompt 列表：Coder 须返回 `self_check` / `skip_reviewer_eligible`
- 步骤 3 第 5 点改为：**条件性**委派 reviewer（粘贴 spec 硬条件 + 可跳过条件摘要）
- Agent 面索引增加 Coder 行

- [ ] **Step 3: `platform-adapters.zh.md`**

- 表增加 `harness-coder.md`
- 「五套」→ **六套**（全文检索替换）

- [ ] **Step 4: 验证**

```bash
rg "harness-coder" adapters/cursor/orchestration/agents/leader.md adapters/cursor/orchestration/dispatcher-workflow.md adapters/cursor/orchestration/platform-adapters.zh.md
rg "跳过.*[Rr]eviewer|skip_reviewer" adapters/cursor/orchestration/dispatcher-workflow.md
```

- [ ] **Step 5: Commit**

```bash
git add adapters/cursor/orchestration/agents/leader.md adapters/cursor/orchestration/dispatcher-workflow.md adapters/cursor/orchestration/platform-adapters.zh.md
git commit -m "feat(harness-kit): Leader/Dispatcher 接入 Coder 与条件性 Reviewer"
```

---

### Task 5: 更新 Cursor Rules 与 core 路由

**Files:**
- Modify: `adapters/cursor/.cursor/rules/cursor-subagent-routing.mdc`
- Modify: `adapters/cursor/.cursor/rules/ai-entry.mdc`
- Modify: `core/routing.md`
- Modify: `core/runbooks.md`

- [ ] **Step 1: `cursor-subagent-routing.mdc`**

- 阶段门禁追加：代码 WU → `harness-coder`；docs/chore → `harness-implementer`
- Leader 协议第 3 点：同上 + 条件性 reviewer
- 「何时委派」表：实现 → 按 `wu_type` 选 coder 或 implementer
- 委派示例增加：`Use the harness-coder subagent to implement WU-01: ...`
- 推荐 skill 链保持不变

- [ ] **Step 2: `ai-entry.mdc`**

会话开始第 2 点改为：

`多 task 实现：harness-coder（代码 WU）/ harness-implementer（docs/chore）+ cursor-orchestration`

- [ ] **Step 3: `core/routing.md` § Cursor 实现阶段**

将「委派 harness-implementer」改为：

「代码类 WU 委派 `harness-coder`；docs/chore/config 委派 `harness-implementer`」

- [ ] **Step 4: `core/runbooks.md` § 新功能**

步骤 4 编码实现 Cursor 行同步；步骤 60 附近 runbook 同步。

- [ ] **Step 5: 验证**

```bash
rg "harness-coder" adapters/cursor/.cursor/rules/cursor-subagent-routing.mdc core/routing.md
```

- [ ] **Step 6: Commit**

```bash
git add adapters/cursor/.cursor/rules/cursor-subagent-routing.mdc adapters/cursor/.cursor/rules/ai-entry.mdc core/routing.md core/runbooks.md
git commit -m "feat(harness-kit): rules 与 core 路由支持 Coder/Implementer 分流"
```

---

### Task 6: 收窄 Implementer 与更新 Reviewer 措辞

**Files:**
- Modify: `adapters/cursor/orchestration/agents/implementer.md`
- Modify: `adapters/cursor/.cursor/agents/harness-implementer.md`
- Modify: `adapters/cursor/orchestration/agents/reviewer.md`
- Modify: `adapters/cursor/.cursor/agents/harness-reviewer.md`

- [ ] **Step 1: `implementer.md`**

- 角色段：轻量 Worker，**不**用于 feature/bugfix/refactor/ui
- Task Prompt 默认 `wu_type: docs`（或 chore）
- 删除「不要审查自己的代码」若仅针对窄 Worker；保留不重规划

- [ ] **Step 2: `harness-implementer.md`**

- `description` 改为：docs/chore/config 轻量 WU；**不要**写「并行实现必须委派本 subagent 做业务代码」
- 改为：代码类 WU 委派 `harness-coder`

- [ ] **Step 3: reviewer 文件**

- `implementer` → `coder/implementer` 或「实现者（coder 或 implementer）」
- BLOCK 后修复 WU：开 **`harness-coder`**（review-fix）

- [ ] **Step 4: Commit**

```bash
git add adapters/cursor/orchestration/agents/implementer.md adapters/cursor/.cursor/agents/harness-implementer.md adapters/cursor/orchestration/agents/reviewer.md adapters/cursor/.cursor/agents/harness-reviewer.md
git commit -m "refactor(harness-kit): Implementer 收窄为轻量 WU，Reviewer 对齐 Coder"
```

---

### Task 7: 模板、README、bootstrap、cursor-orchestration skill

**Files:**
- Modify: `artifact-templates/wu-checklist.md`
- Modify: `README.md`
- Modify: `entrypoints/AGENTS.cursor-overlay.md`
- Modify: `init/bootstrap.prompt.md`
- Modify: `adapters/cursor/README.md`
- Modify: `adapters/cursor/orchestration/CURSOR-PRECHECK.md`
- Modify: `adapters/agents/.agents/skills/cursor-orchestration/SKILL.md`

- [ ] **Step 1: `wu-checklist.md`**

- 标题说明：Coder 或 Implementer 勾选
- 新增 `## 开发者自检（仅 Coder）`：`self_check`、`open_items`、`skip_reviewer_eligible`
- 完成签名：Coder 完成时间

- [ ] **Step 2: `README.md`**

- 「五套」→「六套」；Worker 表增加 `harness-coder` 行
- 派发说明：代码 → coder

- [ ] **Step 3: `AGENTS.cursor-overlay.md`**

增加 `harness-coder` 条目；implementer 说明收窄

- [ ] **Step 4: `bootstrap.prompt.md` + `adapters/cursor/README.md`**

清单含 `harness-coder.md`

- [ ] **Step 5: `CURSOR-PRECHECK.md`**

检查项 1：六套角色，含 `harness-coder.md`

- [ ] **Step 6: `cursor-orchestration/SKILL.md`**

description 与正文：并行派发 **harness-coder**（代码）与 implementer（轻量）

- [ ] **Step 7: Commit**

```bash
git add artifact-templates/wu-checklist.md README.md entrypoints/AGENTS.cursor-overlay.md init/bootstrap.prompt.md adapters/cursor/README.md adapters/cursor/orchestration/CURSOR-PRECHECK.md adapters/agents/.agents/skills/cursor-orchestration/SKILL.md
git commit -m "docs(harness-kit): 模板与入口文档对齐 Coder 六角色编排"
```

---

### Task 8: 全库一致性检查与收尾

**Files:**
- Modify: `docs/superpowers/specs/2026-05-26-coder-role-design.md`（`status: approved`）

- [ ] **Step 1: grep 漏网之鱼**

```bash
cd /Users/mima0000/Downloads/harness-kit
rg "五套" --glob '*.md' --glob '*.mdc'
rg "代码实现.*harness-implementer|实现 → \`harness-implementer\`" --glob '*.{md,mdc}'
```

对仍暗示「所有代码走 implementer」的命中项逐条改为 coder/implementer 分流（`VENDOR.md` 若仅记录上游映射可注明例外）。

- [ ] **Step 2: 确认 spec 与 plan 对齐**

人工核对 spec § 需要的变更清单 每一项是否已有对应 commit。

- [ ] **Step 3: 更新 spec status**

```yaml
status: approved
```

（仅当全部任务完成）

- [ ] **Step 4: 可选 — 在消费项目中跑 bootstrap**

若本仓库即 harness-kit 源：确认 `scripts/` 中 bootstrap 会复制 `harness-coder.md`（读 `init/bootstrap.prompt.md` 与相关脚本；若无自动复制逻辑，在 Task 7 已改 prompt 即可）。

- [ ] **Step 5: Commit**

```bash
git add docs/superpowers/specs/2026-05-26-coder-role-design.md docs/superpowers/plans/2026-05-26-coder-role.md
git commit -m "chore(harness-kit): Coder 角色实现完成，spec 标记 approved"
```

---

## 验证（整体验收）

| # | 检查 | 命令 / 标准 |
| --- | --- | --- |
| 1 | Coder 双文件存在 | `test -f adapters/cursor/orchestration/agents/coder.md && test -f adapters/cursor/.cursor/agents/harness-coder.md` |
| 2 | skill 路由 | `rg "coder \| feature" adapters/cursor/orchestration/skill-preferences.zh.md` |
| 3 | Dispatcher 路由 | `rg "harness-coder" adapters/cursor/orchestration/dispatcher-workflow.md` |
| 4 | Rules 加载 | `rg "harness-coder" adapters/cursor/.cursor/rules/cursor-subagent-routing.mdc` |
| 5 | 无矛盾「五套」 | `rg "五套" README.md adapters/cursor/orchestration/CURSOR-PRECHECK.md` 应为六套或已更新 |
| 6 | Prompt 可拷贝 | `coder.md` 含 Task Prompt 与 `self_check` 返回格式 |

**手工抽检（推荐）：** 用 spec § Leader→Coder 模板组装一条假 WU prompt，确认字段齐全。

---

## 风险

| 风险 | 缓解 |
| --- | --- |
| 消费项目未 bootstrap 新 agent | bootstrap.prompt + README 说明需重新投影 |
| 旧 plan 仍写 `wu_type: feature` + implementer | runbook 与 Leader 文档强调重标注 |
| 跳过 Reviewer 误用 | dispatcher 步骤 3 粘贴硬条件清单 |

---

## Next

**（写入后须暂停，等用户明确继续 — 见 `harness-kit/core/routing.md` § 阶段门禁）**

- 计划确认 → 说「**开始实现**」或「**执行**」
- 需要调整 → 直接说修改意见
- 想拆分并行 → 说「**并行执行**」（可按本 plan 执行图派 WU）
