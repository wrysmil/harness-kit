# Project Verification

本文件描述当前项目的验证命令。

## Harness 验证

```bash
bash harness-kit/scripts/harness-check.sh
```

> 脚本位于 `harness-kit/scripts/` 时以 **source** 布局检查 kit 自身；投影与 `project.*` 更新后应在项目根执行并人工确认根目录 `AGENTS.md`、`.cursor/`、`.ai-runtime-artifacts/` 子目录齐全。

## 应用验证

| 命令 | 用途 |
| --- | --- |
| `cd frontend && npm install && npm run build` | 用户端 TypeScript 编译与生产构建 |
| `cd frontend && npm run lint` | 用户端 ESLint |
| `cd admin && npm install && npm run build` | 管理端构建 |
| `cd admin && npm run lint` | 管理端 ESLint |
| `pip install -r backend/requirements.txt`（建议在 venv） | 后端依赖 |
| `cd backend && python -c "from main import app; print('ok')"` | FastAPI 应用可导入（需 `.env` 非必须项时） |
| `docker compose build` | 根目录一体镜像构建 |
| `docker compose up` | 全栈启动（需根目录 `.env`，见 `.env.example`） |

## 静态检查

| 命令 | 用途 |
| --- | --- |
| `cd nanobot && pytest`（若已安装 nanobot 开发依赖） | nanobot 子项目回归（大量用例） |
| `bash harness-kit/scripts/harness-check.sh` | Harness 文件与产物 front matter |

## 最小验证策略（Leader）

1. 改 `frontend/` / `admin/`：对应 `npm run build`（+ lint 若 touched TS）。
2. 改 `backend/`：导入检查或相关 API 手测；涉及 nanobot 时确认 gateway 进程状态。
3. 改 Docker/nginx： `docker compose build`。
4. 声称完成前：运行与本 diff 相关的上表命令并贴输出摘要（`verification-before-completion`）。

## 待确认项

- 是否将 `pytest nanobot/tests` 纳入 PR 必跑（当前 CI 仅 Docker 推送）。
- 业务 `backend/` 专用测试命令（暂无统一 pytest 目录）。
