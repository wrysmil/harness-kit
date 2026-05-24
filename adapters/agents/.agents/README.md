# .agents

本目录存放当前项目自己新增的 AI 规则和 skills。

## 目录约定

- `skills/`：项目自己新增的 skills。

Harness 脚手架不会预置业务 skill。比如专利、业务分析、发布检查等能力，都应由项目按需新增到 `.agents/skills/`。

## AI 接入方式

团队成员不需要自己照着命令逐条执行。把下面这段话交给 AI：

```text
请先读取 AGENTS.md 和 cow-harness/README.md。
如果当前环境需要安装或检查 AI runtime，请先说明会修改哪些本机环境，然后由你执行 cow-harness/scripts/install-ai-skills.sh。
完成后请汇总 oh-my-codex / omx 和基础 skills 的可用状态。
```

AI 会按需调用 `cow-harness/scripts/install-ai-skills.sh`。该脚本负责安装或检查 `oh-my-codex` / `omx`，并检查本机是否已安装 superpowers skills。

## 外部通用 Skills

本仓库不复制 superpowers skills。通过标准方式安装后，优先使用以下外部能力；若未安装，则使用 `oh-my-codex` 中的等价工作流能力：

- `superpowers:brainstorming`
- `superpowers:writing-plans`
- `superpowers:systematic-debugging`
- `superpowers:test-driven-development`
- `superpowers:verification-before-completion`

安装方式（全局）：

```bash
npx skills add obra/superpowers -g
```

安装后 skills 位于 `~/.claude/skills/` 或 `~/.agents/skills/` 下（由 skills CLI 自动管理）。

其他成员如果尚未安装，AI 应按 `AGENTS.md` 的行为要求使用当前工具中等价的能力。

## 优先级

项目级 skill 只放真正属于本项目的能力。`oh-my-codex` / `omx` 由 npm 包和 `cow-harness/scripts/install-ai-skills.sh` 管理，不在 `.agents/skills/` 中重复定义。

若 `.agents/skills/` 中的项目级规则与旧 `.cursor/`、`.agent/`、`.conductor/`、`.kiro/` 规则冲突，以项目级规则和 `AGENTS.md` 为准。
