---
artifact: runbook
route: harness-init
skills:
  - explore
  - planner
source:
  - cow-harness/core/harness.md
  - cow-harness/init/templates/project.profile.md
  - cow-harness/init/templates/context-map.md
  - cow-harness/init/templates/project.verification.md
created_at: 2026-05-14
---

# Project Profiler Prompt

你正在为一个新项目初始化 Agent Harness。目标是读取当前仓库，生成项目画像、上下文地图和验证画像。

## 输入

请读取：

1. `README.md`
2. `package.json`
3. lockfile / workspace 配置
4. 顶层目录结构
5. `src/`、`main/`、`preload/`、`apps/`、`packages/`、`docs/` 等存在的关键目录
6. 已有构建、测试、lint、CI 配置
7. 现有项目文档

## 输出文件

请创建或更新：

1. `cow-harness/project.profile.md`
2. `cow-harness/context-map.md`
3. `cow-harness/project.verification.md`

## 要求

- 不修改业务代码。
- 不读取 secret、token、provider key 或本机私有配置。
- 对无法确认的信息，写入“待确认项”。
- 对基于文件结构推断的信息，写入“推断项”。
- 保持内容简洁，面向 AI 和工程师共同阅读。
- 最后运行 `bash cow-harness/scripts/harness-check.sh`。

## 输出摘要

完成后在回复中说明：

- 读取了哪些关键文件。
- 生成或更新了哪些 Harness 文件。
- 哪些信息是推断项。
- 哪些信息需要人工确认。
- `harness-check` 是否通过。
