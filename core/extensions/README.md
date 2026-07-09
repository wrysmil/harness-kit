# Extensions（平台扩展抽象层）

把跨平台需要统一、但 wire format 又必然平台相关的「扩展能力」抽到 core 层，由平台适配器做 binding。  
与 `core/orchestration/` 的关系：orchestration 是核心运行原语（必须实现），extensions 是可选增强（可降级）。

## 包含的扩展

| 扩展 | 抽象 | 平台 binding |
|------|------|--------------|
| `hooks/` | 生命周期 hook（内容 + 触发事件） | Cursor: `.cursor/hooks.json` + bash；Claude: `.claude/settings.json` `hooks` 段 + bash |
| `mcp/` | MCP server 配置 | 各平台均读项目根 `.mcp.json`（标准） |

## 设计原则

1. **内容与格式分离**：hook 的「内容」（提示文本）放 `content/`，「平台格式」（JSON wire format）由 `scripts/<platform>/` 决定。
2. **单一来源**：同一份 hint 文本只存一次（`content/<name>.md`），由各平台 wrapper 读取并包成平台 JSON。
3. **声明式 spec**：`hooks.spec.yaml` / `mcp.servers.template.json` 是 source of truth，`harness-project.sh` 在投影时按当前平台读 `bindings.<platform>` 段。
4. **fail-open**：所有 hook 脚本失败时 `exit 0`，不阻塞主路径（与原 Cursor 实现一致）。
5. **opt-in**：投影脚本本身会同步复制脚本与配置示例，但启用需用户手动确认（避免误开副作用）。

## 投影位置

| 平台 | 脚本落点 | 配置文件 |
|------|----------|----------|
| Cursor | `.cursor/hooks/` | `.cursor/hooks.json`（用户从 `.example` 改名启用） |
| Claude | `.claude/hooks/` | `.claude/settings.json` `hooks` 段（合并，不覆盖已有） |

## 不在 extensions 范围内

- 编排 skill（`orchestration`）— 已在 `.agents/skills/`
- 子 Agent manifest（coder / implementer / reviewer / …）— 已在 `.agents/agents/`
- 入口文件（AGENTS.md / CLAUDE.md）— 在 `entrypoints/`

这些都已经统一，无需再放到 extensions。
