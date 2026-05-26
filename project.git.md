---
generated_at: 2026-05-26
generator: harness-project-profiler
org_skill: git-xywh
---

# Project Git — travel-assistant

本文件只记录**相对组织 Git 规范（`git-xywh` skill）的差异**与**本项目约束**。分支模型、MR 流程、Angular 提交格式全文见 skill，不在此重复。

## 组织基线（默认）

- **Skill**：`git-xywh`
- **何时 invoke**：建分支、提交、rebase、开 MR/PR、热修、合流、打标签、历史恢复
- **执行角色**：**Leader / 主 Agent**；子 Agent 默认不 `git commit` / `push`

## 本项目差异（delta）

| 项 | 值 |
| --- | --- |
| 组织模型 | 默认遵循 `git-xywh`；当前功能分支 `feature/architecture-to-chat` |
| 提交格式 | 无 commitlint；plan 中出现 `chore:` 英文提交，团队若要求 Angular + 中文以 skill 为准 |
| 提交前检查 | 无 husky / lint-staged（推断） |
| MR / PR 平台 | **GitHub**（`.github/workflows/travel-assistant.yml`） |
| Harness 脚手架提交 | 类型可用 `feat`/`chore`/`docs` 等；**标题与正文须中文**（如 `chore(harness-kit): 更新项目画像`），与业务 commit 分开 |
| CI | `workflow_dispatch` 与 tag `api-v*` 触发 Docker 构建推送至 DockerHub `qian777/travel-assistant` |

## 如何调用 git-xywh

| 环境 | 做法 |
| --- | --- |
| Cursor / 支持 Skill 工具 | **先** `invoke` / 加载 skill **`git-xywh`**，再读本文件 |
| 无 Skill 工具 | Read `~/.cursor/skills/git-xywh/SKILL.md`（或 `~/.agents/skills/` 下同路径） |
| 安装检查 | `bash harness-kit/scripts/install-ai-skills.sh` 会输出 `ok:` 或 `missing:` |

完整步骤见 `harness-kit/core/runbooks.md` § Git 协作。

## AI 执行约束

1. 提交 / 分支操作前：**已加载 `git-xywh` skill 正文** + 读本文件（仅 delta）。
2. 禁止（除非用户明确要求）：向 `main`/`develop` 直推；公共分支 force push；子 Agent 擅自 commit。
3. 用户说「帮我提交」：Leader 声明 `「Harness：git-xywh + project.git.md」` 后执行。

## 待确认项

- 默认主干与受保护分支名称（`main` 是否唯一生产线）。
- 是否允许 AI 创建 PR / push 到 `origin`。
- Docker 镜像 tag 规范与发布是否仅维护者操作。

## 推断项

- 远程托管为 GitHub；无 GitLab CI 配置。
- 仓库含未跟踪的 `harness-kit copy/` 目录（本地副本），**不应提交**。
- 重构期大量 commit 可能为 `chore` / `feat` 混合，合流前宜 squash 或按团队规范整理。
