---
artifact: runbook
route: harness-bootstrap
skills:
  - planner
source:
  - harness-kit/README.md
  - harness-kit/init/onboarding-handoff.txt
  - harness-kit/entrypoints/
  - harness-kit/adapters/
created_at: 2026-05-14
---

# Harness Bootstrap Prompt

你正在把 Agent Harness 脚手架接入当前项目。`harness-kit/` 是源头，根目录入口和工具目录都是投影。

## 清理 harness-kit 源仓库残留 + 更新 .gitignore

`harness-kit/` 是从源仓库拷贝过来的，**绝不能把它的 git 元数据也带进新项目**。在开始投影前必须先做：

1. **删除 harness-kit/ 内的 git 元数据**（仅限 `harness-kit/` 内，不要动项目自身的 `.git/`）：
   - `harness-kit/.git/`（源仓库的 .git 目录）
   - 存在则一并删除：`harness-kit/.gitignore`、`harness-kit/.gitattributes`、`harness-kit/.gitmodules`
2. **在项目根 `.gitignore` 追加**（保留已有内容；不存在则创建）：

   ```gitignore
   # Agent Harness
   harness-kit/*
   .ai-runtime-artifacts/
   ```

   - `harness-kit/*`：不把 harness-kit 目录提交到新项目（接入团队应通过 Git Submodule 或独立仓库管理 harness-kit 升级）
   - `.ai-runtime-artifacts/`：AI 运行时产物（spec / plan / execution-log / review 等），仅本地使用，不入仓

完成后用 `git check-ignore -v harness-kit .ai-runtime-artifacts` 自检（应分别命中 `harness-kit/*` 和 `.ai-runtime-artifacts/`）。

## 平台检测

运行平台检测脚本，确定当前环境：

```bash
bash harness-kit/scripts/harness-project.sh detect
```

输出为 `cursor`、`claude`、`trae` 或 `unknown`。后续投影按检测结果执行。

## 投影入口文件

从 `harness-kit/entrypoints/` 投影到项目根目录：

- `harness-kit/entrypoints/AGENTS.md` -> `AGENTS.md`
- `harness-kit/entrypoints/AGENTS.cursor-overlay.md` -> 保留在 harness-kit 内（Cursor 深读）
- `harness-kit/entrypoints/CLAUDE.md` -> `CLAUDE.md`

`harness-kit/entrypoints/HARNESS-PLATFORM-ENTRY.md` 为 Claude Code **共享正文**（不单独投影到根目录）。

如果目标文件已存在，先读取现有内容，只合并 Harness 入口，不删除项目已有约束。

## 投影工具适配（自动化）

运行投影脚本，自动检测平台并生成对应目录：

```bash
bash harness-kit/scripts/harness-project.sh project
```

或手动指定平台：

```bash
bash harness-kit/scripts/harness-project.sh project --platform cursor
```

### 投影结构

**Cursor 平台层：** `adapters/cursor/.cursor/` + `harness-kit/.agents/` -> `.cursor/`

```
.cursor/
├── rules/           ← ai-entry.mdc、cursor-subagent-routing.mdc
├── skills/          ← 从 harness-kit/.agents/skills/ 镜像
├── hooks/           ← session-init、subagent-track-reminder
└── hooks.json.example
```

**Claude 平台层：** `harness-kit/.claude/` + `harness-kit/.agents/` -> `.claude/`

```
.claude/
├── rules/                       ← ai-entry.md（强制声明、首行「Harness：…」、写文件纪律）
├── skills/                      ← 从 harness-kit/.agents/skills/ 镜像
├── hooks/                       ← opt-in：harness-session-init.sh、harness-subagent-stop.sh、block-native-plan-mode.sh
│   └── content/                 ← 配套 content/*.md
└── settings.json.example        ← hooks 配置示例（默认不启用，需手动 cp）
```

**Trae 平台层：** `adapters/trae/.trae/` + `harness-kit/.agents/` -> `.trae/`

```
.trae/
├── rules/                       ← ai-entry.md、trae-subagent-routing.md
├── skills/                      ← 从 harness-kit/.agents/skills/ 镜像
├── hooks/                       ← session-init、subagent-stop（opt-in）
└── settings.json.example        ← hooks 配置示例（默认不启用，需手动 cp）
```

### 投影后验证

**Claude 平台层预期文件清单（必须全部出现，缺一即视为投影失败）：**

```bash
# 1) rules（always-loaded；Claude Code 会话开始自动加载）
test -f .claude/rules/ai-entry.md && echo "OK: rules/ai-entry.md"

# 2) skills（Claude Code 自动发现 .claude/skills/）
ls -d .claude/skills/*/ | wc -l

# 3) hooks（opt-in，脚本默认投影；启用需手动 cp settings.json.example → settings.json）
test -x .claude/hooks/harness-session-init.sh    && echo "OK: hooks/harness-session-init.sh"
test -x .claude/hooks/harness-subagent-stop.sh   && echo "OK: hooks/harness-subagent-stop.sh"
test -f .claude/settings.json.example            && echo "OK: settings.json.example"
```

**Trae 平台层预期文件清单：**

```bash
# 1) rules（Trae 统一入口）
test -f .trae/rules/ai-entry.md                  && echo "OK: rules/ai-entry.md"
test -f .trae/rules/trae-subagent-routing.md    && echo "OK: rules/trae-subagent-routing.md"

# 2) skills（Trae skill 目录）
ls -d .trae/skills/*/ | wc -l

# 3) hooks（opt-in，脚本默认投影；启用需手动 cp settings.json.example → settings.json）
test -x .trae/hooks/harness-session-init.sh      && echo "OK: hooks/harness-session-init.sh"
test -x .trae/hooks/harness-subagent-stop.sh    && echo "OK: hooks/harness-subagent-stop.sh"
test -f .trae/settings.json.example              && echo "OK: settings.json.example"
```

**Cursor 平台层预期文件清单：**

```bash
# 1) rules
test -f .cursor/rules/ai-entry.mdc               && echo "OK: rules/ai-entry.mdc"
test -f .cursor/rules/cursor-subagent-routing.mdc && echo "OK: rules/cursor-subagent-routing.mdc"

# 2) skills
ls -d .cursor/skills/*/ | wc -l

# 3) hooks
test -f .cursor/hooks.json.example               && echo "OK: hooks.json.example"
```

随后跑：

```bash
bash harness-kit/scripts/harness-check.sh
```

## AI runtime（可选）

如需安装或检查 AI runtime（superpowers、组织 skill `git-xywh` 等），先说明会修改哪些本机环境，再由你执行：

```bash
bash harness-kit/scripts/install-ai-skills.sh
```

见 `harness-kit/.agents/README.md`。

## 初始化项目画像

创建 AI 运行时产物目录：

- `.ai-runtime-artifacts/specs/`
- `.ai-runtime-artifacts/plans/`
- `.ai-runtime-artifacts/reviews/`
- `.ai-runtime-artifacts/verifications/`
- `.ai-runtime-artifacts/decisions/`
- `.ai-runtime-artifacts/retros/`
- `.ai-runtime-artifacts/research/`
- `.ai-runtime-artifacts/research/screenshots/`（网探截图，可选）
- `.ai-runtime-artifacts/execution-logs/`
- `.ai-runtime-artifacts/execution-logs/tracking/`（Cursor 并行追踪，可选目录）

产物模板位于 `harness-kit/artifact-templates/`：**编排类**（`execution-log.md`、`dispatch-track.md`、`handoff.md`、`progress.md`、`wu-checklist.md`、`research-report.md`）；**尾盘**（`collective-test.md`、`code-review.md`）；**文档审查**（`document-review.md`）；**stage skill 契约**（`spec.harness-overlay.md`、`plan.harness-overlay.md`、`dispatch.harness-overlay.md`、`verification.md`）；`spec.md`/`plan.md` 仅为 redirect stub。GROUP 收尾须落盘 collective-test + code-review（见 `docs/superpowers/specs/2026-05-28-batch-closeout-review-and-collective-test.md`）。

完成入口和工具适配投影后，读取 `harness-kit/init/project-profiler.prompt.md`。

以 `harness-kit/init/templates/` 下对应文件为**章节骨架**，扫描当前仓库后生成或更新：

- `harness-kit/project.profile.md`
- `harness-kit/context-map.md`
- `harness-kit/project.verification.md`
- `harness-kit/project.git.md`

## 填充平台入口背景

用 `project.profile.md` 的「项目身份」与「技术栈」写成 2–4 句摘要，替换下列文件中的 `{{PROJECT_BACKGROUND}}`（勿删除 Harness 规则段落）：

- 根目录 `CLAUDE.md`（若已投影）
- `harness-kit/entrypoints/HARNESS-PLATFORM-ENTRY.md`（共享正文，供 Claude Code 深读）

## 验证

最后运行：

```bash
bash harness-kit/scripts/harness-check.sh
```

回复中说明：

- 检测到的平台（`harness-project.sh detect` 输出）。
- 投影了哪些入口和适配目录。
- **平台层**实际生成了哪些文件（按 § 投影后验证 根据检测到的平台逐项列：rules/skills/hooks 各自的数量与关键文件名；任一缺失即报告并补投影）。
- 是否创建了 `.ai-runtime-artifacts/`。
- 是否执行了 AI runtime 安装或检查。
- 生成或更新了哪些项目画像文件。
- Harness 检查是否通过。
- **推断项**与**待确认项**（摘自 `project.profile.md`、`project.git.md` 等，供负责人 review）。
