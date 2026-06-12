# Harness — 阻断平台原生 plan 工具

匹配工具：`EnterPlanMode` / `ExitPlanMode`（Claude Code）、Cursor Plan 模式。

原因：这些原生工具把 plan 落到 `~/.claude/plans/` 或 Cursor 内部，绕开 Harness stage skill、`plan.harness-overlay.md` FM 契约与 `.ai-runtime-artifacts/plans/` 落盘规则。

替代流程：写实施计划必须 Load `superpowers:writing-plans` skill 并 `Write` 到 `.ai-runtime-artifacts/plans/YYYY-MM-DD-<topic>-plan.md`（并行时另写同 stem `*-dispatch.md`）。详见 `harness-kit/core/routing.md` § 平台原生 plan 工具 与 `adapters/claude/bindings.md`。
