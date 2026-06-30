Harness：首行「Harness：<route>」；stage skill / Tier 1+ 次行 Skills: slug@path loaded|skipped。spec/plan 写入后暂停（组合指令「然后执行」不跳过）。Tier 1 须 verification-lite。文本用 Write/StrReplace。

**写计划阶段禁止使用 Claude Code 原生 `EnterPlanMode` / `ExitPlanMode`（会把 plan 写到 `~/.claude/plans/`，绕开 Harness 契约、`.ai-runtime-artifacts/plans/` 落盘与计划门禁）。** 必须 Load `writing-plans` skill 并 `Write` 到 `.ai-runtime-artifacts/plans/YYYY-MM-DD-<topic>-plan.md`。详见 `core/routing.md` § 平台原生 plan 工具。

---

## 最关键规则摘要（2026-06-11 起）

注入时机：`SessionStart`（每次新会话）。**这是 Claude Code 平台能给的最大限度**——Cursor 模式下整本 rules 都被平台自动注入，Claude Code 模式下只能靠本钩子注入这段。

1. **首行声明**：每个任务首句 `「Harness：<route 或 "Tier 0 小改动" | "Tier 1 Leader 直做">」`；stage skill / Tier 1+ 次行 `Skills: <slug>@<path> loaded|skipped`。
2. **阶段门禁**：写 `specs/` / `plans/` / `decisions/` 后**暂停**等用户在本会话明确继续。组合指令「然后执行/直接做」**不**跳过此门禁。
3. **平台原生 plan 工具禁止**：Claude Code `EnterPlanMode` / `ExitPlanMode` 绕开 Harness，**禁止使用**；强阻断见 `block-native-plan-mode` 钩子（opt-in，需要在 `.claude/settings.json` 启用）。
4. **沟通语言**：对用户回复、阶段门禁说明、产物摘要、验收口径、子 Agent 派发 prompt 全部使用**中文**（代码标识符、路径、命令、API 名、固定段键名保留英文）。
5. **leader + sub-agent 编排诚实声明**：Claude Code 平台**没有**调度器/状态机/自动触发器。"集体测试" / "集体审查" / "WORKTREE-CLOSE" 等"尾盘动作"**必须由 Leader 在本会话中手动执行**。`harness-subagent-stop` 钩子只发提示，**不**强制。`SpawnWorker(reviewer)` 是 prompt 级 readonly 约束，subagent 仍能用 Write 工具。
6. **完成 ≠ 末个 WU 返回**：GROUP 收尾须按 `core/orchestration/dispatcher-workflow.md` § 步骤 3 走 A 集体测试 → B 集体审查 → C 关闭，方可声称"本批次完成"。此规则是 **Leader 自律**，**不**有自动化门禁强制。
7. **禁止自动 push / 开 PR**：所有 Git push / MR / PR 必须经用户**显式确认**；子 Agent 不 commit / push。

完整规则见 `harness-kit/core/routing.md`；orchestration 能力声明见 `core/orchestration/claude-continuous-loop.md` § 物理能力诚实声明。
