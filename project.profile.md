# Project Profile

本文件是当前项目画像，由 Harness 初始化（project-profiler）生成。迁移到其他项目时须重新生成并由人 review 推断项与待确认项。

## 项目身份

**travel-assistant（旅行规划助手）** — 基于 AI 的智能旅行规划与推荐系统。当前处于 **架构迁移期**（分支 `feature/architecture-to-chat`）：从旧版多 Agent + 独立 MCP Server 流水线，重构为 **nanobot 聊天网关 + 地图/聊天双面板前端 + FastAPI 管理后台** 的携程式体验。根目录 `README.md` 仍描述旧架构，实施以 `.ai-runtime-artifacts/specs/` 与 `plans/` 为准。

## 技术栈

| 层 | 技术 |
| --- | --- |
| 用户端 | React 19、TypeScript、Vite 8、Tailwind CSS 4、高德 JS API、Zustand |
| 管理端 | React 19、Vite、React Router（`admin/`） |
| 管理 API | Python 3.11+、FastAPI、uvicorn、aiosqlite、PyJWT |
| 聊天 / Agent | **nanobot**（仓库内 `nanobot/` 源码，`pip install -e`） |
| 工具 / 地理 | MCP（`mcp` 包）、高德 / Unsplash（经 MCP 或配置） |
| 部署 | 根目录 `Dockerfile` + `docker-compose.yml`（nginx 反代、前后端一体镜像） |
| Harness | `harness-kit/`、`.ai-runtime-artifacts/`、Cursor `harness-*` subagent |

## 主要目录

| 路径 | 职责 |
| --- | --- |
| `backend/` | FastAPI 管理 API：认证、技能/知识库/定时任务/配置；`nanobot_mgr` 生命周期 |
| `backend/app/api/` | HTTP 路由（`auth`、`admin/*`） |
| `backend/app/core/` | 配置、依赖、nanobot 管理、路径 |
| `backend/mcp_servers/` | 遗留/可选 MCP Server（amap、unsplash，stdio） |
| `frontend/` | 用户端：地图 + 聊天（WebSocket → nanobot） |
| `admin/` | 运营/管理后台 SPA |
| `nanobot/` | 嵌入的 nanobot 源码与测试 |
| `harness-kit/` | Agent Harness 规范、适配器、脚本（勿当业务模块改） |
| `.ai-runtime-artifacts/` | spec / plan / verification / execution-log 等过程产物 |
| `docker/`、`nginx.conf` | 容器与反代配置 |
| `.github/workflows/` | Docker 镜像构建推送（`travel-assistant.yml`） |

## 禁区

- **勿读、勿提交**：`.env`、密钥、token、本机私有 MCP 配置。
- **勿在未过阶段门禁时**大规模改业务代码（Harness `routing.md`）；小改动除外。
- **勿删改** `harness-kit/` 内 `core/` 通用规则（项目差异写在 `project.*`）。
- **子 Agent 默认不** `git commit` / `push`（Leader + `git-xywh` 执行）。

## 交付口径

- 非琐碎需求：先 spec → 人确认 → plan → 人确认 → 实现（Cursor：`cursor-orchestration`；代码 WU → `harness-coder`，docs/chore/config → `harness-implementer`）→ 按规则委派或跳过 `harness-reviewer` → verification 证据。
- 重构验收：前后端可构建、Docker 可启动、聊天链路可连 nanobot、管理 API 可鉴权；详见 `project.verification.md` 与 `.ai-runtime-artifacts/plans/`。
- 文档与根 `README.md` 不一致时，以 **已批准 spec/plan** 与当前代码为准，并记待确认项。

## 推断项

- 默认远程为 GitHub（存在 `.github/workflows/`）；MR/PR 平台推断为 **GitHub**。
- 无根级 `package.json`；前后端各自 `package.json`，Python 依赖在 `backend/requirements.txt`。
- 无 `backend/` 内 pytest 套件；**nanobot/** 含大量测试，业务后端测试策略待团队确认。
- 无 husky / commitlint；提交格式推断仅依赖团队习惯 + `git-xywh` skill。
- CI 主要为 **Docker 镜像构建推送**，非 PR 门禁 lint/test。
- `nanobot/` 为 vendored 源码，升级需与上游 nanobot 仓库协调。

## 待确认项

- 旧 `README.md` 与多 Agent 描述何时同步为新架构说明。
- 生产默认分支名（`main` / `develop`）及是否启用 `git-xywh` 三主干模型。
- 是否允许 AI 自动 `git push` / 开 PR（默认禁止，需负责人明确）。
- `backend/mcp_servers/` 在新架构下是否保留或废弃。
- 业务后端单元测试 / E2E 的最低验收命令（当前 plan 含 Docker E2E，无统一 `pytest backend`）。
