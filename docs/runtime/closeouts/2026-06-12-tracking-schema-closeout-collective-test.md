---
artifact: collective-test
route: superpowers:verification-before-completion
skills:
  - verification-before-completion
skills_evidence:
  - adapters/agents/.agents/skills/verification-before-completion/SKILL.md
source:
  - core/orchestration/tracking/schema.md
  - docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md
created_at: 2026-06-12
status: done
verdict: PASS
---

# tracking schema Closeout 字段 集体测试

> **纪律：** 先 Load **verification-before-completion** skill；**先跑命令、再给结论**。
> **范围：** 验证 commit `1f4c540`（`docs(harness-kit): tracking schema 加 Closeout 字段`）落盘后，`core/orchestration/tracking/schema.md` 行为符合设计且未破坏 harness-kit 自身 lint。

## 路径位置说明（gap #1、#2 治本 — 路径决定）

**本文件**位于 `docs/runtime/closeouts/`，**不**位于 `.ai-runtime-artifacts/verifications/`。

原因：harness-kit 仓库的 `.gitignore` 排除 `.ai-runtime-artifacts/`（这是合理设计：harness-kit 是工具/规则，`.ai-runtime-artifacts/` 是**消费者项目**的运行时目录）。但本次 GROUP（gap #10）要做的是治 gap #1、#2——即"closeout 流程仅在文档中存在、无真实产物落盘"——这要求**真**产物能 commit 到 harness-kit 仓库。

解决：
- **消费者侧**（harness-init 出来的项目）：closeout 产物落在 `.ai-runtime-artifacts/verifications/`、`.ai-runtime-artifacts/reviews/`、`.ai-runtime-artifacts/execution-logs/`（**不**入 .gitignore）。harness-check.sh 425-463 段在消费者仓库**会**触发 closeout ERROR 门禁。
- **harness-kit 仓库自身**：本 GROUP 的真产物**示例**放在 `docs/runtime/closeouts/`（harness-kit **可入库**位置）——便于阅读者看到真产物的真实样貌，且能作为 consumer-side 模板参考。

> 这是 docs/diagnosis/2026-06-11-collective-test-code-review-gap.md 之外的**新发现**：`.gitignore` 排除与"closeout 产物入库"存在结构性冲突，harness-kit 必须**显式区分**两个位置（见 `core/orchestration/tracking/schema.md` § Closeout 行注释——本文件 commit 后会补）。

## 命令

```bash
# 1. Closeout 行存在
grep -nE '^Closeout:' core/orchestration/tracking/schema.md

# 2. verdict 合法值枚举
grep -nE 'verdict=(PASS\|FAIL\|n/a)' core/orchestration/tracking/schema.md

# 3. status 合法值枚举
grep -nE 'status=(pending\|in-progress\|done)' core/orchestration/tracking/schema.md

# 4. harness-check.sh bash 语法（不破坏现有脚本）
bash -n scripts/harness-check.sh

# 5. 跑 harness-check 整段
bash scripts/harness-check.sh
```

## 结果

| 命令 | 结果 |
| --- | --- |
| 1 | 命中 `core/orchestration/tracking/schema.md:55`，输出 Closeout 行整行 |
| 2 | 命中 line 55，verdict 三个合法值（PASS / FAIL / n/a）均出现 |
| 3 | 命中 line 55，status 三个合法值（pending / in-progress / done）均出现 |
| 4 | `syntax OK`，bash 语法无错 |
| 5 | `Harness check complete` + `exit=0`；FM 路径 lint、closeout ERROR 门禁、layout 全部通过 |

> harness-check 在 harness-kit 仓库内**不**触发 closeout ERROR 门禁段——因为 `.ai-runtime-artifacts/execution-logs/*.md` 在 .gitignore 下不存在；这是**符合设计**的行为（harness-kit 自身**不**消费 closeout 流程；消费的是 consumer-side 项目）。

## 未验证项

- **历史 DISPATCH-TRACK 文件**：harness-check **未**扫 tracking 目录 Closeout 行存在性（避免历史合规问题）——本次故意不扫，schema 描述里也明确「已存在的 DISPATCH-TRACK 文件不强制有 Closeout 行」。如未来要扫，须先决定宽限期 + 范围。
- **下游 tracking 工具脚本**：当前 harness-kit 仓库无消费 DISPATCH-TRACK 字段的下游脚本（grep / awk 类），所以新增 Closeout 行**没有**运行时副作用；语义层影响在所有未来的 reader 落地时才会被检验。
- **Consumer 侧回归**：未在真消费者项目（harness-init 出来的项目）上跑端到端 closeout 流程——本次只验证 schema 描述层 + harness-check 自身未破坏。

## 残留风险

- **格式 vs 自由文本**：Closeout 行是自由文本而非 YAML/JSON schema，harness-check 不解析；如要机器校验需引入 schema 解析（out of scope for gap #10 本次）。
- **路径漂移**：Leader 在写 Closeout 时若把路径写错（如 `verfications/` 拼写错），harness-check 不会发现——**靠 Leader 自律**（与本仓库「物理能力诚实声明」一致：不可被门禁强制）。
- **两套位置认知负担**：consumer-side 在 `.ai-runtime-artifacts/`，harness-kit 内部示例在 `docs/runtime/closeouts/`——读 Closeout 行时不能机械信路径；harness-check 425-463 段 grep 不到本文件路径（因为不在 `.ai-runtime-artifacts/execution-logs/`）——**这是**新位置带来的副作用，**不是** bug。

## Next

- 验证通过、任务完成 → 说「完成」或「归档」
- 发现新问题 → 描述问题，自动进入修复流程
- 需要复盘 → 说「复盘」或「retro」
