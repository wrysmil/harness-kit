---
artifact: diagnosis
title: "集体测试/集体审查流程的静态 gap 报告"
date: 2026-06-11
status: draft
route: static-analysis
related:
  - docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md
  - artifact-templates/collective-test.md
  - artifact-templates/code-review.md
  - artifact-templates/execution-log.md
  - core/orchestration/dispatcher-workflow.md
  - core/orchestration/agents/reviewer.md
  - core/orchestration/tracking/schema.md
  - core/orchestration/skill-preferences.md
  - core/routing.md
  - core/extensions/hooks/hooks.spec.yaml
  - adapters/agents/.agents/skills/requesting-code-review/code-reviewer.md
  - adapters/claude/bindings.md
  - scripts/harness-check.sh
source:
  - 仓库根 commit b229a1a（含其前历史）的静态读取
created_at: 2026-06-11
---

# 集体测试/集体审查流程的静态 gap 报告

> **范围：** 仅静态文本与脚本分析；**不**实施任何修复。
> **意图：** 把 `docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md` 落地的过程中积累的、跨 spec / 模板 / 路由 / 钩子 / 脚本的不一致固化下来，给后续 refactor 或下游接入项目作为风险参考。

---

## 1. 调查范围与可复现命令

```bash
# 仓库状态
git -C d:/workspace/ai/harness-kit log --all --oneline | head -30

# 找任何集体测试/审查的实际产物
find d:/workspace/ai/harness-kit -type f -name "*collective-test*" 2>/dev/null
find d:/workspace/ai/harness-kit -type f -name "*code-review*" 2>/dev/null
ls -la d:/workspace/ai/harness-kit/.ai-runtime-artifacts/ 2>/dev/null

# 找 spec/模板/脚本/钩子的相关文件
ls d:/workspace/ai/harness-kit/docs/superpowers/specs/ | grep batch
ls d:/workspace/ai/harness-kit/artifact-templates/ | grep -E "collective|code-review|execution-log"

# 路径存在性核查（验证 gap #3、#4）
test -d d:/workspace/ai/harness-kit/adapters/cursor/.cursor/skills && echo exists || echo "no adapters/cursor/.cursor/skills/"
ls d:/workspace/ai/harness-kit/adapters/cursor/.cursor/
ls d:/workspace/ai/harness-kit/adapters/agents/.agents/skills/ | head
```

运行于 commit `b229a1a`（branch `feature/cross-platform-capability-kernel`）。

---

## 2. 已对齐部分（✓）

| # | 项 | 证据 |
| --- | --- | --- |
| A | `reviewer.md` 角色明确"只返回、不 Write .ai-runtime-artifacts/" | [core/orchestration/agents/reviewer.md:53-58](core/orchestration/agents/reviewer.md#L53) |
| B | `code-reviewer.md` prompt 模板与 reviewer.md readonly 表述一致 | [adapters/agents/.agents/skills/requesting-code-review/code-reviewer.md](adapters/agents/.agents/skills/requesting-code-review/code-reviewer.md) |
| C | `execution-log.md` 模板含「尾盘门禁」节，引用正确的 verifications / reviews 路径 | [artifact-templates/execution-log.md:30-46](artifact-templates/execution-log.md#L30) |
| D | `dispatcher-workflow.md` 步骤 3 已写 A 集体测试 → B 集体审查 → C 关闭 | [core/orchestration/dispatcher-workflow.md:81-97](core/orchestration/dispatcher-workflow.md#L81) |
| E | `routing.md` 路由表第 118 行有「批次收尾（尾盘）」行 | [core/routing.md:118](core/routing.md#L118) |
| F | `routing.md` 按判定加载有「GROUP 收尾 / 批次交付」4 步引导 | [core/routing.md:144](core/routing.md#L144) |
| G | `harness-check.sh` 425-463 行有 batch-closeout 链接 warn（虽为 warn-only，见 gap #6） | [scripts/harness-check.sh:425-463](scripts/harness-check.sh#L425) |

骨架在文档/脚本层是**完整**的，问题在于下面 §3 的不一致。

---

## 3. Gap 列表

按严重度（实际后果 × 触发概率）排序。每条带证据文件:行号。

### Gap #1 — spec 自指矛盾：实施 [x] 与运行时验收 [ ] 互斥

**证据：** [docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md §9](docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md#L307-L346) Phase 1-4 全部标 `[x]` 表示"已实施"；同 spec §10「运行时」4 条验收全部标 `[ ]`。

**实际后果：** 任何读 spec 的人都以为"流程已落地"；但 spec §10 自己也承认—— 真实 GROUP 跑过、Reviewer 实际 readonly、测试报告含真实命令输出、未生成产物时 Leader 不能写完成，**4 条全未验证**。这是"形式自洽、实质未跑"的典型状态。

---

### Gap #2 — harness-kit 自己从未跑过该流程

**证据：**
- `find` 全仓库 `*-collective-test.md` / `*-code-review.md` 实际产物：**0 个**（只有 `artifact-templates/` 下的**模板**和 `docs/superpowers/specs/` 下的**规范**）。
- `.ai-runtime-artifacts/` 目录不存在。
- `git log` 显示 `e146d50 feat(harness-kit): 尾盘集体测试与集体审查门禁及产物落盘` 之后的所有 multi-file commit（含 `b229a1a`、`c5d18b8`、`8064479`、`0204672`、`443a2ec`、`3786a03`、`b08d5ac`、`ca9101f`、`b202ebd` 等）都**未生成** collective-test / code-review 产物。
- 按 [spec §6.1](docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md#L211-L219)（"本批次 ≥2 个实现 WU，或触及 ≥3 个写文件"即必走尾盘），上述 commit **均**应已走尾盘。

**实际后果：** 「规范方自己没跑过」是制度性 gap。下游项目照搬这套流程时，**没有"已跑通"的样例可参考**；模板里写的 `## Findings`、`## 命令表`、`exit code` 怎么填、verdict 怎么下，**全靠下游自己踩坑**。

---

### Gap #3 — 模板 `skills_evidence` 路径全错

**证据：**
- [artifact-templates/code-review.md:7-8](artifact-templates/code-review.md#L7) 写：
  ```yaml
  skills_evidence:
    - adapters/cursor/.cursor/skills/requesting-code-review/SKILL.md
    - .agents/skills/cursor-orchestration/SKILL.md
  ```
- 实际仓库：
  - `adapters/cursor/.cursor/skills/` 目录**不存在**（cursor 适配器下只有 `.cursor/rules/`、`.cursor/config.defaults.yaml`、`.cursor/CURSOR-PRECHECK.md`）。
  - `requesting-code-review` 物理位置：`adapters/agents/.agents/skills/requesting-code-review/SKILL.md`。
  - `cursor-orchestration` 物理位置：`adapters/agents/.agents/skills/cursor-orchestration/SKILL.md`。
- [artifact-templates/collective-test.md:6](artifact-templates/collective-test.md#L6) 写 `adapters/cursor/.cursor/skills/verification-before-completion/SKILL.md` —— 实际在 `adapters/agents/.agents/skills/verification-before-completion/SKILL.md`。

**实际后果：** 模板教 Leader/Coder 写产物时引用错误路径；按此填 FM 会被 harness-check 放过（见 gap #5）。

---

### Gap #4 — 模板 `source:` 在 source 布局下前缀错误

**证据：**
- 两个模板都写 `source: harness-kit/docs/superpowers/specs/2026-05-28-...` 和 `source: harness-kit/artifact-templates/...`。
- [scripts/harness-check.sh:7-19](scripts/harness-check.sh#L7) 的布局检测：
  - `source` 布局（`core/harness.md` 在根）→ `HK="."`、所有 kit 路径**不**前缀 `harness-kit/`。
  - `deployed` 布局（`harness-kit/core/harness.md` 存在）→ `HK="harness-kit"`、所有路径前缀 `harness-kit/`。
- 模板 FM 是写死的、不分布局 → **source 布局下 source 路径前缀错误**。

**实际后果：** 在 source 布局下（harness-kit 仓库自身）按模板填 FM 会得到字面上不存在的 `harness-kit/...` 路径；下游已部署项目用 deployed 布局则正确。**同一份模板两个布局只有一个对**。

---

### Gap #5 — 模板 FM 路径错误不会被 harness-check 抓到

**证据：** [scripts/harness-check.sh:374-420](scripts/harness-check.sh#L374) 的 artifact FM 扫描：
- 只扫 `.ai-runtime-artifacts/` 下产物的 FM，**不扫 `artifact-templates/` 模板本身**。
- placeholder 扫描（line 411）只挡 `^(<path|<skill>|\.{3})`，**挡不住"路径拼错但语法合法"**（如 `adapters/cursor/.cursor/skills/...` 是合法路径字符串，脚本无法判断该路径是否存在）。
- `required_kit_files`（line 66-67）只检查模板文件存在，不检查内容。

**实际后果：** gap #3、#4 的错误模板被仓库原样接受，**无人发现、无人阻止**。

---

### Gap #6 — "未生成产物不能声称完成" 是规范文本，无强制门禁

**证据：**
- spec §10 写「未生成上述产物时，Leader **不能** 在 execution-log 写「批次完成」」。
- 实际 [scripts/harness-check.sh:425-463](scripts/harness-check.sh#L425) 的 closeout 链接检查**全部**为 `warn`（不阻塞、exit code 不变）。
- 即使 warn 触发（"warn: 声称批次完成但未引用 collective-test PASS"），**CI 不会失败**。

**实际后果：** spec 的硬性"不能"在脚本层降级为"建议"。`b229a1a` / `c5d18b8` / `8064479` 等 commit 的 execution-log 应当引用集体测试/审查产物，**实际都没有**——因为没有强制门禁，所以规范自我放行。

---

### Gap #7 — hooks spec 描述与 spec §9 Phase 4 承诺不一致

**证据：**
- [docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md §9 Phase 4](docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md#L342-L346) 写：「Hook：`harness-subagent-track-reminder.sh` 已含尾盘提醒」并标 `[x]`。
- 实际 [core/extensions/hooks/hooks.spec.yaml:21-35](core/extensions/hooks/hooks.spec.yaml#L21)：
  ```yaml
  - name: harness-subagent-stop
    description: 提醒 Leader 追加 DISPATCH 追踪与 plan 勾选
  ```
  description **未提及**"尾盘提醒"。
- hooks 实际内容（`core/extensions/hooks/content/subagent-stop.md`，未在本报告读出，但 description 文本已确定不含 closeout 关键词）也未声称包含尾盘逻辑。

**实际后果：** spec 实施勾选 [x] 与实现不一致；下游阅读 spec 期望"SubagentStop 时收到尾盘提醒"，**实际收不到**。

---

### Gap #8 — reviewer readonly 是 prompt 约束、非平台强制

**证据：**
- [adapters/claude/bindings.md:7](adapters/claude/bindings.md#L7)：「`SpawnWorker(reviewer)` → 新 Task 实例 + readonly 约束」。
- Claude Code 的 `Task` 工具=subagent `generalPurpose` + 角色 prompt 当正文；subagent **仍然能用 Write 工具**，所谓"readonly 约束"是写在 prompt 里的文本指令。
- 平台层（`generalPurpose` subagent）**没有任何工具级 deny**。

**实际后果：** Reviewer 写文件这件事**技术上完全可行**——只要 prompt 写得不够严、或者 reviewer 实例有意为之。`requesting-code-review` 的"不许写文件"靠纪律，不靠门禁。这与 spec §6.5 的 `readonly: true` 表述存在强度差。

---

### Gap #9 — spec 文本停留在 cursor 时代，与 platform-agnostic 重构脱节

**证据：**
- spec front matter `platform: cursor`。
- [spec §4](docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md#L63-L95) 标题直接叫"尾盘标准流程（Cursor）"；§4 文本中只描述 Cursor 的执行步骤。
- [spec §7.1 路由表](docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md#L268-L276) Cursor Route 列写 `cursor-orchestration` / `requesting-code-review` / `verification-before-completion`，**没有 Claude / Trae 列**。
- 仓库 [commit 185e4e4](https://github.com) 已做 core-first 重构：[core/orchestration/dispatcher-workflow.md](core/orchestration/dispatcher-workflow.md) 已是平台无关；[core/routing.md:13-14](core/routing.md#L13) 把 `Cursor: cursor-orchestration`、`Claude: claude-orchestration` 并列。
- 各平台适配器（`adapters/claude/bindings.md`、`adapters/trae/bindings.md`）**没有**对应的尾盘流程描述。

**实际后果：** spec 描述的"尾盘流程"只对 Cursor 平台完整；Claude / Trae 用户**没有对应的 spec 章节**。`routing.md` 的尾盘路由是平台无关的，但**只引用 cursor-orchestration 时代**的 spec。

---

### Gap #10 — dispatch tracking schema 无 closeout 字段

**证据：** [core/orchestration/tracking/schema.md](core/orchestration/tracking/schema.md)：
- 通用条目格式：Phase-Step、Agent、Status、Detail、Sub-agents、Context、Output、Error、Next。
- DISPATCH 专用字段：GROUP、WU、ITER、STEP、WorktreeId/Path/Branch/Base、Tests、Queue-remaining、Reviewer、Worktree、Title(zh)。
- **没有** collective-test / code-review / verdict / closeout-status 字段位。
- [scripts/harness-check.sh:374-420](scripts/harness-check.sh#L374) 也**不扫** `tracking/` 目录。

**实际后果：** Leader 在 `DISPATCH-TRACK-*.md` 里写"集体测试 PASS / 集体审查 APPROVE"是**自由文本**，没有 schema 约束；harness-check 也不验证 tracking 里的 closeout 状态。尾盘门禁的"可审计"目标在 tracking 层落空。

---

## 4. 根因（一句话）

规范方自己没跑过 + 模板/规范/钩子三套文本各写各的 + 没有"模板生成器"也没有"落盘前 lint" → 静态文本层互相脱节；最关键的"未生成产物不能声称完成"是规范理想，自动化门禁降级为 warn，**等于无门禁**。

具体的失败链：

```text
spec §9 实施 [x]  ─┐
模板 FM 路径写错  ─┼─→ 三个不一致都"被仓库接受"
hooks 描述未更新  ─┘
                          ↓
        规范方 (harness-kit) 自己 commit 时绕过
                          ↓
        零产物 + zero sample for downstream
                          ↓
        下游项目照搬只有"模板"没有"先例"
```

---

## 5. Next（建议，不实施）

| 优先级 | 候选方向 | 风险/代价 |
| --- | --- | --- |
| P0 | 修两个模板的 `skills_evidence` 与 `source` 路径（gap #3、#4） | 1-2 文件；下游产物 FM 与仓库布局同步 |
| P0 | 给 `harness-check.sh` 加模板自身 FM lint：扫描 `artifact-templates/*.md`、校验 `skills_evidence` 路径存在 | 中等；需先有"路径存在"判定（不区分 layout） |
| P1 | 把 closeout 链接 warn **至少**对"声称批次完成"的 execution-log 升级为 `error`（gap #6） | 小；但会立刻让 `b229a1a` 等历史 commit 失合规，需配合 reset 或豁免 |
| P1 | hooks.spec.yaml 修正 `harness-subagent-stop` 描述为实际行为（gap #7） | 一行改；spec §9 Phase 4 [x] 取消或重述 |
| P1 | spec §9 Phase 4 改写为"已纳入路由行 / 已落盘模板，未启用自动提醒"——承认与实现差异（gap #7 的另一面） | 文字修订 |
| P2 | 补 spec 的 Claude / Trae 章节（gap #9）；或将 spec 改为 platform-agnostic 化 | 文档工作量大；与 refactor 同步 |
| P2 | `tracking/schema.md` 增加 closeout 字段（gap #10）；harness-check 加 tracking 扫描 | schema 变更要带 migration 思路 |
| P2 | 跑一次"真 GROUP"（含 ≥2 WU）并落盘**真实产物**，把 harness-kit 自身从"规范方"变成"先例方"（gap #1、#2） | 最重；但**唯一**能让下游有样例可参考 |

不建议：仅以"补充 doc"形式回避以上 gap —— doc 越多，gates 越少，规范越接近"参考意见"。

---

## 6. 参考

- 本报告基于 commit `b229a1a`（branch `feature/cross-platform-capability-kernel`）的静态读取；运行 `bash scripts/harness-check.sh` 在 source 布局下应"ok: harness check complete"（无 .ai-runtime-artifacts 触发 skip），证明 gap #2 的"零产物"状态。
- 相关 commit：`e146d50`（spec 落地）、`b08d5ac`（agents 抽到 core）、`185e4e4`（core-first 重构）、`0204672`（能力缺口修复）—— 都在仓库历史里可查。
