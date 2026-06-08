# 共享 Skills（`.agents/skills/`）

本目录存放所有平台通用的 harness skill。各平台 adapter 通过 `LoadSkill(slug)` 绑定引用。

## 内容

| Skill | 用途 |
| --- | --- |
| `git-xywh` | 组织 Git 规范（分支、Angular 提交、MR） |
| `test-driven-development` | TDD 纪律 |
| `verification-before-completion` | 完成验证门禁 |
| `systematic-debugging` | 根因调查 |
| `requesting-code-review` | 代码审查请求 |
| `receiving-code-review` | 代码审查接收 |
| `document-review` | 文档审查 |
| `frontend-design` | 前端美学 |
| `ui-ux-pro-max` | UI/UX 设计系统 |
| `agent-browser` | 浏览器自动化 |
| `cursor-orchestration` | Cursor 编排 |
| `claude-orchestration` | Claude 编排 |
| `trae-orchestration` | Trae 编排 |

## 路径约定

- 共享层：`.agents/skills/<slug>/SKILL.md`（本目录）
- 平台覆盖：`.cursor/skills/`、`.claude/skills/`、`.trae/skills/`
- 用户全局：`~/.agents/skills/<slug>/SKILL.md`

加载顺序与路由：见 `core/orchestration/skill-preferences.md`。

## 来源

多数 skill 来自 `obra/superpowers`、`anthropics/skills` 等上游，通过 `_vendor-sources.yaml` 追踪。
