# 上下文预算（Cursor 编排）

改编自 harness-engineer `runtime/context-engineering.md`。

---

## 40% 规则

上下文约 **40%** 时采取行动：

| 选项 | 场景 |
| --- | --- |
| **压缩** | 同阶段内继续，丢弃 raw 工具输出 |
| **Handoff + 新 Task** | 探索/实现 Worker 范围过大 |
| **新会话** | 跨阶段（plan → implement）或上下文焦虑 |

Handoff 路径：`.ai-runtime-artifacts/execution-logs/HANDOFF.md`

---

## 范围控制

- 每个 Implementer subagent：**≤5 个写文件**
- 每个 Explorer subagent：限定目录，跳过 `node_modules/`、`.git/`、`dist/`、`target/`、`.venv/`
- 大仓库：按模块拆多个 explore Task

---

## 监控

- 后台 Task：每 2–3 分钟轮询输出
- **10 分钟无输出**：kill → 缩小 scope → 重派
- exit 0 不保证有有效输出 — 检查产物文件与行数

---

## 阶段边界

| 跨越 | 建议 |
| --- | --- |
| 调研 → 计划 | 新会话或 HANDOFF |
| 计划 → 实现 | **必须** HANDOFF 或新 Leader 上下文 |
| 实现 → 审查 | **必须** 独立 `reviewer` subagent（不同实例） |
