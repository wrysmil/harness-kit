Harness：首行「Harness：<route>」；stage skill / Tier 1+ 次行 Skills: slug@path loaded|skipped。spec/plan 写入后暂停（组合指令「然后执行」不跳过）。Tier 1 须 verification-lite。文本用 Write/StrReplace。

**写计划阶段禁止使用 Claude Code 原生 `EnterPlanMode` / `ExitPlanMode`（会把 plan 写到 `~/.claude/plans/`，绕开 Harness 契约、`.ai-runtime-artifacts/plans/` 落盘与计划门禁）。** 必须 Load `writing-plans` skill 并 `Write` 到 `.ai-runtime-artifacts/plans/YYYY-MM-DD-<topic>-plan.md`。详见 `core/routing.md` § 平台原生 plan 工具。
