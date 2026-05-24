# Cursor Hooks（Harness 可选增强）

Phase 3 可选能力：通过 Cursor 生命周期 hook 辅助路由声明与并行追踪。

**默认不启用** — 规则（`.cursor/rules/`）与 skill 已足够。启用 hook 前请确认 Cursor 版本支持项目级 `hooks.json`。

---

## 启用步骤

1. 投影 `adapters/cursor/.cursor/` → 项目根 `.cursor/`
2. 复制示例配置：

```bash
cp harness-kit/adapters/cursor/.cursor/hooks.json.example .cursor/hooks.json
chmod +x .cursor/hooks/*.sh
```

3. 重启 Cursor 或在 Hooks 设置中确认已加载
4. 新开 Agent 会话，检查 Hooks 输出通道是否有 `sessionStart` 触发

---

## 包含的 Hook

| 事件 | 脚本 | 行为 |
| --- | --- | --- |
| `sessionStart` | `hooks/harness-session-init.sh` | 注入 Harness 路由提示（`additional_context`） |
| `subagentStop` | `hooks/harness-subagent-track-reminder.sh` | 提醒 Leader 追加 DISPATCH 追踪 |

均为 **fail-open**：脚本失败不阻塞会话（未设 `failClosed: true`）。

---

## 扩展（自行添加）

| 目标 | 建议事件 |
| --- | --- |
| 用户 prompt 路由分诊 | `beforeSubmitPrompt` + matcher `UserPromptSubmit` |
| 审查/实现 Task 分离审计 | `subagentStart` matcher `generalPurpose` |
| Shell 危险命令 | `beforeShellExecution` |

改编思路来自 harness-engineer `runtime/hook-system.md`；Cursor 具体 JSON 字段以当前 Cursor 文档为准。

---

## 与 OMX hooks 的关系

| | OMX / Codex | Cursor Harness hooks |
| --- | --- | --- |
| 关键词路由 | `UserPromptSubmit` + keyword registry | 可选 `beforeSubmitPrompt`（本 kit 未默认启用） |
| 状态 | `.omx/state/` | `.ai-runtime-artifacts/execution-logs/tracking/` |
| 启用 | `omx setup` | 手动复制 `hooks.json.example` |

---

## 故障排查

1. 路径相对于**项目根**：`.cursor/hooks/...`
2. 脚本须可执行：`chmod +x .cursor/hooks/*.sh`
3. `harness-subagent-track-reminder.sh` 依赖 `python3`（无则改为纯 echo JSON）
4. Hook 未加载 → 重启 Cursor；检查 Hooks 面板
