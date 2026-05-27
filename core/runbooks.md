# Harness Runbooks

## 新功能

1. 先 Read/invoke **`brainstorming`** skill（`SKILL.md`），再按 skill 流程产出 spec；澄清需求时**优先**用 ask 类工具（如 Cursor `AskQuestion`）；不可用则对话逐条问。
2. 将 spec 保存到 `.ai-runtime-artifacts/specs/`（勿默认写入 `docs/superpowers/`）；契约见 `artifact-templates/spec.harness-overlay.md`。
3. **Plan 判定（条件分支）：**
   - spec 涉及多模块协调 / 有先后依赖 / 需要分步编排 → 先 Read **`writing-plans`** skill，再写 plan 至 `.ai-runtime-artifacts/plans/`；并行时另写同 stem `*-dispatch.md`
   - spec 已确认后被修改（范围扩大或方向变化）→ 触发 plan（重新编排）
   - 变更范围单一模块内、无依赖序 → 跳过 plan，直接实现（在 spec front matter route 中记录 `skip:plan(reason)`）
   - 用户显式说"不需要计划"/"直接做" → 跳过 plan
4. **编码实现：**
   - **Codex CLI**：必须使用 `omx ultrawork` 或等价 omx 工作流
   - **Cursor**：必须使用 `cursor-orchestration:dispatcher-workflow`（`.cursor/agents/harness-*` 并行，见 `dispatcher-workflow.md`）
   不允许跳过编排层直接大规模编码。
5. 编码完成后产出 `execution-log` 到 `.ai-runtime-artifacts/execution-logs/`，记录实际路由、变更文件和待验证项。
6. 验证结果保存到 `.ai-runtime-artifacts/verifications/`。

## 缺陷修复

1. 使用 `superpowers:systematic-debugging` 或 omx debugger 路由复现并定位。
2. 写清根因、影响范围和修复方案。
3. **修复实现：**
   - **Codex CLI**：必须使用 `omx` 工作流
   - **Cursor**：`cursor-orchestration` 或主 Agent + Task（单 WU 修复）
4. 编码完成后产出 `execution-log` 到 `.ai-runtime-artifacts/execution-logs/`。
5. 使用最接近缺陷的命令验证。
6. 验证摘要保存到 `.ai-runtime-artifacts/verifications/`。

## 架构决策

1. 读取 `harness-kit/project.profile.md` 和相关代码。
2. 必要时用 omx architect / critic / planner 组合做对比。
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

## Cursor 编排 Runbook

**适用：** Cursor Agent + `.cursor/agents/harness-*`；路由见 `harness-kit/core/routing.md` Cursor 列。

完整步骤见 `harness-kit/adapters/cursor/orchestration/dispatcher-workflow.md`。要点：

1. 遵守 **阶段门禁**（spec/plan 写入后暂停，见 `harness-kit/core/routing.md` § 阶段门禁）
2. plan 批准后声明 `cursor-orchestration`，拆 WU；代码类委派 `harness-coder`，docs/chore/config 委派 `harness-implementer`
3. 整合后委派 **独立** `harness-reviewer`
4. 并行 WU 须有 `tracking/DISPATCH-TRACK-*.md`；中断恢复读 `HANDOFF.md` + tracking（见 `tracking/schema.md`）
