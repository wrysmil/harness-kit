# AGENTS.md（Harness 仓库根覆盖层）

> 本文件是 **harness-kit 仓库根** 的 `AGENTS.md`。  
> 详细入口与跨平台规则见 `harness-kit/entrypoints/HARNESS-PLATFORM-ENTRY.md`。  
> 本文件与 `harness-kit/entrypoints/AGENTS.md` 同源；OMX 专章在本仓库忽略。

## 仓库性质

本仓库是 **harness-kit 自身**（脚手架 + 模板 + 适配器 + 脚本），**不是**部署目标。业务项目通过 `harness-kit/scripts/install-ai-skills.sh` 接入。

## AI 入口（按序读取）

1. 本文件（仓库根覆盖层）
2. `harness-kit/entrypoints/HARNESS-PLATFORM-ENTRY.md`（跨平台共享入口）
3. `harness-kit/core/routing.md`（路由判定 / 阶段门禁 / 按判定加载）
4. `harness-kit/entrypoints/CLAUDE.md` 或 `.cursor/rules/ai-entry.mdc`（按平台）

## 强制声明

每个任务首句 `「Harness：<route 或 "Tier 0 小改动" | "Tier 1 Leader 直做">」`；stage skill / Tier 1+ 次行 `Skills: <slug>@<path> loaded|skipped`。细则见 `routing.md` § 阶段指定 skill 必用。

## 沟通语言

对用户回复、子 Agent 派发、产物摘要、验收口径全部使用**中文**（代码标识符、路径、命令、API 名、固定段键名保留英文）。细则见 `routing.md` § 沟通语言。
