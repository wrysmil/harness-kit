# Hooks 扩展

平台无关的 hook 内容（`content/*.md`）+ 平台 binding（`scripts/<platform>/`），由 `harness-project.sh` 在投影时按当前平台复制到目标项目对应位置。

## 包含的 Hook

| Hook | 用途 | 触发时机 |
|------|------|----------|
| `harness-session-init` | 注入 Harness 路由提示到会话上下文 | 会话开始（Cursor `sessionStart` / Claude `SessionStart` / Trae `sessionStart`） |
| `harness-subagent-stop` | 提醒 Leader 追加 DISPATCH 追踪与 plan 勾选 | 子 Agent 结束（Cursor `subagentStop` / Claude `SubagentStop` / Trae `subagentStop`） |
| `block-native-plan-mode` | 阻断 Claude Code 原生 `EnterPlanMode` / `ExitPlanMode`，强制走 `writing-plans` skill | 工具调用前（Claude `PreToolUse`，matcher: `EnterPlanMode\|ExitPlanMode`） |

## 文件结构

```
hooks/
├── content/                            # 平台无关的提示文本（单一来源）
│   ├── session-init.md
│   ├── subagent-stop.md
│   └── block-native-plan-mode.md
├── scripts/                            # 平台 wrapper：读 content，包成平台 JSON
│   ├── cursor/
│   │   ├── harness-session-init.sh     # 输出 {"additional_context": "..."}
│   │   └── harness-subagent-stop.sh    # 输出 {"followup_message": "..."}
│   ├── claude/
│   │   ├── harness-session-init.sh     # 输出 {"hookSpecificOutput": {...}}
│   │   ├── harness-subagent-stop.sh
│   │   └── block-native-plan-mode.sh   # 匹配 EnterPlanMode/ExitPlanMode，exit 2 + stderr 阻断
│   └── trae/
│       ├── harness-session-init.sh      # 输出 {"additional_context": "..."}
│       └── harness-subagent-stop.sh    # 输出 {"followup_message": "..."}
├── hooks.spec.yaml                     # 声明：name + content + per-platform binding
└── README.md
```

> **`block-native-plan-mode` 解决：** Claude Code 的 `EnterPlanMode`/`ExitPlanMode` 会把 plan 写到 `~/.claude/plans/`，完全绕过 Harness stage skill 与 `.ai-runtime-artifacts/plans/` 落盘规则。Hook 在 `PreToolUse` 阶段识别 tool name = `EnterPlanMode|ExitPlanMode`，**退出码 2 + stderr 反馈**（模型可读），让 Claude 改用 `writing-plans` skill。详见 `core/routing.md` § 平台原生 plan 工具。

## 启用方式（opt-in）

**默认不启用** — `harness-project.sh` 投影时只复制脚本与配置示例，不自动启用 hook。

### Cursor

```bash
# 1. 确认脚本已投影
ls .cursor/hooks/harness-*.sh

# 2. 启用
cp .cursor/hooks.json.example .cursor/hooks.json
chmod +x .cursor/hooks/*.sh

# 3. 重启 Cursor，Hooks 面板确认已加载
```

### Claude

```bash
# 1. 确认脚本已投影
ls .claude/hooks/harness-*.sh .claude/hooks/block-native-plan-mode.sh

# 2. 把 .claude/settings.json.example 的 hooks 段合并到 .claude/settings.json
#    （harness-project.sh 不覆盖用户已有 settings.json）
chmod +x .claude/hooks/*.sh

# 3. 重启 Claude Code
```

> `settings.json.example` 默认包含 `PreToolUse` 钩子（阻断 `EnterPlanMode|ExitPlanMode`）。如不希望被强阻断，从示例中删除 `PreToolUse` 段即可。

### Trae

```bash
# 1. 确认脚本已投影
ls .trae/hooks/harness-*.sh

# 2. 启用
cp .trae/settings.json.example .trae/settings.json
chmod +x .trae/hooks/*.sh

# 3. 重启 Trae，Hooks 面板确认已加载
```

## 添加新 Hook

1. 在 `content/<name>.md` 写提示文本
2. 在 `scripts/cursor/<name>.sh`、`scripts/claude/<name>.sh` 和 `scripts/trae/<name>.sh` 写平台 wrapper
3. 在 `hooks.spec.yaml` 加 entry（含 `bindings.cursor` / `bindings.claude` / `bindings.trae`）
4. 跑 `bash scripts/harness-check.sh` 验证

## 故障排查

- 脚本失败不阻塞（`exit 0`），可看 stderr / Hooks 面板
- Cursor/Trae `harness-subagent-stop.sh` 依赖 `python3`（无则降级为 echo JSON）
- Claude 输出必须包含 `hookSpecificOutput.hookEventName`，否则 hook 被忽略
- 路径相对**项目根**（如 `.claude/hooks/...` 或 `.trae/hooks/...`）
