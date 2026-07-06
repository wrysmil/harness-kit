# Trae 平台适配器

第三参考实现：Trae Agent 并行 + core 编排语义 + extensions 扩展（hooks / MCP）。

## 接入

1. 根目录 `AGENTS.md`
2. 投影 skill + extensions：`bash harness-kit/scripts/harness-project.sh project`（含 `orchestration` skill、hooks 脚本与配置示例、`.mcp.json`）
3. 多 task 实现：Load **`orchestration`** → `core/orchestration/dispatcher-workflow.md`

## 平台检测

Trae 工作区 → `platform: trae`

## 与 Claude/Cursor 差异

| 能力 | 状态 |
| --- | --- |
| `interaction.structured-ask` | supported — Task 工具 |
| `hooks.session-lifecycle` | supported — `.trae/settings.json` hooks（`harness-project.sh` 自动生成 `.example`） |
| `extensions.mcp.servers` | supported — 项目根 `.mcp.json` |
| `orchestration.parallel-wu` | supported — max 3 并行 |
| `orchestration.continuous-loop` | manual — 多会话 HANDOFF |

parity 全表：`capability-matrix.yaml`。绑定：`bindings.md`。

## 目录结构

```
adapters/trae/
├── bindings.md                 # 原语 → Trae 绑定映射
├── capability-matrix.yaml      # 26 项能力状态
├── VENDOR.md                   # 上游来源说明
├── README.md                   # 本文件
└── .trae/
    ├── rules/
    │   ├── ai-entry.md         # 统一入口
    │   └── trae-subagent-routing.md  # 子 Agent 路由
    ├── TRAE-PRECHECK.md        # 编排自检清单
    └── config.defaults.yaml   # 配置覆盖
```

## 关键文档

| 文档 | 用途 |
| --- | --- |
| `../../core/orchestration/dispatcher-workflow.md` | 编排唯一步骤源 |
| `bindings.md` | Trae 原语映射 |
| `capability-matrix.yaml` | parity 审计 |
| `.trae/rules/ai-entry.md` | Trae 入口规则 |
| `.trae/rules/trae-subagent-routing.md` | 子 Agent 路由 |
| `../../core/routing.md` | 路由权威 |

## Hooks（opt-in）

`harness-project.sh project` 会复制 hooks 脚本到 `.trae/hooks/` 并生成 `.trae/settings.json.example`，**默认不启用**。启用步骤：

```bash
ls .trae/hooks/harness-*.sh           # 确认脚本已投影
# 把 .trae/settings.json.example 的 hooks 段合并到 .trae/settings.json
# （harness-project.sh 不覆盖用户已有 settings.json）
chmod +x .trae/hooks/*.sh
```

Hook 内容与 Claude/Cursor 完全共享（来自 `core/extensions/hooks/content/`），仅 wrapper 脚本的 JSON wire format 不同。详见 [core/extensions/hooks/README.md](../../core/extensions/hooks/README.md)。

## MCP

`harness-project.sh project` 会把 `core/extensions/mcp/mcp.servers.template.json` 复制到项目根 `.mcp.json`（**仅在文件不存在时**，避免覆盖用户配置）。详见 [core/extensions/mcp/README.md](../../core/extensions/mcp/README.md)。

## 共享层

Trae 引用 `.agents/` 中的共享 skill 和 agent manifest：

- `.agents/skills/orchestration/SKILL.md`
- `.agents/agents/coder.md`
- `.agents/agents/implementer.md`
- `.agents/agents/reviewer.md`
- `.agents/agents/test-engineer.md`
- `.agents/agents/explorer.md`
- `.agents/agents/debugger.md`
- `.agents/agents/web-investigator.md`
