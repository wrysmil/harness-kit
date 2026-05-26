# Plan Progress Sync（计划勾选同步）

以仓库 Markdown 为准；**禁止**仅在聊天里用 `[√]` 充当完成记录。

## 格式

| 状态 | 写法 |
| --- | --- |
| 未完成 | `- [ ]` |
| 完成 | `- [√]` |
| 不适用 | `- [—]` + 简短原因 |

## 谁改什么

| 角色 | plan / CHECKLIST | tracking |
| --- | --- | --- |
| Coder / Implementer / Test Engineer | **不改** | 不改 |
| **Leader** | WU 验证通过后 `- [ ]` → `- [√]` | append `DISPATCH-TRACK-*.md` |

子 Agent 返回 **`wu_status: done | blocked`** 及 done criteria 对照结果；Leader 据此写文件。

## 时机

- **单 WU**：Leader 验证通过 → 立即勾 plan + append tracking
- **GROUP 交付**：集体 Reviewer `APPROVE`（或合法跳过）后，方可对外声称批次完成；此前可逐步勾单项

## Leader

- 对照子 Agent 返回与代码/验证，不采信回复里的「已勾选」表述
- Reviewer `APPROVE` 后确认 plan / CHECKLIST 与验收一致

## 例外

可选未做：`- [—]`，勿留空 `- [ ]`。
