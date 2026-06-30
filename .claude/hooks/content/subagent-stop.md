Harness：子 Agent 已结束。请 Leader 按顺序执行：

(1) 先更新 plan 勾选：在对应 plan 条目将 `- [ ]` → `- [√]`，并在该条目下追加证据行（见 `core/orchestration/runtime/plan-progress-sync.md`），明确：哪个 WU-id/Agent(role) 完成了哪些条目 + 验证证据。
    - 推荐证据行：`  - evidence: WU-<id> | agent_role=<role> | verified_by=<Leader> | proof=<tests|lint|manual>`

(2) 再做追踪落盘：向 `.ai-runtime-artifacts/execution-logs/tracking/DISPATCH-TRACK-*.md` append（如启用 tracking）。

(3) 最后判断是否进入尾盘（仅当本 GROUP 末 WU 已完成）：集体测试 → Write `*-collective-test.md` → 集体审查 → Write `*-code-review.md`（见 spec 2026-05-28-batch-closeout）。

责任边界：子 Agent 不改 plan；由 Leader 验证后落盘。
