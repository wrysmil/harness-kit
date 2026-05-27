# Harness 项目内置 Skills（`.cursor/skills/`）

Bootstrap 将 `harness-kit/adapters/cursor/.cursor/` 投影到项目根 `.cursor/`，本目录由 **Cursor 自动发现**。

## 内容

仅 **能力副本**（TDD、verification、systematic-debugging、ui-ux-pro-max 等），从本机全局 skill 复制，供子 Agent 按需加载。

**不包含** Leader 阶段 skill：`brainstorming`、`writing-plans`、`git-xywh` 在 `~/.agents/skills/` 或 `~/.cursor/skills/`（Leader 须 Read，见 `routing.md`）。WU 级 skill 查 **`skill-preferences.zh.md`**（`wu_skills: auto`）。

## 同步

```bash
bash harness-kit/scripts/sync-cursor-skills.sh
```

登记见 `_vendor-sources.yaml`。
