---
artifact: spec
title: "尾盘集体代码审查与集体测试"
date: 2026-05-28
status: approved
platform: cursor
route: cursor-orchestration:dispatcher-workflow -> batch-closeout
related:
  - docs/superpowers/specs/2026-05-26-coder-role-improvement-design.md
  - docs/superpowers/specs/2026-05-27-doc-review-and-quality-improvement.md
  - harness-kit/core/routing.md
  - harness-kit/adapters/cursor/orchestration/dispatcher-workflow.md
---

# 尾盘集体代码审查与集体测试

## 1. 背景与问题

Harness 已在 `dispatcher-workflow.md` GROUP 收尾中定义「跑验证 → 派 `harness-reviewer`」，但实践中出现：

| 现象 | 根因（摘要） |
| --- | --- |
| skill 生成的审查内容未保存 | `requesting-code-review` 无落盘契约；`harness-reviewer` 为 readonly 却要求自写文件；Leader 输出清单未含 `reviews/` |
| 执行任务时不主动审查 | 入口规则未在「实现/尾盘」加载审查 skill；审查仅写在 GROUP 第 3 步，易被「执行至完成」自主性跳过 |
| 验证与审查混淆 | `routing.md` 将「代码审查/验证」合并为 `verification-before-completion` → `verifications/`，Agent 只跑命令不写 review |
| 集体测试无标准产物 | 各 WU 单测通过 ≠ 批次集成验证；缺少统一的「集体测试报告」结构与门禁 |

**本方案目标：** 把 **尾盘（批次/GROUP/阶段交付前）** 固化为两条**强制、可审计**的闭环：**集体代码审查** + **集体测试**，并规定 **Leader 落盘**（子 Agent 只返回，不写 review 文件）。

---

## 2. 术语

| 术语 | 定义 |
| --- | --- |
| **尾盘** | 一个 **GROUP**（或单 WU 交付批次）全部实现 WU 返回后、对外声称「本批次完成 / 可合并 / 可提测」之前的门禁阶段 |
| **集体测试** | Leader 按 **本批次整合后的 diff 范围**，运行 `project.verification.md` 最小验证集；plan 要求时追加 `harness-test-engineer` 的集成/E2E |
| **集体代码审查** | Leader 委派 **独立** `harness-reviewer`（与所有实现实例不同），对照 spec/plan done criteria 审查 **整批变更面** |
| **WU 轻量审查** | Coder 在单 WU 内用 `requesting-code-review` + 独立 reviewer 实例；**不替代**尾盘集体审查 |
| **交付完成** | 集体测试 **PASS** + 集体审查 **APPROVE**（或合法跳过审查）+ 产物已落盘 |

---

## 3. 目标与非目标

### 3.1 目标

1. **尾盘必做**：每个 GROUP（及非编排但 multi-file 的交付批次）必须经过集体测试与集体审查，才能写 execution-log 完成态。
2. **产物必落盘**：审查 → `.ai-runtime-artifacts/reviews/`；集体测试 → `.ai-runtime-artifacts/verifications/`。
3. **责任清晰**：readonly Reviewer / Test Engineer **只返回**；**Leader 整合并 Write 文件**。
4. **路由可加载**：`routing.md` / `ai-entry.mdc` 增加 **「尾盘 / 批次收尾」** 判定行，显式 Load `requesting-code-review` + `verification-before-completion`。
5. **与现有分层兼容**：保留 Coder 轻量审查、小 WU 跳过集体 Reviewer 的规则（须落盘理由）。

### 3.2 非目标

- 不取消 spec/plan 阶段门禁。
- 不新增角色（仍用 Leader、Reviewer、Test Engineer）。
- 不在本 spec 中实现 `leader-review-coordination` 独立 skill（用 **编排文档 + 模板 + routing 行** 即可；skill 可作为 P2）。
- 不强制每个 WU 结束都写 review 文件（仅 **尾盘集体** 必写；WU 级可选摘要进 tracking）。

---

## 4. 尾盘标准流程（Cursor）

适用于：`cursor-orchestration:dispatcher-workflow` 的 **GROUP 收尾**，以及 Leader 主线程完成的 **单批次交付**（多文件、非「小改动」）。

```text
[所有本 GROUP 的 WU 已返回且 Leader 已整合冲突]

步骤 A — 集体测试（先测后审）
  A1. Leader Load verification-before-completion + project.verification.md
  A2. 按本批次变更范围选定命令集（见 §5.2）
  A3. 若 plan 含集成/E2E → 先完成或委派 harness-test-engineer WU
  A4. Leader 将命令、完整输出摘要、未验证项写入 collective-test 产物
  A5. 任一必跑项失败 → STOP，开 bugfix WU，不得进入步骤 B

步骤 B — 集体代码审查
  B1. Leader Load requesting-code-review（Cursor：委派 harness-reviewer，禁 generalPurpose 泛型）
  B2. 准备审查上下文：BASE_SHA/HEAD_SHA 或文件列表、spec/plan 路径、各 WU 验证摘要
  B3. 委派 harness-reviewer（与所有 Coder/Implementer 不同实例）
  B4. Reviewer 返回 APPROVE | BLOCK + Findings（不 Write 文件）
  B5. Leader 将返回写入 code-review 产物（§5.1）
  B6. BLOCK → 开 review-fix WU（Coder + receiving-code-review）→ 回到 A（至少重跑受影响验证）

步骤 C — 批次关闭
  C1. 更新 execution-log：链接 review + collective-test 路径、审查结论、测试结论
  C2. 更新 DISPATCH-TRACK / plan 勾选（plan-progress-sync.md）
  C3. 对甲方汇报（中文）：状态、验收口径、两产物路径、是否跳过审查及理由
  C4. 未过 A+B 不得声称「本 GROUP / 本批次交付完成」
```

**顺序说明：** 先集体测试再集体审查，避免审查通过后发现构建/测试失败需重复审查。

**单 WU 批次：** 仍执行 A+B；若满足「小 WU 跳过 Reviewer」全部条件，B3–B5 改为在 review 产物中记录 **跳过依据**（见 §6.3），且 `skip_reviewer_eligible` 须为 yes。

---

## 5. 产物契约

### 5.1 集体代码审查报告

**路径：**

```text
.ai-runtime-artifacts/reviews/YYYY-MM-DD-<topic>-code-review.md
```

**模板（新建）：** `harness-kit/artifact-templates/code-review.md`

**Front matter 示例：**

```yaml
---
artifact: review
route: cursor-orchestration:dispatcher-workflow -> batch-closeout
skills:
  - requesting-code-review
  - cursor-orchestration
skills_evidence:
  - adapters/cursor/.cursor/skills/requesting-code-review/SKILL.md
  - .agents/skills/cursor-orchestration/SKILL.md
source:
  - .ai-runtime-artifacts/plans/YYYY-MM-DD-<topic>-plan.md
  - harness-kit/docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md
created_at: YYYY-MM-DD
batch_id: GROUP-1 | single-wu
reviewer_instance: harness-reviewer
verdict: APPROVE | BLOCK | SKIPPED
---
```

**正文必填节：**

| 节 | 内容 |
| --- | --- |
| 审查范围 | 文件列表或 `git diff BASE..HEAD` 摘要 |
| 对照依据 | spec/plan 路径、done criteria 勾选 |
| Findings | Critical / Important / Suggestion / Nit |
| 证据 | Reviewer 已读/已跑的命令或文件 |
| 未验证项 | 明确列出 |
| 结论 | APPROVE \| BLOCK \| SKIPPED（跳过时写 §6.3 依据） |
| Next | BLOCK → review-fix；APPROVE → 可合并/提测；SKIPPED → 谁批准跳过 |

**写入者：** 仅 **Leader**（收到 Reviewer 返回后）。

### 5.2 集体测试报告

**路径：**

```text
.ai-runtime-artifacts/verifications/YYYY-MM-DD-<topic>-collective-test.md
```

**模板（新建）：** `harness-kit/artifact-templates/collective-test.md`

**Front matter：**

```yaml
---
artifact: verification
route: cursor-orchestration:dispatcher-workflow -> batch-closeout
skills:
  - verification-before-completion
skills_evidence:
  - adapters/cursor/.cursor/skills/verification-before-completion/SKILL.md
source:
  - harness-kit/project.verification.md
created_at: YYYY-MM-DD
batch_id: GROUP-1
verdict: PASS | FAIL
---
```

**正文必填节：**

| 节 | 内容 |
| --- | --- |
| 变更范围 | 本批次触及的模块/目录 |
| 命令表 | 命令、cwd、exit code、关键输出摘要（禁止「应该通过」） |
| 集成/E2E | 无 \| Test Engineer WU-id + 摘要 |
| 未验证项 | 及原因 |
| 残留风险 | |
| 结论 | PASS \| FAIL |
| Next | FAIL → bugfix WU；PASS → 进入集体审查 |

**与 WU 单测的关系：** Coder 返回中的单测/lint 摘要 **引用** 到 collective-test 的「WU 已覆盖项」，但 **不能替代** Leader 本机重跑的集体测试命令。

### 5.3 execution-log 衔接

在 `artifact-templates/execution-log.md` 增加固定节（实现阶段改模板）：

```markdown
## 尾盘门禁

| 门禁 | 产物 | 结论 |
| --- | --- | --- |
| 集体测试 | `verifications/...-collective-test.md` | PASS / FAIL |
| 集体审查 | `reviews/...-code-review.md` | APPROVE / BLOCK / SKIPPED |

## 审查摘要
（1–3 句或链接）

## 测试摘要
（1–3 句或链接）
```

---

## 6. 规则细则

### 6.1 何时必须走尾盘（不可声称完成）

满足 **任一** 即必须执行 §4 全流程（小改动除外）：

- 本批次 ≥2 个实现 WU，或触及 ≥3 个写文件
- plan / 用户要求「提测 / 合并 / 交付 / 验收」
- 作为已批准 plan 的 **GROUP 收尾**
- `routing.md` §「小改动」排除项命中（含「实施流程末尾验证」）

### 6.2 集体测试命令集（默认）

以 **`project.verification.md` § 最小验证策略** 为基线，按 diff 扩展：

| 变更触达 | 集体测试至少包含 |
| --- | --- |
| `frontend/` | `npm run build`（+ lint 若改 TS） |
| `admin/` | 同上 |
| `backend/` | 导入检查或相关 pytest |
| `nanobot/` | `pytest` 子集或 smoke（按 plan） |
| Docker/nginx | `docker compose build` |
| 仅 harness-kit 文档 | `harness-check.sh` |

plan 中写的 **集成 / E2E / 契约测试** 列入必跑，由 `harness-test-engineer` 执行并回填 collective-test。

### 6.3 跳过集体审查（保留原规则）

仅当 **全部** 满足 `2026-05-26-coder-role-design.md` § 小 WU 跳过 Reviewer 时，可 `verdict: SKIPPED`：

- 文件数 ≤5，无安全/API/跨模块等硬条件
- 各 WU `self_check: PASS`，无 open Critical/Important
- 集体测试已 PASS
- Leader 在 code-review 产物记录跳过理由 + `skip_reviewer_eligible` 引用

**禁止：** 以「Coder 已 code_review: PASS」单独跳过集体审查。

### 6.4 Cursor 审查委派统一

| 场景 | 机制 |
| --- | --- |
| WU 轻量审查 | Coder Load `requesting-code-review` → 委派 **harness-reviewer**（非本 WU 实现实例） |
| 尾盘集体审查 | Leader Load `requesting-code-review` → 委派 **harness-reviewer** |
| 禁止 | 仅用 Task `generalPurpose` 且无 `harness-reviewer` 约束（与 Harness 实例隔离冲突） |

`requesting-code-review/SKILL.md` 应增加 **Harness 覆盖段**：Cursor 下使用 `harness-reviewer` + `orchestration/agents/reviewer.md`；落盘由 Leader 按 `code-review.md` 执行。

### 6.5 readonly Reviewer

`harness-reviewer` 保持 `readonly: true`。正文改为：

- **只返回** §5.1 结构的可复制 markdown
- **不** Write `.ai-runtime-artifacts/`
- Leader 收到后 **必须** Write `code-review.md`

---

## 7. 路由与入口改动（已实施 2026-05-28）

### 7.1 `core/routing.md` 路由表

**拆分**原「代码审查 / 验证」行，并 **新增** 尾盘行：

| 任务类型 | Cursor Route | 产物 |
| --- | --- | --- |
| 代码审查（尾盘/批次） | `requesting-code-review` + `cursor-orchestration` | `.ai-runtime-artifacts/reviews/` |
| 验证 / 集体测试 | `verification-before-completion` | `.ai-runtime-artifacts/verifications/` |
| **批次收尾（尾盘）** | 先 `verification-before-completion`，再 `requesting-code-review` | `verifications/*-collective-test.md` + `reviews/*-code-review.md` |

### 7.2 § 按判定加载

新增一行：

| 判定 | 再读（按序） |
| --- | --- |
| GROUP 收尾 / 批次交付 / 用户说「收尾」「提测前检查」 | **①** `verification-before-completion` → `project.verification.md` **②** `requesting-code-review` **③** `dispatcher-workflow.md` § 步骤 3 **④** 本 spec |

### 7.3 `ai-entry.mdc` / `AGENTS.cursor-overlay.md`

与上表同步增加「尾盘 / 批次收尾」行；实现阶段完成后 **默认进入尾盘**，而非直接「完成」。

### 7.4 Leader 阶段链（`leader.md`）

```text
... → cursor-orchestration（实现）
→ [尾盘] verification-before-completion（集体测试）
→ [尾盘] requesting-code-review（集体审查，Leader 落盘）
→ execution-log 关闭
```

**输出** 增补：

- `.ai-runtime-artifacts/reviews/*-code-review.md`
- `.ai-runtime-artifacts/verifications/*-collective-test.md`

---

## 8. Skill 与同步改动（待实施）

| 项 | 改动 |
| --- | --- |
| `requesting-code-review/SKILL.md` | 增加 Harness/Cursor 段：委派 `harness-reviewer`；Leader 落盘 `code-review.md`；禁止仅对话输出 |
| `sync-cursor-skills.sh` | `requesting-code-review` 改为目录同步，包含 `code-reviewer.md`（或 Harness 专用 `harness-code-review-prompt.md`） |
| `harness-reviewer.md` / `reviewer.md` | 删除「写入 reviews/」；改为「返回给 Leader 落盘」 |
| `document-review` Integration 表 | 与本文一致：代码审查走 `requesting-code-review`，文档走 `document-review` |

---

## 9. 实施计划（分阶段）

### Phase 1 — 契约与模板（P0）

- [x] 新建 `artifact-templates/code-review.md`
- [x] 新建 `artifact-templates/collective-test.md`
- [x] 更新 `artifact-templates/execution-log.md` § 尾盘门禁
- [x] 更新 `core/artifacts.md`：区分 `review` vs `verification`；集体测试命名约定
- [x] 本 spec 状态 → `approved`

### Phase 2 — 编排与入口（P0）

- [x] 更新 `dispatcher-workflow.md` § 步骤 3：显式 A/B 顺序 + 产物路径 + Leader Write
- [x] 更新 `leader.md`：输出清单、阶段链、尾盘职责
- [x] 更新 `core/routing.md`、`ai-entry.mdc`、`AGENTS.cursor-overlay.md`
- [x] 更新 `cursor-subagent-routing.mdc`：尾盘禁止跳过审查/测试

### Phase 3 — Skill 对齐（P1）

- [x] 补丁 `requesting-code-review/SKILL.md`（Harness 段）
- [x] 修正 `harness-reviewer` / `reviewer.md` readonly 表述
- [x] `sync-cursor-skills.sh` 同步 `code-reviewer.md`
- [x] `skill-preferences.zh.md` 速查表补全 `requesting-code-review`

### Phase 4 — 可选增强（P2）

- [x] `harness-check.sh`：execution-log 尾盘链接 warn（非 fatal）
- [ ] 独立 `leader-review-coordination` skill（**暂缓**；当前用 routing + runbook + 模板）
- [x] Hook：`harness-subagent-stop.sh` 已含尾盘提醒（content 含 plan 勾选 / 追踪落盘 / 尾盘判断 3 步；hooks.spec.yaml 的 description 落后于 content，2026-06-11 同步）

---

## 10. 验收标准

**文档 / 规则（已满足）：**

- [x] `routing.md` 与 `ai-entry.mdc` 含「尾盘」判定行，且与本文 §4 一致
- [x] 文档审查仍只走 `document-review`，与代码尾盘审查路径分离
- [x] `runbooks.md` § GROUP 尾盘、`README.md`、`harness-check` warn 已同步

**运行时（须在真实 GROUP 上人工或 Agent 复验）：**

- [ ] 完成一个含 ≥2 Coder WU 的 GROUP 后，仓库存在 **pair**：`*-collective-test.md`（PASS）+ `*-code-review.md`（APPROVE 或合法 SKIPPED）
- [ ] Reviewer 会话无 Write 工具调用，审查内容仍在 `reviews/` 文件中
- [ ] 集体测试报告含 **真实命令输出摘要**，非「应该通过」
- [ ] 未生成上述产物时，Leader **不能** 在 execution-log 写「批次完成」（`harness-check` 对已有 log 会 **warn**）

---

## 11. 风险与缓解

| 风险 | 缓解 |
| --- | --- |
| 尾盘两次委派耗时长 | 仅 GROUP/交付批次执行；WU 内仍轻量审查 |
| Leader 忘记落盘 | execution-log 模板强制链接；P2 harness-check warn |
| 与 AGENTS「执行至完成」冲突 | 覆盖层注明：**完成** = 尾盘 A+B 通过，非末 WU 返回 |
| 跳过审查滥用 | SKIPPED 必须引用 §6.3 全条件 + Coder 字段 |

---

## 12. 参考

- 前轮排查结论（会话 2026-05-28）：审查不落盘、入口未加载审查 skill、`verification` 与 `review` 路由合并
- `docs/superpowers/specs/2026-05-26-coder-role-improvement-design.md` § Leader 收尾集体审查
- `adapters/cursor/orchestration/dispatcher-workflow.md` § 步骤 3
- `harness-kit/project.verification.md` § 最小验证策略

---

## Next

- 审阅本 spec → 说「按方案实施 Phase 1+2」或提出修改
- 仅需模板草案 → 说「先写 artifact-templates」
- 批准后直接改 routing / dispatcher / leader（不碰业务代码）
