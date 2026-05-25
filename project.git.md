---
generated_at: 2026-05-25
generator: harness-init
org_skill: git-xywh
---

# Project Git — lightapp-meeting-summary

本文件只记录**相对组织 Git 规范（`git-xywh` skill）的差异**与**本项目约束**。分支模型、MR 流程、Angular 提交格式全文见 skill，不在此重复。

## 组织基线（默认）

- **Skill**：`git-xywh`（slug；人类可读名 `Git`）
- **何时 invoke**：建分支、提交、rebase、开 MR/PR、热修、合流、打标签、历史恢复（见 `harness-kit/core/routing.md` Git 路由行）
- **执行角色**：**Leader / 主 Agent**；`harness-implementer` 等子 Agent **默认不** `git commit` / `push`，除非 Leader 在委派 prompt 中明确要求

## 本项目差异（delta）

| 项 | 值 |
| --- | --- |
| 组织模型 | 默认遵循 `git-xywh`（`main` / `test` / `develop` + `feature`/`task`/`temp`/`bugfix`/`test/v*`） |
| 提交格式 | **Conventional Commits**（`commitlint` + husky `lint-staged`） |
| 提交前检查 | husky pre-commit → lint-staged（ESLint / Prettier / Stylelint） |
| MR / PR 平台 | 【待确认】未发现 `.gitlab-ci.yml` / `.github/workflows`；README 提及 Jenkins |
| CI | 【推断】Jenkins 构建（见项目 README） |
| Harness 脚手架提交 | 独立 commit，建议 `chore(harness-kit): <说明>`，与业务变更分开 |

## AI 执行约束

1. **提交前**：读取本文件 + invoke `git-xywh`；运行 `harness-kit/project.verification.md` 中的 pre-commit 相关检查（若适用）。
2. **分支**：从 `develop` 拉 `task/*` 或 `feature/*`（常规需求）；生产热修走 `bugfix/*`（自 `main`）；与 skill 冲突时以 skill 为准，本文件仅记录已确认的仓库例外。
3. **禁止**（除非用户在本会话明确要求）：
   - 向 `main` / `develop` 直推
   - `git push --force` 到公共受保护分支
   - 子 Agent 擅自 commit / push
4. **用户说「帮我提交」**：Leader 执行；须在回复中声明分支名、提交说明、是否已跑 pre-commit。

## 待确认项

- 【待确认】远程默认保护分支与 MR 目标分支是否与组织 `git-xywh` 完全一致
- 【待确认】MR 在 GitLab 还是 GitHub（或仅 Jenkins + 内部流程）
- 【待确认】是否允许 AI 代开 MR（`gh` / `glab` 是否已配置）

## 推断项

- 【推断】业务代码提交须通过 commitlint；类型与范围应与模块划分一致（见 `git-xywh` Angular 约定）
