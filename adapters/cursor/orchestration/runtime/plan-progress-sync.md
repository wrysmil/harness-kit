# Plan Progress Sync（计划勾选同步）

WU / 单步验收通过后，**必须**在仓库 Markdown 里把对应 `- [ ]` 改为 `- [√]`。  
**禁止**仅在 Agent 回复里列出 `[√]` 充当“已完成”记录——以文件为准。

## 格式

| 状态 | 写法 |
| --- | --- |
| 未完成 | `- [ ]` |
| 完成 | `- [√]` |
| 不适用 | `- [—]` + 简短原因 |

## 更新范围（按优先级）

1. **`.ai-runtime-artifacts/plans/<plan-file>.md`** — 本 WU / 本步对应的任务勾选（主来源，与 `superpowers:writing-plans` 的 checkbox 步骤一致）
2. **`CHECKLIST-<topic>-WU-<id>.md`**（若 Leader 已创建）— Done criteria / 验证命令
3. **`tracking/DISPATCH-TRACK-*.md`** — 仅 append 状态行，**不**替代 plan 勾选

## 时机

- 每完成 plan 中一步且验证通过 → **立即**编辑 plan，将该步 `- [ ]` → `- [√]`
- WU 全部 done criteria 满足 → plan 中本 WU 相关项 + 可选 CHECKLIST 文件全部 `[√]`
- 声称 WU / 任务完成前 → 用搜索 `^- \[ \]` 自检 plan 中本 WU 范围无遗漏

## Implementer 纪律

1. 用 **StrReplace / Write** 改 plan（或 CHECKLIST）文件，不要只改聊天输出
2. 返回摘要里**只写**「已同步的文件路径 + 勾选项标题/行号」，**不要**在 `### 计划勾选同步` 下复述一整份带 `[√]` 的 checklist
3. 若一步未完成，plan 中保持 `- [ ]`

## Leader 纪律

- 整合 WU 结果时对照 plan 文件，而非子 Agent 回复里的勾选列表
- Reviewer `APPROVE` 后，Leader 确认 plan 与 CHECKLIST 已与验收一致

## 例外

可选路径未做：标 `- [—]`，勿留空 `- [ ]`。
