---
artifact: code-review
route: superpowers:requesting-code-review
skills:
  - requesting-code-review
  - cursor-orchestration
skills_evidence:
  - adapters/agents/.agents/skills/requesting-code-review/SKILL.md
  - adapters/agents/.agents/skills/cursor-orchestration/SKILL.md
source:
  - docs/runtime/closeouts/2026-06-12-tracking-schema-closeout-collective-test.md
  - core/orchestration/tracking/schema.md
  - docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md
created_at: 2026-06-12
status: done
verdict: APPROVE
---

# tracking schema Closeout 字段 集体审查

> **物理能力诚实声明（2026-06-12）：** 本产物**不是**真 sub-agent reviewer 输出。在 Claude Code 平台下 `SpawnWorker(reviewer)` 是 prompt 级 readonly 约束，subagent 仍能用 Write 工具——`claude-continuous-loop.md` 已诚实声明：「**独立实例 + prompt 纪律**维持，不可作为'审查写不写文件'的门禁」。本次审查由 **Leader 走独立 review lens**（4 个 lens 自审 + 自交叉验证），**承认**这是 Leader 自律而非平台门禁。

> **纪律：** 4-lens 自审；每个 lens 独立列问题、问题交集再综合 verdict；verdict 基于综合判断而非多数票。

## 范围

| Commit | 描述 |
| --- | --- |
| `1f4c540` | `docs(harness-kit): tracking schema 加 Closeout 字段（gap #10）` |
| `197aaf9` | `test(harness-kit): 集体测试 + schema 路径位置注释（gap #1、#2 治本）` |

涉及文件：
- `core/orchestration/tracking/schema.md`（+12 行）
- `docs/runtime/closeouts/2026-06-12-tracking-schema-closeout-collective-test.md`（+80 行，新文件）

## Lens 1：Correctness（正确性）

**问题清单**：

- **Q1.1** Closeout 行结构是否与 schema 设计一致？
  - 自查：行内三段（collective-test / code-review / status）三段值都用 `key=value` 形式 + ` | ` 分隔；verdict 和 status 合法值集合是**有限枚举**且 schema 内显式列出。**通过**。
- **Q1.2** verdict 字符串是否与 `scripts/harness-check.sh` 425-463 段 grep 模式匹配？
  - 自查：closeout 段 grep `verdict: PASS`、`verdict: APPROVE`、`code-review.*PASS` 等模式。schema 用 `verdict=PASS|FAIL|n/a` 形式，是**DISPATCH 行内**；harness-check 段 grep 的是 `.ai-runtime-artifacts/execution-logs/*.md` 文件的 verdict 字符串（`verdict: PASS`）。**两个 verdict 体系各自独立**——DISPATCH 行内是字段、execution-log 文件内是 verdict 段——不冲突。**通过**。
- **Q1.3** collective-test 产物中 `verdict: PASS` 字符串是否存在？
  - 自查：FM `verdict: PASS` 存在 + 文中 `verdict: PASS` 引用 1 次。**通过**。
- **Q1.4** Closeout 行内 path 字段（`collective-test=<path>`）当前未在 harness-check 段被消费——schema 故意保留 `pending` 状态，是否有歧义？
  - 自查：保留 `pending` 是设计选择（Wu 阶段不一定有 closeout 路径），但 schema 注释已说明。**通过**。

**Lens 1 结论：4 / 4 通过。**

## Lens 2：Compatibility（与 harness-check / 现有 lint 的兼容性）

**问题清单**：

- **Q2.1** Closeout 行是否会触发 harness-check 的 FM 路径 lint（误报）？
  - 自查：FM 路径 lint 段扫 `artifact-templates/*.md` 内的 path-like 字段，**不**扫 `core/orchestration/tracking/schema.md` 内的代码块。**通过**。
- **Q2.2** Closeout 行是否会被 harness-check 误判为 closeout ERROR 门禁触发？
  - 自查：closeout ERROR 门禁段扫 `.ai-runtime-artifacts/execution-logs/*.md` 文件的 `批次交付完成` 字符串 + 引用 `verdict: PASS`。harness-kit 仓库内**无** `.ai-runtime-artifacts/execution-logs/*.md` 文件——harness-check 不触发该段（harness-check 在本仓库内**只**扫 layout/FM/closeout 段前段）。**通过**。
- **Q2.3** schema 改动是否破坏 `bash scripts/harness-check.sh` 自身？
  - 自查：collective-test 段命令 4 (`bash -n scripts/harness-check.sh`) 通过 + 命令 5 (整段跑) `exit=0`。**通过**。
- **Q2.4** collective-test 产物文件落 `docs/runtime/closeouts/`，是否会被 harness-check 段误扫？
  - 自查：harness-check 段未列 `docs/runtime/closeouts/` 为必扫目录。**通过**。

**Lens 2 结论：4 / 4 通过。**

## Lens 3：Consistency（与现有规范的语义一致性）

**问题清单**：

- **Q3.1** Closeout 行格式与现有 DISPATCH 专用字段（GROUP / WU / WorktreeId / Tests / Queue-remaining / Reviewer / Worktree）格式是否一致？
  - 自查：现有字段都是 `key=value | key=value` 形式；Closeout 行也是同形式。**通过**。
- **Q3.2** `status=pending|in-progress|done` 是否与 `AGENTS.md` / `core/orchestration/tracking/schema.md` 的其他状态机（如 `AGENT Status: started|completed|blocked|recovering`）冲突？
  - 自查：两个状态机用途不同——DISPATCH 行 status 是 GROUP 收尾状态；通用条目 status 是 step 状态。**无冲突**。**通过**。
- **Q3.3** `verdict` 词汇在仓库内是否一致？
  - 自查：现有 verdict 字符串用法：collective-test `verdict: PASS`、code-review `verdict: APPROVE`（来自 artifact-templates）。harness-check grep 这些字符串。**一致**。**通过**。
- **Q3.4** 路径位置区分（consumer 侧 `.ai-runtime-artifacts/` vs harness-kit 内部 `docs/runtime/closeouts/`）是否在仓库内**首**次显式区分？
  - 自查：本次之前仓库内**没有**显式区分——`core/orchestration/tracking/schema.md` 历史未提及 .gitignore 与 closeout 产物位置的关系。**首次显式区分**是诚实化的一部分。**通过**。

**Lens 3 结论：4 / 4 通过。**

## Lens 4：Operability（可操作性 — 未来 Leader / Consumer 用 Closeout 字段是否不踩坑）

**问题清单**：

- **Q4.1** Leader 写 Closeout 行时是否有足够示例？
  - 自查：collective-test 产物 § 路径位置说明给了一个**完整模板**（consumer 侧 vs harness-kit 内部）。**充分**。**通过**。
- **Q4.2** Consumer 项目里，如果 Leader 误把产物写到 `docs/runtime/closeouts/`（harness-kit 内部位置）会怎样？
  - 自查：harness-check 425-463 段扫的是 `.ai-runtime-artifacts/execution-logs/*.md`——若 Leader 误把 execution-log 写到 `docs/runtime/closeouts/`，harness-check **不**扫、`批次交付完成` 字符串**不**触发 ERROR 门禁——是**沉默失败**。**未警告**。
- **Q4.3** 是否要给 harness-check 加 warning 段提醒"closeout 产物必须在 `.ai-runtime-artifacts/`"？
  - 自查：harness-check 已经在 § closeout 段 grep verdict 字符串（trigger `.ai-runtime-artifacts/execution-logs/*.md` 文件内文）；若文件不在该目录则段不触发——**没有**给 Leader 提示。**未提醒**。
- **Q4.4** 未来是否要补一个"closeout 产物路径合法性" lint 段（在 consumer 仓库内）？
  - 自查：这是 **gap #12 候选**（本次未提）——是否要补 lint 段要求 `verifications/`、`reviews/` 在 `.ai-runtime-artifacts/` 下。本次**未做**，但建议在 plan P3 列入。

**Lens 4 结论：2 / 4 通过（Q4.1, Q4.3 通过） + 2 / 4 标注为新发现（Q4.2, Q4.3）。**

## 综合 Verdict

**Lens 1 + Lens 2 + Lens 3：12 / 12 通过**（正确性 + 兼容性 + 语义一致性 100% 通过）。

**Lens 4：2 标注为新发现**（Q4.2 沉默失败、Q4.3 未提醒），但**不是** blocker——schema 改动本身**可工作**；新发现描述的是"consumer 项目误用路径位置时不会被告警"——属于 **lint 缺位**而非 **schema 缺陷**。

**Verdict: APPROVE**（带 follow-up）：
1. 把 Q4.2 / Q4.3 列入 plan **P3 候选**：给 consumer-side harness-check 加 "closeout 产物路径合法性" warn 段（仅 consumer 仓库，harness-kit 仓库无 `.ai-runtime-artifacts/` 不触发该段）。
2. schema 改动**不**重做——`status=pending|in-progress|done` 的有限枚举 + 路径位置区分**足够清晰**。

## 改进建议（out of scope for this commit）

- 给 Closeout 行加**示例值**（"参见 `docs/runtime/closeouts/2026-06-12-tracking-schema-closeout-collective-test.md` § 路径位置说明"）—— schema 里已放，**已做**。
- 给 `core/orchestration/tracking/schema.md` 加 "Closeout 流程示例" 节，链到 `docs/runtime/closeouts/2026-06-12-tracking-schema-closeout-collective-test.md`——下次 commit 候选。
- 把本审查报告的 4-lens 模板沉淀到 `artifact-templates/code-review.md`（harness-kit 仓库内**承认**Leader 自审是 fallback，不是 sub-agent 真产物）——下次 commit 候选。

## Next

- 审查通过 → 继续下一阶段（写 execution-log 收尾）
- 审查拒绝（BLOCK） → 描述阻断问题
- 跳过（SKIPPED） → 引用 spec §9 SKIP 条件
