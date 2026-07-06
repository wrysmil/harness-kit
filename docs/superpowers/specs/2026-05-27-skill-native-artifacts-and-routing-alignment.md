---
artifact: spec
title: "Skill 原生产物 + 路由对齐（合并方案）"
date: 2026-05-27
status: draft
platform: cursor
route: harness-kit:internal
relates_to:
  - docs/superpowers/specs/2026-05-27-stage-skill-enforcement.md
skills:
  - harness-kit:internal
source:
  - harness-kit/core/routing.md
  - harness-kit/core/artifacts.md
  - harness-kit/artifact-templates/
  - user-review: skill-vs-template
created_at: 2026-05-27
---

# Skill 原生产物 + 路由对齐 — 完整方案（待审）

> **审阅说明：** 本文合并此前讨论的两条线：**(A) 阶段 skill 必用但未真正 Load**、**(B) Harness 短模板干扰 superpowers skill 内置流程**。实施前请审阅 §3 设计原则与 §7 文件清单；批准后将按 §11 分期落地。

---

## 1. 背景与问题

### 1.1 现象

| # | 现象 |
| --- | --- |
| P1 | 用户**未** @ skill 时，Agent 不 Load 路由表要求的阶段 skill；**显式** @ 后才 Read `SKILL.md`。 |
| P2 | Agent 声明 `Harness：设计/计划阶段`，但无 `Skills: brainstorming@… loaded`，直接搜代码、读 `routing.md` / `artifact-templates/spec.md` 后写 spec。 |
| P3 | spec/plan front matter 填了 `skills: [brainstorming]`，但正文是 Harness 短提纲，**未**做 skill 要求的方案对比、TDD 细步、自检等。 |
| P4 | skill 默认写入 `docs/superpowers/specs|plans/`，Harness 要求 `.ai-runtime-artifacts/`，产物分裂，`harness-check` 与门禁指针不一致。 |

### 1.2 根因（归纳）

| 类别 | 原因 |
| --- | --- |
| **加载表冲突** | `routing.md` § 按判定加载 对设计/计划只列 `artifacts.md` + **`artifact-templates/spec|plan.md`**，未列阶段 skill；Git/多 task 行却列了 skill → 模型跟表走、跳过 Load。 |
| **入口三份表不一致** | `AGENTS.md`、`AGENTS.cursor-overlay.md`、`ai-entry.mdc` 均写「写产物 → artifact-templates」，强化「模板 = 完成设计」。 |
| **模板替代 skill** | Harness `spec.md` / `plan.md` 是短提纲，与 `brainstorming` / `writing-plans` 深度流程**竞争**；Agent 填模板即以为完成阶段。 |
| **用语弱化** | `leader.md`「推荐 skill」、`skill-preferences`「按需加载」、runbooks「使用 brainstorming」未写「先 Read SKILL.md」。 |
| **其它误导** | `continuous-loop` 第 1 步用 Task explore 写 spec；`harness-explorer`「Use proactively」；`project.profile` 指向旧 spec 供直接阅读。 |
| **校验滞后** | `harness-check`  mostly 查 front matter；Hooks 默认关闭；对话中无硬拦截。 |

### 1.3 与已批准 spec 的关系

[`2026-05-27-stage-skill-enforcement.md`](./2026-05-27-stage-skill-enforcement.md)（**已 approved**）定义了：

- Route 列 skill **必 Load**、子 Agent `### Skills 使用`、front matter `skills` 非空等。

**本文是其实施补全 + 产物策略修正**，解决「规则写了仍被模板和加载表抵消」的问题。不推翻 stage-skill 原则，而是明确：

> **必 Load 的是 skill 流程与 skill 规定的文档结构，不是 Harness 同名短模板。**

---

## 2. 目标与非目标

### 2.1 目标

1. **有阶段 skill 的产物**：正文结构以 **SKILL.md 流程与内置/规定的文档形态** 为准；Harness **不**提供与之平行的「短正文模板」。
2. **无 skill / 编排专有产物**：继续使用 `artifact-templates/`（execution-log、dispatch-track、handoff、wu-checklist 等）。
3. **统一落盘路径**：Harness 项目内，brainstorming / writing-plans 产出写入 **`.ai-runtime-artifacts/`**（覆盖 skill 默认的 `docs/superpowers/…` 说明，写在 `artifacts.md`）。
4. **修正所有「按判定加载」与入口加载表**，设计/计划/验证/缺陷行 **先 skill、再 artifacts 契约**，**禁止**将 `artifact-templates/spec.md` / `plan.md` 列为设计/计划阶段必读正文模板。
5. **保留 Harness 增值**：阶段门禁 `## Next`、front matter、`skills_evidence`、Cursor 执行图 / WU 元数据（作为 **附录**，不替代 writing-plans 任务体）。

### 2.2 非目标

- 不修改上游 superpowers 仓库内的 `brainstorming` / `writing-plans` SKILL.md 正文（仅在 Harness `artifacts.md` / 项目 overlay 声明路径覆盖）。
- 不要求全局「任意工具调用前 Load 全量 skill」（仍仅 Route 列 + WU 列表）。
- 不在本方案实现 LLM 无法绕过的硬拦截（P2 Hooks 仍为可选提醒）。
- 不一次性做正文质量 lint（如强制 spec 含「方案对比」），可作为 P2 增强。

---

## 3. 设计原则（审阅重点）

### 3.1 唯一原则（用户确认 🎯）

```text
有阶段 skill → 产物形态以该 skill 的流程与文档结构为准（须先 Load SKILL.md）
无 stage skill / Harness 编排专有 → 使用 artifact-templates/ 中的模板
Harness 一律管辖：目录、front matter、阶段门禁、校验；不管辖 skill 正文章节怎么写
```

### 3.2 三层分工

| 层 | 职责 | 来源 |
| --- | --- | --- |
| **Skill 正文** | 怎么做（澄清、方案对比、TDD 任务粒度、验证纪律） | `~/.agents/skills/` 或 `.cursor/skills/` |
| **Harness 契约** | 写在哪、FM 字段、暂停话术、check 规则 | `core/artifacts.md`、`core/routing.md` |
| **Harness 模板** | 仅 **无对应 stage skill** 或 **编排附录** | `artifact-templates/*` |

### 3.3 禁止

- **禁止**在未 Load 阶段 skill 前，以「填写 `artifact-templates/spec.md` / `plan.md` 正文」作为设计/计划完成标准。
- **禁止**在 `routing.md` § 按判定加载 中，将上述两文件列为需求澄清/实施计划的「再读」项（可列为 overlay 指针，见 §6.2）。
- **禁止**用 Harness 短提纲替代 skill 强制步骤（如 brainstorming 的 2–3 方案对比、writing-plans 的逐步 TDD checkbox）。

---

## 4. 产物分工表（单一真相源）

### 4.1 阶段 skill 产物（正文跟 skill）

| 阶段 | Route skill | 保存路径 | 正文结构 | Harness 提供 |
| --- | --- | --- | --- | --- |
| 需求/设计 | `brainstorming` | `.ai-runtime-artifacts/specs/YYYY-MM-DD-<topic>-spec.md` | **SKILL.md**（探索、一问一答、2–3 方案、设计节、自检、用户审阅） | FM + `## Next` 门禁（见 §6.2 overlay） |
| 实施计划 | `writing-plans` | `.ai-runtime-artifacts/plans/YYYY-MM-DD-<topic>-plan.md` + 同 stem `*-dispatch.md` | **SKILL.md**（Task 细步等） | FM + `## Next`；执行图在 **dispatch**（§6.3 已决议） |
| 验证 | `verification-before-completion` | `.ai-runtime-artifacts/verifications/` | skill 纪律（先跑命令再声称）+ 简短记录节 | `verification.harness-overlay.md` 或 artifacts 示例 |
| 缺陷 | `systematic-debugging` | `specs/` 或 `verifications/` | SKILL 四阶段 | P2 可选 `investigation.md` |

**路径覆盖（写入 `artifacts.md`）：**

```text
接入 Harness 的项目：brainstorming / writing-plans 产物写入 .ai-runtime-artifacts/，
不写入 docs/superpowers/（除非用户显式要求保留双份）。
```

### 4.2 无 stage skill / 编排专有（全文用 Harness 模板）

| 产物 | 模板文件 | 目录 |
| --- | --- | --- |
| execution-log | `execution-log.md` | `execution-logs/` |
| dispatch-track | `dispatch-track.md` | `execution-logs/tracking/` |
| handoff | `handoff.md` | `execution-logs/` |
| progress-summary | `progress.md` | `execution-logs/` |
| wu-checklist | `wu-checklist.md` | 与 plan 同目录或约定路径 |
| research-report | `research-report.md` | `research/` |
| decision-record | `decision.md` | `decisions/` |
| review（新增） | `review.md`（§6.4） | `reviews/` |
| retro（可选 P2） | `retro.md` | `retros/` |

### 4.3 plan、dispatch 与 wu-checklist 的关系（§6.3 已决议）

| 文档 | 角色 | 用户审阅 |
| --- | --- | --- |
| **`*-plan.md`** | writing-plans 级实施计划（做什么、怎么做、测什么） | **计划门禁**：「写计划」阶段主要看此文件；大改任务/范围时改它 |
| **`*-dispatch.md`** | Harness 执行图：GROUP / WU / `wu_type` / `wu_skills` | **派发前可多次审**；并行拆分、依赖、派谁改时**只改此文件**，diff 不与 Task 细步混在一起 |
| **wu-checklist.md** | **单 WU** 可执行面；Coder 用 | 实现阶段按 WU 审（可选） |

**命名：** 与 plan 同 stem，例如 `2026-05-27-foo-plan.md` + `2026-05-27-foo-dispatch.md`。  
**plan front matter** 增加 `dispatch: <path>` 指向 dispatch 文件。

---

## 5. 路由与加载规则（修订全文）

### 5.1 `core/routing.md` § 按判定加载 — **替换表**

| 判定 | 再读（按序） |
| --- | --- |
| 小改动 / 单文件机械修改 | 无（可选 `project.profile.md`） |
| **需求澄清 / 方案设计** | **①** Load `brainstorming`（Read `SKILL.md`）→ **②** `core/artifacts.md` → **③**（**已决议：允许**）skill 澄清已起步后，涉及模块时再读 `project.profile.md`、`context-map.md`。**禁止**未 Load skill 前用 profile/扫代码代替 brainstorming；**禁止**用 `artifact-templates/spec.md` 当正文模板。 |
| **实施计划** | **①** Load `writing-plans` → **②** `artifacts.md` → **③** `plan.harness-overlay.md`（FM + Next）；**④** 并行时另写 `*-dispatch.md`（模板 `dispatch.harness-overlay.md`，§6.3）。 |
| 多 task 编码（Cursor） | `cursor-orchestration` skill → `dispatcher-workflow.md`；派发 WU 时 `skill-preferences.zh.md` |
| **代码审查 / 验证** | **①** Load `verification-before-completion` → **②** `project.verification.md`、`core/verification.md` |
| **缺陷调查** | **①** Load `systematic-debugging` → **②** `project.profile.md`；Cursor 委派见 `orchestration/agents/` |
| 信息调研 | 委派 `harness-web-investigator` → `web-investigator.md`；产物用 `research-report.md` |
| Git | **`git-xywh` skill** → `project.git.md` → `runbooks.md` § Git |
| 架构决策 | `artifacts.md` + `decision.md`（无统一 stage skill，保留 Harness 模板） |
| runbook 明示 | `runbooks.md` 对应节 |

**在 § 按判定加载 表后增加一段（短）：**

```markdown
**Skill 产物：** 上表中带 stage skill 的阶段，正文结构以已 Load 的 SKILL.md 为准；
`artifact-templates/spec.md` / `plan.md` 已废弃为正文模板，见 `plan.harness-overlay.md` / `spec.harness-overlay.md`。
```

**保留现有 § 阶段指定 skill 必用**（不变）。

### 5.2 `core/routing.md` § 阶段指定 skill 必用 — **增补一句**

```markdown
- Load 阶段 skill 后，**不得**用 `artifact-templates` 中同名文件的**正文**替代 skill 流程；模板仅提供 overlay（FM、Next、执行图）。
```

### 5.3 入口文件加载规则 — **统一替换**

以下三处 **同步**为同一张表（仅列差异列）：

| 文件 | 改动 |
| --- | --- |
| `entrypoints/AGENTS.md` § 加载规则 | 删除「写产物 → artifact-templates/」；改为 §5.1 对应行 |
| `entrypoints/AGENTS.cursor-overlay.md` | 同上 |
| `adapters/cursor/.cursor/rules/ai-entry.mdc` | 删表中「写 spec/plan → artifact-templates」行；第 3 步改为「先 Load 阶段 skill，再读 artifacts 契约」 |

**`ai-entry.mdc` 本地表建议：**

| 判定 | 再读 |
| --- | --- |
| 设计 / spec | `brainstorming` skill → `core/artifacts.md` |
| 计划 | `writing-plans` skill → `artifacts.md` → `plan.harness-overlay.md` |
| 验证 | `verification-before-completion` → `project.verification.md` |
| 决策 | `artifacts.md` + `decision.md` |
| Git / 多 task / WU | （保持现有） |

---

## 6. 模板文件变更

### 6.1 重命名与废弃

| 现文件 | 动作 | 新角色 |
| --- | --- | --- |
| `artifact-templates/spec.md` | **重命名** → `spec.harness-overlay.md` | 仅 YAML FM 示例 + `## Next` + 注释「正文见 brainstorming skill」 |
| `artifact-templates/plan.md` | **重命名** → `plan.harness-overlay.md`；**新建** `dispatch.harness-overlay.md` | plan overlay：FM + Next；dispatch：执行图 + 与 plan 的 `dispatch:` 指针 |
| `artifact-templates/spec.md` / `plan.md` | **保留 stub（已决议 §6.1-A）** | 3–5 行 redirect：「正文见 skill；契约见 `*-harness-overlay.md`；执行图见 `*-dispatch.md`。」 |

**§6.1 审阅决议：A（stub redirect）** — 不删除旧文件名，避免旧链接与 harness-check 路径断裂。

### 6.2 `spec.harness-overlay.md` 建议内容

```markdown
---
artifact: spec
route: superpowers:brainstorming
skills:
  - brainstorming
skills_evidence:
  - <path-to-brainstorming/SKILL.md>
source:
  - harness-kit/core/routing.md
created_at: <YYYY-MM-DD>
---

# Harness overlay（非正文模板）

> **正文：** 按已 Load 的 **brainstorming** skill 撰写（含方案对比、设计节、Spec 自检等）。
> **禁止**用本文件历史版「背景/目标/方案」短提纲替代 skill 流程。
> **路径：** `.ai-runtime-artifacts/specs/YYYY-MM-DD-<topic>-spec.md`

## Next

（门禁话术 — 与现 spec.md 相同）
```

### 6.3 执行图：独立 `*-dispatch.md`（审阅决议 + 推荐理由）

**决议：** 执行图**不**放在 plan 文末附录，使用与 plan **同 stem** 的独立文件：

```text
.ai-runtime-artifacts/plans/YYYY-MM-DD-<topic>-plan.md      ← writing-plans 正文（用户「计划门禁」）
.ai-runtime-artifacts/plans/YYYY-MM-DD-<topic>-dispatch.md  ← GROUP / WU / wu_type / wu_skills
```

**推荐理由（甲方常审 plan、可能 5–6 轮且改动大）：**

| 关切 | 独立 dispatch 的好处 |
| --- | --- |
| 审阅 diff 清晰 | 改并行拆分时只 diff dispatch，不淹没 writing-plans 里大量 Task/代码块 |
| 多轮修订 | plan 正文相对稳定后，仍可反复改 WU/依赖/派谁，无需动已认可的 Task 节 |
| 门禁分离 | 「写计划」主要审 `*-plan.md`；「开始实现」前或每次大改派发策略时审 `*-dispatch.md` |
| 大改范围 | 大范围调整 GROUP/文件所有权时，dispatch 可整文件重写，plan 仍保留实施真理源 |

**`plan.harness-overlay.md`：** FM（含 `dispatch: ../plans/...-dispatch.md`）+ `## Next`；正文结构见 writing-plans skill。

**`dispatch.harness-overlay.md`（新建模板）：**

```markdown
---
artifact: implementation-dispatch
route: cursor-orchestration:dispatcher-workflow
plan: .ai-runtime-artifacts/plans/YYYY-MM-DD-<topic>-plan.md
skills:
  - writing-plans
  - cursor-orchestration
created_at: <YYYY-MM-DD>
---

# <Topic> — Harness 执行图

> 实施步骤以 **plan** 为准；本文件只描述并行 GROUP / WU 与派发。

## 执行图

GROUP-1:
  WU-01: … | 文件: … | wu_type: feature | wu_skills: auto

## 变更记录（可选，便于多轮审阅）

| 轮次 | 日期 | 变更摘要 |
| --- | --- | --- |
| 1 | | 初稿 |
```

**Leader：** 用户说「开始实现」前，须存在与 plan 配对的 dispatch（多 task 时）；仅单 WU/小改动可写 `dispatch: n/a` 于 plan FM。

**暂停话术（可选）：** 大改 dispatch 后向用户一句：「执行图已更新：`<path>`，请确认后再派发。」

### 6.4 其它模板微调

| 文件 | 改动 |
| --- | --- |
| `verification.md` | 改为 `verification.harness-overlay.md` 或保留名；增加「验证纪律见 verification-before-completion skill」；补 `skills_evidence` 示例 |
| `decision.md` | `skills:` 改为示例 `generalPurpose` 或留空说明；去掉 `<skill>` 占位 |
| `execution-log.md` | `skills:` 用真实示例如 `cursor-orchestration`；去掉 `<skill>` |
| `review.md` | **新建**（`artifacts.md` 已列 `review` 类型但无模板） |
| `retro.md` | P2 新建（可选） |

### 6.5 `core/artifacts.md` — **新增 § Skill 产物 vs Harness 模板**

（§3 原则 + §4 分工表浓缩写入；含路径覆盖、overlay 文件列表。）

**`skills_evidence`：** P0 仍**可选**（overlay 给示例）；**P1 起**对含 stage skill 的 spec/plan/verification **必填**（§13.4 已决议）；`harness-check` 在 P1 增加校验。

---

## 7. 其它规则与文档改动清单

### 7.1 P0 — 堵住「不 Load skill / 用模板代替」

| 文件 | 改动要点 |
| --- | --- |
| `core/routing.md` | §5.1 表替换；§5.2 增补；§4.3 与 stage-skill 关系已在 spec §1.3 |
| `core/artifacts.md` | 新 § Skill 产物 vs Harness 模板；路径覆盖 |
| `artifact-templates/spec.harness-overlay.md` | 新建（§6.2） |
| `artifact-templates/plan.harness-overlay.md` | 新建（§6.3） |
| `artifact-templates/spec.md` / `plan.md` | stub 或删除（§6.1） |
| `entrypoints/AGENTS.md` | §5.3 |
| `entrypoints/AGENTS.cursor-overlay.md` | §5.3 |
| `adapters/cursor/.cursor/rules/ai-entry.mdc` | §5.3 |
| `core/runbooks.md` | 「使用 brainstorming」→「先 Read/invoke `brainstorming` SKILL.md，再…」；Git 小节已清晰，保持 |
| `adapters/cursor/orchestration/agents/leader.md` | 「推荐 skill」→「阶段 skill（必用）」；删「读 spec 模板」类表述 |
| `scripts/harness-check.sh` | 模板存在性改为检查 `*-harness-overlay.md`；stub 若保留则仍检查 `spec.md` 仅为 redirect |

### 7.2 P1 — 消歧与闭环（stage-skill 子 Agent 链 + 误导项）

| 文件 | 改动要点 |
| --- | --- |
| `adapters/cursor/orchestration/skill-preferences.zh.md` | 文首框：**本文档仅 WU 级**；Leader 阶段 skill 见 `routing.md` §；「按需」不适用于 stage skill |
| `adapters/cursor/.cursor/skills/README.md` | 说明 brainstorming/writing-plans 在全局路径；**非**本目录副本 |
| `adapters/cursor/orchestration/continuous-loop.md` | 阶段 1：Task explore → **brainstorming + spec** |
| `README.md` § 阶段怎么走 | 每阶段标明 skill；不写「只写 specs 目录」 |
| `project.profile.md` | 设计阶段：旧 spec/research **作参考**，不替代 brainstorming |
| `adapters/cursor/.cursor/hooks/harness-session-init.sh` | 注入：有 route skill 须 `Skills:` 行；勿用 artifact-templates 代替 skill |
| `adapters/cursor/orchestration/dispatcher-workflow.md` | plan 附录 / overlay 文件名引用 |
| `adapters/cursor/orchestration/tracking/schema.md` | 模板路径更新 |
| `init/bootstrap.prompt.md` | 列举模板时区分 overlay vs 编排模板 |
| `docs/superpowers/specs/2026-05-27-stage-skill-enforcement.md` | 文首 **Amendment** 指向本文；§7.1 删除「读 artifact-templates/spec 写 spec」负例中的旧路径或加注「已废弃」 |

**已在 stage-skill spec 中、本文不重复展开的 P1：** dispatcher 禁裸 `auto`、`### Skills 使用`、各 `harness-*.md` 一句（见原 spec §7.2）。

### 7.3 P2 — 可选增强

| 文件 | 改动 |
| --- | --- |
| `artifact-templates/review.md` / `retro.md` | 新建 |
| `artifact-templates/investigation.md` | 缺陷调查薄模板 |
| `harness-check.sh` | 可选：spec 正文含「方案对比」等关键字（脆弱，默认不做） |

| 项目 `.cursor/rules` 一句 | `brainstorming` / `writing-plans` 落盘路径覆盖 |

---

## 8. 短提示汇编（写入规则时照抄）

### 8.1 `routing.md` / `ai-entry` 增补块

```markdown
## Skill 产物（Harness）

- 有阶段 skill：先 Load SKILL.md；正文按 skill，落盘 `.ai-runtime-artifacts/`。
- 禁止用 artifact-templates 旧 spec/plan 短提纲代替 skill。
- 仅 FM + Next + 执行图：见 `spec.harness-overlay.md` / `plan.harness-overlay.md`。
- 无 stage skill 的编排产物：用 artifact-templates/（execution-log、track、handoff 等）。
```

### 8.2 用户纠偏（一句）

```text
阶段 skill 未执行：请先 Load 本 route 的 SKILL.md，按 skill 写 spec/plan 到 .ai-runtime-artifacts/，并补 Skills: 行；不要用 artifact-templates 短模板代替。
```

### 8.3 Leader 会话头（示例）

```text
「Harness：superpowers:brainstorming」
Skills: brainstorming@~/.agents/skills/brainstorming/SKILL.md loaded
```

---

## 9. 与 superpowers skill 的对照（实施参考）

| Skill 强制项 | Harness 如何处理 |
| --- | --- |
| brainstorming：2–3 方案、一问一答、自检 | **不写进 overlay**；验收靠审阅 + 可选 P2 lint |
| brainstorming：默认 `docs/superpowers/specs/` | `artifacts.md` **路径覆盖** |
| writing-plans：Task 细步 + 代码块 | plan 正文跟 skill；执行图在附录 |
| writing-plans：Subagent-Driven vs Inline | Cursor 第三条：**cursor-orchestration**（写在 plan 附录或 overlay 注释） |
| verification：先跑命令再声称 | overlay 记录命令/结果；纪律在 skill |

---

## 10. 验收标准

### 10.1 Leader / 设计阶段

- [ ] 首句 `「Harness：superpowers:brainstorming」` + `Skills: … loaded`
- [ ] 对话中 **Read `brainstorming/.../SKILL.md` 早于** 创建 spec 文件
- [ ] **未**将 `artifact-templates/spec.md` 短提纲当作正文（或仅打开 stub/overlay）
- [ ] spec 在 `.ai-runtime-artifacts/specs/`，含 skill 典型结构（至少方案对比或等价节）
- [ ] spec FM：`skills` 非空，建议含 `skills_evidence`
- [ ] 写入后暂停，`## Next` 存在

### 10.2 计划阶段

- [ ] Load `writing-plans` 后再写 plan
- [ ] plan 含 writing-plans 级 Task（非仅「步骤 1、2」）
- [ ] 若有并行：存在配对 `*-dispatch.md`，plan FM 含 `dispatch:` 指针

### 10.3 负例（应判失败）

- [ ] 只读 `routing.md` + `artifact-templates/spec.md` 写 spec，未 Load brainstorming
- [ ] spec 仅 Harness 旧版六节短提纲、无方案对比
- [ ] 产物写在 `docs/superpowers/` 且未说明

### 10.4 编排模板（无 skill）

- [ ] execution-log / DISPATCH-TRACK 仍按 `artifact-templates/` 创建
- [ ] `harness-check.sh` 通过

---

## 11. 实施分期

| 阶段 | 范围 | 建议 commit |
| --- | --- | --- |
| **P0** | §7.1 + §6 overlay/stub + `artifacts.md` | `feat(harness-kit): skill-native artifacts + routing load order (P0)` |
| **P1** | §7.2 + stage-skill 剩余子 Agent 项 | `feat(harness-kit): routing de-conflict + hooks hint (P1)` |
| **P2** | §7.3 可选模板与 lint | 按需 |

**依赖：** P0 应在业务项目 **重新 bootstrap `.cursor/rules`** 后验证。

---

## 12. 风险与缓解

| 风险 | 缓解 |
| --- | --- |
| 旧文档/话术仍引用 `artifact-templates/spec.md` | stub redirect + grep 全库 |
| 同仓库 `docs/superpowers/specs/` 与 `.ai-runtime-artifacts/` 并存 | `artifacts.md` 写清主路径；迁移期双份需人工合并 |
| 模型仍先搜代码 | `project.profile` 注明设计阶段先 skill；用户纠偏句 §8.2 |
| overlay 文件名变长 | 仅 Leader 读，频率低 |

---

## 13. 审阅决议（全部已定）

| # | 议题 | 决议 | 日期 |
| --- | --- | --- | --- |
| 1 | §6.1 stub vs 删除 | **A：保留 `spec.md` / `plan.md` 为 redirect stub** | 2026-05-27 |
| 2 | §5.1 设计阶段读 profile/map | **允许**：须在 **Load brainstorming 之后**；禁止用其替代 skill 澄清 | 2026-05-27 |
| 3 | §6.3 执行图位置 | **独立 `*-dispatch.md`**（同 stem；plan FM 含 `dispatch:` 指针） | 2026-05-27 |
| 4 | `skills_evidence` 必填时机 | **P1 必填**（P0 仅 overlay 示例 + `skills` 非空）；见 §13.1 | 2026-05-27 |
| 5 | 修订 stage-skill-enforcement | **仅交叉引用本文**，不改正文；见 §13.2 | 2026-05-27 |
| 6 | P2 spec「方案对比」关键字检查 | **不做**（人工审 spec 即可）；见 §13.3 | 2026-05-27 |

### 13.1 `skills_evidence` 是什么？为何 P1 才必填？

**是什么：** spec/plan 等文件 YAML 里的一列，记录 Leader **实际 Read 过**的 `SKILL.md` 路径，或 `skipped: brainstorming (not found)`。

```yaml
skills:
  - brainstorming
skills_evidence:
  - ~/.agents/skills/brainstorming/SKILL.md
```

**和 `skills` 的区别：**

| 字段 | 含义 | 现状 |
| --- | --- | --- |
| `skills` | 声称用了哪些 slug | `harness-check` **已**要求非空（有 stage skill 的 route） |
| `skills_evidence` | 证明读过的路径 / skipped 原因 | 目前**不**检查，可填假路径 |

**P0 vs P1：**

| 阶段 | 要求 |
| --- | --- |
| **P0** | 只强制 `skills` 非空 + Load 顺序写进 routing；overlay 里给 `skills_evidence` **示例** |
| **P1** | `harness-check` 增加：`skills_evidence` 至少一行，且非占位；与 `skills` 列表对应 |

**决议理由：** P0 先解决「不 Load skill、用短模板」主矛盾；evidence 防「填了 brainstorming 但没 Read」是第二层，放 P1 不拖慢首轮落地。

### 13.2 要不要改旧的 stage-skill spec？

**背景：** [`2026-05-27-stage-skill-enforcement.md`](./2026-05-27-stage-skill-enforcement.md) 已是 **approved**，但 §7.1 仍写「读 `artifact-templates/spec.md` 写 spec」等，与本文冲突。

| 选项 | 做法 |
| --- | --- |
| **改正文** | 在旧 spec 里改加载表、加 Amendment 节 → 两份文档都要维护 |
| **仅交叉引用（决议）** | 旧 spec **status 保持 approved**；文首加 3–5 行 **Superseded in part by** 指向本文；实施以**本文**为准 |

**决议理由：** 避免改已批准文档的流程争议；新行为单一真相源 = 本文 + 实施后的 `routing.md` / `artifacts.md`。

### 13.3 P2「方案对比」关键字检查是什么？为何不做？

**是什么：** 在 `harness-check.sh` 里扫 spec 正文是否含「方案对比」「Approaches」等字样，没有则 **fail**，逼 Agent 走完 brainstorming 的比选步骤。

| 优点 | 缺点 |
| --- | --- |
| 自动抓「只写单一方案」的偷懒 spec | 英文/中文标题不统一易误报；合规格式也可能不用这四个字 |
| | 维护成本高，和你**人工审 plan/spec** 重复 |

**决议：** **不做**自动关键字检查；验收靠 §10 人工清单 + 你审 spec 时看是否有 2–3 方案对比（brainstorming skill 要求）。

---

## 14. 参考

- `harness-kit/core/routing.md`
- `harness-kit/core/artifacts.md`
- `harness-kit/docs/superpowers/specs/2026-05-27-stage-skill-enforcement.md`
- `~/.agents/skills/brainstorming/SKILL.md`
- `~/.agents/skills/writing-plans/SKILL.md`
- `~/.agents/skills/verification-before-completion/SKILL.md`

---

## 附录 A：冲突项与本文决议对照

| 冲突项 | 决议 |
| --- | --- |
| 按判定加载无 stage skill | §5.1 表重写 |
| AGENTS / overlay / ai-entry 写 artifact-templates | §5.3 同步 |
| spec/plan 短模板 vs skill | §3–§6 overlay 化 |
| skill 路径 `docs/superpowers/` vs `.ai-runtime-artifacts/` | §4.1 路径覆盖 |
| leader「推荐 skill」 | §7.1 改「必用」 |
| skill-preferences「按需」 | §7.2 限定 WU 级 |
| continuous-loop explore 写 spec | §7.2 改 brainstorming |
| harness-explorer proactive | §7.2 README/leader 注明设计阶段优先 brainstorming |
| stage-skill 已 approved 与模板冲突 | §1.3 本文补全 |
| 缺 review 模板 | §6.4 P1/P2 |
| execution-log `<skill>` 占位 | §6.4 修 |
| using-superpowers vs Harness 窄绑定 | 不全局强制；仅 Route 列 + 用户 @ |

---

## 附录 B：P0/P1 实施检查表

- [x] `core/routing.md`
- [x] `core/artifacts.md`
- [x] `artifact-templates/spec.harness-overlay.md`
- [x] `artifact-templates/plan.harness-overlay.md`
- [x] `artifact-templates/dispatch.harness-overlay.md`
- [x] `artifact-templates/spec.md`（stub）
- [x] `artifact-templates/plan.md`（stub）
- [x] `entrypoints/AGENTS.md`
- [x] `entrypoints/AGENTS.cursor-overlay.md`
- [x] `adapters/cursor/.cursor/rules/ai-entry.mdc`
- [x] `core/runbooks.md`
- [x] `adapters/cursor/orchestration/agents/leader.md`
- [x] `scripts/harness-check.sh`（含 P1 `skills_evidence`）
- [x] P1：`skill-preferences`、`README`、`continuous-loop`、`project.profile`、`hooks`、`dispatcher`、`tracking`、`bootstrap`、`stage-skill` 交叉引用

---

**状态：** `approved`（2026-05-27，§13 全部决议已定）

**实施记录：** 2026-05-27 已完成 P0 + P1（附录 B 已勾选）；`bash scripts/harness-check.sh` 通过。业务项目须重新 bootstrap `.cursor/rules` 与 `artifact-templates` 投影后生效。
