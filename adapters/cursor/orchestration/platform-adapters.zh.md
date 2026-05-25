# Cursor 平台适配（harness-kit）

本文档是 harness-engineer `platform-adapters.md` 的 harness-kit 中文版改编。  
上游版本见 `VENDOR.md`。

---

## 平台检测

| 信号 | 平台 |
| --- | --- |
| Cursor 工作区、`.cursor/`、subagent 可委派 | **cursor** |
| Codex CLI + `omx` 在 PATH | **codex** |
| 以上皆否 | **generic** — 单会话顺序执行，关键步骤需人工确认 |

在 execution-log 的 front matter 中记录 `platform: cursor | codex | generic`。

---

## Cursor 角色映射

| Harness 角色 | Cursor 机制 |
| --- | --- |
| 编排者（Leader） | 主 Agent（Composer / Agent 模式） |
| 实现 / 审查 / 探查 / 调试 | **`.cursor/agents/harness-*.md`** 项目 subagent |
| Shell / 测试 / 构建 | Task `shell`（补充） |
| CI 失败 | Task `ci-investigator`（补充） |
| 项目规则 | `.cursor/rules/`、`AGENTS.md`、`harness-kit/core/` |
| 生命周期钩子（可选） | `.cursor/hooks.json` |

### 项目 Subagent（`.cursor/agents/`）

| 文件 | 用途 |
| --- | --- |
| `harness-implementer.md` | 有界 WU 实现 |
| `harness-reviewer.md` | 独立审查（readonly） |
| `harness-explorer.md` | 只读探查 |
| `harness-debugger.md` | 缺陷调查 |
| `harness-test-engineer.md` | 测试 / E2E 资产 |

内置 skill（`.cursor/skills/`，Cursor 自动发现）：见 `orchestration/skill-preferences.zh.md`。

源模板：`harness-kit/adapters/cursor/.cursor/agents/`（bootstrap 投影到项目根 `.cursor/agents/`）。

详细 prompt 与返回格式见各文件及 `orchestration/agents/`（Leader 参考）。

### Task 内置类型（补充）

| 类型 | 用途 |
| --- | --- |
| `explore` | 无 harness-explorer 时的只读搜索 |
| `shell` | 测试、构建、脚本 |
| `ci-investigator` | CI 失败根因 |

---

## Cursor 默认参数

```yaml
max_parallel_agents: 3      # 上限 5；遇限流则降低
loop_mode: single-pass      # 默认；continuous 需显式 opt-in
subagent_spawn: .cursor/agents/harness-*  # 实现/审查优先
monitoring: 轮询后台 Task 与终端输出
```

配置模板：`harness-kit/adapters/cursor/orchestration/config.defaults.yaml`

阶段门禁见 `harness-kit/core/routing.md` § 阶段门禁。

---

## Codex 路径（并存）

当平台为 **codex** 时，并行实现仍走 `omx ultrawork`（见 `harness-kit/core/routing.md`）。  
**不要**在 Codex 会话中强制 Cursor subagent 映射。

---

## 限制与缓解

| Cursor 限制 | 缓解 |
| --- | --- |
| 无内置 cron | 后台 Task 每 2–3 分钟轮询；可用 `/loop` skill |
| subagent 需项目级定义 | bootstrap 投影 `harness-*.md` 五套角色 |
| 无 omx 式模型能力表 | 可选 `model-routing.yaml` |
| 连续自治循环非原生 | single-pass + `HANDOFF.md` 链接多会话 |

---

## 自检清单（非阻塞）

详见 `CURSOR-PRECHECK.md`（同目录）。
