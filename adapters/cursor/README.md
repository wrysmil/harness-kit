# Cursor 适配（harness-kit）

Cursor 侧子 Agent 编排层，与 Codex/omx Runtime 并列，共享 `harness-kit/core/` 规范。

## 目录

```
adapters/cursor/
├── .cursor/
│   ├── rules/                   # ai-entry、cursor-subagent-routing
│   ├── hooks.json.example       # 可选 hooks（复制为 hooks.json）
│   └── hooks/*.sh
├── orchestration/
│   ├── platform-adapters.zh.md
│   ├── dispatcher-workflow.md
│   ├── context-budget.md
│   ├── continuous-loop.md       # opt-in 自治循环
│   ├── model-routing.yaml
│   ├── hooks/README.md
│   ├── agents/                  # Leader / Implementer / Reviewer / Debugger
│   └── tracking/schema.md
└── README.md
```

## 投影到目标项目

| 源 | 目标 |
| --- | --- |
| `adapters/cursor/.cursor/` | `.cursor/` |
| `adapters/agents/.agents/skills/cursor-orchestration/` | `.agents/skills/cursor-orchestration/` |
| `adapters/cursor/orchestration/` | 保留在 harness-kit 内（不投影） |

## AGENTS 拆分

| 文件 | 用途 |
| --- | --- |
| `entrypoints/AGENTS.md` | 工具中立 Harness 入口（投影到根） |
| `entrypoints/AGENTS.omx.md` | Codex/OMX 专章 |
| `entrypoints/AGENTS.cursor-overlay.md` | Cursor 深读 |

## 可选 Hooks

```bash
cp harness-kit/adapters/cursor/.cursor/hooks.json.example .cursor/hooks.json
chmod +x .cursor/hooks/*.sh
```

## 上游

改编自 harness-engineer 5.3.1。见 `orchestration/VENDOR.md` 与 `CURSOR-HARNESS-INTEGRATION-PLAN.md`。
