# Harness Runbooks

## 新功能

1. 先 Read/invoke **`brainstorming`** skill（`SKILL.md`），再按 skill 流程产出 spec；澄清需求时**优先**用结构化提问工具（见适配器 `bindings.md`）；不可用则对话逐条问。
2. 将 spec 保存到 `.ai-runtime-artifacts/specs/`（勿默认写入 `docs/superpowers/`）；契约见 `artifact-templates/spec.harness-overlay.md`。
3. **Plan 判定（条件分支）：**
   - spec 涉及多模块协调 / 有先后依赖 / 需要分步编排 → 先 Read **`writing-plans`** skill，再写 plan 至 `.ai-runtime-artifacts/plans/`；并行时另写同 stem `*-dispatch.md`
   - spec 已确认后被修改（范围扩大或方向变化）→ 触发 plan（重新编排）
   - 变更范围单一模块内、无依赖序 → 跳过 plan，直接实现（在 spec front matter route 中记录 `skip:plan(reason)`）
   - 用户显式说"不需要计划"/"直接做" → 跳过 plan
4. **编码实现：** 必须使用编排调度 skill（见适配器 `bindings.md`），不允许跳过编排层直接大规模编码。
5. 全部 WU 返回后执行 **尾盘**（先集体测试、再集体审查）；见下文 § GROUP 尾盘。
6. 产出 `execution-log`（含 § 尾盘门禁 与两产物链接），再声称批次完成。
7. 集体测试 → `verifications/*-collective-test.md`；集体审查 → `reviews/*-code-review.md`（Leader 落盘）。

## 缺陷修复

1. 使用 `superpowers:systematic-debugging` 路由复现并定位。
2. 写清根因、影响范围和修复方案。
3. **修复实现：** 使用编排调度或主 Agent 直做（单 WU 修复；见适配器 `bindings.md`）
4. 编码完成后产出 `execution-log` 到 `.ai-runtime-artifacts/execution-logs/`。
5. 使用最接近缺陷的命令验证。
6. 验证摘要保存到 `.ai-runtime-artifacts/verifications/`。

## 架构决策

1. 读取 `harness-kit/project.profile.md` 和相关代码。
2. 读取 `harness-kit/project.profile.md` 和相关代码。
3. 决策写入 `.ai-runtime-artifacts/decisions/`。
4. 决策必须包含接受方案、拒绝方案、约束和风险。

## Git 协作（提交 / 分支 / MR）

**权威：** `harness-kit/core/routing.md` § Git 协作（路由表、invoke 规则、谁执行 Git）。

**Leader 顺序（不可跳过 skill 正文）：** 声明 `「Harness：git-xywh + project.git.md」` → invoke/Read **`git-xywh`** → Read **`project.git.md`** → 按 skill 执行。本机 skill 路径：`bash harness-kit/scripts/install-ai-skills.sh`。仅改 `harness-kit/` 时用 `chore(harness-kit):` 且正文中文。

**叠加：** 开 PR / 看 CI 可叠加 `.agents/skills/github`（`gh`），不替代 `git-xywh`。

## Harness 迁移到新项目

1. 将 `harness-kit/` 放入新项目。
2. 对 AI 发送 **`harness-kit/init/onboarding-handoff.txt`** 全文（或运行 `bash harness-kit/scripts/harness-init.sh` 输出同一段话术）；详版见 **`harness-kit/init/bootstrap.prompt.md`**。
3. 人 review `project.profile.md` 与 `project.git.md` 中的推断项和待确认项。

---

## 编排 Runbook

**适用：** 走编排调度的任务；路由见 `harness-kit/core/routing.md`。

完整步骤见 `harness-kit/core/orchestration/dispatcher-workflow.md`。要点：

1. 遵守 **阶段门禁**（spec/plan 写入后暂停，见 `harness-kit/core/routing.md` § 阶段门禁）
2. 需委派 worker 时：拆 WU → **WORKTREE-INIT**（见 worktree spec）；不派 worker 的简单任务跳过沙箱
3. 代码类 → coder，轻量 → implementer；沙箱批次 worker **cwd = worktree_path**
4. 并行 WU 须有 `tracking/DISPATCH-TRACK-*.md`；中断恢复读 `HANDOFF.md` + tracking（见 `tracking/schema.md`）
5. **GROUP 全部 WU 返回后** 必须走 § GROUP 尾盘（不可末 WU 完成即停）；交付后 **WORKTREE-CLOSE**（用户确认 Git 后）

具体委派方式见适配器 `bindings.md`。

## GROUP 尾盘（集体测试 + 集体审查）

**适用：** 编排调度的 GROUP 收尾或单批次交付（非 routing「小改动」）。

**权威：** `docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md` §4；步骤 `dispatcher-workflow.md` § 步骤 3。

| 步骤 | Leader 动作 | 产物 |
| --- | --- | --- |
| A 集体测试 | Load `verification-before-completion`；按 `project.verification.md` 跑本批次命令；plan 要 E2E 时先完成 Test Engineer WU | Write `verifications/YYYY-MM-DD-<topic>-collective-test.md`（`collective-test.md`） |
| B 集体审查 | Load `requesting-code-review`；委派**独立 reviewer**（与所有实现实例不同）；Reviewer 只返回 | Write `reviews/YYYY-MM-DD-<topic>-code-review.md`（`code-review.md`） |
| C 关闭 | 更新 execution-log § 尾盘门禁；测试 PASS 且审查 APPROVE（或合法 SKIPPED）后方可声称批次完成 | execution-log |

**禁止：** 仅以 Coder `code_review: PASS` 替代 B；未 Write A+B 产物即在 execution-log 写「批次完成」。

**可跳过集体审查：** 仅当满足 `docs/superpowers/specs/2026-05-26-coder-role-design.md` § 小 WU 跳过 Reviewer 全条件 → `verdict: SKIPPED` 写入 code-review 产物。
