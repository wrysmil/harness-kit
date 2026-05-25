---
generated_at: YYYY-MM-DD
generator: harness-init
org_skill: git-xywh
---

# Project Git — <project-name>

本文件只记录**相对组织 Git 规范（`git-xywh` skill）的差异**与**本项目约束**。分支模型、MR 流程、Angular 提交格式全文见 skill，不在此重复。

## 组织基线（默认）

- **Skill**：`git-xywh`
- **何时 invoke**：建分支、提交、rebase、开 MR/PR、热修、合流、打标签、历史恢复
- **执行角色**：**Leader / 主 Agent**；子 Agent 默认不 `git commit` / `push`

## 本项目差异（delta）

| 项 | 值 |
| --- | --- |
| 组织模型 | 默认遵循 `git-xywh`；若本项目偏离，在下表写明 |
| 提交格式 | <!-- 如：commitlint / 仅 Angular / 自定义 --> |
| 提交前检查 | <!-- 如：husky、lint-staged、CI pre-commit --> |
| MR / PR 平台 | <!-- GitLab / GitHub / 其他 --> |
| Harness 脚手架提交 | `chore(harness-kit): <说明>`，与业务分开 |

## AI 执行约束

1. 提交 / 分支操作前：读本文件 + invoke `git-xywh`。
2. 禁止（除非用户明确要求）：向 `main`/`develop` 直推；公共分支 force push；子 Agent 擅自 commit。
3. 用户说「帮我提交」：由 Leader 执行，并声明分支与提交说明。

## 待确认项

- <!-- 远程保护分支、MR 平台、是否允许 AI 开 MR -->

## 推断项

- <!-- 基于 package.json、.husky、CI 配置的推断 -->
