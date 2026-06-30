# MCP 扩展

MCP（Model Context Protocol）server 配置。`.mcp.json` 是事实标准，Cursor 与 Claude Code 都读项目根的 `.mcp.json`，**无需平台 adapter 翻译**。

## 包含的 Server

模板默认空（`mcpServers: {}`）。各项目按需在 `.mcp.json` 的 `mcpServers` 下加 server，例如：

```json
{
  "mcpServers": {
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${env:GITHUB_TOKEN}"
      }
    }
  }
}
```

## 启用方式

`harness-project.sh project` 会自动把 `mcp.servers.template.json` 复制到项目根 `.mcp.json`（**仅在文件不存在时**；已有则不动，避免覆盖用户配置）。

```bash
# 1. 投影
bash harness-kit/scripts/harness-project.sh project

# 2. 编辑 .mcp.json（按需添加 server）
# 3. 重启 AI 工具，确认 MCP server 已加载
```

## 与 cursor 适配器的关系

`adapters/cursor/.cursor/config.defaults.yaml` 可包含 MCP 相关默认配置（如 server 白名单）。`.mcp.json` 是项目级注册，`config.defaults.yaml` 是 Cursor UI 行为配置，两者职责分离。

## 故障排查

- `.mcp.json` 在项目根，不是 `harness-kit/` 里
- `command` 用 `npx` / `uvx` / 绝对路径均可；`args` 透传
- `env` 中可用 `${env:VAR_NAME}` 引用本机环境变量
- server 启动失败 → AI 工具的 MCP 面板看具体 stderr
