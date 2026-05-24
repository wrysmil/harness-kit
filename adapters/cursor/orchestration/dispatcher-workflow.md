# Cursor Dispatcher 工作流（ultrawork 等价）

将已批准的实施计划转为并行 Task 执行。改编自 harness-engineer `agents/dispatcher.md`。

**触发条件：** `harness-kit/core/routing.md` 判定为「多 task 编码 / 并行实现」，且平台为 Cursor。

---

## 输入

- `.ai-runtime-artifacts/plans/` 中已批准 plan，或
- spec front matter 中 `skip:plan(reason)` 且范围仍属多 task（需说明）

## 输出

- 代码变更
- `.ai-runtime-artifacts/execution-logs/YYYY-MM-DD-<topic>-execution-log.md`
- 可选：`.ai-runtime-artifacts/execution-logs/tracking/DISPATCH-TRACK-<date>.md`

---

## 步骤 1：Worktree 拆分（主 Agent）

从 plan 提取 work unit（WU），每个 WU 须满足：

- **有界**：明确文件列表（通常 ≤5 个写文件）
- **可验证**：有 done criteria（测试、lint 或手工检查点）
- **所有权清晰**：并行 WU 不修改同一文件

产出简易 worktree（可写在 execution-log 正文或 tracking 文件）：

```markdown
## 执行图

GROUP-1（并行）:
  WU-01: <描述> | 文件: a.ts, b.ts | 依赖: 无
  WU-02: <描述> | 文件: c.ts | 依赖: 无

GROUP-2（依赖 GROUP-1）:
  WU-03: <描述> | 文件: d.ts | 依赖: WU-01 接口
```

## 步骤 2：并行派发（Task）

对当前 GROUP 内无未完成依赖的 WU，**并行**派发 Task：

| WU 类型 | subagent_type | readonly |
| --- | --- | --- |
| 只读探查 | `explore` | true |
| 代码实现 | `generalPurpose` | false |
| 测试/构建 | `shell` | false |

**每个 Task prompt 必须包含：**

1. WU 目标与 done criteria
2. 允许修改的文件列表
3. 禁止事项（不改哪些文件、不新增依赖等）
4. 必须返回：变更摘要、命令输出摘要、阻塞项

## 步骤 3：整合与门禁

1. 收集所有 WU 结果
2. 检查文件冲突 — 有冲突则顺序合并或开修复 WU
3. 运行 `harness-kit/project.verification.md` 中的最小验证集
4. **派发独立审查 Task**（`generalPurpose`，只读 + 审查 prompt）— 不得用实现者自审
5. 审查通过后写 execution-log

## 步骤 4：追踪（并行编排时**必须**）

1. 从 `artifact-templates/dispatch-track.md` 创建 `tracking/DISPATCH-TRACK-<date>-<topic>.md`
2. 每 WU 派发/完成时 **append** 条目（格式见 `tracking/schema.md`）
3. 每 WU 可选 `CHECKLIST-<topic>-WU-<id>.md`（模板 `artifact-templates/wu-checklist.md`）
4. 上下文重置时覆盖写 `execution-logs/HANDOFF.md`（模板 `artifact-templates/handoff.md`）

中断恢复：见 `tracking/schema.md` § 中断恢复协议。

---

## Agent 面索引

| 角色 | 文件 | Task 类型 |
| --- | --- | --- |
| Leader | `agents/leader.md` | 主 Agent |
| Implementer | `agents/implementer.md` | `generalPurpose` / `shell` |
| Reviewer | `agents/reviewer.md` | `generalPurpose`（只读，**独立实例**） |
| Debugger | `agents/debugger.md` | `explore` → 修复 WU |

上下文纪律：`context-budget.md`。模型建议：`model-routing.yaml`。

---

## 与 superpowers 的衔接

| 阶段 | Skill |
| --- | --- |
| 需求 / 设计 | `superpowers:brainstorming` |
| 计划 | `superpowers:writing-plans` |
| **本工作流** | `cursor-orchestration` |
| 完成前验证 | `superpowers:verification-before-completion` |

---

## 反模式

- 未读 plan 直接开 Task
- 一个 Task 包整个 epic（范围过大 → 超时/ killed）
- 实现与审查同一 Task
- 跳过 execution-log 声称完成
