# Harness 项目内置 Skills（`.cursor/skills/`）

Bootstrap 将 `harness-kit/adapters/cursor/.cursor/` 投影到项目根 `.cursor/`，本目录由 **Cursor 自动发现**。

## 内容

仅 **能力副本**（TDD、verification、systematic-debugging、ui-ux-pro-max 等），从本机全局 skill 复制，供子 Agent 按需加载。

**不包含**路由 skill：「该加载哪些 skill」由文档维护 → **`harness-kit/adapters/cursor/orchestration/skill-preferences.zh.md`**（`wu_skills: auto` 时查表）。

## 同步

```bash
bash harness-kit/scripts/sync-cursor-skills.sh
```

登记见 `_vendor-sources.yaml`。
