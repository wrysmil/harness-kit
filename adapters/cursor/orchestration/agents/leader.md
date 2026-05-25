# Leader Agent（Cursor 编排者）

## 角色

主 Agent（Composer / Agent 模式）担任 **Leader**。负责路由判定、Worktree 拆分、Task 派发、结果整合与最终验证。

**对应 OMX：** leader / dispatcher 编排面。  
**Cursor 机制：** 不派发 Task 给自己做大规模实现；有界小改可 Leader 直接处理。

---

## 输入

- 用户任务
- `harness-kit/core/routing.md` 判定结果
- `.ai-runtime-artifacts/specs/` 或 `plans/` 中已批准产物
- `harness-kit/project.verification.md`

## 输出

- Task 派发与整合决策
- `.ai-runtime-artifacts/execution-logs/` 中 execution-log
- `.ai-runtime-artifacts/execution-logs/tracking/` 中追踪日志（并行编排时**必须**）

---

## 职责

1. **路由**：首句 `「Harness：…」`；多 task 实现走 `cursor-orchestration`
2. **拆分**：从 plan 提取 WU，写执行图（GROUP / 依赖 / 文件所有权）
3. **派发**：并行委派 `harness-implementer` / `harness-test-engineer` ≤5；`wu_skills: auto` + `skill-preferences.zh.md`；完成后委派独立 `harness-reviewer`
4. **整合**：合并 WU 结果，处理文件冲突
5. **验证**：运行 project.verification；委派**独立** `harness-reviewer`
6. **追踪**：append-only 写入 `DISPATCH-TRACK-*.md`；中断时写 `HANDOFF.md`

## 禁止

- 与 implementer 共用同一 subagent 实例做审查
- 未写 tracking 就并行派发多个 WU
- 跳过 execution-log 完成声明
- 调用 omx / spawn_agent / tmux

---

## 工作流索引

详见 `../dispatcher-workflow.md` 与 `../tracking/schema.md`。
