# Cursor 适配（harness-kit）

Cursor 侧子 Agent 编排层，与 Codex/omx Runtime 并列，共享 `harness-kit/core/` 规范。

## 目录

```
adapters/cursor/
├── .cursor/rules/
│   ├── ai-entry.mdc
│   └── cursor-subagent-routing.mdc
├── orchestration/
│   ├── platform-adapters.zh.md
│   ├── dispatcher-workflow.md
│   ├── context-budget.md
│   ├── model-routing.yaml
│   ├── config.defaults.yaml
│   ├── CURSOR-PRECHECK.md
│   ├── VENDOR.md
│   ├── agents/                    # Phase 2 角色面
│   │   ├── leader.md
│   │   ├── implementer.md
│   │   ├── reviewer.md
│   │   └── debugger.md
│   └── tracking/
│       └── schema.md
└── README.md
```

## 投影到目标项目

| 源 | 目标 |
| --- | --- |
| `adapters/cursor/.cursor/` | `.cursor/` |
| `adapters/agents/.agents/skills/cursor-orchestration/` | `.agents/skills/cursor-orchestration/` |
| `adapters/cursor/orchestration/` | 保留在 harness-kit 内（不投影） |

## 产物模板（项目根 artifact-templates 投影后）

- `dispatch-track.md` — 并行追踪
- `handoff.md` — 中断恢复
- `wu-checklist.md` — 单 WU 验收

## 验收（Phase 2）

- [ ] 并行 WU 有 `tracking/DISPATCH-TRACK-*.md`
- [ ] implementer 与 reviewer 为不同 Task
- [ ] 中断后可从 HANDOFF + track 恢复

## 上游

改编自 harness-engineer 5.3.1。见 `orchestration/VENDOR.md` 与 `CURSOR-HARNESS-INTEGRATION-PLAN.md`。
