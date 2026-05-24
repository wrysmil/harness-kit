# Cursor 平台适配（harness-kit）

本文档是 harness-engineer `platform-adapters.md` 的 harness-kit 中文版改编。  
上游版本见 `VENDOR.md`。

---

## 平台检测

| 信号 | 平台 |
| --- | --- |
| Cursor 工作区、`.cursor/`、Task 工具可用 | **cursor** |
| Codex CLI + `omx` 在 PATH | **codex** |
| 以上皆否 | **generic** — 单会话顺序执行，关键步骤需人工确认 |

在 execution-log 的 front matter 中记录 `platform: cursor | codex | generic`。

---

## Cursor 角色映射

| Harness 角色 | Cursor 机制 |
| --- | --- |
| 编排者（Leader） | 主 Agent（Composer / Agent 模式） |
| 子 Agent | Task 工具 |
| 只读调研 | `explore` + `readonly: true` |
| 实现 | `generalPurpose` 或 `shell`（钉死文件列表） |
| 审查 | **独立** Task 或新主线程轮次 |
| 后台长任务 | `run_in_background: true` + 轮询终端/通知 |
| 项目规则 | `.cursor/rules/`、`AGENTS.md`、`harness-kit/core/` |
| 生命周期钩子（可选） | `.cursor/hooks.json` |

### Task `subagent_type` 速查

| 类型 | 用途 |
| --- | --- |
| `explore` | 代码库搜索、调用链、文件映射 |
| `generalPurpose` | 有界实现、架构分析、调试 |
| `shell` | 测试、构建、脚本 |
| `ci-investigator` | CI 失败根因 |
| `best-of-n-runner` | 隔离实验（显式启用） |

---

## Cursor 默认参数

```yaml
max_parallel_agents: 3      # 上限 5；遇限流则降低
loop_mode: single-pass      # 默认；continuous 需显式 opt-in
subagent_spawn: Task 工具   # 禁止自造 spawn 命令
monitoring: 轮询后台 Task 与终端输出
```

配置模板：`harness-kit/adapters/cursor/orchestration/config.defaults.yaml`

---

## Codex 路径（并存）

当平台为 **codex** 时，并行实现仍走 `omx ultrawork` 或等价 omx 工作流（见 `harness-kit/core/routing.md`）。  
**不要**在 Codex 会话中强制 Task 工具映射。

---

## 限制与缓解

| Cursor 限制 | 缓解 |
| --- | --- |
| 无内置 cron | 后台 Task 每 2–3 分钟轮询；可用 `/loop` skill |
| 无项目级自定义 subagent 类型 | 用 `generalPurpose` + 角色 prompt 前缀 |
| 无 omx 式模型能力表 | 可选 `model-routing.yaml`（Phase 2） |
| 连续自治循环非原生 | single-pass + `HANDOFF.md` 链接多会话 |

---

## 自检清单（非阻塞）

启动 Cursor 编排前建议确认：

1. Task 工具可派发（试一次只读 `explore`）
2. `.cursor/rules/cursor-subagent-routing.mdc` 已投影
3. `.agents/skills/cursor-orchestration/` 已投影
4. Git 在 feature 分支操作，不直推 main
5. 多 task 实现前已有 spec 或 plan（或 routing 允许 skip 并记录原因）

详见 `CURSOR-PRECHECK.md`（同目录）。
