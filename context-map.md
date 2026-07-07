# Context Map

本文件由 Harness 初始化流程生成，用于帮助 AI 快速理解项目结构。

## 顶层结构

| 路径 | 类型 | 说明 |
| --- | --- | --- |
| `backend/` | Python | FastAPI 管理 API、SQLite、nanobot 进程管理 |
| `frontend/` | Node/React | 用户端 SPA（地图 + 聊天） |
| `admin/` | Node/React | 管理后台 SPA |
| `nanobot/` | Python | 聊天网关与 Agent 运行时（可编辑依赖） |
| `harness-kit/` | 文档/配置 | Harness 规范与 Cursor 适配源 |
| `docker-compose.yml` | 部署 | 本地/生产一体容器编排 |
| `Dockerfile` | 部署 | 多阶段：Python + 前后端 build + nginx |
| `.ai-runtime-artifacts/` | 产物 | AI 过程文档（spec/plan/log） |
| `.cursor/`、`.agents/` | 工具 | Cursor rules、subagent、skills 投影 |
| `nanobot/`（勿与 backend/skills 混淆） | 子项目 | 独立 Python 包与测试树 |

## 主要入口

| 入口 | 说明 |
| --- | --- |
| `backend/main.py` | FastAPI 应用入口、`lifespan` 内 `nanobot_mgr.start()` |
| `backend/requirements.txt` | 后端 pip 依赖（含 `-e ../nanobot`） |
| `frontend/package.json` | 用户端 `npm run dev` / `build` / `lint` |
| `admin/package.json` | 管理端 `npm run dev` / `build` / `lint` |
| `nanobot/` | nanobot CLI / gateway（见 nanobot 文档与 `backend/nanobot_config.json`） |
| `docker-compose.yml` | `docker compose up` 全栈 |
| `AGENTS.md` | 工具中立 Harness 顶层入口 |
| `harness-kit/core/routing.md` | 路由表与阶段门禁 |

## 关键模块

| 模块 | 路径 | 说明 |
| --- | --- | --- |
| 认证 | `backend/app/api/auth.py`、`backend/app/core/auth.py` | JWT 登录 |
| 管理 API | `backend/app/api/admin/` | skills、knowledge、cron、config |
| nanobot 集成 | `backend/app/core/nanobot_mgr.py` | 启动/停止网关 |
| 数据 | `backend/app/database.py`、`backend/data/` | SQLite 与运行时数据 |
| 用户 UI | `frontend/src/` | 页面、组件、API/WS 封装 |
| 聊天面板 | `frontend/src/components/chat/ChatPanel.tsx`、`frontend/src/hooks/useChat.ts` | WebSocket → nanobot |
| 地图 | `frontend/src/components/map/MapPanel.tsx`、`frontend/src/hooks/useAMap.ts` | 高德 JS API |
| 管理 UI | `admin/src/` | 路由与后台页面 |
| MCP（遗留） | `backend/mcp_servers/` | amap / unsplash stdio server |
| Harness 编排 | `harness-kit/core/orchestration/` | dispatcher、WU、skill 偏好 |
| 重构计划 | `.ai-runtime-artifacts/plans/2026-05-25-travel-assistant-refactor-plan.md` | 分 Phase 实施清单 |
| 竞品调研 | `.ai-runtime-artifacts/specs/2026-05-26-ctrip-ai-tripplanner-competitive-spec.md` | 携程 AI 行程对标 |
| Demo 打磨 | `.ai-runtime-artifacts/plans/2026-05-26-demo-polish-amap-integration-plan.md` | LLM Key / 高德 / 聊天冒烟 |
| 系统设置 | `backend/app/core/system_settings.py` | LLM Key 合并与 gateway 重启 |
| 网探角色 | `.agents/agents/web-investigator.md` | 竞品截图与页面取证 |

## 读码优先级

1. 任务相关：`harness-kit/project.profile.md` → 本文件 → `harness-kit/core/routing.md`
2. 实现前端：`frontend/src/` + plan 中对应 Phase
3. 实现后端：`backend/app/` + `backend/main.py`
4. 聊天链路：`nanobot/` + `backend/app/core/nanobot_mgr.py`
5. 避免先读：根 `README.md` 旧架构大段（除非同步文档任务）

## 待确认项

- nanobot WebSocket 对外 URL 与 nginx 路由是否与 `nginx.conf` 一致（本地 vs Docker）。
- `admin` 与 `frontend` 是否共用同一 Docker 镜像端口策略。
