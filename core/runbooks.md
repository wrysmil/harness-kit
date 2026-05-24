# Harness Runbooks

## 新功能

1. 使用 `superpowers:brainstorming` 产出 spec。
2. 将 spec 保存到 `.ai-runtime-artifacts/specs/`。
3. **Plan 判定（条件分支）：**
   - spec 涉及多模块协调 / 有先后依赖 / 需要分步编排 → 使用 `superpowers:writing-plans` 产出实施计划
   - spec 已确认后被修改（范围扩大或方向变化）→ 触发 plan（重新编排）
   - 变更范围单一模块内、无依赖序 → 跳过 plan，直接实现（在 spec front matter route 中记录 `skip:plan(reason)`）
   - 用户显式说"不需要计划"/"直接做" → 跳过 plan
4. **编码实现：**
   - **Codex CLI**：必须使用 `omx ultrawork` 或等价 omx 工作流
   - **Cursor**：必须使用 `cursor-orchestration:dispatcher-workflow`（Task 并行，见 `harness-kit/adapters/cursor/orchestration/dispatcher-workflow.md`）
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

## Harness 迁移到新项目

1. 将 `harness-kit/` 放入新项目。
2. 对 AI 说：

```text
请先读取 harness-kit/README.md 和 harness-kit/init/bootstrap.prompt.md。
这是一个新项目刚接入 Agent Harness，请按 Harness 初始化流程处理：
1. 从 harness-kit/entrypoints/ 投影根目录 AI 入口文件。
2. 从 harness-kit/adapters/ 投影工具适配目录。
3. 创建 .ai-runtime-artifacts/ 及其子目录。
4. 如需安装或检查 AI runtime，请先说明会修改哪些本机环境，然后由你执行 harness-kit/scripts/install-ai-skills.sh。
5. 读取 harness-kit/init/project-profiler.prompt.md。
6. 扫描当前项目，生成或更新 harness-kit/project.profile.md、harness-kit/context-map.md、harness-kit/project.verification.md。
7. 由你运行 harness-kit/scripts/harness-check.sh。
8. 汇总推断项、待确认项和验证结果。
```

3. 人 review `project.profile.md` 中的推断项和待确认项。

---

## Cursor 编排 Runbook

**适用：** Cursor Agent + Task 工具；路由见 `harness-kit/core/routing.md` Cursor 列。

### 新功能（Cursor 全链路）

1. `superpowers:brainstorming` → spec → `.ai-runtime-artifacts/specs/`
2. 需要时 `superpowers:writing-plans` → plan → `.ai-runtime-artifacts/plans/`
3. 声明 `「Harness：cursor-orchestration:dispatcher-workflow」`
4. Leader 读 `adapters/cursor/orchestration/dispatcher-workflow.md` + `agents/leader.md`
5. 拆 WU，创建 `tracking/DISPATCH-TRACK-*.md`（模板 `artifact-templates/dispatch-track.md`）
6. 并行 Task 派发 Implementer（`agents/implementer.md`）— 每 WU 独立实例
7. 整合后派发 **独立** Reviewer Task（`agents/reviewer.md`）— **不得**与 implementer 同实例
8. `superpowers:verification-before-completion` → `.ai-runtime-artifacts/verifications/`
9. execution-log → `.ai-runtime-artifacts/execution-logs/`

### 缺陷修复（Cursor）

1. `superpowers:systematic-debugging` + Task `explore`（只读）— `agents/debugger.md`
2. 根因写清 → spec 或 verification 草稿
3. 单 WU：`generalPurpose` 修复；多模块：走 cursor-orchestration
4. execution-log + verification

### 架构决策（Cursor）

1. 读 `project.profile.md` + 相关代码
2. Task `generalPurpose`（**只读**）分别扮演 architect / critic 视角 — 各独立 Task
3. Leader 汇总 → `.ai-runtime-artifacts/decisions/`

### 中断恢复

1. 读 `execution-logs/HANDOFF.md`（若存在）
2. 读 `tracking/DISPATCH-TRACK-*.md` — 找最后 `completed` WU
3. 从 `tracking/schema.md` 恢复协议继续；不重跑已 APPROVE 的审查

### 关键约束

- implementer 与 reviewer **必须**不同 Task 实例
- 并行 WU **必须**有 tracking 文件
- 上下文 ~40% → `handoff.md` 模板（`artifact-templates/handoff.md`）
- 模型建议见 `orchestration/model-routing.yaml`（可选）
